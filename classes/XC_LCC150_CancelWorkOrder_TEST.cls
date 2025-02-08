/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 23/04/2020
* @description XC_LCC150_CancelWorkOrder_TEST - Test Class for XC_LCC150_CancelWorkOrder
*/

@isTest
private class XC_LCC150_CancelWorkOrder_TEST {
   @isTest
    static void cancelWorkOrder() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1, Label.XC_CL_WorkType_Repair);
        insert listServiceAppointment; 
        Test.startTest();
        XC_LCC150_CancelWorkOrder.updateFLS(listServiceAppointment[0].ParentRecordId); 
        List<WorkOrder> listWo = XC_UTIL_Sobject.selectAllFields(listServiceAppointment[0].ParentRecordId);
        XC_LCC150_CancelWorkOrder.updateWoAfterSA(listWo[0]);
        Test.stopTest();        
    }
    
    @isTest
    static void cancelWorkOrderWithErrorWO() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1, Label.XC_CL_WorkType_DeliveryInstallation);
        insert listServiceAppointment; 
        Test.startTest();
        XC_LCC150_CancelWorkOrder.updateFLS(listServiceAppointment[0].ParentRecordId); 
        Test.stopTest();  
    }

    @isTest
    static void cancelWorkOrderWithErrorSA() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        insert listWo;
        Test.startTest();
        XC_LCC150_CancelWorkOrder.updateFLS(listWo[0].Id); 
        Test.stopTest();  
    }
}