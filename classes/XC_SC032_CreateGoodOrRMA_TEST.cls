/**
* @author FSL Team - salvatore.agrillo@nttdata.com 
* @date Creation 15/06/2020
* @description XC_SC032_CreateGoodOrRMA_TEST – Test Class for XC_SC032_CreateGoodIssueRepair
*                                                             XC_SC032_CreateGoodIssueDelivInstal
*                                                             XC_SC032_CreateRMAReturn
*/

@isTest
private class XC_SC032_CreateGoodOrRMA_TEST {

    @TestSetup
    static void makeData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1,'Repair - Gas',Label.XC_CL_WorkType_Repair);
        listWorkOrder.addAll(XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1,'Delivery & Installation - Boiler',Label.XC_CL_WorkType_DeliveryInstallation));
        listWorkOrder.addAll(XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1,'Return', Label.XC_CL_WorkType_Return));
        List<Account> listOfAccPartner = XC_DF_Account.insertPartnerAccounts(1);
        for(WorkOrder wo : listWorkOrder) {
            wo.XC_ToDoGoodIssueOrRMA__c = true;
            wo.XC_LegalEntity__c = 'EndesaX';
            wo.XC_AssignedPartner__c = listOfAccPartner[0].Id;
        }
        insert listWorkOrder;
    }

    @isTest
    static void executeBatch() {
        Test.startTest(); 
        List<WorkOrder> listOfWo = new List<WorkOrder>([SELECT Id, XC_WorkTypeLabel__c, XC_WorkTypeCategory__c, XC_ToDoGoodIssueOrRMA__c FROM Workorder]);
        XC_SC032_CreateGoodIssueDelivInstal myClass = new XC_SC032_CreateGoodIssueDelivInstal();   
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass);
        Test.stopTest();
    }

}