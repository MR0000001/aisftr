/** 
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @date Creation 15/10/2020
  * @description XC_LCC213_CreateServiceReport_TEST - Test class for XC_LCC213_CreateServiceReport
*/

@isTest
private class XC_LCC213_CreateServiceReport_TEST {

    @isTest
    static void onCreateServiceReport() {
      XC_LCC213_CreateServiceReport.createServiceReport('');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        listWorkOrder[0].XC_CreateReducedReport__c = true;
        listWorkOrder[0].XC_forSATO__c = true;
        listWorkOrder[0].Status = Label.XC_CL_InProgress;
        insert listWorkOrder;
        Test.startTest();
        XC_LCC213_CreateServiceReport.createServiceReport(listWorkOrder[0].Id);
        listWorkOrder[0].XC_CreateReducedReport__c = false;
        listWorkOrder[0].XC_CongaDynamicAPI__c = 'TEST';
        update listWorkOrder;
        XC_LCC213_CreateServiceReport.createServiceReport(listWorkOrder[0].Id);
        listWorkOrder[0].XC_CongaDynamicAPI__c = '';
        update listWorkOrder;
        XC_LCC213_CreateServiceReport.createServiceReport(listWorkOrder[0].Id);
        WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId = listWorkOrder[0].Id, Status = 'New');
        insert woli;
        woli.Status = 'In Progress';
        update woli;
        listWorkOrder[0].XC_CongaDynamicAPI__c = '';
        listWorkOrder[0].XC_CreateReducedReport__c = false;
        update listWorkOrder;
        XC_LCC213_CreateServiceReport.createServiceReport(listWorkOrder[0].Id);

        List<WorkOrder> listWorkOrderErrorStatus = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        listWorkOrderErrorStatus[0].XC_forSATO__c = true;
        listWorkOrderErrorStatus[0].Status = Label.XC_CL_WorkOrder_Assigned;
        insert listWorkOrderErrorStatus;
        XC_LCC213_CreateServiceReport.createServiceReport(listWorkOrderErrorStatus[0].Id);
        Test.stopTest();
    }

}