/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Test of the XC_TR_Configuration_U_ChangeOrder class
*/
@isTest
public class XC_TR_Configuration_U_ChangeOrder_TEST {
	
    @testSetup
    private static void setup() {

        XC_CS_UtilityGlobalValues__c csInsertDML = new XC_CS_UtilityGlobalValues__c();
        csInsertDML.Name = 'InsertLogsGenerateWO';
        csInsertDML.Value__c = 'true';
        insert csInsertDML;
        XC_CS_UtilityGlobalValues__c csInsertDML1 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML1.Name = 'InsertLogsGenerateWO_OK';
        csInsertDML1.Value__c = 'true';
        insert csInsertDML1;
        XC_CS_UtilityGlobalValues__c csInsertDML2 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML2.Name = 'GenerateWOB2Win_Log';
        csInsertDML2.Value__c = 'false';
        insert csInsertDML2;
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

        String orgId = UserInfo.getOrganizationId();
        System.debug('orgID > ' + orgId);
        zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
        billingEntity.zqu__EntityID__c = [Select  XC_ZuoraEntityId__c from XC_CM_LegalEntity_Configuration__mdt where XC_OrgId__c =: orgId and XC_LegalEntity__c = 'EndesaX'][0].XC_ZuoraEntityId__c;
        billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50c4';
        billingEntity.zqu__ZuoraID__c = '2000378';
        billingEntity.zqu__EntityName__c = [SELECT Id, XC_EntityId__c,XC_EntityName__c FROM XC_CM_ZuoraOAuth__mdt WHERE XC_EntityName__c LIKE '%Spain%' AND XC_OrgId__c =: orgId][0].XC_EntityName__c;
        billingEntity.zqu__ZuoraID__c = [Select  XC_ZuoraEntityId__c from XC_CM_LegalEntity_Configuration__mdt where XC_OrgId__c =: orgId and XC_LegalEntity__c = 'EndesaX'][0].XC_ZuoraEntityId__c;
        insert billingEntity;

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntity);
      
        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c, NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id];

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
		listBillingProfiles.get(0).NE__Payment__c  ='Bank Transfer';
        update listBillingProfiles;
        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id 
                                                        FROM XC_BillingProfileLineItem__c 
                                                        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
       	item.XC_PaymentMethod__c = 'Bank Transfer';
        item.XC_ZQuoteId__c = dResp.parentId;
        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        item.NE__Action__c = 'Add';
        item.NE__BaseOneTimeFee__c = 89;
        item.XC_Product_Subtype__c = 'Tariff';
        update item;

        NE__OrderItem__c originalItem = XC_DF_OrderItem.createOrderItem(order);
        originalItem.XC_PaymentMethod__c ='Bank Transfer';
        originalItem.XC_ZQuoteId__c = dResp.parentId;
        originalItem.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        originalItem.NE__Action__c = 'Remove';
        originalItem.NE__BaseOneTimeFee__c = 89;
        insert originalItem;

        B2WExtCat__Work_Order_Item__c woDB = [SELECT Id, B2WExtCat__Work_Order_Item_Code__c, B2WExtCat__Configuration_Item__c,
                                                       B2WExtCat__Work_Order__c, B2WExtCat__Action__c, RecordTypeId
                                                FROM B2WExtCat__Work_Order_Item__c LIMIT 1];
        B2WExtCat__Work_Order_Item__c workOrderOldItem = woDB.clone(false, false, false, false);
        workOrderOldItem.B2WExtCat__Configuration_Item__c = originalItem.Id;
        insert workOrderOldItem;

        List<Asset> listAssets = XC_DF_Asset.createAssets(1);
        listAssets[0].XC_Configuration_Item__c = item.Id;
        listAssets[0].XC_Original_Configuration_Item__c = originalItem.Id;
        listAssets[0].XC_Original_Creation_OrderItem__c  = originalItem.Id;
        insert listAssets;
    }
    
    @isTest
    private static void enqueueJobTEST() {
        B2WExtCat__Work_Order_Item__c workOrderItem = [SELECT Id, B2WExtCat__Work_Order_Item_Code__c FROM B2WExtCat__Work_Order_Item__c LIMIT 1];
        List<String> listRatePlan = new List<String>{workOrderItem.B2WExtCat__Work_Order_Item_Code__c};
        
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
  
        XC_TR_Configuration_U_ChangeOrder.UtilWrapper wr = new XC_TR_Configuration_U_ChangeOrder.UtilWrapper();
        wr.originalZQuoteId = quote.Id;
        wr.ratePlanAddList = listRatePlan;
        wr.ratePlanRemoveList = listRatePlan;
        
        Test.startTest();
        	Id jobId = System.enqueueJob(new XC_TR_Configuration_U_ChangeOrder.ManageDMLQueuable(wr));
        Test.stopTest();
        
        System.assert(true);
    }
    
  	@isTest
    private static void enqueueJobTEST2() {
        B2WExtCat__Work_Order_Item__c workOrderItem = [SELECT Id, B2WExtCat__Work_Order_Item_Code__c FROM B2WExtCat__Work_Order_Item__c LIMIT 1];
        List<String> listRatePlan = new List<String>{workOrderItem.B2WExtCat__Work_Order_Item_Code__c};
        
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        
        XC_TR_Configuration_U_ChangeOrder.UtilWrapper wr = new XC_TR_Configuration_U_ChangeOrder.UtilWrapper();
        wr.originalZQuoteId = quote.Id;
        wr.ratePlanAddList = listRatePlan;
        wr.ratePlanRemoveList = listRatePlan;
        wr.postponeTermDate = true;
            
        Test.startTest();
        	Id jobId = System.enqueueJob(new XC_TR_Configuration_U_ChangeOrder.DeleteFutureQueuable(wr));
        Test.stopTest();
    }
    
   	@isTest
    private static void enqueueJobTEST3() {
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        XC_TR_Configuration_U_ChangeOrder.UtilWrapper wr = new XC_TR_Configuration_U_ChangeOrder.UtilWrapper();
        wr.originalZQuoteId = quote.Id;
            
        Test.startTest();
        	Id jobId = System.enqueueJob(new XC_TR_Configuration_U_ChangeOrder.SendFutureQueuable(wr));
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
    private static void enqueueJobTEST4() {
        B2WExtCat__Work_Order_Item__c workOrderItem = [SELECT Id, B2WExtCat__Work_Order_Item_Code__c FROM B2WExtCat__Work_Order_Item__c LIMIT 1];
        List<String> listRatePlan = new List<String>{workOrderItem.B2WExtCat__Work_Order_Item_Code__c};
        
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        NE__OrderItem__c oi = [SELECT Id, XC_Product_Subtype__c FROM NE__OrderItem__c WHERE XC_Product_Subtype__c = 'Tariff' and NE__Action__c = 'Add'  LIMIT 1];
        
        XC_TR_Configuration_U_ChangeOrder.UtilWrapper wr = new XC_TR_Configuration_U_ChangeOrder.UtilWrapper();
        wr.originalZQuoteId = quote.Id;
        wr.newZQuoteId = quote.Id;
        wr.ratePlanAddList = listRatePlan;
        wr.ratePlanRemoveList = listRatePlan;
        wr.postponeTermDate = true;
        wr.confItem = oi;
        wr.subscriptionTermEndDate = Date.Today();
        wr.qrpcList = new List<zqu__QuoteRatePlanCharge__c>{new zqu__QuoteRatePlanCharge__c(zqu__SpecificEndDate__c = wr.subscriptionTermEndDate.addDays(30))};
        wr.startDateLocal = Date.Today();
        wr.subscriptionRenewalTerm = '3';
        wr.subscriptionAutoRenew = true;
            
        Test.startTest();
        	Id jobId = System.enqueueJob(new XC_TR_Configuration_U_ChangeOrder.TermsAndContitionsAmendmentQueuable(wr));
        Test.stopTest();
    }
    
    @isTest
    private static void createAddRemoveProductsAmendmentQuoteTEST() {
        
        NE__Catalog__c cat = new NE__Catalog__c(XC_LIC_Name__c = 'eMobility');
        insert cat;
        NE__Catalog_Item__c catItem = new NE__Catalog_Item__c(NE__Catalog_Id__c = cat.Id);
        insert catItem; 
       
        
        B2WExtCat__Work_Order_Item__c workOrderItem = [SELECT Id, B2WExtCat__Work_Order_Item_Code__c FROM B2WExtCat__Work_Order_Item__c LIMIT 1];
        List<String> listRatePlan = new List<String>{workOrderItem.B2WExtCat__Work_Order_Item_Code__c};
        
        NE__OrderItem__c item = [SELECT Id, NE__OrderId__c FROM NE__OrderItem__c LIMIT 1];
        item.NE__CatalogItem__c = catItem.Id; 
        update item;

        
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        zqu__QuoteAmendment__c zqa  = new zqu__QuoteAmendment__c(zqu__Quote__c = quote.Id, zqu__Type__c = 'RemoveProduct');
		insert zqa;
            
        XC_Provisioning_Step__c step = [SELECT Id FROM XC_Provisioning_Step__c LIMIT 1];
       
            
        XC_TR_Configuration_U_ChangeOrder.UtilWrapper wr = new XC_TR_Configuration_U_ChangeOrder.UtilWrapper();
        wr.orderId = item.NE__OrderId__c;
        wr.originalZQuoteId = quote.Id;
        wr.ratePlanAddList = listRatePlan;
        wr.ratePlanRemoveList = listRatePlan;
        wr.stepId = step.Id;
        wr.confItemId = item.Id;
		Test.startTest();
        XC_TR_Configuration_U_ChangeOrder.createAddRemoveProductsAmendmentQuote(wr);
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__External_Id__c =  quote.Id, Zuora__SubscriptionNumber__c = 'Test001', Zuora__Version__c = 0, 
                                                                Zuora__TermEndDate__c = Date.newInstance(2021, 08, 9), 
                                                                Zuora__ContractEffectiveDate__c =Date.newInstance(2020, 08, 9));
        insert sub;
        
        
        	XC_TR_Configuration_U_ChangeOrder.createAddRemoveProductsAmendmentQuote(wr);
        Test.stopTest();
        
        System.assert(true);
    }
    
    /*@isTest
    private static void updateRatePlanChargeTEST() {
        
        B2WExtCat__Work_Order_Item__c workOrderItem = [SELECT Id, B2WExtCat__Work_Order_Item_Code__c FROM B2WExtCat__Work_Order_Item__c LIMIT 1];
        List<String> listRatePlan = new List<String>{workOrderItem.B2WExtCat__Work_Order_Item_Code__c};
    	
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        
        zqu__QuoteAmendment__c zqa = new zqu__QuoteAmendment__c(zqu__Quote__c = quote.Id);
        insert zqa;
        
        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c(zqu__Quote__c = quote.Id, zqu__QuoteAmendment__c = zqa.Id);
        insert qrp; 
        zqu__ProductRatePlanCharge__c prpc= new zqu__ProductRatePlanCharge__c();
        prpc=[SELECT Id FROM zqu__ProductRatePlanCharge__c LIMIT 1][0];
        zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c(zqu__QuoteRatePlan__c = qrp.Id, zqu__ProductRatePlanCharge__c = prpc.Id);
        insert qrpc;
               
        Test.startTest();
        	XC_TR_Configuration_U_ChangeOrder.updateRatePlanCharge(quote.Id, listRatePlan);
        Test.stopTest();
        
        System.assert(true);
    }*/
    
    @isTest
    private static void updateStepErrorInfoTEST() {
        
        List<zqu.ZQuoteUtil.ZBillingResult> zbrList = new List<zqu.ZQuoteUtil.ZBillingResult> ();
        zqu.ZQuoteUtil.ZBillingResult zbr = new zqu.ZQuoteUtil.ZBillingResult();
        zbr.deltaDiscountMrr = 0;
        zbr.deltaDiscountTcb = 0;
        zbr.success = false;
        zbrList.add(zbr);
        
        
       	XC_Provisioning_Step__c step = [SELECT Id FROM XC_Provisioning_Step__c LIMIT 1];
        
        Test.startTest();
        	XC_TR_Configuration_U_ChangeOrder.updateStepErrorInfo(zbrList, step.Id);
        Test.stopTest();
        
        System.assert(true);
    }
    
      @isTest
    private static void createAddRemoveProductsAmendmentQuoteTEST2() {
        
        NE__Catalog__c cat = new NE__Catalog__c(XC_LIC_Name__c = 'eMobility');
        insert cat;
        NE__Catalog_Item__c catItem = new NE__Catalog_Item__c(NE__Catalog_Id__c = cat.Id);
        insert catItem; 
       
        
        B2WExtCat__Work_Order_Item__c workOrderItem = [SELECT Id, B2WExtCat__Work_Order_Item_Code__c FROM B2WExtCat__Work_Order_Item__c LIMIT 1];
        List<String> listRatePlan = new List<String>{workOrderItem.B2WExtCat__Work_Order_Item_Code__c};
        
        NE__OrderItem__c item = [SELECT Id, NE__OrderId__c FROM NE__OrderItem__c LIMIT 1];
        item.NE__CatalogItem__c = catItem.Id; 
        update item;

        
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        zqu__QuoteAmendment__c zqa  = new zqu__QuoteAmendment__c(zqu__Quote__c = quote.Id, zqu__Type__c = 'RemoveProduct');
		insert zqa;
            
        XC_Provisioning_Step__c step = [SELECT Id FROM XC_Provisioning_Step__c LIMIT 1];
       
            
        XC_TR_Configuration_U_ChangeOrder.UtilWrapper wr = new XC_TR_Configuration_U_ChangeOrder.UtilWrapper();
        wr.orderId = item.NE__OrderId__c;
        wr.originalZQuoteId = quote.Id;
        wr.ratePlanAddList = listRatePlan;
        wr.ratePlanRemoveList = listRatePlan;
        wr.stepId = step.Id;
        wr.confItemId = item.Id;
		Test.startTest();
        XC_TR_Configuration_U_ChangeOrder.createAddRemoveProductsAmendmentQuote(wr);
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__External_Id__c =  quote.Id, Zuora__SubscriptionNumber__c = 'Test001', Zuora__Version__c = 0, 
                                                                Zuora__TermEndDate__c = Date.newInstance(2023, 08, 9), 
                                                                Zuora__TermStartDate__c = Date.newInstance(2022, 08, 9), 
                                                                Zuora__ContractEffectiveDate__c =Date.newInstance(2020, 08, 9));
        insert sub;
        
        
        	XC_TR_Configuration_U_ChangeOrder.createAddRemoveProductsAmendmentQuote(wr);
        Test.stopTest();
        
        System.assert(true);
    }
}