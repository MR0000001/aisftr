/**
* @author Domenico Del Prete  - domenico.delprete@nttdata.com
* @date Creation 11/10/2019
* @description XC_SC024_UpdateWOAfterFailedVisit_Test – Test class for XC_SC024_UpdateWOAfterFailedVisit
*/ 
@isTest
public without sharing class XC_SC024_UpdateWOAfterFailedVisit_Test {

    @isTest
    static void onExecuteBatch() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceAppointment> listOfServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1, Label.XC_CL_CommercialVisit);
        listOfServiceAppointment[0].Status = Label.XC_CL_ServiceAppointment_In_Progress;
        insert listOfServiceAppointment;
        listOfServiceAppointment[0].XC_StatusReason__c = Label.XC_CL_StatusReason_Failedvisit;
        listOfServiceAppointment[0].Status = Label.XC_CL_ServiceAppointment_CannotComplete;
        update listOfServiceAppointment;
        WorkOrder wo = new WorkOrder(Id = listOfServiceAppointment[0].ParentRecordId);
        wo.Status = Label.XC_CL_OnHold;
        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_Customernotlocated;
        update wo;
        Test.startTest();
        String batchId = Database.executeBatch(new XC_SC024_UpdateWOAfterFailedVisit(), 50); 
        System.assert(!String.isBlank(batchId));
        Test.stopTest();
    }

}