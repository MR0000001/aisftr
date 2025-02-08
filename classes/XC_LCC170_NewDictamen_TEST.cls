/*
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 30/01/2020
* @description XC_LCC170_NewDictamen_TEST - Test Class for XC_LCC170_NewDictamen and trigger Dictamen
*/

@isTest
private class XC_LCC170_NewDictamen_TEST {

    @IsTest
    static void getVisibleRecordType() {
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        insert listWorkOrder;
        Test.startTest();
        XC_LCC170_NewDictamen.InfoDictamenWrapper outputWrapper = XC_LCC170_NewDictamen.getVisibleRecordType(listWorkOrder[0].Id);
        System.assertNotEquals(outputWrapper, null);
        Test.stopTest();
    }

    @isTest
    static void newDictamen() {
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        insert listWorkOrder;
        Test.startTest();
        XC_DictamenItem__c newDictamen = new XC_DictamenItem__c(XC_WorkOrder__c = listWorkOrder[0].Id);
        insert newDictamen;
        newDictamen.XC_IsPerformed__c = true;
        update newDictamen;
        System.assertNotEquals(newDictamen.Id, null);
        Test.stopTest();
    }

}