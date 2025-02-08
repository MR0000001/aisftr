/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ServiceAppointment_U_UpdateWO_TEST – Test Class for XC_TR_ServiceAppointment_U_UpdateWO
*/ 

@isTest
public class XC_TR_ServiceAppointment_U_UpdateWO_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true; 
        insert org;
    }

    static testMethod void onUpdate(){        
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation', 'Delivery & Installation');
        insert listOfWo;
        List<ServiceAppointment> saToInsert = XC_DF_ServiceAppointment.createServiceAppointment(listOfWo);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment];
        Test.startTest();
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            saToUpdate.add(sa);
        } 
        update saToUpdate;
        Test.stopTest();
    }

    static testMethod void onUpdateToNone(){        
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation', 'Delivery & Installation');
        insert listOfWo;
        List<ServiceAppointment> saToInsert = XC_DF_ServiceAppointment.createServiceAppointment(listOfWo);
        ServiceAppointment sa = saToInsert[0]; 
        sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
        insert sa;
        Test.startTest(); 
        sa.Status = 'None';
        update sa;
        Test.stopTest();
    }
    
    static testMethod void onUpdateInProgress(){
        Test.startTest();
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        Lead leadToInsert = XC_DF_Lead.createResidentialLead();
        insert leadToInsert;
        XC_TR_ServiceAppointment_U_UpdateWO.manageInProgress(new List<String> {listOfOpp[0].Id}, new List<String> {leadToInsert.Id});
        Test.stopTest();
    }
    
     static testMethod void onUpdateCanceled(){        
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation', 'Delivery & Installation');
        insert listOfWo;
        List<ServiceAppointment> saToInsert = XC_DF_ServiceAppointment.createServiceAppointment(listOfWo);
         for (ServiceAppointment sa : saToInsert){
            sa.Status = Label.XC_CL_ServiceAppointment_None;
        }
        insert saToInsert;
        Test.startTest();
        for(ServiceAppointment sa : saToInsert){
            sa.Status = Label.XC_CL_ServiceAppointment_Canceled;
        }
        update saToInsert; 
        Test.stopTest();
    }
    
     static testMethod void onUpdateCannotComplete(){
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(2, 'Planned Maintenance - Gas', Label.XC_CL_WorkType_PlannedMaintenance);
        insert listOfWo;
        listOfWo[1].ParentWorkOrderId = listOfWo[0].Id;
		listOfWo[0].XC_AssignmentDateTimestamp__c = System.now();
        listOfWo[0].XC_ScheduleDateTimestamp__c = System.now();
		update listOfWo;
        List<ServiceAppointment> saBefore = XC_DF_ServiceAppointment.createServiceAppointment(listOfWo);
        for (ServiceAppointment sa : saBefore){
            sa.Status = Label.XC_CL_ServiceAppointment_In_Progress;
        }
        insert saBefore;
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment];
        Test.startTest();
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            sa.XC_Reason_Cannot_Complete__c = 'Customer not presence';
            sa.XC_StatusReason__c = Label.XC_CL_StatusReason_Customerrefusesthevisit;
            saToUpdate.add(sa);
        }
        update saToUpdate; 
        Test.stopTest();
    }
    
    /*static testMethod void onUpdateOnHold(){
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation', 'Delivery & Installation');
        insert listOfWo;
        List<ServiceAppointment> saToInsert = XC_DF_ServiceAppointment.createServiceAppointment(listOfWo); 
        saToInsert[0].Status = Label.XC_CL_ServiceAppointment_Scheduled;
        insert saToInsert; 
        Test.startTest();
        for(ServiceAppointment sa : saToInsert){
            sa.Status = Label.XC_CL_ServiceAppointment_OnHold;
        }
        update saToInsert; 
        Test.stopTest();
    }*/
    
    @isTest
    static void calculateHoursFromOppCreation (){
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1,'Delivery & Installation - Solar photovoltaic', 'Delivery & Installation');
        listOfWo[0].XC_Opportunity__c = listOfOpp[0].Id;
        insert listOfWo;
        List<ServiceAppointment> listOfSa = XC_DF_ServiceAppointment.createServiceAppointment(1);
        listOfSa[0].ParentRecordId = listOfWo[0].Id;
        insert listOfSa;
        Test.startTest();
        listOfSa[0].ActualStartTime = Datetime.now(); 
        listOfSa[0].ActualEndTime = Datetime.now().addDays(1); 
        listOfSa[0].XC_Result__c = 'OK';
        listOfSa[0].XC_MaxWallboxPower__c = '3,7 KWh';
        update listOfSa; 
        Test.stopTest();
    }
    
    @isTest
    static void manageInProgressTEST(){
        Test.startTest();        
        List<Opportunity> listOpp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        insert listOpp;
        List<String> listIdsOpp = XC_UTIL_Sobject.getIds(listOpp);
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(3);
        insert listLead;
        List<String> listIdsLead = XC_UTIL_Sobject.getIds(listLead);
        XC_TR_ServiceAppointment_U_UpdateWO.manageInProgress(listIdsOpp, listIdsLead); 
        Test.stopTest();
    }
    
    
    static testMethod void onUpdateDueDateTEST(){        
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation', 'Delivery & Installation');
        insert listOfWo;
        List<ServiceAppointment> saToInsert = XC_DF_ServiceAppointment.createServiceAppointment(listOfWo);
         for (ServiceAppointment sa : saToInsert){
            sa.Status = Label.XC_CL_ServiceAppointment_None;
            sa.DueDate = Date.today().adddays(5);
        }
        insert saToInsert;
        Test.startTest();
        for(ServiceAppointment sa : saToInsert){
            sa.DueDate = Date.today().adddays(15);
        }
        update saToInsert; 
        Test.stopTest();
    }
}