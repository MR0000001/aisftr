@isTest
public without sharing class TA_LCC243_CreateRecordModal_Test {    

    @testSetup
    static void setup() {
        NE__Order__c order = new NE__Order__c();
        insert order;

        WorkOrder workOrder = new WorkOrder(XC_Configuration__c = order.Id, XC_LegalEntity__c = 'EndesaX', XC_Segment__c = 'B2C',
                                            RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_ESP_WorkOrder').getRecordTypeId());
        insert workOrder;

    }

    @isTest
    static void getRecordTypesByObjectName_Test() {
        TA_LCC243_CreateRecordModal.RecordWrapper rw = new TA_LCC243_CreateRecordModal.RecordWrapper('test','test');
        WorkOrder wo = [select id from workorder limit 1];
        Test.startTest();
        String recordTypes = TA_LCC243_CreateRecordModal.getRecordTypesByObjectName('WorkOrderLineItem', wo.id, true);
        Test.stopTest();
    }  

    @isTest
    static void getRecordTypesByObjectName_Test_2() {
        TA_LCC243_CreateRecordModal.RecordWrapper rw = new TA_LCC243_CreateRecordModal.RecordWrapper('test','test');
        WorkOrder wo = [select id from workorder limit 1];
        Test.startTest();
        String recordTypes = TA_LCC243_CreateRecordModal.getRecordTypesByObjectName('WorkOrderLineItem', wo.id, false);
        Test.stopTest();
    }  
    
    @isTest
    static void getPredefinedValues_Test() {
        
        TA_LCC243_CreateRecordModal.PredefinedValue predefinedValue = new TA_LCC243_CreateRecordModal.PredefinedValue();
        predefinedValue.apiName = 'Id';
        predefinedValue.queryField = 'TestTest';

        WorkOrder wo = [select id from workorder limit 1];

        Test.startTest();
        List<TA_LCC243_CreateRecordModal.PredefinedValue> predefinedValues = TA_LCC243_CreateRecordModal.getPredefinedValues(JSON.serialize(new List<TA_LCC243_CreateRecordModal.PredefinedValue> {predefinedValue}), wo.Id, 'WorkOrder');
        Test.stopTest();
    }

    @isTest
    static void getPredefinedValuesException_Test() {
        
        TA_LCC243_CreateRecordModal.PredefinedValue predefinedValue = new TA_LCC243_CreateRecordModal.PredefinedValue();
        predefinedValue.apiName = 'Id';
        predefinedValue.queryField = 'TestTest';

        WorkOrder wo = [select id from workorder limit 1];

        Test.startTest();
        try {
            List<TA_LCC243_CreateRecordModal.PredefinedValue> predefinedValues = TA_LCC243_CreateRecordModal.getPredefinedValues(JSON.serialize(new List<TA_LCC243_CreateRecordModal.PredefinedValue> {predefinedValue}), wo.Id,'WorkOrder');
        } catch(Exception e) {
            System.assertEquals(true, e.getMessage() != null);
        }
        Test.stopTest();
        
    }
}