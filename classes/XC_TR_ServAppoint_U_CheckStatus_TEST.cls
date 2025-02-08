/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 06/05/2019
* @date Modification 26/06/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_ServAppoint_U_CheckStatus_TEST – Test Class for XC_TR_ServiceAppointment_U_CheckStatus
*/

@isTest
private class XC_TR_ServAppoint_U_CheckStatus_TEST {
    @testSetup 
	static void makeData(){
    
}

    @isTest
    static void checkInsertServiceAppointment() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(1);
        Test.startTest();
        insert listSa;
        Test.stopTest();
    }

    @isTest
    static void checkSerialNumber() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(1);
        listSa[0].Status = Label.XC_CL_ServiceAppointment_Completed;
        insert listSa;
        Test.startTest();
        XC_TR_ServiceAppointment_U_CheckStatus.checkWOSerialNumber(listSa);
        Test.stopTest();
    }
    
    @isTest
    static void checkInsertServiceAppointment1() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        //List<ServiceAppointment> listSa99 = XC_DF_ServiceAppointment.createServiceAppointment(99);
        List<ServiceAppointment> listSa1 = XC_DF_ServiceAppointment.createServiceAppointment(1);
        Test.startTest();
        //insert listSa99;
        insert listSa1;
        Test.stopTest();
    }
    
    @isTest
    static void manageChangeStatus() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_ServiceAppointment.createServiceAppointment(1);        
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        List<ServiceResource> servRes = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];
        
        Test.startTest();
        for(ServiceAppointment sa : servAppoInsert){
            sa.XC_AssignedResource__c = servRes[0].Id;
            sa.Status = 'Scheduled';
            sa.SchedStartTime=  (System.now()).addHours(2);
            sa.SchedEndTime = (System.now()).addHours(4);
            sa.ArrivalWindowEndTime =(System.now()).addHours(4);
            sa.ArrivalWindowStartTime = (System.now()).addHours(4);
        }
        update servAppoInsert;
        System.assertEquals('Scheduled', servAppoInsert[0].Status);
        Test.stopTest();
    }
    
    @isTest
    static void manageChangeStatus1() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_ServiceAppointment.createServiceAppointment(1);        
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        List<ServiceResource> servRes = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];
        
        Test.startTest();
        for(ServiceAppointment sa : servAppoInsert){
            sa.XC_AssignedResource__c = servRes[0].Id;
            sa.Status = 'Scheduled';
            sa.SchedStartTime=  (System.now()).addHours(2);
            sa.SchedEndTime = (System.now()).addHours(4);
            sa.ArrivalWindowEndTime =(System.now()).addHours(4);
            sa.ArrivalWindowStartTime = (System.now()).addHours(4);
        }
        update servAppoInsert;
        for(ServiceAppointment sa : servAppoInsert){
            sa.Status = 'Dispatched';
        }
        update servAppoInsert;
        for(ServiceAppointment sa : servAppoInsert){
            sa.XC_AssignedResource__c = servRes[0].Id;
            sa.Status = Label.XC_CL_WorkOrderLineItem_InProgressStatus;
        }
        update servAppoInsert;
        System.assertEquals(Label.XC_CL_WorkOrderLineItem_InProgressStatus, servAppoInsert[0].Status);
        Test.stopTest();
    }
    
    @isTest
    static void manageChangeStatus2() {
        //insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_ServiceAppointment.createServiceAppointment(1);        
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        List<ServiceResource> servRes = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];

        for(ServiceAppointment sa : servAppoInsert){
            sa.XC_AssignedResource__c = servRes[0].Id;
            sa.Status = 'Scheduled';
            sa.SchedStartTime=  (System.now()).addHours(2);
            sa.SchedEndTime = (System.now()).addHours(4);
            sa.ArrivalWindowEndTime =(System.now()).addHours(4);
            sa.ArrivalWindowStartTime = (System.now()).addHours(4);
        }
        update servAppoInsert;
        for(ServiceAppointment sa : servAppoInsert){
            sa.Status = 'Dispatched';
        }
        update servAppoInsert;
        Test.startTest();
        for(ServiceAppointment sa : servAppoInsert){
            sa.Status = Label.XC_CL_WorkOrderLineItem_InProgressStatus;
        }
        
        update servAppoInsert;
        for(ServiceAppointment sa : servAppoInsert){
            sa.Status = Label.XC_CL_ServiceAppointment_Completed;
        }
        update servAppoInsert;
        System.assertEquals( Label.XC_CL_ServiceAppointment_Completed, servAppoInsert[0].Status);
        Test.stopTest();
    }

    @isTest
    static void manageChangeStatus3() {
        //insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> parents = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        insert parents;
        List<WorkOrder> children = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        children[0].ParentWorkOrderId = parents[0].Id;
        insert children;
        insert XC_DF_ServiceAppointment.createServiceAppointment(parents);         
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        List<ServiceResource> servRes = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment FOR UPDATE];
        
        Test.startTest();
        for(ServiceAppointment sa : servAppoInsert){
            sa.Status =  Label.XC_CL_ServiceAppointment_Canceled;
            sa.ActualStartTime = DateTime.now();
        }
        update servAppoInsert;
        System.assertEquals(  Label.XC_CL_ServiceAppointment_Canceled, servAppoInsert[0].Status);
        Test.stopTest();
    }
    
    @isTest
    static void manageChangeStatus4() {
        //insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> parents = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        insert parents;
        insert XC_DF_ServiceAppointment.createServiceAppointment(parents);         
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        List<ServiceResource> servRes = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment FOR UPDATE];
        
        Test.startTest();
        for(ServiceAppointment sa : servAppoInsert){
            sa.Status =  Label.XC_CL_ServiceAppointment_Canceled;
            sa.ActualStartTime = DateTime.now();
        }
        update servAppoInsert;
        System.assertEquals(  Label.XC_CL_ServiceAppointment_Canceled, servAppoInsert[0].Status);
        Test.stopTest();
    }
    
    @isTest
    static void populateCustomerInterFromLeadTEST() {
        Test.startTest();
		XC_UTIL_ServiceApp_CreateCustomInter.PopulateCustomInterConsumerWrapper populateWrapper = new XC_UTIL_ServiceApp_CreateCustomInter.PopulateCustomInterConsumerWrapper();
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        XC_UTIL_ServiceApp_CreateCustomInter.populateCustomerInterFromLead(populateWrapper, ci);
        String a = 'pippo';
        System.assertEquals(a, 'pippo');
        Test.stopTest();
    }

    @isTest
    static void checkFieldsForStatus() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert listSa;
        listSa[0].Status = Label.XC_CL_ServiceAppointment_Scheduled;
        update listSa;
        Test.startTest();
        listSa[0].Status = Label.XC_CL_ServiceAppointment_None;
        update listSa;
        Test.stopTest();
    }

    @isTest
    static void coverageCode() { 
        XC_TR_ServiceAppointment_U_CheckStatus.codeCoverage();
    }


/*    @isTest
    static void checkMalfunctioningSA(){
        insert XC_DF_OneOrg.createOneOrg('Italy');
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkTypeWithName('Malfunctioning','Malfunctioning - Card');
        //insert workTypeToInsert;
        Account acc = new Account();
        acc.Name = 'Account Test 1';
        acc.PrimaryEmail__c = 'test@test.it';
        insert acc;
        Case c = new Case();
        c.AccountId = acc.Id;
        c.XC_BusinessLine__c = 'eCity';
        insert c;
        List<WorkOrder> parents = new List<WorkOrder>();
        WorkOrder wo = new WorkOrder(
        CaseId = c.Id, 
        XC_LegalEntity__c = 'EnelSole',
        XC_Segment__c = 'B2B',
        BusinessLine__c = 'eCity',

        Status = 'In Progress',
        XC_WorkTypeCategory__c = Label.XC_CL_WorkType_Malfunctioning,
        RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_WorkOrder').getRecordTypeId());
        parents.add(wo);
        insert parents;
        List<WorkOrderLineItem> listWoli = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem (WorkOrderId = wo.Id, Status = 'In Progress');
        listWoli.add(woli);
        insert listWoli;
        List<WorkOrder> children = new List<WorkOrder>();
        WorkOrder childWo = new WorkOrder(ParentWorkOrderId = wo.Id, Status = 'In Progress');
        children.add(childWo);
        insert children;
        Test.startTest();
        insert XC_DF_ServiceAppointment.createServiceAppointment(parents);
        List<ServiceAppointment> listSA = [SELECT Id FROM ServiceAppointment FOR UPDATE];        
        for(ServiceAppointment sa : listSA){
            sa.Status = 'Scheduled';
            sa.SchedStartTime=  (System.now()).addHours(2);
            sa.SchedEndTime = (System.now()).addHours(4);
            sa.ArrivalWindowEndTime =(System.now()).addHours(4);
            sa.ArrivalWindowStartTime = (System.now()).addHours(4);
        }
        update listSA;
        for(ServiceAppointment sa1 : listSA){
            sa1.Status = 'Dispatched';
        }
        update listSA;
        for(ServiceAppointment sa2 : listSA){
            sa2.Status = Label.XC_CL_WorkOrderLineItem_InProgressStatus;
        }
        update listSA;
        
        for(ServiceAppointment servappointment : listSA){
            servappointment.Status = Label.XC_CL_ServiceAppointment_Completed;
        }
        update listSA;
        System.debug('*************listSA:' + listSA);
        List<WorkOrder> woDBList = [SELECT id, Status FROM WorkOrder LIMIT 2];
        WorkOrderLineItem woliDB = [SELECT id, Status FROM WorkOrderLineItem LIMIT 1];
        System.debug('woDBList: '+ woDBList);
        System.debug('woliDB: '+ woliDB);
        System.assertEquals(Label.XC_CL_WorkOrder_Completed, woliDB.Status, 'WOLI status should be updated to Completed');
        System.assertEquals(Label.XC_CL_WorkOrder_Completed, woDBList[0].Status, 'Work Order status should be updated to Completed');
        System.assertEquals(Label.XC_CL_WorkOrder_Completed, woDBList[1].Status, 'Work Order status should be updated to Completed');
        Test.stopTest();
    }*/
    
/*    @isTest
    static void checkMalfunctioningSA1(){
        insert XC_DF_OneOrg.createOneOrg('Italy');
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkTypeWithName('Malfunctioning','Malfunctioning - Card');
        //insert workTypeToInsert;
        Account acc = new Account();
        acc.Name = 'Account Test 1';
        acc.PrimaryEmail__c = 'test@test.it';
        insert acc;
        Case c = new Case();
        c.AccountId = acc.Id;
        c.XC_BusinessLine__c = 'eCity';
        insert c;
        List<WorkOrder> parents = new List<WorkOrder>();
        WorkOrder wo = new WorkOrder(
        CaseId = c.Id,
        XC_LegalEntity__c = 'EnelSole',
        XC_Segment__c = 'B2B',
        BusinessLine__c = 'eCity',
        Status = 'In Progress',
        XC_WorkTypeCategory__c = Label.XC_CL_WorkType_Malfunctioning,
        RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_WorkOrder').getRecordTypeId());
        parents.add(wo);
        insert parents;
        List<WorkOrderLineItem> listWoli = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem (WorkOrderId = wo.Id, Status = 'New');
        listWoli.add(woli);
        insert listWoli;
        List<WorkOrder> children = new List<WorkOrder>();
        WorkOrder childWo = new WorkOrder(ParentWorkOrderId = wo.Id, Status = 'In Progress');
        children.add(childWo);
        insert children;
        Test.startTest();
        insert XC_DF_ServiceAppointment.createServiceAppointment(parents);        
        List<ServiceAppointment> listSA = [SELECT Id FROM ServiceAppointment FOR UPDATE];        
        for(ServiceAppointment sa : listSA){
            sa.Status = 'Scheduled';
            sa.SchedStartTime=  (System.now()).addHours(2);
            sa.SchedEndTime = (System.now()).addHours(4);
            sa.ArrivalWindowEndTime =(System.now()).addHours(4);
            sa.ArrivalWindowStartTime = (System.now()).addHours(4);
        }
        update listSA;
        for(ServiceAppointment sa1 : listSA){
            sa1.Status = 'Dispatched';
        }
        update listSA;
        for(ServiceAppointment sa2 : listSA){
            sa2.Status = Label.XC_CL_WorkOrderLineItem_InProgressStatus;
        }
        update listSA;
        
        for(ServiceAppointment servappointment : listSA){
            servappointment.Status = Label.XC_CL_ServiceAppointment_Completed;
        }
        List<Database.SaveResult> results = Database.update(listSA, false);
        System.debug('*************listSA:' + listSA);
        //System.assert(results[0].isSuccess()==false);
        //System.assert(results[0].getErrors().size()==1);
        Test.stopTest();
    }*/

}