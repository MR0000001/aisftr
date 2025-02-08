/**
* @author Eleni Tsiolaki - etsiolaki@deloitte.gr 
* @Creation 14/03/2022
* @Modification
* @description Test Class for XC_LCC270_CreateReturnMaterial
*/
@isTest
private class XC_LCC270_CreateReturnMaterial_TEST {

    @TestSetup
    static void testSetup() {

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        WorkOrderLineItem woli = new WorkOrderLineItem(
            Status = 'New',
            XC_Form_Type__c = 'RMA',
            WorkOrderId = workOrderTest.Id,
            RecordTypeID = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXMobility_ReturnMaterial').getRecordTypeId()
        );
        insert woli;

        XC_ProductConsumed__c product = new XC_ProductConsumed__c(XC_WorkOrderLineItem__c = woli.Id, XC_QuantityConsumed__c = 2, XC_WorkOrder__c = workOrderTest.Id);
        insert product;

    }

    @isTest
    static void createReturnMaterialTest(){
        List<WorkOrderLineItem> woli = [SELECT Id FROM WorkOrderLineItem LIMIT 1];
        Test.startTest();
        XC_UTIL_ResultWrapper resultOK = XC_LCC270_CreateReturnMaterial.createReturnMaterial(woli[0].Id);
        woli[0].RecordTypeID = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXMobility_ReturnMaterial').getRecordTypeId();
        update woli[0];
        XC_UTIL_ResultWrapper resultOK2 = XC_LCC270_CreateReturnMaterial.createReturnMaterial(woli[0].Id);
        Test.stopTest();
    }

}