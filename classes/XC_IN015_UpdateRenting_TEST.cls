/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Test of the invocable class that calls the Order Callback interface
*/
@isTest
public with sharing class XC_IN015_UpdateRenting_TEST {
    
     @testSetup
    private static void setup() {

        /* This method creates and inserts too the order */
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);
        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        insert ps;

        B2WExtCat__Work_Order_Item__c workOrderItem = XC_DF_RatePlan.createJunctionProductRatePlanToItem(order, order.NE__Order_Items__r[0]);
        insert workOrderItem;

        B2WZC__Bit2WinConnector__c b2wConnector = new B2WZC__Bit2WinConnector__c(Name = 'ZuoraConnector', B2WZC__isActiveConnector__c = true);
        insert b2wConnector;

        zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
        billingEntity.zqu__EntityID__c = '8adc8f99684b618601684d4127781f61';
        billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50c4';
        billingEntity.zqu__ZuoraID__c = '2000378';
        billingEntity.zqu__EntityName__c = 'Enel Spain B2C';
        insert billingEntity;

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntity);

        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id];

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        listBillingProfiles[0].NE__Payment__c='Cash';
        update listBillingProfiles;  
        item.NE__BaseOneTimeFee__c = 89;
        item.XC_PaymentMethod__c=listBillingProfiles[0].NE__Payment__c;
        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id 
                                                        FROM XC_BillingProfileLineItem__c 
                                                        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
        item.XC_ZQuoteId__c = dResp.parentId;
        item.NE__Activation_Date__c = DateTime.now();
        update item;

        NE__OrderItem__c oldItem = XC_DF_OrderItem.createOrderItem(order);
        oldItem.XC_ZQuoteId__c = dResp.parentId;
        oldItem.NE__Activation_Date__c = DateTime.now();
        insert oldItem;

        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item, 'Modalidad de Contratacion', '3');
        insert attr;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        listAsset[0].XC_Configuration_Item__c = item.Id;
        listAsset[0].XC_Original_Creation_OrderItem__c = oldItem.Id;
        insert listAsset;
      

    }

    @isTest
    private static void updateRentingTEST() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN015_UpdateRenting.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];

        Test.startTest();
            XC_IN015_UpdateRenting.updateRenting(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        System.assert(numberOfQuote == 1);
		
		zqu__Quote__c q = [SELECT id FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];
		Map<String, XC_TR_ConfigurationItem_U_UpdateZQuote.Params> mapZQuotePrice = new Map<String, XC_TR_ConfigurationItem_U_UpdateZQuote.Params>();
		XC_TR_ConfigurationItem_U_UpdateZQuote.Params par = new XC_TR_ConfigurationItem_U_UpdateZQuote.Params();
		par.quantity = '1';
		par.price = '1';
		mapZQuotePrice.put(q.Id,par);
		XC_TR_ConfigurationItem_U_UpdateZQuote.overridePrices(mapZQuotePrice);
		
		XC_TR_ConfigurationItem_U_UpdateZQuote.ManageDMLQueuable dmlq = new XC_TR_ConfigurationItem_U_UpdateZQuote.ManageDMLQueuable(q.Id,mapZQuotePrice);

    }


    private static List<XC_IN015_UpdateRenting.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN015_UpdateRenting.InputWrapper> listWrapperInput = new List<XC_IN015_UpdateRenting.InputWrapper>();
        XC_IN015_UpdateRenting.InputWrapper wr = new XC_IN015_UpdateRenting.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);

        return listWrapperInput;

    }
    
    @isTest
    private static void coverDAOClass() {
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c FROM NE__OrderItem__c LIMIT 1]);
        List<Id> orderItemIds = XC_UTIL_SObject.getIds(orderItemList);
        String orderId = orderItemList[0].NE__OrderId__c;
        XC_IN015_UpdateRenting_D.getItemsByIds(orderItemIds, orderId);
        System.assert(orderItemList.size()==1);   
    }
}