/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 19/07/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_U_CancelManag_TEST – Test Class for XC_TR_WorkOrder_U_CancellationManagement
*/ 
@isTest
public class XC_TR_WorkOrder_U_CancelManag_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        /*List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
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

    static testMethod void manageCanceledTest() { 
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert saList;
        List<WorkOrder> woListToUpdate = new List<WorkOrder>();
        for(WorkOrder wo : woList){
            wo.Status = Label.XC_CL_WorkOrder_Canceled;
            woListToUpdate.add(wo);
        }
        Test.startTest();
        try{
        update woListToUpdate;
        }
         catch(Exception e) {
             Boolean expectedExceptionThrown =  e.getMessage().contains(Label.XC_CL_WorkOrder_CannotCancel) ? true : false;
             System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }

    static testMethod void manageCannotCompleteTest() { 
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_PlannedMaintenance);
        woList[0].Status = 'Assigned';
        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert saList;
        List<WorkOrder> woListToUpdate = new List<WorkOrder>();
        for(WorkOrder wo : woList){
            wo.Status = 'In Progress';
            woListToUpdate.add(wo);
        }
        update woListToUpdate;
        List<WorkOrder> woListToUpdate2 = new List<WorkOrder>();
        for(WorkOrder wo : woList){
            wo.Status = Label.XC_CL_WorkOrder_CannotComplete;
            woListToUpdate2.add(wo);
        }
        Test.startTest();
        try{
        update woListToUpdate2;
        }
         catch(Exception e) {
             Boolean expectedExceptionThrown =  e.getMessage().contains(Label.XC_CL_WorkOrder_PutInCannotComplete) ? true : false;
             System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }

}