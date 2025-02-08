/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Test of the invocable class that calls the Order Callback interface
*/
@isTest
public class XC_IN016_ChangeMalf_TEST {
   
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

        /*zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
        billingEntity.zqu__EntityID__c = '8adc8f99684b618601684d4127781f61';
        billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50c4';
        billingEntity.zqu__ZuoraID__c = '2000378';
        billingEntity.zqu__EntityName__c = 'Enel Spain B2C';
        insert billingEntity;*/
        
        String orgId = UserInfo.getOrganizationId();
        List<XC_CM_ZuoraOAuth__mdt> zuoraList = [SELECT Id, XC_EntityId__c, XC_EntityName__c FROM XC_CM_ZuoraOAuth__mdt WHERE XC_EntityName__c LIKE '%Spain%'  AND XC_OrgId__c =: orgId];
        List<zqu__BillingEntity__c> billingEntityList = new List<zqu__BillingEntity__c>();
        Integer i = 1;
        for(XC_CM_ZuoraOAuth__mdt z : zuoraList){
            zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
            billingEntity.zqu__EntityID__c = z.XC_EntityId__c;
            billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50' + i;
            billingEntity.zqu__ZuoraID__c = '2000378' + i;
            billingEntity.zqu__EntityName__c = z.XC_EntityName__c;
            billingEntityList.add(billingEntity);
            i++;
        }
        insert billingEntityList;
        System.debug(LoggingLevel.FINEST, '@@@NM billingEntityList: ' + billingEntityList);

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntityList[0]);

        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id];

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        NE__Billing_Profile__c bp = listBillingProfiles[0];
        bp.NE__Payment__c = Label.XC_CL_Credit_Card;
        update bp;
        item.NE__BaseOneTimeFee__c = 89;

        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id, XC_PaymentMethod__c
                                                        FROM XC_BillingProfileLineItem__c 
                                                        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
		item.XC_PaymentMethod__c  = listBPLI[0].XC_PaymentMethod__c;
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
        item.XC_ZQuoteId__c = dResp.parentId;
        item.NE__Action__c = 'Add';
        item.NE__Activation_Date__c = DateTime.now();
        NE__Catalog_Item__c ci = XC_DF_CatalogItem.createCatalogItem();
        insert ci;
        item.NE__CatalogItem__c = ci.Id;
        update item;


    }

    @isTest
    private static void updateRentingTEST() {
        NE__Order__c order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
   		NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id]; 
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
        NE__OrderItem__c oldItem = XC_DF_OrderItem.createOrderItem(order);
        oldItem.XC_ZQuoteId__c = dResp.parentId;
        oldItem.NE__Activation_Date__c = DateTime.now();
        oldItem.NE__Action__c = 'Remove';
        oldItem.NE__CatalogItem__c = [SELECT Id FROM NE__Catalog_Item__c LIMIT 1].Id;
        insert oldItem;

        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item, 'Modalidad de Contratacion', '3');
        insert attr;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        listAsset[0].XC_Configuration_Item__c = item.Id;
        listAsset[0].XC_Original_Configuration_Item__c = oldItem.Id;
        insert listAsset;
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];
        List<XC_IN016_ChangeMalf_BillingProcess_U.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c ordItem = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];

        Test.startTest();
            XC_IN016_ChangeMalf_BillingProcess.billingPenalty(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :ordItem.XC_ZQuoteId__c];

        System.assert(numberOfQuote == 1);
    }

    @isTest
    private static void itemAdd() {
        NE__Order__c order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
   		NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id]; 
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
        NE__OrderItem__c oldItem = XC_DF_OrderItem.createOrderItem(order);
        oldItem.XC_ZQuoteId__c = dResp.parentId;
        oldItem.NE__Activation_Date__c = DateTime.now();
        oldItem.NE__Action__c = 'Add';
        insert oldItem;

        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item, 'Modalidad de Contratacion', '3');
        insert attr;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        listAsset[0].XC_Configuration_Item__c = item.Id;
        listAsset[0].XC_Original_Configuration_Item__c = oldItem.Id;
        insert listAsset;
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];
        List<XC_IN016_ChangeMalf_BillingProcess_U.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c ordItem = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];

        Test.startTest();
            XC_IN016_ChangeMalf_BillingProcess.billingPenalty(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :ordItem.XC_ZQuoteId__c];

        System.assert(numberOfQuote == 1);
    }

    @isTest
    private static void itemAdd2() {
        
        NE__Order__c order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
   		NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id]; 
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
        
        NE__OrderItem__c oldItem = XC_DF_OrderItem.createOrderItem(order);
        oldItem.NE__Activation_Date__c = DateTime.now();
        oldItem.NE__Action__c = 'Remove';
        oldItem.NE__OrderId__c = order.Id;
        oldItem.NE__CatalogItem__c = [SELECT Id FROM NE__Catalog_Item__c LIMIT 1].Id;
        insert oldItem;

        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item, 'Modalidad de Contratacion', '3');
        insert attr;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        listAsset[0].XC_Configuration_Item__c = item.Id;
        listAsset[0].XC_SubscriptionName__c = 'Test001';
        insert listAsset;

        List<Asset> listAsset2 = XC_DF_Asset.createAssets(accList);
        listAsset2[0].XC_Configuration_Item__c = oldItem.Id;
        listAsset2[0].XC_SubscriptionName__c = 'Test001';
        insert listAsset2;
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN016_ChangeMalf_BillingProcess_U.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c ordItem = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];

        Test.startTest();
            XC_IN016_ChangeMalf_BillingProcess.billingPenalty(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :ordItem.XC_ZQuoteId__c];

        System.assert(numberOfQuote == 1);
    }
    
    
    private static List<XC_IN016_ChangeMalf_BillingProcess_U.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN016_ChangeMalf_BillingProcess_U.InputWrapper> listWrapperInput = new List<XC_IN016_ChangeMalf_BillingProcess_U.InputWrapper>();
        XC_IN016_ChangeMalf_BillingProcess_U.InputWrapper wr = new XC_IN016_ChangeMalf_BillingProcess_U.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);

        return listWrapperInput;

    }
}