/**
* @author Domenico Del Prete domenico.delprete@nttdata.com
* @date Creation  06/02/2020
* @description XC_LCC089_AssignToPartner_TEST – Test class for XC_LCC089_AssignToPartner
*/ 

@isTest
public without sharing class XC_LCC089_AssignToPartner_TEST {

    @isTest
    static void assignToTechnicians() {
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        Test.startTest();
        List<WorkOrder> workOrderList = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_WorkType_Repair);
        for(WorkOrder currentWO : workOrderList){
            currentWO.XC_Urgent_Repair__c = false;
        }
        insert workOrderList;
        String workOrderId = workOrderList[0].Id; 
        List<WorkOrder> workOrderList2 = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_CommercialVisit);
        insert workOrderList2;
        String workOrderId2 = workOrderList2[0].Id; 
        XC_LCC089_AssignToPartner.ResultWrapper rw = XC_LCC089_AssignToPartner.assignToPartner(workOrderId);
        XC_LCC089_AssignToPartner.ResultWrapper rw2 = XC_LCC089_AssignToPartner.assignToPartner(workOrderId2);
        System.debug('@@@ assignToTechnicians ' + rw);
        Test.stopTest();
    }
    
    @isTest
    static void assignToTechnicians2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> workOrderList = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_WorkType_Repair);
        for(WorkOrder currentWo: workOrderList){
            currentWo.XC_Urgent_Repair__c = false;
        }
        insert workOrderList;
        String workOrderId = workOrderList[0].Id;
        List<WorkOrder> workOrderList2 = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_CommercialVisit);
        insert workOrderList2;
        String workOrderId2 = workOrderList2[0].Id; 
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(workOrderList);
        listServiceAppointment[0].Status = 'None';
        insert listServiceAppointment;
        List<ServiceAppointment> listServiceAppointment2 = XC_DF_ServiceAppointment.createServiceAppointment(workOrderList2);
        listServiceAppointment2[0].Status = 'None';
        insert listServiceAppointment2;
        XC_LCC089_AssignToPartner.ResultWrapper rw = XC_LCC089_AssignToPartner.assignToPartner(workOrderId);
        XC_LCC089_AssignToPartner.ResultWrapper rw2 = XC_LCC089_AssignToPartner.assignToPartner(workOrderId2);
        System.debug('@@@ assignToTechnicians2 ' + rw);
        Test.stopTest();
    }

}