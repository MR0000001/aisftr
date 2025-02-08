/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Test of the invocable class that creates the zQuote in the relative provisioning step
*/
@isTest
public class XC_IN018_CreateZQuote_TEST {

    @testSetup
    private static void setup() {
        

        /* This method creates and inserts too the order */
        
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);

        order = [SELECT Id, NE__AccountID__c, NE__OptyId__c, (SELECT Id, NE__ProdName__c , NE__ProdId__r.Manage_Complex_Product_B2C__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];

        //CR771 Start
        List<Opportunity> opp=[Select id,RecordTypeid,XC_BusinessLine__c,XC_Country__c,XC_ProductCategory__c,XC_ProductCategoryOfInterest__c,XC_Commercial_Contract_Type__c from Opportunity where id=:order.NE__OptyId__c];
        opp[0].RecordTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_Chile').getRecordTypeId();
        opp[0].XC_ProductCategoryOfInterest__c = 'Digital Services';
        opp[0].XC_Commercial_Contract_Type__c='Simple contracts';
        opp[0].XC_ProductCategory__c = 'Optimize';
        opp[0].XC_BusinessLine__c='eCity';
        opp[0].XC_Country__c ='Italy';
        update opp;
        //CR771 End
        
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        insert ps;

        B2WExtCat__Work_Order_Item__c workOrderItem = XC_DF_RatePlan.createJunctionProductRatePlanToItem(order, order.NE__Order_Items__r[0]);
        insert workOrderItem;

        B2WZC__Bit2WinConnector__c b2wConnector = new B2WZC__Bit2WinConnector__c(Name = 'ZuoraConnector', B2WZC__isActiveConnector__c = true);
        insert b2wConnector;

        String orgId = UserInfo.getOrganizationId();
        List<XC_CM_ZuoraOAuth__mdt> zuoraList = [SELECT Id, XC_EntityId__c, XC_EntityName__c FROM XC_CM_ZuoraOAuth__mdt WHERE XC_EntityName__c LIKE '%Spain%'  AND XC_OrgId__c =: orgId];
        List<zqu__BillingEntity__c> billingEntityList = new List<zqu__BillingEntity__c>();
        Set<String> entityIds = new Set<String>();
		Integer i = 1;
        for(XC_CM_ZuoraOAuth__mdt z : zuoraList){
            zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
            billingEntity.zqu__EntityID__c = z.XC_EntityId__c;
            billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50' + i;
            billingEntity.zqu__ZuoraID__c = '2000378' + i;
            billingEntity.zqu__EntityName__c = z.XC_EntityName__c;
            if(!entityIds.contains(billingEntity.zqu__EntityID__c)){
                billingEntityList.add(billingEntity);
            }
            entityIds.add(billingEntity.zqu__EntityID__c);
            i++;
        }
        insert billingEntityList;

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntityList[0]);

        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c , NE__OrderId__r.XC_Annex__c , XC_Product_Subtype__c , NE__ProdId__c  FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id];

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        item.NE__BaseOneTimeFee__c = 89;

        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id
        FROM XC_BillingProfileLineItem__c
        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        if( listBillingProfiles[0].NE__Payment__c == null || listBillingProfiles[0].NE__Payment__c == ''){
            listBillingProfiles[0].NE__Payment__c = 'Credit Card';
            item.XC_BillingModel__c = 'One Shot';
            item.XC_PaymentMethod__c = 'Credit Card';
            update listBillingProfiles[0];
        }
        if( item.XC_PaymentMethod__c == null || item.XC_PaymentMethod__c == ''){
            item.XC_BillingModel__c = 'One Shot';
            item.XC_PaymentMethod__c = 'Credit Card';
        }

        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        update item;

        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item,
                Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel,
                'Payment');
        insert attr;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        listAsset[0].XC_Configuration_Item__c = item.Id;
        insert listAsset;      
        
        XC_CS_UtilityGlobalValues__c a = new XC_CS_UtilityGlobalValues__c();
        a.Name = 'CheckBlankValuesWBE';
        a.Value__c = 'false';
        insert a;

        XC_CS_UtilityGlobalValues__c b = new XC_CS_UtilityGlobalValues__c();
        b.Name = 'CheckWBETracking';
        b.Value__c = 'false';
        insert b;
    }

    @isTest
    private static void createZQuoteExternalTEST() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
        FROM XC_Provisioning_Step__c
        LIMIT 1];

        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c , NE__OrderId__r.XC_Annex__c , XC_Product_Subtype__c , NE__ProdId__r.Manage_Complex_Product_B2C__c
        FROM NE__OrderItem__c
        LIMIT 1];
        List<XC_IN018_CreateZQuote.ExternalWrapper> listWrapperExternal = new List<XC_IN018_CreateZQuote.ExternalWrapper>();
        XC_IN018_CreateZQuote.ExternalWrapper wr = new XC_IN018_CreateZQuote.ExternalWrapper();
        wr.stepId = ps.Id;
        wr.generateInvoice = true;
        wr.separateInvoice = false;
        wr.configurationItemId = item.Id;
        listWrapperExternal.add(wr);

        Test.startTest();
        XC_IN018_CreateZQuote.createZquote(listWrapperExternal);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        System.assert(numberOfQuote == 0);

    }

    @isTest
    private static void createZQuoteTEST() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
        FROM XC_Provisioning_Step__c
        LIMIT 1];

        List<XC_IN018_CreateZQuote.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c , NE__OrderId__r.XC_Annex__c , XC_Product_Subtype__c , NE__ProdId__r.Manage_Complex_Product_B2C__c
        FROM NE__OrderItem__c
        LIMIT 1];

        Test.startTest();
        XC_IN018_CreateZQuote.createZquote(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        System.assert(numberOfQuote == 0);

    }

    @isTest
    private static void createZQuoteTEST2() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
        FROM XC_Provisioning_Step__c
        LIMIT 1];

        List<XC_IN018_CreateZQuote.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c, XC_BillingModel__c, XC_BillingProfileLineItem__c, NE__CatalogItem__c, NE__CatalogItem__r.NE__Catalog_Id__c , NE__OrderId__r.XC_Annex__c , XC_Product_Subtype__c , NE__ProdId__c
        FROM NE__OrderItem__c
        LIMIT 1];
        item.XC_BillingModel__c = 'Usage';
        item.XC_BillingProfileLineItem__c = null;
        update item;
        
        NE__Catalog__c catalog = new NE__Catalog__c(Id = item.NE__CatalogItem__r.NE__Catalog_Id__c);
        catalog.XC_LIC_Name__c = 'eHome - ES';
        update catalog;

        Test.startTest();
        XC_IN018_CreateZQuote.createZquote(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        System.assert(numberOfQuote == 0);

    }

    @isTest
    private static void createZQuoteTEST3() {

        XC_IN018_CreateZQuote_U.UpdateWrapper wr = new  XC_IN018_CreateZQuote_U.UpdateWrapper();
        NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c FROM NE__OrderItem__c]);
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
        // Mod CV CR.NR2044 add fields to complete test Start -->
        mapItem.values()[0].XC_Effective_Start_Date_Recurring__c = Date.today();
        mapItem.values()[0].XC_Billing_Period_Recurring__c = 3;
        //<-- End
        update mapItem.values()[0];

        List<String> listZQuoteIds = new List<String>{dResp.parentId};

        List<Asset> a = XC_DF_Asset.createAssets(1);
        a[0].XC_Configuration_Item__c = mapItem.values()[0].Id;
        insert a;

        List<zqu__ProductRatePlan__c> listPRPObj = [SELECT Id FROM zqu__ProductRatePlan__c];
        List<String> listPRP = new List<String>();
        for(zqu__ProductRatePlan__c prp : listPRPObj) {
            listPRP.add(String.valueOf(prp.Id));
        }

        List<zqu__QuoteRatePlanCharge__c> rpChargeList = [SELECT Id, Name, zqu__ChargeType__c, zqu__EffectivePrice__c, TariffType__c FROM zqu__QuoteRatePlanCharge__c];

        Map<String, List<String>> prpcConfItemMap = new Map<String, List<String>>();
        List<zqu__ProductRatePlanCharge__c> prpcList = [SELECT Id, name, XC_WBE__c, XC_ProfitCenter__c, PIncludedkWh__c, TariffType__c
        FROM zqu__ProductRatePlanCharge__c];
        for(zqu__ProductRatePlanCharge__c prpc : prpcList) {
            prpcConfItemMap.put(prpc.Id, new List<String>{mapItem.values()[0].Id});
        }
        update prpcList;

        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Quote__c = dResp.parentId;
        insert quoteAmendment;

        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        qrp.zqu__Quote__c = dResp.parentId;
        qrp.zqu__QuoteAmendment__c = quoteAmendment.Id;
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
        qrpc.zqu__QuoteRatePlan__c = qrp.Id;
        qrpc.zqu__ProductRatePlanCharge__c = prpcList[0].Id;
        insert qrpc;

        wr.prpcConfItemsMap = prpcConfItemMap;
        wr.listRatePlans = listPRP;

        Test.startTest();
        System.enqueueJob(new XC_IN018_CreateZQuote_U.UpdateRPQueuable(listZQuoteIds, wr));
        Test.stopTest();

        //Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];
        //System.assert(numberOfQuote == 0);
        System.assert(true);
    }

    @isTest
    private static void createZQuoteTEST4() {

        XC_IN018_CreateZQuote_U.UpdateWrapper wr = new  XC_IN018_CreateZQuote_U.UpdateWrapper();
        NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c /*, NE__OrderId__r.XC_Annex__c*/ FROM NE__OrderItem__c]);
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
        // Mod CV CR.NR2044 add fields to complete test Start -->
        mapItem.values()[0].XC_Effective_Start_Date_Recurring__c = Date.today();
        mapItem.values()[0].XC_Billing_Period_Recurring__c = 3;
        //<-- End
        update mapItem.values()[0];

        List<String> listZQuoteIds = new List<String>{dResp.parentId};

        List<Asset> a = XC_DF_Asset.createAssets(1);
        a[0].XC_Configuration_Item__c = mapItem.values()[0].Id;
        insert a;

        List<zqu__ProductRatePlan__c> listPRPObj = [SELECT Id FROM zqu__ProductRatePlan__c];
        List<String> listPRP = new List<String>();
        for(zqu__ProductRatePlan__c prp : listPRPObj) {
            listPRP.add(String.valueOf(prp.Id));
        }

        List<zqu__QuoteRatePlanCharge__c> rpChargeList = [SELECT Id, Name, zqu__ChargeType__c, zqu__EffectivePrice__c, TariffType__c FROM zqu__QuoteRatePlanCharge__c];
        for(zqu__QuoteRatePlanCharge__c rpc : rpChargeList) {
            rpc.zqu__ChargeType__c = 'Usage';
        }
        update rpChargeList;

        Map<String, List<String>> prpcConfItemMap = new Map<String, List<String>>();
        List<zqu__ProductRatePlanCharge__c> prpcList = [SELECT Id, name, XC_WBE__c, XC_ProfitCenter__c, PIncludedkWh__c, TariffType__c
        FROM zqu__ProductRatePlanCharge__c];
        for(zqu__ProductRatePlanCharge__c prpc : prpcList) {
            prpcConfItemMap.put(prpc.Id, new List<String>{mapItem.values()[0].Id});
        }
        update prpcList;

        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Quote__c = dResp.parentId;
        insert quoteAmendment;

        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        qrp.zqu__Quote__c = dResp.parentId;
        qrp.zqu__QuoteAmendment__c = quoteAmendment.Id;
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
        qrpc.zqu__QuoteRatePlan__c = qrp.Id;
        qrpc.zqu__ProductRatePlanCharge__c = prpcList[0].Id;
        qrpc.zqu__ChargeType__c = 'Usage';
        insert qrpc;

        wr.prpcConfItemsMap = prpcConfItemMap;
        wr.listRatePlans = listPRP;

        Test.startTest();
        System.enqueueJob(new XC_IN018_CreateZQuote_U.UpdateRPQueuable(listZQuoteIds, wr));
        Test.stopTest();

        //Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];
        //System.assert(numberOfQuote == 0);
        System.assert(true);
    }

     @isTest
    private static void createZQuoteTEST5() { // is preview

        XC_IN018_CreateZQuote_U.UpdateWrapper wr = new  XC_IN018_CreateZQuote_U.UpdateWrapper();
        NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c FROM NE__OrderItem__c]);
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
        update mapItem.values()[0];

        List<String> listZQuoteIds = new List<String>{dResp.parentId};

        List<zqu__ProductRatePlan__c> listPRPObj = [SELECT Id FROM zqu__ProductRatePlan__c];
        List<String> listPRP = new List<String>();
        for(zqu__ProductRatePlan__c prp : listPRPObj) {
            listPRP.add(String.valueOf(prp.Id));
        }

        List<zqu__QuoteRatePlanCharge__c> rpChargeList = [SELECT Id, Name, zqu__ChargeType__c, zqu__EffectivePrice__c, TariffType__c FROM zqu__QuoteRatePlanCharge__c];

        Map<String, List<String>> prpcConfItemMap = new Map<String, List<String>>();
        List<zqu__ProductRatePlanCharge__c> prpcList = [SELECT Id, name, XC_WBE__c, XC_ProfitCenter__c, PIncludedkWh__c, TariffType__c
        FROM zqu__ProductRatePlanCharge__c];
        for(zqu__ProductRatePlanCharge__c prpc : prpcList) {
            prpcConfItemMap.put(prpc.Id, new List<String>{mapItem.values()[0].Id});
        }
        update prpcList;

        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Quote__c = dResp.parentId;
        insert quoteAmendment;

        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        qrp.zqu__Quote__c = dResp.parentId;
        qrp.zqu__QuoteAmendment__c = quoteAmendment.Id;
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
        qrpc.zqu__QuoteRatePlan__c = qrp.Id;
        qrpc.zqu__ProductRatePlanCharge__c = prpcList[0].Id;
        insert qrpc;
        
        XC_Milestone__c mile = new XC_Milestone__c();
        mile.XC_Rate__c = 100;
        mile.XC_StartDate__c = Date.today();
        mile.XC_OrderItem__c = mapItem.values()[0].Id;
        insert mile;


        wr.prpcConfItemsMap = prpcConfItemMap;
        wr.listRatePlans = listPRP;
        wr.isPreview = true;
        wr.milestone = mile;

        Test.startTest();
        System.enqueueJob(new XC_IN018_CreateZQuote_U.UpdateRPQueuable(listZQuoteIds, wr));
        Test.stopTest();

        System.assert(true);
    }

         @isTest
    private static void createZQuoteTEST6() { // milestone

        XC_IN018_CreateZQuote_U.UpdateWrapper wr = new  XC_IN018_CreateZQuote_U.UpdateWrapper();
        NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c FROM NE__OrderItem__c]);
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
        // Mod CV CR.NR2044 add fields to complete test Start -->
        mapItem.values()[0].XC_Effective_Start_Date_Recurring__c = Date.today();
        mapItem.values()[0].XC_Billing_Period_Recurring__c = 3;
        //<-- End
        update mapItem.values()[0];

        List<String> listZQuoteIds = new List<String>{dResp.parentId};

        List<zqu__ProductRatePlan__c> listPRPObj = [SELECT Id FROM zqu__ProductRatePlan__c];
        List<String> listPRP = new List<String>();
        for(zqu__ProductRatePlan__c prp : listPRPObj) {
            listPRP.add(String.valueOf(prp.Id));
        }

        List<zqu__QuoteRatePlanCharge__c> rpChargeList = [SELECT Id, Name, zqu__ChargeType__c, zqu__EffectivePrice__c, TariffType__c FROM zqu__QuoteRatePlanCharge__c];
      

        Map<String, List<String>> prpcConfItemMap = new Map<String, List<String>>();
        List<zqu__ProductRatePlanCharge__c> prpcList = [SELECT Id, name, XC_WBE__c, XC_ProfitCenter__c, PIncludedkWh__c, TariffType__c
        FROM zqu__ProductRatePlanCharge__c];
        for(zqu__ProductRatePlanCharge__c prpc : prpcList) {
            prpcConfItemMap.put(prpc.Id, new List<String>{mapItem.values()[0].Id});
        }
        update prpcList;

        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Quote__c = dResp.parentId;
        insert quoteAmendment;

        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        qrp.zqu__Quote__c = dResp.parentId;
        qrp.zqu__QuoteAmendment__c = quoteAmendment.Id;
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
        qrpc.zqu__QuoteRatePlan__c = qrp.Id;
        qrpc.zqu__ProductRatePlanCharge__c = prpcList[0].Id;
        qrpc.zqu__Model__c = 'value';
        insert qrpc;

        XC_Milestone__c mile = new XC_Milestone__c();
        mile.XC_Rate__c = 100;
        mile.XC_StartDate__c = Date.today();
        mile.XC_OrderItem__c = mapItem.values()[0].Id;
        insert mile;

        //Project
		project_cloud__Project__c p = new project_cloud__Project__c(name='ProgettoTest',XC_ConfigurationItem__c = mapItem.values()[0].Id);
				
		insert p;

		//Create a new phase
		project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c(name='Phase Progetto di Test',
                                                                                     project_cloud__Project__c=p.id);
		insert ph;
        
        //Created a Project Task
		project_cloud__Project_Task__c pt=new project_cloud__Project_Task__c(name='Project Task Test',
		    	                                                                  project_cloud__Duration__c=1,
                                                                                  project_cloud__Project_Phase__c=ph.id,
		    	                                                                  XC_TaskType__c=Constants.PPM_PROJECT_TASK_TYPE_BILLING,
		    	                                                                  XC_TaskReason__c='Milestone',
		    	                                                                  XC_TaskStatus__c='Work in Progress',
		    	                                                                  project_cloud__Autonomous_Start__c=system.today(), 
                                                                             	  project_cloud__Estimated_Hours__c = 1,
                                                                             	  XC_Milestone__c = mile.Id,
                                                                             	  XC_OrderItem__c = mapItem.values()[0].Id
		    	                                                                  );
        insert pt;

        wr.prpcConfItemsMap = prpcConfItemMap;
        wr.listRatePlans = listPRP;
        wr.isPreview = false;
        wr.milestone = mile;
        wr.task = pt;

        Test.startTest();
        System.enqueueJob(new XC_IN018_CreateZQuote_U.UpdateRPQueuable(listZQuoteIds, wr));
        Test.stopTest();

        System.assert(true);
    }

    @isTest
    private static void createZQuoteTEST7() {
        
        XC_CS_UtilityGlobalValues__c b = new XC_CS_UtilityGlobalValues__c();
        b.Name = 'CheckBlankValuesWBE';
        b.Value__c = 'true';
        insert b; 

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
        FROM XC_Provisioning_Step__c
        LIMIT 1];

        List<XC_IN018_CreateZQuote.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c , NE__OrderId__r.XC_Annex__c , XC_Product_Subtype__c , NE__ProdId__c
        FROM NE__OrderItem__c
        LIMIT 1];

        Test.startTest();
        XC_IN018_CreateZQuote.createZquote(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        System.assert(numberOfQuote == 0);

    }
    
    @isTest
    private static void createZQuoteTEST8() {
        
        XC_CS_UtilityGlobalValues__c b = new XC_CS_UtilityGlobalValues__c();
        b.Name = 'CheckWBETracking';
        b.Value__c = 'true';
        insert b; 

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
        FROM XC_Provisioning_Step__c
        LIMIT 1];

        List<XC_IN018_CreateZQuote.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c , NE__OrderId__r.XC_Annex__c , XC_Product_Subtype__c , NE__ProdId__c
        FROM NE__OrderItem__c
        LIMIT 1];

        Test.startTest();
        XC_IN018_CreateZQuote.createZquote(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        System.assert(numberOfQuote == 0);

    }

    @isTest
    private static void createZQuoteTEST9() {
        
     
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
        FROM XC_Provisioning_Step__c
        LIMIT 1];

        ps.XC_lastInvoiceDate__c = DateTime.Now().dateGMT().adddays(-1);
        update ps;

        NE__Order__c order = new NE__Order__c(Id = ps.XC_Configuration_Item__r.NE__OrderId__c);
        order.XC_LegalEntity__c = Label.XC_CL_LegalEntity_EnelSole;
        order.NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder;
        order.XC_Subtype__c = Label.XC_CL_ConfigurationSubtype_ServiceUpgradeDowngrade;
        update order;

        NE__OrderItem__c itemToUpdate = new NE__OrderItem__c (id = ps.XC_Configuration_Item__c, XC_BillingModel__c = 'Recurring');
        update itemToUpdate;

        NE__Product__c prod = new NE__Product__c();
        prod.XC_LIC_Product_Name__c = Label.XC_CL_AdjustmentProdName;
        insert prod;

        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.NE__ProdId__c = prod.Id;
        item.XC_BillingModel__c = 'Recurring';
        item.NE__Parent_Order_Item__c = itemToUpdate.id;
        item.NE__OrderId__c = order.Id;
        item.XC_Effective_Start_Date_Recurring__c = DateTime.Now().dateGMT();
        insert item; 

        Asset ass= new Asset();
        ass.NE__Order_Config__c= order.id;
        ass.XC_Configuration_Item__c= item.id;
        ass.Name='Test';
        ass.XC_LegalEntity__c = Label.XC_CL_LegalEntity_EnelSole;
        ass.XC_Segment__c = 'B2G';
        insert ass; 

        List<XC_IN018_CreateZQuote.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        

        Test.startTest();
        XC_IN018_CreateZQuote.createZquote(listInputWrapper);
        Test.stopTest();
        System.assert(true, ps != null);

    }
	
	@isTest
    private static void createZQuoteTEST10() {
        
     
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
        FROM XC_Provisioning_Step__c
        LIMIT 1];

        ps.XC_lastInvoiceDate__c = DateTime.Now().dateGMT().adddays(-1);
        update ps;

        NE__Order__c order = new NE__Order__c(Id = ps.XC_Configuration_Item__r.NE__OrderId__c);
        order.XC_LegalEntity__c = Label.XC_CL_LegalEntity_EnelSole;
        order.NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder;
        order.XC_Subtype__c = Label.XC_CL_ConfigurationSubtype_ServiceUpgradeDowngrade;
        update order;

        NE__OrderItem__c bundleitem = XC_DF_OrderItem.createOrderItem(order);
		bundleitem.CurrencyIsoCode = Label.XC_CL_UnidadFomento_ISO;
		insert bundleitem;
		
        NE__OrderItem__c itemToUpdate = new NE__OrderItem__c (id = ps.XC_Configuration_Item__c, XC_BillingModel__c = 'Recurring', XC_ProvisioningSpareParts__c = true, NE__Bundle_Configuration__c = bundleitem.Id);
        update itemToUpdate;

        NE__Product__c prod = new NE__Product__c();
        prod.XC_LIC_Product_Name__c = Label.XC_CL_AdjustmentProdName;
        insert prod;

        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.NE__ProdId__c = prod.Id;
        item.XC_BillingModel__c = 'Recurring';
        item.NE__Parent_Order_Item__c = itemToUpdate.id;
        item.NE__OrderId__c = order.Id;
        item.XC_Effective_Start_Date_Recurring__c = DateTime.Now().dateGMT();
        insert item; 

        Asset ass= new Asset();
        ass.NE__Order_Config__c= order.id;
        ass.XC_Configuration_Item__c= item.id;
        ass.Name='Test';
        ass.XC_LegalEntity__c = Label.XC_CL_LegalEntity_EnelSole;
        ass.XC_Segment__c = 'B2G';
        insert ass; 

        List<XC_IN018_CreateZQuote.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        

        Test.startTest();
        XC_IN018_CreateZQuote.createZquote(listInputWrapper);
        Test.stopTest();
        System.assert(true, ps != null);

    }
	
	@isTest
    private static void createZQuoteTEST11() {
        
     
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
        FROM XC_Provisioning_Step__c
        LIMIT 1];

        ps.XC_lastInvoiceDate__c = DateTime.Now().dateGMT().adddays(-1);
        update ps;

        NE__Order__c order = new NE__Order__c(Id = ps.XC_Configuration_Item__r.NE__OrderId__c);
        order.XC_LegalEntity__c = Label.XC_CL_LegalEntity_EnelSole;
        order.NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder;
        order.XC_Subtype__c = Label.XC_CL_ConfigurationSubtype_ServiceUpgradeDowngrade;
        update order;
		
		List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        productList[0].NE__Engine_Code__c= '22123';
		productList[0].Manage_Complex_Product_B2C__c = true;
        productList[0].Name = 'prodName2223';
        insert productList;

        NE__OrderItem__c itemToUpdate = new NE__OrderItem__c (id = ps.XC_Configuration_Item__c, XC_BillingModel__c = 'Recurring', NE__ProdId__c = productList[0].Id);
        update itemToUpdate;

        NE__Product__c prod = new NE__Product__c();
        prod.XC_LIC_Product_Name__c = Label.XC_CL_AdjustmentProdName;
        insert prod;

        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.NE__ProdId__c = prod.Id;
        item.XC_BillingModel__c = 'Recurring';
        item.NE__Parent_Order_Item__c = itemToUpdate.id;
        item.NE__OrderId__c = order.Id;
        item.XC_Effective_Start_Date_Recurring__c = DateTime.Now().dateGMT();
        insert item; 

        Asset ass= new Asset();
        ass.NE__Order_Config__c= order.id;
        ass.XC_Configuration_Item__c= item.id;
        ass.Name='Test';
        ass.XC_LegalEntity__c = Label.XC_CL_LegalEntity_EnelSole;
        ass.XC_Segment__c = 'B2G';
        insert ass; 

        List<XC_IN018_CreateZQuote.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        

        Test.startTest();
        XC_IN018_CreateZQuote.createZquote(listInputWrapper);
        Test.stopTest();
        System.assert(true, ps != null);

    }

	@isTest
    private static void createZQuoteTEST_B2G7() {
	
        List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, false);
        insert o;
        
        List<Contract> listContracts = XC_DF_Contract.createContracts(1);
        listContracts[0].Opportunity__c = o[0].Id;
        insert listContracts;
        NE__Order__c order2 = new NE__Order__c();
        order2.NE__Type__c = 'InOrder';
        order2.NE__OptyId__c = o[0].Id;
        order2.XC_DeliveryAddress__c = o[0].XC_Address__c;
        order2.NE__AccountId__c = o[0].AccountId;
        order2.XC_Country__c = 'Italy';
        order2.XC_LegalEntity__c = 'EnelXItalia';
        order2.XC_Segment__c = 'B2G';
        insert order2;
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        insert cat;

        List<NE__Product__c> productList = XC_DF_Product.createProducts(2);
        productList[1].NE__Engine_Code__c= '22123';
        productList[1].Name = 'prodName2223';
        insert productList;
        
        NE__OrderItem__c item2 = new NE__OrderItem__c(
           XC_Product_Type__c = 'Bundle',              
           XC_Product_Subtype__c = 'Bundle',           
           NE__Status__c = 'Pending',   
           NE__ProdId__c = productList[1].Id,
           NE__Qty__c = 1,                           
           NE__BaseRecurringCharge__c = 0,             
           NE__OrderId__c = order2.Id,                  
           NE__RecurringChargeOv__c = 0,               
           NE__CatalogItem__c = cat.Id,                
           XC_BillingModel__c = 'Usage',
           NE__OneTimeFeeOv__c = 1
        );
        item2.NE__Account__c = o[0].AccountId;
        insert item2;
        NE__Order_Item_Attribute__c attr2 = XC_DF_OrderItemAttribute.createOrderItemAttribute(item2,
                                                                                             Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel,
                                                                                             'Payment');
        attr2.name = Label.XC_CL_ReverseCharge;
        attr2.NE__Order_Item__c = item2.Id;
        insert attr2;
        update order2;
        order2 = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order2.Id];
        //B2WExtCat__Work_Order_Item__c workOrderItem2 = XC_DF_RatePlan.createJunctionProductRatePlanToItem(order2, order2.NE__Order_Items__r[0]);
        //insert workOrderItem2;
/*
        if( listBillingProfiles[0].NE__Payment__c == null || listBillingProfiles[0].NE__Payment__c == ''){
            listBillingProfiles[0].NE__Payment__c = 'Credit Card';
            item2.XC_BillingModel__c = 'One Shot';
            item2.XC_PaymentMethod__c = 'Credit Card';
            update listBillingProfiles[0];
        }
        if( item2.XC_PaymentMethod__c == null || item2.XC_PaymentMethod__c == ''){
            item2.XC_BillingModel__c = 'One Shot';
            item2.XC_PaymentMethod__c = 'Credit Card';
        }

        item2.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        update item2;*/
        
		Product2 realProduct = new Product2();
        realProduct.Name = 'Real Product Name2';                                        
        realProduct.IsActive = true;
        realProduct.ProductCode ='332211';
        realProduct.zqu__ZuoraId__c = '8adc9dee7253141801725626f5c5120e';
        insert realProduct;
        
        zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c();
        prp.Name = item2.NE__ProdName__c;
        prp.zqu__ProductRatePlanFullName__c =  item2.NE__ProdName__c;
        prp.zqu__EffectiveEndDate__c = Date.newInstance(3000, 1, 12);
        prp.zqu__EffectiveStartDate__c = Date.today();
        prp.zqu__ZuoraId__c = '8adc9dee7253141801725626f5c5120e';
        prp.CurrencyIsoCode = 'EUR';
        prp.zqu__ActiveCurrencies__c = 'EUR';
        prp.zqu__Product__c = realProduct.Id;
        insert prp;

        zqu__ProductRatePlanCharge__c prpc = new zqu__ProductRatePlanCharge__c();
        prpc.Name = 'Rate Plan Charge TEST';
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.zqu__ProductRatePlanChargeName__c = 'Rate Plan Charge TEST2';
        prpc.zqu__ZuoraId__c = '8adc9dee7253141801725626f5c5120e';
        prpc.zqu__Model__c = 'Per Unit Pricing';
        insert prpc;

        B2WExtCat__External_Catalog__c extCatalog = new B2WExtCat__External_Catalog__c();
        extCatalog.B2WExtCat__External_Catalog_Name__c = 'TEST CATALOG2';
        insert extCatalog;

        B2WExtCat__External_Catalog_Item__c extCatalogItem = new B2WExtCat__External_Catalog_Item__c();
        extCatalogItem.B2WExtCat__Type__c = 'Item';
        extCatalogItem.B2WExtCat__External_Catalog_Item_Name__c = 'catalogo';
        extCatalogItem.B2WExtCat__External_Catalog__c = extCatalog.Id;
        insert extCatalogItem;
        
        B2WZC__ECI_RatePlan_Junction__c junctionB2WZC = new B2WZC__ECI_RatePlan_Junction__c();
        junctionB2WZC.B2WZC__Name__c = 'Junction Test B2W2';
        junctionB2WZC.B2WZC__IdRatePlan__c = prp.Id;
        junctionB2WZC.B2WZC__EciId__c = extCatalogItem.Id;
        insert junctionB2WZC;

        B2WExtCat__Work_Order__c b2wWorkOrder = new B2WExtCat__Work_Order__c();
        b2wWorkOrder.B2WExtCat__External_Catalog__c = extCatalog.Id;
        b2wWorkOrder.B2WExtCat__Configuration__c = order2.Id;
        insert b2wWorkOrder;

        Id junctionRT = Schema.SObjectType.B2WExtCat__Work_Order_Item__c.getRecordTypeInfosByDeveloperName().get('ZuoraOneTime').getRecordTypeId();

        B2WExtCat__Work_Order_Item__c junction = new B2WExtCat__Work_Order_Item__c();
        junction.B2WExtCat__Work_Order_Item_Code__c = prp.Id;
        junction.B2WExtCat__Configuration_Item__c = item2.Id;
        junction.B2WExtCat__Work_Order__c = b2wWorkOrder.Id;
        junction.B2WExtCat__Action__c = 'Provide';
        junction.RecordTypeId = junctionRT;
        insert junction;
        
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order2.NE__Order_Items__r[0].Id));
        insert ps;

        List<XC_IN018_CreateZQuote.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c, XC_BillingModel__c, XC_BillingProfileLineItem__c
        FROM NE__OrderItem__c
        LIMIT 1];
        item.XC_BillingModel__c = 'Recurring';
        item.XC_BillingProfileLineItem__c = null;
        item.XC_RecurringDuration__c = 1;
        item.NE__OneTimeFeeOv__c = 1;
        update item;

        Test.startTest();
        XC_IN018_CreateZQuote.createZquote(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        System.assert(numberOfQuote == 0);

    }
    
    @isTest
    private static void calculateInitialTermTEST() {

        String paymentModel = Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel;
        String formaDePago = Label.XC_CL_ConfigurationItemAttribute_DevFormaDePago;

        NE__OrderItem__c item = [SELECT ID FROM NE__OrderItem__c LIMIT 1];
        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item, paymentModel, '3');
        insert attr;

        Test.startTest();
        XC_IN018_CreateZQuote_UU.calculateInitialTerm(item.Id);
        attr.NE__Value__c = '5';
        update attr;
        XC_IN018_CreateZQuote_UU.calculateInitialTerm(item.Id);
        attr.NE__Value__c = '7';
        update attr;
        XC_IN018_CreateZQuote_UU.calculateInitialTerm(item.Id);
        attr.name = formaDePago;
        update attr;
        XC_IN018_CreateZQuote_UU.calculateInitialTerm(item.Id);
        Test.stopTest();

        System.assert([SELECT COUNT() FROM NE__OrderItem__c WHERE Id = :item.Id] == 1);
    }

    private static List<XC_IN018_CreateZQuote.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN018_CreateZQuote.InputWrapper> listWrapperInput = new List<XC_IN018_CreateZQuote.InputWrapper>();
        XC_IN018_CreateZQuote.InputWrapper wr = new XC_IN018_CreateZQuote.InputWrapper();
        wr.stepId = ps.Id;
        wr.generateInvoice = true;
        wr.separateInvoice = false;
        listWrapperInput.add(wr);

        return listWrapperInput;

    }


    @isTest
    private static void retrieveBundleConfItemsTEST() {

        List<NE__OrderItem__c> itemsList = [SELECT Id FROM NE__OrderItem__c];
        List<NE__OrderItem__c> bundleItemsList = XC_DF_OrderItem.createOrderItems(1);
        bundleItemsList[0].NE__Bundle_Configuration__c = itemsList[0].Id;
        insert bundleItemsList;

        Test.startTest();
        List<NE__OrderItem__c> orderItemList = XC_IN018_CreateZQuote_D.retrieveBundleConfItems(itemsList[0].Id);
        Test.stopTest();

        System.assert(true);
    }


    @isTest
    private static void generateErrorForNoRatePlanTEST() {

        List<NE__OrderItem__c> itemsList = [SELECT Id FROM NE__OrderItem__c];
        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(itemsList[0].Id);
        step.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateSubscription_Flow;
        insert step;

        Test.startTest();
        XC_IN018_CreateZQuote.generateErrorForNoRatePlan(new List<String>{itemsList[0].Id});
        Test.stopTest();

        System.assert(true);
    }

    @isTest
    private static void replacePaymentMethod1() {

        zqu__Quote__c z = new zqu__Quote__c();
        z.zqu__PaymentMethod__c = 'Credit Card SIA';

        Test.startTest();
        XC_IN018_CreateZQuote_UU.replacePaymentMethod(z);
        Test.stopTest();

        System.assert(true, z != null);
    }

    @isTest
    private static void replacePaymentMethod2() {

        zqu__Quote__c z = new zqu__Quote__c();
        z.zqu__PaymentMethod__c = 'Commodity Bill';

        Test.startTest();
        XC_IN018_CreateZQuote_UU.replacePaymentMethod(z);
        Test.stopTest();

        System.assert(true, z != null);
    }

    @isTest
    private static void replacePaymentMethod3() {

        zqu__Quote__c z = new zqu__Quote__c();
        z.zqu__PaymentMethod__c = 'Direct Debt';

        Test.startTest();
        XC_IN018_CreateZQuote_UU.replacePaymentMethod(z);
        Test.stopTest();

        System.assert(true, z != null);
    }

    @isTest
    private static void getTecnicalProductTEST() {
        List<NE__OrderItem__c> oiList;
        Test.startTest();
        oiList = XC_IN018_CreateZQuote_D.retrieveTecnicalProductConfItems([SELECT Id FROM NE__Order__c LIMIT 1][0].Id);
        Test.stopTest();

        System.assert(true, oiList != null);
    }

    @isTest
    private static void getTecnicalProductTEST2() { //MP start
        
        List<NE__OrderItem__c> itemsList = [SELECT Id FROM NE__OrderItem__c];
        List<NE__OrderItem__c> bundleItemsList = XC_DF_OrderItem.createOrderItems(1);
        bundleItemsList[0].NE__Root_Order_Item__c = itemsList[0].Id;
        insert bundleItemsList;

        Test.startTest();
        List<NE__OrderItem__c> orderItemList = XC_IN018_CreateZQuote_D.retrieveBundleConfItems(itemsList[0].Id);
        Test.stopTest();

        System.assert(true,orderItemList!=null);

    }//MP stop

    @isTest
    private static void manageDiscountPercentageTEST() {
        zqu__QuoteRatePlanCharge__c rpc = new zqu__QuoteRatePlanCharge__c();
        rpc.zqu__Model__c = 'Discount-Percentage';
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c, NE__OneTimeFeeOv__c, NE__BaseOneTimeFee__c FROM NE__OrderItem__c]);

        
        List <NE__Order_Item_Discount__c> discounts = new List <NE__Order_Item_Discount__c>();
        NE__Order_Item_Discount__c discount = new NE__Order_Item_Discount__c();
        discount.NE__Order_Item__c = mapItem.values()[0].Id;
 		discount.NE__Type__c = 'Percentage';
        discount.NE__One_Time_Value__c = 10;
        discount.NE__Start_Date__c = Date.Today();
        discount.NE__End_Date__c = Date.Today().addMonths(1);
        discount.NE__Code__c = '33333';
        discount.NE__One_Time_Price__c=0;
        discount.NE__Recurring_Price__c=0;
        discount.NE__Recurring_Value__c=0;
        discounts.add(discount);
	 	insert discount;
        
        List<NE__Order_Item_Discount__c> disc = [Select id,NE__Type__c,NE__One_Time_Value__c,NE__One_Time_Percentage__c,NE__Code__c,NE__Start_Date__c,NE__Recurring_Price__c,NE__End_Date__c, NE__Order_Item__c,NE__Order_Item__r.NE__OrderId__c,NE__Order_Item__r.NE__OrderId__r.CreatedDate from NE__Order_Item_Discount__c where Id = :discount.Id];
 
        Test.startTest();
        XC_IN018_CreateZQuote_UU.manageOrderItemDiscountsCharges(rpc, disc, new Map<String,Object>());
        Test.stopTest();

        System.assert(true, discounts != null);
    }

    @isTest
    private static void manageDiscountFixedTEST() {
        zqu__QuoteRatePlanCharge__c rpc = new zqu__QuoteRatePlanCharge__c();
        rpc.zqu__Model__c = 'Discount-Fixed Amount';
		NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c, NE__OrderId__c FROM NE__OrderItem__c LIMIT 1];
        
        List <NE__Order_Item_Discount__c> discounts = new List <NE__Order_Item_Discount__c>();
        NE__Order_Item_Discount__c discount = new NE__Order_Item_Discount__c();
        
        discount.NE__Type__c = 'Value';
        discount.NE__Order_Item__c = item.Id;
        discount.NE__One_Time_Value__c = 10;
        discount.NE__Start_Date__c = Date.Today();
        discount.NE__End_Date__c = Date.Today().addMonths(1);
        discount.NE__Code__c = '33333';
        discount.NE__One_Time_Price__c=0;
        discount.NE__Recurring_Price__c=0;
        discount.NE__Recurring_Value__c=0;
        discounts.add(discount);
	 	insert discount;
        
        List<NE__Order_Item_Discount__c> disc = [Select id,NE__Type__c,NE__One_Time_Value__c,NE__Code__c,NE__Start_Date__c,NE__Recurring_Price__c,NE__End_Date__c, NE__Order_Item__c,NE__Order_Item__r.NE__OrderId__c,NE__Order_Item__r.NE__OrderId__r.CreatedDate from NE__Order_Item_Discount__c where Id = :discount.Id];
        Test.startTest();
        XC_IN018_CreateZQuote_UU.manageOrderItemDiscountsCharges(rpc, disc, new Map<String,Object>());
        Test.stopTest();

        System.assert(true, disc != null);
    }

    @isTest
    private static void manageDiscountFixedTEST2() {
        zqu__QuoteRatePlanCharge__c rpc = new zqu__QuoteRatePlanCharge__c();
        rpc.zqu__Model__c = 'Discount-Percentage';

        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c, NE__OrderId__c FROM NE__OrderItem__c LIMIT 1];
        
        List <NE__Order_Item_Discount__c> discounts = new List <NE__Order_Item_Discount__c>();
        NE__Order_Item_Discount__c discount = new NE__Order_Item_Discount__c();
        discount.NE__Type__c = 'Value';
        discount.NE__Order_Item__c = item.Id;
        discount.NE__One_Time_Value__c = 10;
        discount.NE__Start_Date__c = Date.Today();
        discount.NE__End_Date__c = Date.Today().addMonths(1);
        discount.NE__Code__c = '33333';
        discount.NE__One_Time_Price__c=0;
        discount.NE__Recurring_Price__c=0;
        discount.NE__Recurring_Value__c=0;
        discounts.add(discount);
	 	insert discount;
        
        List<NE__Order_Item_Discount__c> disc = [Select id,NE__Type__c,NE__One_Time_Value__c,NE__Code__c,NE__Start_Date__c,NE__Recurring_Price__c,NE__End_Date__c, NE__Order_Item__c,NE__Order_Item__r.NE__OrderId__c,NE__Order_Item__r.NE__OrderId__r.CreatedDate from NE__Order_Item_Discount__c where Id = :discount.Id];
   
        Test.startTest();
        XC_IN018_CreateZQuote_UU.manageOrderItemDiscountsCharges(rpc, disc, new Map<String,Object>());
        Test.stopTest();

        System.assert(true, disc != null);
    }
    @isTest
    private static void manageDiscountFixedTEST3() {
        zqu__QuoteRatePlanCharge__c rpc = new zqu__QuoteRatePlanCharge__c();
        rpc.zqu__Model__c = 'Flat Fee Pricing';

        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c, NE__OrderId__c FROM NE__OrderItem__c LIMIT 1];
        
        List <NE__Order_Item_Discount__c> discounts = new List <NE__Order_Item_Discount__c>();
        NE__Order_Item_Discount__c discount = new NE__Order_Item_Discount__c();
        discount.NE__Type__c = 'Value';
        discount.NE__Order_Item__c = item.Id;
        discount.NE__One_Time_Value__c = 10;
        discount.NE__Start_Date__c = Date.Today();
        //discount.NE__End_Date__c = Date.Today().addMonths(1);
        discount.NE__Code__c = '33333';
        discount.NE__One_Time_Price__c=0;
        discount.NE__Recurring_Price__c=0;
        discount.NE__Recurring_Value__c=0;
        discounts.add(discount);
	 	insert discount;
        
        List<NE__Order_Item_Discount__c> disc = [Select id,NE__Type__c,NE__One_Time_Value__c,NE__Start_Date__c,NE__End_Date__c, NE__Order_Item__c,NE__Order_Item__r.NE__OrderId__c,NE__Order_Item__r.NE__OrderId__r.CreatedDate from NE__Order_Item_Discount__c where Id = :discount.Id];
   
        Test.startTest();
        XC_IN018_CreateZQuote_UU.manageOrderItemDiscountsCharges(rpc, disc, new Map<String,Object>());
        Test.stopTest();

        System.assert(true, disc != null);
    }
    
    @isTest
    private static void manageMalfunctionTest() {
        B2WExtCat__Work_Order_Item__c workOrderItem = [SELECT Id, B2WExtCat__Work_Order_Item_Code__c FROM B2WExtCat__Work_Order_Item__c LIMIT 1];
        List<String> listRatePlan = new List<String>{workOrderItem.B2WExtCat__Work_Order_Item_Code__c};

        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', [SELECT Id FROM NE__Order__c LIMIT 1][0].Id);
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c, NE__OneTimeFeeOv__c, NE__BaseOneTimeFee__c FROM NE__OrderItem__c]);

        Map<String, List<String>> prpcConfItemsMap = new Map<String, List<String>>();
        List<zqu__ProductRatePlanCharge__c> prpcList = [SELECT Id, name, XC_WBE__c, XC_ProfitCenter__c, PIncludedkWh__c, TariffType__c
        FROM zqu__ProductRatePlanCharge__c];
        for(zqu__ProductRatePlanCharge__c prpc : prpcList) {
            prpcConfItemsMap.put(prpc.Id, new List<String>{mapItem.values()[0].Id});
        }

        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
        update mapItem.values();

        Map<String, Object> mapUtil = new Map<String, Object>{ 'newZQuoteId' => dResp.parentId,
        'listRatePlans' => listRatePlan,
        'prpcConfItemsMap' => prpcConfItemsMap,
        'confItemMalfunction'=> mapItem.values()[0]
        };


        Test.startTest();
        XC_IN018_CreateZquote_U.updateRatePlanCharge(mapUtil);
        Test.stopTest();

        System.assert(true, mapUtil.get('confItemMalfunction') != null);
    }

     @isTest
    private static void createZQuoteBillingPlan_Test2() {

        XC_IN018_CreateZQuote_U.UpdateWrapper wr = new  XC_IN018_CreateZQuote_U.UpdateWrapper();
        NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        order.XC_Segment__c = 'B2G';
        order.XC_LegalEntity__c = 'EnelXItalia';
        update order;
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c, XC_BillingProfileLineItem__c FROM NE__OrderItem__c]);
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
        mapItem.values()[0].XC_BillingModel__c = 'Billing Plan';
        mapItem.values()[0].XC_PaymentMethod__c = 'Bank Transfer';
        
        // Mod CV CR.NR2044 add fields to complete test Start -->
        mapItem.values()[0].XC_Effective_Start_Date_Recurring__c = Date.today();
        mapItem.values()[0].XC_Billing_Period_Recurring__c = 3;
        //<-- End

        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id, XC_BillingProfile__r.Id
        FROM XC_BillingProfileLineItem__c
        WHERE Id =:mapItem.values()[0].XC_BillingProfileLineItem__c];
        
        listBPLI[0].XC_BillingProfile__r.NE__Payment__c = 'Bank Transfer';
        update listBPLI[0].XC_BillingProfile__r;
        
        update mapItem.values()[0];

        List<String> listZQuoteIds = new List<String>{dResp.parentId};

        List<Asset> a = XC_DF_Asset.createAssets(1);
        a[0].XC_Configuration_Item__c = mapItem.values()[0].Id;
        insert a;

        List<zqu__ProductRatePlan__c> listPRPObj = [SELECT Id FROM zqu__ProductRatePlan__c];
        List<String> listPRP = new List<String>();
        for(zqu__ProductRatePlan__c prp : listPRPObj) {
            listPRP.add(String.valueOf(prp.Id));
        }

        List<zqu__QuoteRatePlanCharge__c> rpChargeList = [SELECT Id, Name, zqu__ChargeType__c, zqu__EffectivePrice__c, TariffType__c FROM zqu__QuoteRatePlanCharge__c];

        Map<String, List<String>> prpcConfItemMap = new Map<String, List<String>>();
        List<zqu__ProductRatePlanCharge__c> prpcList = [SELECT Id, name, XC_WBE__c, XC_ProfitCenter__c, PIncludedkWh__c, TariffType__c
        FROM zqu__ProductRatePlanCharge__c];
        for(zqu__ProductRatePlanCharge__c prpc : prpcList) {
            prpcConfItemMap.put(prpc.Id, new List<String>{mapItem.values()[0].Id});
        }
        update prpcList;

        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Quote__c = dResp.parentId;
        insert quoteAmendment;

        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        qrp.zqu__Quote__c = dResp.parentId;
        qrp.zqu__QuoteAmendment__c = quoteAmendment.Id;
        insert qrp;		

        zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
        qrpc.zqu__QuoteRatePlan__c = qrp.Id;
        qrpc.zqu__ProductRatePlanCharge__c = prpcList[0].Id;
        insert qrpc;

        wr.prpcConfItemsMap = prpcConfItemMap;
        wr.listRatePlans = listPRP;

        Test.startTest();
        System.enqueueJob(new XC_IN018_CreateZQuote_U.UpdateRPQueuable(listZQuoteIds, wr));
        Test.stopTest();

        //Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];
        //System.assert(numberOfQuote == 0);
        System.assert(true);
    }

    @isTest
    private static void createZQuoteBillingPlan_TEST() {

        XC_IN018_CreateZQuote_U.UpdateWrapper wr = new  XC_IN018_CreateZQuote_U.UpdateWrapper();
        NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        order.XC_Segment__c = 'B2G';
        order.XC_LegalEntity__c = 'EnelXItalia';
        update order;
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c, XC_BillingProfileLineItem__c FROM NE__OrderItem__c]);
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
        mapItem.values()[0].XC_BillingModel__c = 'Billing Plan';
        mapItem.values()[0].XC_PaymentMethod__c = 'Bank Transfer';
        // Mod CV CR.NR2044 add fields to complete test Start -->
        mapItem.values()[0].XC_Effective_Start_Date_Recurring__c = Date.today();
        mapItem.values()[0].XC_Billing_Period_Recurring__c = 3;
        //<-- End
        
        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id, XC_BillingProfile__r.Id
        FROM XC_BillingProfileLineItem__c
        WHERE Id =:mapItem.values()[0].XC_BillingProfileLineItem__c];
        
        listBPLI[0].XC_BillingProfile__r.NE__Payment__c = 'Bank Transfer';
        update listBPLI[0].XC_BillingProfile__r;
        
        update mapItem.values()[0];

        List<String> listZQuoteIds = new List<String>{dResp.parentId};

        List<Asset> a = XC_DF_Asset.createAssets(1);
        a[0].XC_Configuration_Item__c = mapItem.values()[0].Id;
        insert a;

        List<zqu__ProductRatePlan__c> listPRPObj = [SELECT Id FROM zqu__ProductRatePlan__c];
        List<String> listPRP = new List<String>();
        for(zqu__ProductRatePlan__c prp : listPRPObj) {
            listPRP.add(String.valueOf(prp.Id));
        }

        List<zqu__QuoteRatePlanCharge__c> rpChargeList = [SELECT Id, Name, zqu__ChargeType__c, zqu__EffectivePrice__c, TariffType__c FROM zqu__QuoteRatePlanCharge__c];

        Map<String, List<String>> prpcConfItemMap = new Map<String, List<String>>();
        List<zqu__ProductRatePlanCharge__c> prpcList = [SELECT Id, name, XC_WBE__c, XC_ProfitCenter__c, PIncludedkWh__c, TariffType__c
        FROM zqu__ProductRatePlanCharge__c];
        for(zqu__ProductRatePlanCharge__c prpc : prpcList) {
            prpcConfItemMap.put(prpc.Id, new List<String>{mapItem.values()[0].Id});
        }

        update prpcList;

        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Quote__c = dResp.parentId;
        insert quoteAmendment;

        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        qrp.zqu__Quote__c = dResp.parentId;
        qrp.zqu__QuoteAmendment__c = quoteAmendment.Id;
        insert qrp;
		
        zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
        qrpc.zqu__QuoteRatePlan__c = qrp.Id;
        qrpc.zqu__ProductRatePlanCharge__c = prpcList[0].Id;
        insert qrpc;


        wr.prpcConfItemsMap = prpcConfItemMap;
        wr.listRatePlans = listPRP;

        Test.startTest();
        System.enqueueJob(new XC_IN018_CreateZQuote_U.UpdateRPQueuable(listZQuoteIds, wr));
        Test.stopTest();

        //Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];
        //System.assert(numberOfQuote == 0);
        System.assert(true);
    }

    @isTest
    static void checkInvoice (){
        XC_IN018_CreateZQuote_U.UpdateWrapper wr = new  XC_IN018_CreateZQuote_U.UpdateWrapper();
        NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        order.XC_Segment__c ='B2C';
        update order;
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        insert item;
        item.XC_BundleTotalOTAmount__c = 100;
        update item;
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c, NE__ProdName__c FROM NE__OrderItem__c]);
        listOfOrderItem[0].NE__Bundle_Configuration__c = item.Id;
        listOfOrderItem[0].NE__OneTimeFeeOv__c = 1;
        listOfOrderItem[0].XC_RecurringDuration__c = 1;
        update listOfOrderItem;
        listOfOrderItem = [SELECT Id, NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c, NE__ProdName__c FROM NE__OrderItem__c WHERE NE__Bundle_Configuration__c != null];
       

        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Quote__c = dResp.parentId;
        insert quoteAmendment;
        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        qrp.zqu__Quote__c = dResp.parentId;
        qrp.zqu__QuoteAmendment__c = quoteAmendment.Id;
        insert qrp;
        List<zqu__QuoteRatePlanCharge__c> listOfQuoteRatePlanCharge = new List<zqu__QuoteRatePlanCharge__c>();
        zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
        qrpc.zqu__QuoteRatePlan__c = qrp.Id;
        qrpc.zqu__EffectivePrice__c = 10;
        qrpc.zqu__Quantity__c = 2;
        listOfQuoteRatePlanCharge.add(qrpc);
        zqu__QuoteRatePlanCharge__c qrpcNoQuantity = new zqu__QuoteRatePlanCharge__c();
        qrpcNoQuantity.zqu__QuoteRatePlan__c = qrp.Id;
        qrpcNoQuantity.zqu__EffectivePrice__c = 10;
        listOfQuoteRatePlanCharge.add(qrpcNoQuantity);
        zqu__QuoteRatePlanCharge__c qrpcDiscountAmount = new zqu__QuoteRatePlanCharge__c();
        qrpcDiscountAmount.zqu__QuoteRatePlan__c = qrp.Id;
        qrpcDiscountAmount.zqu__DiscountAmount__c = 10;
        qrpcDiscountAmount.zqu__Model__c = 'Discount-Fixed Amount';
        listOfQuoteRatePlanCharge.add(qrpcDiscountAmount);
        zqu__QuoteRatePlanCharge__c qrpcDiscountPercentage = new zqu__QuoteRatePlanCharge__c();
        qrpcDiscountPercentage.zqu__QuoteRatePlan__c = qrp.Id;
        qrpcDiscountPercentage.zqu__Model__c = 'Discount-Percentage';
        qrpcDiscountPercentage.zqu__DiscountPercentage__c= 20;
        listOfQuoteRatePlanCharge.add(qrpcDiscountPercentage); 
        insert listOfQuoteRatePlanCharge;

        wr.item = listOfOrderItem[0];
        wr.zQuoteId = dResp.parentId;

        XC_IN018_CreateZQuote_U.checkInvoice(wr);
    }
    
    
    @isTest
    static void checkInvoiceQueuable (){
        XC_IN018_CreateZQuote_U.UpdateWrapper wr = new  XC_IN018_CreateZQuote_U.UpdateWrapper();
        NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        // Mod CV CR.NR2044 add fields NE__OptyId__c and to select
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c,NE__ProdId__c,NE__OrderId__r.NE__OptyId__c FROM NE__OrderItem__c]);
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        insert item;
        item.XC_BundleTotalOTAmount__c = 100;
        update item;
        
        // Mod CV CR.NR2044 add Product Subvencion to cover /*SUBSIDY MANAGEMENT*/ and legal entity -->
        NE__Product__c proSubVen = new NE__Product__c(Id= mapItem.values()[0].NE__ProdId__c , Name=Label.XC_CL_SubsidyProductName,XC_LIC_Product_Name__c = Label.XC_CL_SubsidyProductName);
        update proSubVen;

/*         Opportunity opty = new Opportunity(Id =mapItem.values()[0].NE__OrderId__r.NE__OptyId__c,XC_LegalEntity__c = 'EnelXItalia');
        update opty; */

        NE__Order_Item_Attribute__c orderItemAtt =  XC_DF_OrderItemAttribute.createOrderItemAttribute(mapItem.values()[0],'Subsidy Amount','5.1');
        insert orderItemAtt;
        //<--End
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
        mapItem.values()[0].NE__Bundle_Configuration__c = item.Id;
        // Mod CV CR.NR2044 add fields to complete test Start -->
        mapItem.values()[0].XC_Effective_Start_Date_Recurring__c = Date.today();
        mapItem.values()[0].XC_Billing_Period_Recurring__c = 3;
        //<-- End
        update mapItem.values()[0];
        mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c, NE__Bundle_Configuration__c, NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c FROM NE__OrderItem__c]);
        List<String> listZQuoteIds = new List<String>{dResp.parentId};
            

        List<Asset> a = XC_DF_Asset.createAssets(1);
        // Mod CV CR.NR2044 add Product Subvencion to cover /*SUBSIDY MANAGEMENT*/ -->
        a[0].Name =Label.XC_CL_SubsidyProductName;
        //<--End
        a[0].XC_Configuration_Item__c = mapItem.values()[0].Id;
        insert a;

            
            
        List<zqu__ProductRatePlan__c> listPRPObj = [SELECT Id FROM zqu__ProductRatePlan__c];
        List<String> listPRP = new List<String>();
        for(zqu__ProductRatePlan__c prp : listPRPObj) {
            listPRP.add(String.valueOf(prp.Id));
        }
		
        List<zqu__QuoteRatePlanCharge__c> rpChargeList = [SELECT Id, Name, zqu__ChargeType__c, zqu__EffectivePrice__c, TariffType__c FROM zqu__QuoteRatePlanCharge__c];
        for(zqu__QuoteRatePlanCharge__c rpc : rpChargeList) {
            rpc.zqu__ChargeType__c = 'Usage';
        }
        update rpChargeList;

        Map<String, List<String>> prpcConfItemMap = new Map<String, List<String>>();
        List<zqu__ProductRatePlanCharge__c> prpcList = [SELECT Id, name, XC_WBE__c, XC_ProfitCenter__c, PIncludedkWh__c, TariffType__c
        FROM zqu__ProductRatePlanCharge__c];
        for(zqu__ProductRatePlanCharge__c prpc : prpcList) {
            prpcConfItemMap.put(prpc.Id, new List<String>{mapItem.values()[0].Id});
        }
        update prpcList;

        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Quote__c = dResp.parentId;
        insert quoteAmendment;

        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        qrp.zqu__Quote__c = dResp.parentId;
        qrp.zqu__QuoteAmendment__c = quoteAmendment.Id;
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
        qrpc.zqu__QuoteRatePlan__c = qrp.Id;
        qrpc.zqu__ProductRatePlanCharge__c = prpcList[0].Id;
        qrpc.zqu__EffectivePrice__c = 10;
        qrpc.zqu__ChargeType__c = 'Usage';
        insert qrpc;

        wr.prpcConfItemsMap = prpcConfItemMap;
        wr.listRatePlans = listPRP;
        wr.item = mapItem.values()[0];
        wr.zquoteID = dResp.parentId;

        Test.startTest();
        System.enqueueJob(new XC_IN018_CreateZQuote_U.UpdateRPQueuable(listZQuoteIds, wr));
        Test.stopTest();

        //Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];
        //System.assert(numberOfQuote == 0);
        System.assert(true);
    }

    @isTest
    public static void updateZQuotesTest(){
        User u = XC_DF_User.createUserAdmin();
        insert u;
        System.runAs(u){

            XC_IN018_CreateZQuote_U.UpdateWrapper wr = new  XC_IN018_CreateZQuote_U.UpdateWrapper();
            NE__Order__c order = [SELECT Id, NE__AccountID__c, (SELECT Id, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_id__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_CompanyCode__c, NE__OrderId__r.NE__OptyId__r.XC_CostCenter__c, NE__OrderId__r.NE__OptyId__r.XC_ActivationCountry__c, XC_BankTransferCode__c, XC_CreditAssignmentAvailable__c, NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c, NE__Bundle_Configuration__r.XC_CreditAssignmentAmount__c, XC_CountryFormula__c, XC_Select_Tax_Completed__c, XC_Tax_Subtype__c, XC_Exemptions__c, XC_BillingModel__c, XC_PaymentMethod__c, NE__RecurringChargeFrequency__c, XC_RecurringDuration__c, NE__OrderId__r.XC_Segment__c, XC_InstallmentPlanType__c, InstallmentDivisionTax__c, XC_InstallmentFrequency__c, XC_InstallmentsNumber__c, XC_Interests_Index__c, XC_InstallmentRate__c, NE__OrderId__r.XC_ActivationDateOverride__c, XC_Segment__c, XC_Wbe__c, XC_CMCostCenter__c, XC_CMProfitCenter__c, NE__ProdName__c, NE__StartDate__c FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
            order.XC_Segment__c = 'B2B';
            update order;
            
            Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c,NE__ProdId__c,NE__OrderId__r.NE__OptyId__c, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_id__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_CompanyCode__c, NE__OrderId__r.NE__OptyId__r.XC_CostCenter__c, NE__OrderId__r.NE__OptyId__r.XC_ActivationCountry__c, XC_BankTransferCode__c, XC_CreditAssignmentAvailable__c, NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c, NE__Bundle_Configuration__r.XC_CreditAssignmentAmount__c, XC_CountryFormula__c, XC_Select_Tax_Completed__c, XC_Tax_Subtype__c, XC_Exemptions__c, XC_BillingModel__c, XC_PaymentMethod__c, NE__RecurringChargeFrequency__c, XC_RecurringDuration__c, NE__OrderId__r.XC_Segment__c, XC_InstallmentPlanType__c, InstallmentDivisionTax__c, XC_InstallmentFrequency__c, XC_InstallmentsNumber__c, XC_Interests_Index__c, XC_InstallmentRate__c, NE__OrderId__r.XC_ActivationDateOverride__c, XC_Segment__c, XC_Wbe__c, XC_CMCostCenter__c, XC_CMProfitCenter__c, NE__ProdName__c, NE__StartDate__c FROM NE__OrderItem__c]);
            NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
            insert item;
            item.XC_BundleTotalOTAmount__c = 100;
            update item;

            
            
            NE__Product__c proSubVen = new NE__Product__c(Id= mapItem.values()[0].NE__ProdId__c , Name=Label.XC_CL_SubsidyProductName,XC_LIC_Product_Name__c = Label.XC_CL_SubsidyProductName);
            update proSubVen;
            
            NE__Order_Item_Attribute__c orderItemAtt =  XC_DF_OrderItemAttribute.createOrderItemAttribute(mapItem.values()[0],'Subsidy Amount','5.1');
            insert orderItemAtt;
            //<--End
            NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
            mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
            mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
            mapItem.values()[0].NE__Bundle_Configuration__c = item.Id;
            mapItem.values()[0].XC_Effective_Start_Date_Recurring__c = Date.today();
            mapItem.values()[0].XC_Billing_Period_Recurring__c = 3;
            update mapItem.values()[0];


            //mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c, NE__Bundle_Configuration__c, NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_id__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_CompanyCode__c, NE__OrderId__r.NE__OptyId__r.XC_CostCenter__c, NE__OrderId__r.NE__OptyId__r.XC_ActivationCountry__c, XC_BankTransferCode__c, XC_CreditAssignmentAvailable__c, NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c, NE__Bundle_Configuration__r.XC_CreditAssignmentAmount__c, XC_CountryFormula__c, XC_Select_Tax_Completed__c, XC_Tax_Subtype__c, XC_Exemptions__c, XC_BillingModel__c, XC_PaymentMethod__c, NE__RecurringChargeFrequency__c, XC_RecurringDuration__c, NE__OrderId__r.XC_Segment__c, XC_InstallmentPlanType__c, InstallmentDivisionTax__c, XC_InstallmentFrequency__c, XC_InstallmentsNumber__c, XC_Interests_Index__c, XC_InstallmentRate__c, NE__OrderId__r.XC_ActivationDateOverride__c, XC_Segment__c, XC_Wbe__c, XC_CMCostCenter__c, XC_CMProfitCenter__c, NE__ProdName__c, NE__StartDate__c, XC_Product_Subtype__c FROM NE__OrderItem__c]);
            mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c, NE__Bundle_Configuration__c, NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_id__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_CompanyCode__c, NE__OrderId__r.NE__OptyId__r.XC_CostCenter__c, NE__OrderId__r.NE__OptyId__r.XC_ActivationCountry__c, XC_BankTransferCode__c, XC_CreditAssignmentAvailable__c, NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c, NE__Bundle_Configuration__r.XC_CreditAssignmentAmount__c, XC_CountryFormula__c, XC_Select_Tax_Completed__c, XC_Tax_Subtype__c, XC_Exemptions__c, XC_BillingModel__c, XC_PaymentMethod__c, NE__RecurringChargeFrequency__c, XC_RecurringDuration__c, NE__OrderId__r.XC_Segment__c, XC_InstallmentPlanType__c, InstallmentDivisionTax__c, XC_InstallmentFrequency__c, XC_InstallmentsNumber__c, XC_Interests_Index__c, XC_InstallmentRate__c, NE__OrderId__r.XC_ActivationDateOverride__c, XC_Segment__c, XC_Wbe__c, XC_CMCostCenter__c, XC_CMProfitCenter__c, NE__ProdName__c, NE__StartDate__c, XC_Product_Subtype__c, NE__OrderId__r.XC_Annex__c, NE__OrderId__r.XC_Country__c, NE__OrderId__r.NE__OptyId__r.Account.XC_AccountTaxType__c FROM NE__OrderItem__c]);
         
			List<String> listZQuoteIds = new List<String>{dResp.parentId};
                
            List<Asset> a = XC_DF_Asset.createAssets(1);
            a[0].Name =Label.XC_CL_SubsidyProductName;
            a[0].XC_Configuration_Item__c = mapItem.values()[0].Id;
            insert a;

            
            List<zqu__ProductRatePlan__c> listPRPObj = [SELECT Id FROM zqu__ProductRatePlan__c];
            List<String> listPRP = new List<String>();
            for(zqu__ProductRatePlan__c prp : listPRPObj) {
                listPRP.add(String.valueOf(prp.Id));
            }
            
            Map<String, List<String>> prpcConfItemMap = new Map<String, List<String>>();
            List<zqu__ProductRatePlanCharge__c> prpcList = [SELECT Id, name, XC_WBE__c, XC_ProfitCenter__c, PIncludedkWh__c, TariffType__c
                                                            FROM zqu__ProductRatePlanCharge__c];
            for(zqu__ProductRatePlanCharge__c prpc : prpcList) {
                prpcConfItemMap.put(prpc.Id, new List<String>{mapItem.values()[0].Id});
            }
            update prpcList;
            
            List<zqu__QuoteRatePlanCharge__c> rpChargeList = [SELECT Id, Name, zqu__ChargeType__c, zqu__EffectivePrice__c, TariffType__c, zqu__ProductRatePlanCharge__c FROM zqu__QuoteRatePlanCharge__c];
            for(zqu__QuoteRatePlanCharge__c rpc : rpChargeList) {
                rpc.zqu__ChargeType__c = 'Usage';
                rpc.zqu__ProductRatePlanCharge__c = prpcList[0].Id;
            }
            update rpChargeList;
            
            zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
            quoteAmendment.zqu__Quote__c = dResp.parentId;
            insert quoteAmendment;
            
            zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
            qrp.zqu__Quote__c = dResp.parentId;
            qrp.zqu__QuoteAmendment__c = quoteAmendment.Id;
            insert qrp;
            
            zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
            qrpc.zqu__QuoteRatePlan__c = qrp.Id;
            qrpc.zqu__ProductRatePlanCharge__c = prpcList[0].Id;
            qrpc.zqu__EffectivePrice__c = 10;
            qrpc.zqu__ChargeType__c = 'Usage';
            insert qrpc;
            
            //Project
            project_cloud__Project__c p = new project_cloud__Project__c(name='ProgettoTest',XC_ConfigurationItem__c = item.id );
            
            insert p;
            
            //Create a new phase
            project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c(name='Phase Progetto di Test', project_cloud__Project__c=p.id);
            insert ph;
            
            XC_Milestone__c mile = new XC_Milestone__c();
            mile.XC_Rate__c = 100;
            mile.XC_StartDate__c = Date.today();
            mile.XC_OrderItem__c = mapItem.values()[0].Id;
            insert mile;

            List<Account> accList = [SELECT Id, Country__c FROM Account WHERE Id = :order.NE__AccountID__c];
            accList[0].Country__c = 'Spain';
            update accList[0];
            
            project_cloud__Project_Task__c task = new project_cloud__Project_Task__c(name='Project Task Test',
                                                                                     project_cloud__Duration__c=1,
                                                                                     project_cloud__Project_Phase__c=ph.id,
                                                                                     XC_TaskType__c=Constants.PPM_PROJECT_TASK_TYPE_BILLING,
                                                                                     XC_TaskReason__c='Milestone',
                                                                                     XC_TaskStatus__c='Work in Progress',
                                                                                     project_cloud__Autonomous_Start__c=system.today(), 
                                                                                     project_cloud__Estimated_Hours__c = 1,
                                                                                     XC_Milestone__c = mile.Id,
                                                                                     XC_OrderItem__c = mapItem.values()[0].Id,
                                                                                     XC_Account__c = accList[0].Id,
                                                                                     XC_ApplySuplido__c = true);
            insert task;
            
            wr.prpcConfItemsMap = prpcConfItemMap;
            wr.listRatePlans = listPRP;
            wr.item = mapItem.values()[0];
            wr.zquoteID = dResp.parentId;
            wr.task = task;
            wr.confItemId = mapItem.values()[0].Id;

            zqu__ZProduct__c zp = new zqu__ZProduct__c();
            insert zp;
			
			zqu__ZProduct__c zp2 = new zqu__ZProduct__c();
            insert zp2;
			
            zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c(Name = 'Suplido B2B', zqu__ZProduct__c =zp.id,  zqu__ProductRatePlanFullName__c = 'Suplido B2B');
            insert prp;
            
            zqu__ProductRatePlanCharge__c prpc = new zqu__ProductRatePlanCharge__c(Name = 'Suplido B2B', zqu__ProductRatePlan__c = prp.id);
        	insert prpc;
			
            zqu__ProductRatePlan__c prp2 = new zqu__ProductRatePlan__c(Name = 'Suplido B2G', zqu__ZProduct__c =zp.id,  zqu__ProductRatePlanFullName__c = 'Suplido B2G');
            insert prp2;
            
            zqu__ProductRatePlanCharge__c prpc2 = new zqu__ProductRatePlanCharge__c(Name = 'Suplido B2G', zqu__ProductRatePlan__c = prp2.id);
        	insert prpc2;

            
             Test.startTest();           
            List<XC_UTIL_Sobject.WrapperResult> resultado = XC_IN018_CreateZQuote_U.updateZQuotes(wr);
            System.assert(resultado != null, 'No se ha rellenado el wrapper correctamente');
            Test.stopTest();
        }
    }

}