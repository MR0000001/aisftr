@isTest
public with sharing class TA_LCC242_DynamicCreateRecord_Test {

    @isTest
    static void getRecordTypesByObjectName_Test() {
        Test.startTest();
        String recordTypes = TA_LCC242_DynamicCreateRecord.getRecordTypesByObjectName('XC_TechnicalSheet__c');
        Test.stopTest();
    }

    @isTest
    static void deleteRecord_Test() {
        XC_TechnicalSheet__c technicalSheet = new XC_TechnicalSheet__c();
        insert technicalSheet;

        Test.startTest();
        Boolean deleted = TA_LCC242_DynamicCreateRecord.deleteRecord(technicalSheet.Id, 'XC_TechnicalSheet__c');
        Test.stopTest();
    }

    @isTest
    static void deleteRecordException_Test() {
        Test.startTest();
        try {
            Boolean deleted = TA_LCC242_DynamicCreateRecord.deleteRecord('testId', 'XC_TechnicalSheet__c');
        } catch(Exception e) {
            System.assertEquals(true, e.getMessage() != null);
        }
        Test.stopTest();
    }

    @isTest
    static void getCurrentRecordId_Test() {
        
        WorkOrder workOrder = new WorkOrder();
        insert workOrder;
        
        XC_TechnicalSheet__c technicalSheet = new XC_TechnicalSheet__c(XC_WorkOrder__c = workOrder.Id);
        insert technicalSheet;

        Test.startTest();
        List<TA_LCC242_DynamicCreateRecord.RecordWrapper> recordWrappers = TA_LCC242_DynamicCreateRecord.getCurrentRecords(workOrder.Id, TA_LCC242_DynamicCreateRecord.OBJ_NAME_TECHNICAL_SHEET, false, 'XC_Email__c',new List<String>{'CreatedDate'});
        List<TA_LCC242_DynamicCreateRecord.RecordWrapper> recordWrappers2 = TA_LCC242_DynamicCreateRecord.getCurrentRecords(workOrder.Id, TA_LCC242_DynamicCreateRecord.OBJ_NAME_TECHNICAL_SHEET, true, 'XC_Email__c',new List<String>{'CreatedDate'});
        Test.stopTest();
    }

    @isTest
    static void getCurrentRecordId_Test2() {

        List<Contact> contList = XC_DF_Contact.createResidentialContacts(1);
        insert contList;
        WorkOrder workOrder = new WorkOrder();
        workOrder.ContactId = contList[0].id;
        insert workOrder;
        
        XC_PersonalDocument__c personalDocument = new XC_PersonalDocument__c(XC_ContactId__c = contList[0].id);
        insert personalDocument;

        Test.startTest();
        List<TA_LCC242_DynamicCreateRecord.RecordWrapper> recordWrappers = TA_LCC242_DynamicCreateRecord.getCurrentRecords(workOrder.Id, TA_LCC242_DynamicCreateRecord.OBJ_NAME_PERSONAL_DOCUMENT, false, 'Name',new List<String>{'CreatedDate'});
        List<TA_LCC242_DynamicCreateRecord.RecordWrapper> recordWrappers2 = TA_LCC242_DynamicCreateRecord.getCurrentRecords(workOrder.Id, TA_LCC242_DynamicCreateRecord.OBJ_NAME_PERSONAL_DOCUMENT, true, 'Name',new List<String>{'CreatedDate'});
        Test.stopTest();
    }

    /*@isTest
    static void getCurrentRecordId_Test3() {

        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, 'Quality Check Inspection');
        WorkOrder workOrder = listWorkOrder[0];
        WorkType wt = XC_DF_WorkType.createWorkTypeWithName('Quality Check Inspection', 'Quality Check Inspection');
        insert wt;
        workOrder.WorkTypeId = wt.id;
        insert workOrder;
        List<XC_B2BG_QualityCheck__c> qualityCheckList = XC_DF_QualityCheck.createQualityChecks(1);
        XC_B2BG_QualityCheck__c qualityCheck = qualityCheckList[0];
        qualityCheck.XC_WorkOrder__c = workOrder.id;
        insert qualityCheck;

        Test.startTest();
        List<TA_LCC242_DynamicCreateRecord.RecordWrapper> recordWrappers = TA_LCC242_DynamicCreateRecord.getCurrentRecords(workOrder.Id, TA_LCC242_DynamicCreateRecord.OBJ_NAME_QUALITY_CHECK, false, 'Name',new List<String>{'CreatedDate'});
        List<TA_LCC242_DynamicCreateRecord.RecordWrapper> recordWrappers2 = TA_LCC242_DynamicCreateRecord.getCurrentRecords(workOrder.Id, TA_LCC242_DynamicCreateRecord.OBJ_NAME_QUALITY_CHECK, true, 'Name',new List<String>{'CreatedDate'});
        Test.stopTest();
    }*/

    @isTest
    static void isComponentVisible_Test() {
        
        NE__Order__c order = new NE__Order__c();
        insert order;

        WorkOrder workOrder = new WorkOrder(XC_Configuration__c = order.Id);
        insert workOrder;

        Test.startTest();
        Boolean isVisible = TA_LCC242_DynamicCreateRecord.isComponentVisible(workOrder.Id, TA_LCC242_DynamicCreateRecord.OBJ_NAME_TECHNICAL_SHEET);
        Boolean isVisible2 = TA_LCC242_DynamicCreateRecord.isComponentVisible(workOrder.Id, TA_LCC242_DynamicCreateRecord.OBJ_NAME_PERSONAL_DOCUMENT);
        Test.stopTest();
    }
    
    @isTest
    static void getPredefinedValues_Test() {
        
        TA_LCC242_DynamicCreateRecord.PredefinedValue predefinedValue = new TA_LCC242_DynamicCreateRecord.PredefinedValue();
        predefinedValue.apiName = 'Id';
        predefinedValue.queryField = 'TestTest';

        WorkOrder workOrder = new WorkOrder();
        insert workOrder;

        Test.startTest();
        List<TA_LCC242_DynamicCreateRecord.PredefinedValue> predefinedValues = TA_LCC242_DynamicCreateRecord.getPredefinedValues(JSON.serialize(new List<TA_LCC242_DynamicCreateRecord.PredefinedValue> {predefinedValue}), workOrder.Id);
        Test.stopTest();
    }

    @isTest
    static void getPredefinedValuesException_Test() {
        
        TA_LCC242_DynamicCreateRecord.PredefinedValue predefinedValue = new TA_LCC242_DynamicCreateRecord.PredefinedValue();
        predefinedValue.apiName = 'Id';
        predefinedValue.queryField = 'TestTest';

        WorkOrder workOrder = new WorkOrder();
        insert workOrder;

        Test.startTest();
        try {
            List<TA_LCC242_DynamicCreateRecord.PredefinedValue> predefinedValues = TA_LCC242_DynamicCreateRecord.getPredefinedValues(JSON.serialize(new List<TA_LCC242_DynamicCreateRecord.PredefinedValue> {predefinedValue}), workOrder.Id);
        } catch(Exception e) {
            System.assertEquals(true, e.getMessage() != null);
        }
        Test.stopTest();
    }
}