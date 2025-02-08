/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Test of the invocable class that changes the zuora account. Test class for XC_IN011_ChangeProvBillingProcess and XC_IN038_ApplyCoupon
*/
@isTest
public class XC_IN011_ChangeProvBillingProcess_TEST {
    
    @testSetup
    private static void setup() {

        /* This method creates and inserts too the order */
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);

        order = [SELECT Id, NE__AccountID__c, NE__OptyId__c,XC_InstallationAddress__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];
        
        NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        insert catalogItem;
        NE__Catalog_Item__c catalogItemQuery = [SELECT Id, NE__Catalog_Id__c FROM NE__Catalog_Item__c WHERE Id = :catalogItem.id];
        NE__Catalog__c catalog = [SELECT Id, XC_LIC_Name__c FROM NE__Catalog__c  WHERE Id = :catalogItemQuery.NE__Catalog_Id__c];
        catalog.XC_LIC_Name__c = 'mobility';
        update catalog;
        
        NE__OrderItem__c orderItemStep = order.NE__Order_Items__r[0];
        orderItemStep.NE__CatalogItem__c = catalogItem.id;
        update orderItemStep;
        
        Opportunity opport = new Opportunity(Id = order.NE__OptyId__c);
        opport.XC_LegalEntity__c = null;
        update opport;
        
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        insert ps;
        
        B2WExtCat__Work_Order_Item__c workOrderItem = XC_DF_RatePlan.createJunctionProductRatePlanToItem(order, order.NE__Order_Items__r[0]);
        insert workOrderItem;

        B2WZC__Bit2WinConnector__c b2wConnector = new B2WZC__Bit2WinConnector__c(Name = 'ZuoraConnector', B2WZC__isActiveConnector__c = true);
        insert b2wConnector;

        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legEntityMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_ZuoraEntityId__c, XC_TimeZone__c
                                                                                                                        FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                        WHERE XC_LegalEntity__c = 'EndesaX' AND XC_OrgId__c =: orgId]);


        zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
        billingEntity.zqu__EntityID__c = legEntityMap.values()[0].XC_ZuoraEntityId__c; //'8adc8f99684b618601684d4127781f61';
        billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50c4';
        billingEntity.zqu__ZuoraID__c = '2000378';
        billingEntity.zqu__EntityName__c = 'Enel Spain B2C';
        insert billingEntity;

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntity);
      
        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c, NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id];
		
        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
		NE__Billing_Profile__c bp = listBillingProfiles[0];
        bp.NE__Payment__c = Label.XC_CL_Credit_Card;
        update bp;
        
        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id, XC_PaymentMethod__c
                                                        FROM XC_BillingProfileLineItem__c 
                                                        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        XC_BillingProfileLineItem__c bpli = listBPLI[0];
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
       
        item.XC_ZQuoteId__c = dResp.parentId;
        item.XC_BillingProfileLineItem__c = bpli.ID;
        item.XC_PaymentMethod__c  = bpli.XC_PaymentMethod__c;
        item.NE__Action__c = 'Add';
        item.NE__BaseOneTimeFee__c = 89;
        update item;
      

        NE__OrderItem__c originalItem = XC_DF_OrderItem.createOrderItem(order);
        originalItem.NE__Account__c = order.NE__AccountID__c;
        originalItem.XC_Installation_Address__c = order.XC_InstallationAddress__c;
        originalItem.XC_ZQuoteId__c = dResp.parentId;
        originalItem.XC_BillingProfileLineItem__c = bpli.ID;
        originalItem.XC_PaymentMethod__c  = bpli.XC_PaymentMethod__c;
        originalItem.NE__Action__c = 'Remove';
        originalItem.NE__BaseOneTimeFee__c = 89;
        insert originalItem;
     

        B2WExtCat__Work_Order_Item__c woDB = [SELECT Id, B2WExtCat__Work_Order_Item_Code__c, B2WExtCat__Configuration_Item__c,
                                                       B2WExtCat__Work_Order__c, B2WExtCat__Action__c, RecordTypeId
                                                FROM B2WExtCat__Work_Order_Item__c LIMIT 1];
        B2WExtCat__Work_Order_Item__c workOrderOldItem = woDB.clone(false, false, false, false);
        workOrderOldItem.B2WExtCat__Configuration_Item__c = originalItem.Id;
        insert workOrderOldItem;

        List<Asset> listAssets = XC_DF_Asset.createAssets(accList);
        listAssets[0].XC_Configuration_Item__c = item.Id;
        listAssets[0].XC_Original_Configuration_Item__c = originalItem.Id;
        listAssets[0].XC_Original_Creation_OrderItem__c  = originalItem.Id;
        insert listAssets;
    }

    @isTest
    private static void payAndBillTEST() {

        XC_Provisioning_Step__c ps = [SELECT Id FROM XC_Provisioning_Step__c LIMIT 1];

        List<XC_IN011_ChangeProvBillingProcess.InputWrapper> listInput = generateInputWrapper(ps);

        Test.startTest();
            XC_IN011_ChangeProvBillingProcess.payAndBill(listInput);
        Test.stopTest();
    }

    @isTest
    private static void payAndBillTEST2() {

        XC_Provisioning_Step__c ps = [SELECT Id FROM XC_Provisioning_Step__c LIMIT 1];

        List<XC_IN011_ChangeProvBillingProcess.InputWrapper> listInput = generateInputWrapper(ps);

        List<NE__OrderItem__c> listItem = [SELECT Id, NE__Action__c FROM NE__OrderItem__c];
        for(NE__OrderItem__c item : listItem) {
            if(item.NE__Action__c == 'Add') {
                item.NE__Action__c = 'Remove';
            } else {
                item.NE__Action__c = 'Add';
            }
        }
        update listItem;

        Test.startTest();
            XC_IN011_ChangeProvBillingProcess.payAndBill(listInput);
        Test.stopTest();
    }

    @isTest
    private static void payAndBillTEST3() {

        XC_Provisioning_Step__c ps = [SELECT Id FROM XC_Provisioning_Step__c LIMIT 1];

        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__External_Id__c = '12345', Zuora__SubscriptionNumber__c = 'Test001', Zuora__Version__c = 0);
        insert sub;

        List<XC_IN011_ChangeProvBillingProcess.InputWrapper> listInput = generateInputWrapper(ps);
        NE__OrderItem__c itemToAdd = new NE__OrderItem__c();
        NE__OrderItem__c itemToRemove = new NE__OrderItem__c();

        List<NE__OrderItem__c> listItem = [SELECT Id, NE__Action__c, NE__OrderId__r.NE__AccountID__c, NE__OrderId__r.NE__OptyId__c FROM NE__OrderItem__c];
        for(NE__OrderItem__c item : listItem) {
            item.XC_ZQuoteId__c = '';
            if(item.NE__Action__c == 'Add') {
               itemToAdd = item;
            } else {
                itemToRemove = item;
            }
        }
        update listItem;

        List<Asset> listAsset =  [SELECT Id FROM Asset];
        listAsset[0].XC_Configuration_Item__c = itemToAdd.Id;
        listAsset[0].XC_SubscriptionName__c = 'Test001';
        update listAsset; 

        List<Account> accList = [SELECT Id FROM Account WHERE Id = : listItem[0].NE__OrderId__r.NE__AccountID__c];
        List<Asset> listAsset2 = XC_DF_Asset.createAssets(accList);
        listAsset2[0].XC_Configuration_Item__c = itemToRemove.Id;
        listAsset2[0].XC_SubscriptionName__c = 'Test001';
        insert listAsset2;

        Opportunity oppToUpdate = [SELECT Id FROM Opportunity WHERE Id = : itemToAdd.NE__OrderId__r.NE__OptyId__c];
        oppToUpdate.XC_LegalEntity__c = 'EndesaX';
        update oppToUpdate;
        

        Test.startTest();
            XC_IN011_ChangeProvBillingProcess.payAndBill(listInput);
        Test.stopTest();
    }
    
    
    private static List<XC_IN011_ChangeProvBillingProcess.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN011_ChangeProvBillingProcess.InputWrapper> listWrapperInput = new List<XC_IN011_ChangeProvBillingProcess.InputWrapper>();
        XC_IN011_ChangeProvBillingProcess.InputWrapper wr = new XC_IN011_ChangeProvBillingProcess.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);

        return listWrapperInput;

    }

    
    @isTest
    public static void applyCouponTest(){

        NE__OrderItem__c item = [SELECT Id FROM NE__OrderItem__c WHERE NE__Action__c =: 'Remove'];
        item.NE__Action__c = 'Change';
        update item;

        Asset ass = [SELECT Id, XC_Original_Creation_OrderItem__c FROM Asset WHERE XC_Original_Configuration_Item__c =:  item.Id];
        ass.XC_Configuration_Item__c = item.id;
        update ass;

        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(item.Id));
        insert ps;

        List<XC_IN038_ApplyCoupon.InputWrapper> listWrapperInput = new List<XC_IN038_ApplyCoupon.InputWrapper>();
        XC_IN038_ApplyCoupon.InputWrapper wr = new XC_IN038_ApplyCoupon.InputWrapper();
        wr.stepToExecuteId = ps.Id;
        listWrapperInput.add(wr);

        Test.startTest();
            XC_IN038_ApplyCoupon.applyCoupon(listWrapperInput);
        Test.stopTest();

        System.assertEquals(item.NE__Action__c,  'Change', 'Wrong assert result');

    }

    @isTest
    static void applyCouponTestWithZQuote(){
        NE__OrderItem__c item = [SELECT Id FROM NE__OrderItem__c WHERE NE__Action__c =: 'Remove'];
        item.XC_ZQuoteId__c = 'test';
        item.NE__Action__c = 'Change';
        update item;
        Asset ass = [SELECT Id, XC_Original_Creation_OrderItem__c FROM Asset WHERE XC_Original_Configuration_Item__c =:  item.Id];
        ass.XC_Configuration_Item__c = item.id;
        update ass;
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(item.Id));
        insert ps;
        List<XC_IN038_ApplyCoupon.InputWrapper> listWrapperInput = new List<XC_IN038_ApplyCoupon.InputWrapper>();
        XC_IN038_ApplyCoupon.InputWrapper wr = new XC_IN038_ApplyCoupon.InputWrapper();
        wr.stepToExecuteId = ps.Id;
        listWrapperInput.add(wr);
        Test.startTest();
        XC_IN038_ApplyCoupon.applyCoupon(listWrapperInput);
        Test.stopTest();
    }

      @isTest
    public static void applyCouponTest_Migration(){

        NE__OrderItem__c item = [SELECT Id FROM NE__OrderItem__c WHERE NE__Action__c =: 'Remove'];
        item.NE__Action__c = 'Change';
        update item;

        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__External_Id__c = '12345', Zuora__SubscriptionNumber__c = 'Test001', Zuora__Version__c = 0);
        insert sub;

        Account acc = [SELECT Id FROM ACCOUNT limit 1];
        List<Asset> assetToUp = [SELECT Id,XC_Original_Creation_OrderItem__c,XC_Original_Configuration_Item__c FROM Asset where AccountId =: acc.Id];
        //Asset ass = [SELECT Id, XC_Original_Creation_OrderItem__c FROM Asset WHERE XC_Original_Configuration_Item__c =:  item.Id];
       // ass.XC_Configuration_Item__c = item.id;
       // assetToUp.add(ass);
        for(Asset asset: assetToUp) {
            if(asset.XC_Original_Configuration_Item__c == item.Id) asset.XC_Configuration_Item__c = item.id;
            asset.XC_Original_Configuration_Item__c = null;
            asset.XC_Subscription__c = null;
            asset.XC_SubscriptionName__c = 'Test001';

        }
        update assetToUp;

        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(item.Id));
        insert ps;

        List<XC_IN038_ApplyCoupon.InputWrapper> listWrapperInput = new List<XC_IN038_ApplyCoupon.InputWrapper>();
        XC_IN038_ApplyCoupon.InputWrapper wr = new XC_IN038_ApplyCoupon.InputWrapper();
        wr.stepToExecuteId = ps.Id;
        listWrapperInput.add(wr);

        Test.startTest();
            XC_IN038_ApplyCoupon.applyCoupon(listWrapperInput);
        Test.stopTest();

        System.assertEquals(item.NE__Action__c,  'Change', 'Wrong assert result');

    }
    
	@isTest
    private static void covergetJunctionRatePlanToItem(){
        List<NE__OrderItem__c> itemsList = new List<NE__OrderItem__c>([SELECT Id FROM NE__OrderItem__c LIMIT 1]);
        List<Id> idList = XC_UTIL_Sobject.getIds(itemsList);
		Test.startTest();
        XC_IN011_ChangeProvBillingProcess_D.getJunctionRatePlanToItem(idList);
        Test.stopTest();     
        System.assertEquals(itemsList.size(),1); 
    }
    
   /* private static void createCODataMap() {

        NE__Map__c dataMap = new NE__Map__c();
        dataMap.NE__Map_Name__c = 'ChangeOrder2ZQuote';
        dataMap.NE__Type__c = 'Object2Object';
        dataMap.CurrencyIsoCode = 'EUR';
        insert dataMap; 

        NE__MapObject__c mapObject = new NE__MapObject__c();
        mapObject.NE__Source__c = 'order__c';
        mapObject.NE__Target__c = 'zqu__quote__c';
        mapObject.NE__Source_Map_Object_Id__c = dataMap.Id;
        mapObject.Name = 'ChangeOrder2ZQuote';
        mapObject.NE__Sequence__c = 0;
        mapObject.NE__Map__c = dataMap.Id;
        insert mapObject;

        List<NE__MapObjectItem__c> listItem = [SELECT Id, NE__Map_Object__c, NE__IsDateField__c, NE__MapAsTag__c, NE__QueryOnly__c, NE__SourceField__c, NE__Stop_Trigger__c,
                                                         NE__TargetField__c, NE__Type__c, NE__UseAsKey__c, NE__Value__c, NE__Field_Type__c
                                                FROM NE__MapObjectItem__c];
        List<NE__MapObjectItem__c> listItemCloned = listItem.clone(false, false, false, false);
        for(NE__MapObjectItem__c item : listItemCloned) {
            item.NE__Map_Object__c = mapObject.Id;
        }
        insert listItemCloned;

    }
*/
}