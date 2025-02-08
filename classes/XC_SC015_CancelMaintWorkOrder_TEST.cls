/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 16/07/2019
* @date Modification dd/mm/yyyy
* @description XC_SC015_CancelMaintWorkOrder_TEST – Test Class for XC_SC015_CancelMaintenanceWorkOrder
*/ 

@isTest
public class XC_SC015_CancelMaintWorkOrder_TEST {
     
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
        /* List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
            ServiceResource serviceRes = new ServiceResource();
            serviceRes.Name = 'No Candidate Found';
            serviceRes.XC_Account__c = accountList[0].Id;
            serviceRes.IsActive = true;
            serviceRes.IsCapacityBased = true;
            serviceRes.XC_AutomaticDeactivation__c = true;
            serviceRes.RelatedRecordId = usersList[1].Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
            serviceResourcesToInsert.add(serviceRes);
        insert serviceResourcesToInsert;*/
    }
    @isTest
    static void testBatch(){
        
      
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_PlannedMaintenance);
        insert woList;
        
        insert XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = [SELECT Id, Status, EarliestStartTime, DueDate FROM ServiceAppointment];
        Test.startTest();
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.EarliestStartTime = System.now().addMonths(-5);
           // sa.DueDate = System.now().addMonths(-4);
            saToUpdate.add(sa);
        }
        update saToUpdate;
         
         XC_SC015_CancelMaintenanceWorkOrder  myClass = new XC_SC015_CancelMaintenanceWorkOrder ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();

        //XC_SC015_CancelMaintenanceWorkOrder bdvi = new XC_SC015_CancelMaintenanceWorkOrder();
        //Id batchId = Database.executeBatch(bdvi);  
        //System.assertEquals(saToUpdate.size(),1);  
    }
    
    @isTest
    static void testBatch2(){
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_PlannedMaintenance);
        insert woList;
        insert XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = [SELECT Id, Status, EarliestStartTime, DueDate FROM ServiceAppointment];
        Test.startTest();
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_None;
            sa.EarliestStartTime = System.now().addMonths(-5);
           // sa.DueDate = System.now().addMonths(-4);
            saToUpdate.add(sa);
        }
        update saToUpdate;

        XC_SC015_CancelMaintenanceWorkOrder bdvi = new XC_SC015_CancelMaintenanceWorkOrder();
        Id batchId = Database.executeBatch(bdvi); 

        System.assertEquals(saToUpdate.size(),1);


    }

}