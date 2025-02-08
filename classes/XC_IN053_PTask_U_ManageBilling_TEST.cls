/**
* @author dpalamides
* @description Test of the invocable class that creates the zQuote in the relative provisioning step
*/


@isTest
public class XC_IN053_PTask_U_ManageBilling_TEST {

    @testSetup
    private static void setup() {

        /* This method creates and inserts too the order */
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);
		order.XC_Segment__c = 'B2B';
        order.XC_Country__c = 'Italy';
        order.XC_LegalEntity__c = 'EnelXItalia';
        order.XC_CallType__c ='Inbound Call';
        update order;

        XC_CS_UtilityGlobalValues__c csInsertDML = new XC_CS_UtilityGlobalValues__c();
        csInsertDML.Name = 'InsertLogsGenerateWO';
        csInsertDML.Value__c = 'true';
        insert csInsertDML;
        XC_CS_UtilityGlobalValues__c csInsertDML1 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML1.Name = 'InsertLogsGenerateWO_OK';
        csInsertDML1.Value__c = 'true';
        insert csInsertDML1;
        
        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];
		
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        insert ps;

        B2WExtCat__Work_Order_Item__c workOrderItem = XC_DF_RatePlan.createJunctionProductRatePlanToItem(order, order.NE__Order_Items__r[0]);
        insert workOrderItem;

        B2WZC__Bit2WinConnector__c b2wConnector = new B2WZC__Bit2WinConnector__c(Name = 'ZuoraConnector', B2WZC__isActiveConnector__c = true);
        insert b2wConnector;
        
        String orgId = UserInfo.getOrganizationId();
        List<XC_CM_ZuoraOAuth__mdt> zuoraList = [SELECT Id, XC_EntityId__c, XC_EntityName__c FROM XC_CM_ZuoraOAuth__mdt WHERE (XC_EntityName__c LIKE '%Italy%' OR XC_EntityName__c LIKE '%Spain%')  AND XC_OrgId__c =: orgId];
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

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntityList[0]);

        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id];

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        item.NE__BaseOneTimeFee__c = 89;

        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id
        FROM XC_BillingProfileLineItem__c
        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        if( listBillingProfiles[0].NE__Payment__c == null || listBillingProfiles[0].NE__Payment__c == ''){
            listBillingProfiles[0].NE__Payment__c = 'Bank Transfer';
            item.XC_BillingModel__c = 'One Shot';
            item.XC_PaymentMethod__c = 'Bank Transfer';
            update listBillingProfiles[0];
        }
        if( item.XC_PaymentMethod__c == null || item.XC_PaymentMethod__c == ''){
            item.XC_BillingModel__c = 'One Shot';
            item.XC_PaymentMethod__c = 'Bank Transfer';
        }

        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        item.XC_Billing_Period_Recurring__c = 1;
        item.XC_Effective_Start_Date_Recurring__c = Date.today();
        item.XC_CMCostCenter__c = 'AAA';
        item.XC_CMProfitCenter__c = 'AAA';
        item.XC_ProductServiceType__c = 'AAA';
        item.XC_ProductLine__c = 'AAA';
        item.XC_Wbe__c = 'AAA';
        update item;

        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item,
                Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel,
                'Payment');
        insert attr;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        listAsset[0].XC_Configuration_Item__c = item.Id;
        insert listAsset;
        
        
        XC_Milestone__c mile = new XC_Milestone__c();
        mile.XC_Rate__c = 100;
         mile.XC_StartDate__c = Date.today();
         mile.XC_OrderItem__c = item.Id;
        insert mile;
        
        
        //Project
		project_cloud__Project__c p = new project_cloud__Project__c(name='ProgettoTest',XC_ConfigurationItem__c = item.id );
				
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
		    	                                                                  XC_TaskStatus__c='Work in Progress',//'New',
		    	                                                                  project_cloud__Autonomous_Start__c=system.today(), 
                                                                             	  project_cloud__Estimated_Hours__c = 1,
                                                                             	  XC_Milestone__c = mile.Id,
                                                                             	  XC_OrderItem__c = item.id
		    	                                                                  );
		    insert pt;
            pt.XC_Account__r.Country__c = 'Spain' ;
            update pt;
			/*pt.XC_TaskStatus__c = 'Planned';
        	update pt;
		    pt.XC_TaskStatus__c = 'Work in Progress';
        	update pt;*/

    }

    @isTest
    private static void createZQuoteExternalTEST() {

        project_cloud__Project_Task__c ps = [SELECT Id, XC_Milestone__r.XC_OrderItem__c, XC_Milestone__r.XC_OrderItem__r.NE__OrderId__c
        FROM project_cloud__Project_Task__c
        LIMIT 1];

        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
        FROM NE__OrderItem__c
        LIMIT 1];
        List<XC_IN053_Project_Task_U_ManageBilling.InputWrapper> listWrapperExternal = new List<XC_IN053_Project_Task_U_ManageBilling.InputWrapper>();
        XC_IN053_Project_Task_U_ManageBilling.InputWrapper wr = new XC_IN053_Project_Task_U_ManageBilling.InputWrapper();
        wr.taskId = ps.Id;
        wr.generateInvoice = true;
        wr.separateInvoice = false;
        //wr.configurationItemId = item.Id;
        listWrapperExternal.add(wr);

        Test.startTest();
        XC_IN053_Project_Task_U_ManageBilling.createZquote(listWrapperExternal);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        //System.assert(numberOfQuote == 0);

    }

    @isTest
    private static void createZQuoteTEST() {

         project_cloud__Project_Task__c ps = [SELECT Id, XC_Milestone__r.XC_OrderItem__c, XC_Milestone__r.XC_OrderItem__r.NE__OrderId__c
        FROM project_cloud__Project_Task__c
        LIMIT 1];
        
        List<XC_IN053_Project_Task_U_ManageBilling.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
        FROM NE__OrderItem__c
        LIMIT 1];

        Test.startTest();
        XC_IN053_Project_Task_U_ManageBilling.createZquote(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        //System.assert(numberOfQuote == 0);

    }

    @isTest
    private static void createZQuoteTEST2() {

        project_cloud__Project_Task__c ps = [SELECT Id, XC_Milestone__r.XC_OrderItem__c, XC_Milestone__r.XC_OrderItem__r.NE__OrderId__c
        FROM project_cloud__Project_Task__c
        LIMIT 1];

        List<XC_IN053_Project_Task_U_ManageBilling.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c, XC_BillingModel__c, XC_BillingProfileLineItem__c
        FROM NE__OrderItem__c
        LIMIT 1];
        item.XC_BillingModel__c = 'Usage';
        item.XC_BillingProfileLineItem__c = null;
        update item;

        Test.startTest();
        XC_IN053_Project_Task_U_ManageBilling.createZquote(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        //System.assert(numberOfQuote == 0);

    }

    @isTest
    private static void createZQuoteTEST3() {

        XC_IN018_CreateZQuote_U.UpdateWrapper wr = new  XC_IN018_CreateZQuote_U.UpdateWrapper();
        NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c, XC_Billing_Period_Recurring__c FROM NE__OrderItem__c]);
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
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
        ////System.assert(numberOfQuote == 0);
        //System.assert(true);
    }

    @isTest
    private static void createZQuoteTEST4() {

        XC_IN018_CreateZQuote_U.UpdateWrapper wr = new  XC_IN018_CreateZQuote_U.UpdateWrapper();
        NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_ZQuoteId__c FROM NE__OrderItem__c]);
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
        mapItem.values()[0].XC_ZQuoteId__c = dResp.parentId;
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
        ////System.assert(numberOfQuote == 0);
        //System.assert(true);
    }
    
    @isTest
    private static void createZQuoteTEST5() {

        XC_CS_UtilityGlobalValues__c a = new XC_CS_UtilityGlobalValues__c();
        a.Name = 'CheckBlankValuesWBE';
        a.Value__c = 'true';
        insert a;

        project_cloud__Project_Task__c ps = [SELECT Id, XC_Milestone__r.XC_OrderItem__c, XC_Milestone__r.XC_OrderItem__r.NE__OrderId__c
        FROM project_cloud__Project_Task__c
        LIMIT 1];

        List<XC_IN053_Project_Task_U_ManageBilling.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c, XC_BillingModel__c, XC_BillingProfileLineItem__c
        FROM NE__OrderItem__c
        LIMIT 1];
        item.XC_BillingModel__c = 'Usage';
        item.XC_BillingProfileLineItem__c = null;
        item.XC_CMCostCenter__c = null;
        item.XC_CMProfitCenter__c = null;
        item.XC_ProductServiceType__c = null;
        item.XC_ProductLine__c = null;
        item.XC_Wbe__c = null;
        update item;

        Test.startTest();
        XC_IN053_Project_Task_U_ManageBilling.createZquote(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        //System.assert(numberOfQuote == 0);

    }
    
    @isTest
    private static void createZQuoteTEST6() {
        
        XC_CS_UtilityGlobalValues__c b = new XC_CS_UtilityGlobalValues__c();
        b.Name = 'CheckWBETracking';
        b.Value__c = 'true';
        insert b;

        project_cloud__Project_Task__c ps = [SELECT Id, XC_Milestone__r.XC_OrderItem__c, XC_Milestone__r.XC_OrderItem__r.NE__OrderId__c
        FROM project_cloud__Project_Task__c
        LIMIT 1];

        List<XC_IN053_Project_Task_U_ManageBilling.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c, XC_BillingModel__c, XC_BillingProfileLineItem__c
        FROM NE__OrderItem__c
        LIMIT 1];
        item.XC_BillingModel__c = 'Usage';
        item.XC_BillingProfileLineItem__c = null;
        update item;

        Test.startTest();
        XC_IN053_Project_Task_U_ManageBilling.createZquote(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT Count() FROM zqu__Quote__c WHERE Id = :item.XC_ZQuoteId__c];

        //System.assert(numberOfQuote == 0);

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

        //System.assert([SELECT COUNT() FROM NE__OrderItem__c WHERE Id = :item.Id] == 1);
    }

    private static List<XC_IN053_Project_Task_U_ManageBilling.InputWrapper> generateInputWrapper(project_cloud__Project_Task__c ps) {

        List<XC_IN053_Project_Task_U_ManageBilling.InputWrapper> listWrapperInput = new List<XC_IN053_Project_Task_U_ManageBilling.InputWrapper>();
        XC_IN053_Project_Task_U_ManageBilling.InputWrapper wr = new XC_IN053_Project_Task_U_ManageBilling.InputWrapper();
        wr.taskId = ps.Id;
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

        //System.assert(true);
    }


    @isTest
    private static void generateErrorForNoRatePlanTEST() {

        List<NE__OrderItem__c> itemsList = [SELECT Id FROM NE__OrderItem__c];
        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(itemsList[0].Id);
        step.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateSubscription_Flow;
        insert step;

        Test.startTest();
        //XC_IN053_Project_Task_U_ManageBilling.generateErrorForNoRatePlan(new List<String>{itemsList[0].Id});
        Test.stopTest();

        //System.assert(true);
    }

    @isTest
    private static void replacePaymentMethod1() {

        zqu__Quote__c z = new zqu__Quote__c();
        z.zqu__PaymentMethod__c = 'Credit Card SIA';

        Test.startTest();
        XC_IN018_CreateZQuote_UU.replacePaymentMethod(z);
        Test.stopTest();

        //System.assert(true, z != null);
    }

    @isTest
    private static void replacePaymentMethod2() {

        zqu__Quote__c z = new zqu__Quote__c();
        z.zqu__PaymentMethod__c = 'Commodity Bill';

        Test.startTest();
        XC_IN018_CreateZQuote_UU.replacePaymentMethod(z);
        Test.stopTest();

        //System.assert(true, z != null);
    }

    @isTest
    private static void replacePaymentMethod3() {

        zqu__Quote__c z = new zqu__Quote__c();
        z.zqu__PaymentMethod__c = 'Direct Debt';

        Test.startTest();
        XC_IN018_CreateZQuote_UU.replacePaymentMethod(z);
        Test.stopTest();

        //System.assert(true, z != null);
    }

    @isTest
    private static void getTecnicalProductTEST() {
        List<NE__OrderItem__c> oiList;
        Test.startTest();
        oiList = XC_IN018_CreateZQuote_D.retrieveTecnicalProductConfItems([SELECT Id FROM NE__Order__c LIMIT 1][0].Id);
        Test.stopTest();

        //System.assert(true, oiList != null);
    }

    @isTest
    private static void manageDiscountPercentageTEST() {
        zqu__QuoteRatePlanCharge__c rpc = new zqu__QuoteRatePlanCharge__c();
        rpc.zqu__Model__c = 'Discount-Percentage';

        List <NE__Order_Item_Discount__c> discounts = new List <NE__Order_Item_Discount__c>();
        NE__Order_Item_Discount__c discount = new NE__Order_Item_Discount__c();
        discount.NE__Type__c = 'Value';
        discount.NE__One_Time_Percentage__c = 10;
        discount.NE__Start_Date__c = Date.Today();
        discount.NE__End_Date__c = Date.Today();
        discounts.add(discount);

        Test.startTest();
        XC_IN018_CreateZQuote_UU.manageOrderItemDiscountsCharges(rpc, discounts, new Map<String,Object>());
        Test.stopTest();

        //System.assert(true, discounts != null);
    }

    //@isTest
    private static void manageDiscountFixedTEST() {
        zqu__QuoteRatePlanCharge__c rpc = new zqu__QuoteRatePlanCharge__c();
        rpc.zqu__Model__c = 'Discount-Fixed Amount';

        List <NE__Order_Item_Discount__c> discounts = new List <NE__Order_Item_Discount__c>();
        NE__Order_Item_Discount__c discount = new NE__Order_Item_Discount__c();
        discount.NE__Type__c = 'Value';
        discount.NE__One_Time_Value__c = 10;
        discount.NE__Start_Date__c = Date.Today();
        discount.NE__End_Date__c = Date.Today();
        discounts.add(discount);

        Test.startTest();
        XC_IN018_CreateZQuote_UU.manageOrderItemDiscountsCharges(rpc, discounts, new Map<String,Object>());
        Test.stopTest();

        //System.assert(true, discounts != null);
    }
    
    @isTest
    private static void getTranscodingMapToZuoraTEST() {
        XC_UTIL_CreateZQuotePPM.getRecurringPeriodTranscodingMapToZuora();
    }

    //@isTest
    private static void manageDiscountFixedTEST2() {
        zqu__QuoteRatePlanCharge__c rpc = new zqu__QuoteRatePlanCharge__c();
        rpc.zqu__Model__c = 'Discount-Percentage';

        List <NE__Order_Item_Discount__c> discounts = new List <NE__Order_Item_Discount__c>();
        NE__Order_Item_Discount__c discount = new NE__Order_Item_Discount__c();
        discount.NE__Type__c = 'Percentage';
        discount.NE__One_Time_Value__c = 10;
        discount.NE__Start_Date__c = Date.Today();
        discount.NE__End_Date__c = Date.Today();
        discounts.add(discount);

        Test.startTest();
        XC_IN018_CreateZQuote_UU.manageOrderItemDiscountsCharges(rpc, discounts, new Map<String,Object>());
        Test.stopTest();

        //System.assert(true, discounts != null);
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
        XC_IN018_CreateZQuote_U.updateRatePlanCharge(mapUtil);
        Test.stopTest();

        //System.assert(true, mapUtil.get('confItemMalfunction') != null);
    }
    
    @isTest
    private static void checkValueForMillestonTest() {
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        insert oppList;
        
        oppList[0].XC_Segment__c = 'B2G';
        oppList[0].XC_LegalEntity__c = 'EnelSole';
        oppList[0].RecordTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Italy').getRecordTypeId();
        update oppList;
        
         NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) ,RecordTypeId, NE__OptyId__c, NE__OptyId__r.XC_LegalEntity__c,XC_Segment__c,XC_LegalEntity__c,XC_Status__c  FROM NE__Order__c LIMIT 1];
         order.XC_LegalEntity__c = 'EnelSole';
         order.NE__OptyId__c = oppList[0].Id ;
         update order ;
        
          XC_CS_UtilityGlobalValues__c b = new XC_CS_UtilityGlobalValues__c();
        b.Name = 'CheckWBETracking';
        b.Value__c = 'true';
        insert b;

        project_cloud__Project_Task__c ps = [SELECT Id, XC_Milestone__r.XC_OrderItem__c, XC_Milestone__r.XC_OrderItem__r.NE__OrderId__c
        FROM project_cloud__Project_Task__c
        LIMIT 1];

        List<XC_IN053_Project_Task_U_ManageBilling.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c, XC_BillingModel__c, XC_BillingProfileLineItem__c
        FROM NE__OrderItem__c
        LIMIT 1];
        item.XC_BillingModel__c = 'Usage';
        item.XC_BillingProfileLineItem__c = null;
        update item;

        Test.startTest();
        XC_IN053_Project_Task_U_ManageBilling.createZquote(listInputWrapper);
        Test.stopTest();

       
        /* NE__OrderItem__c OrdItem = [SELECT Id, XC_ZQuoteId__c, XC_BillingModel__c, XC_PaymentMethod__c, XC_BillingProfileLineItem__c, NE__OneTimeFeeOv__c, NE__BaseOneTimeFee__c FROM NE__OrderItem__c limit 1];
         Map<String, Object> mapResult = new Map<String, Object>();
         Map<String, Object> output = new Map<String, Object>();
        
        Test.startTest();
        //output = XC_UTIL_CreateZQuotePPM.checkValueForMilleston(OrdItem,mapResult);  
        Test.stopTest(); */
    }

     //vaibhav.c.anand@accenture.com
    @isTest
    private static void retrieveRelatedProductConfItemsTEST() {

        List<NE__OrderItem__c> itemsList = [SELECT Id,NE__Item_Code__c,NE__OrderId__c,XC_Product_Type__c,XC_Product_Subtype__c,CurrencyIsoCode FROM NE__OrderItem__c];
        List<NE__OrderItem__c> bundleItemsList = XC_DF_OrderItem.createOrderItems(1);
        bundleItemsList[0].NE__Bundle_Configuration__c = itemsList[0].Id;
        insert bundleItemsList;

        Test.startTest();
        List<NE__OrderItem__c> orderItemList = XC_IN018_CreateZQuote_D.retrieveRelatedProductConfItems(itemsList[0]);
        List<NE__OrderItem__c> orderItemList2 = XC_IN018_CreateZQuote_D.retrieveConfItemsForSpareParts(itemsList[0].Id, 'test', 'test');
        Test.stopTest();

    }

    @isTest
    private static void updateRatePlanChargePreviewTest() {
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
        XC_IN018_CreateZQuote_U.updateRatePlanChargePreview(mapUtil);
        Test.stopTest();

        //System.assert(true, mapUtil.get('confItemMalfunction') != null);
    }
}