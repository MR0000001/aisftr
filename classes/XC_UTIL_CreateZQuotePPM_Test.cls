/**
* The Test Class for XC_UTIL_CreateZQuotePPM.
*
* @author alag - alag@deloitte.es
* @date Creation 18/02/2022
*/
@isTest
public class XC_UTIL_CreateZQuotePPM_Test {
    @testSetup
    public static void setup(){
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);
        
        order.XC_Segment__c = 'B2B';
        order.XC_Country__c = 'Spain';
        order.XC_LegalEntity__c = 'EnelSole';
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
        
        XC_CS_UtilityGlobalValues__c csInsertDML2 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML2.Name = 'CheckBlankValuesWBE';
        csInsertDML2.Value__c = 'true';
        insert csInsertDML2;
        
        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];
        
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
        //XC_CM_ZuoraOAuth__mdt z = zuoraList[0];
        for(XC_CM_ZuoraOAuth__mdt z : zuoraList){
            zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
            billingEntity.Name = z.XC_EntityName__c +''+ i;
            billingEntity.zqu__EntityID__c = z.XC_EntityId__c;
            billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50' + i;
            billingEntity.zqu__ZuoraID__c = '2000378' + i;
            billingEntity.zqu__EntityName__c = z.XC_EntityName__c +''+ i;
            if(!entityIds.contains(billingEntity.zqu__EntityID__c)){
                billingEntityList.add(billingEntity);
            }
            entityIds.add(billingEntity.zqu__EntityID__c);
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
        //pt.XC_Account__c = accList[0].Id;
        //pt.XC_Account__r.Country__c = 'Spain' ;
        //update pt;
    }
    
    @isTest
    public static void manageCreationZquoteTest(){
        XC_UTIL_CreateZQuotePPM.ManageCreationWrapper wr = new XC_UTIL_CreateZQuotePPM.ManageCreationWrapper();
        NE__OrderItem__c orderItem = [SELECT Id, NE__OrderId__c, XC_ProductLine__c, XC_ProductServiceType__c FROM NE__OrderItem__c LIMIT 1];
        project_cloud__Project_Task__c task = [SELECT Id, XC_Project_ID__c, XC_RecurringDuration__c, XC_TaskReason__c FROM project_cloud__Project_Task__c LIMIT 1];
        
        wr.confItemId = orderItem.Id;
        wr.task = task;
        
        List<XC_UTIL_CreateZQuotePPM.MilestoneWrapper> inputWrapperList = new List<XC_UTIL_CreateZQuotePPM.MilestoneWrapper>();
        XC_UTIL_CreateZQuotePPM.MilestoneWrapper inputWrapper = new XC_UTIL_CreateZQuotePPM.MilestoneWrapper();
        
        inputWrapper.item = orderItem;
        inputWrapper.configurationItemId = orderItem.Id;
        inputWrapper.task = task;
        
        inputWrapperList.add(inputWrapper);
        
        Test.startTest();
        XC_UTIL_CreateZQuotePPM.createZquote(inputWrapperList);
        Test.stopTest();
    }
    
    @isTest
    public static void manageCreationZquoteTest2(){
        XC_CS_UtilityGlobalValues__c csInsertDML3 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML3.Name = 'CheckWBETracking';
        csInsertDML3.Value__c = 'true';
        insert csInsertDML3;
        
        NE__Order__c order = [SELECT Id, NE__OptyId__c FROM NE__Order__c LIMIT 1];
        
        XC_UTIL_CreateZQuotePPM.ManageCreationWrapper wr = new XC_UTIL_CreateZQuotePPM.ManageCreationWrapper();
        NE__OrderItem__c orderItem = [SELECT Id, NE__OrderId__c, XC_ProductLine__c, XC_ProductServiceType__c FROM NE__OrderItem__c LIMIT 1];
        project_cloud__Project_Task__c task = [SELECT Id, XC_Project_ID__c, XC_RecurringDuration__c FROM project_cloud__Project_Task__c LIMIT 1];
        
        wr.confItemId = orderItem.Id;
        wr.task = task;
        
        Opportunity opp = [SELECT Id, XC_LegalEntity__c FROM Opportunity WHERE Id=:order.NE__OptyId__c LIMIT 1];
        opp.XC_LegalEntity__c = 'EnelSole';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_BP_Italy').getRecordTypeId();
        opp.XC_Segment__c = 'B2B';
        update opp;
        
        orderItem.XC_CMCostCenter__c = '';
		orderItem.XC_CMProfitCenter__c = '';
        orderItem.XC_ProductServiceType__c = '';
        orderItem.XC_ProductLine__c = '';
        orderItem.XC_Wbe__c = '';
        update orderItem;
        
        List<XC_UTIL_CreateZQuotePPM.MilestoneWrapper> inputWrapperList = new List<XC_UTIL_CreateZQuotePPM.MilestoneWrapper>();
        XC_UTIL_CreateZQuotePPM.MilestoneWrapper inputWrapper = new XC_UTIL_CreateZQuotePPM.MilestoneWrapper();
        
        inputWrapper.item = orderItem;
        inputWrapper.configurationItemId = orderItem.Id;
        inputWrapper.task = task;
        
        inputWrapperList.add(inputWrapper);
        
        Test.startTest();
        XC_UTIL_CreateZQuotePPM.createZquote(inputWrapperList);
        Test.stopTest();
    }
    
    @isTest
    public static void manageCreationZquoteTest3(){
        XC_CS_UtilityGlobalValues__c csInsertDML3 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML3.Name = 'CheckWBETracking';
        csInsertDML3.Value__c = 'true';
        insert csInsertDML3;
        
        XC_UTIL_CreateZQuotePPM.ManageCreationWrapper wr = new XC_UTIL_CreateZQuotePPM.ManageCreationWrapper();
        NE__OrderItem__c orderItem = [SELECT Id, NE__OrderId__c, XC_ProductLine__c, XC_ProductServiceType__c FROM NE__OrderItem__c LIMIT 1];
        project_cloud__Project_Task__c task = [SELECT Id, XC_Project_ID__c, XC_RecurringDuration__c FROM project_cloud__Project_Task__c LIMIT 1];
        
        wr.confItemId = orderItem.Id;
        wr.task = task;
        
        List<XC_UTIL_CreateZQuotePPM.MilestoneWrapper> inputWrapperList = new List<XC_UTIL_CreateZQuotePPM.MilestoneWrapper>();
        XC_UTIL_CreateZQuotePPM.MilestoneWrapper inputWrapper = new XC_UTIL_CreateZQuotePPM.MilestoneWrapper();
        
        inputWrapper.item = orderItem;
        inputWrapper.configurationItemId = orderItem.Id;
        inputWrapper.task = task;
        
        inputWrapperList.add(inputWrapper);
        
        Test.startTest();
        XC_UTIL_CreateZQuotePPM.createZquote(inputWrapperList);
        Test.stopTest();
    }
}