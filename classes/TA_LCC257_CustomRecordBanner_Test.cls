@isTest
public without sharing class TA_LCC257_CustomRecordBanner_Test {

    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
    }

    @isTest
    static void test_initializeOK() {
        Account acc = new Account(
            Name = 'test123',
            PrimaryEmail__c = 'test@test.ad'
        );
        insert acc;

        WorkOrder workOrderTest = new WorkOrder(
            TA_Phase__c = 'checkIn',
            XC_WorkTypeCategory__c = 'Delivery & Installation',
            AccountId = acc.Id
        );
        insert workOrderTest;

        TA_Phase_Configuration__c phase = new TA_Phase_Configuration__c();
        phase.Name = 'TA_Phase_RecordBanner';
        phase.TA_DeveloperName__c = 'RecordBanner';
        phase.TA_Hidden__c = true;
        phase.TA_External_Id__c = 'phase1234';
        insert phase;

        TA_Capability_Configuration__c capConfig = new TA_Capability_Configuration__c();
        capConfig.TA_Configuration_Set__c = 'B2C_Italy_Set';
        capConfig.TA_DeveloperName__c = 'TA_LCP257_CustomRecordBanner';
        capConfig.TA_Index__c = 1;
        capConfig.TA_Phase__c = phase.Id;
        capConfig.TA_Type__c = 'RecordBanner';
        capConfig.TA_Value__c = 'RecordBanner';
        capConfig.TA_WorkType_Category__c = 'Delivery & Installation';
        capConfig.TA_External_Id__c = 'Cap1234';
        capConfig.TA_JSON_Param__c = '{"general":{"bgColor":"","bgImage":"","bgPosition":"","iconName":"standard:work_order","defaultTitle":"WorkOrderNumber,Account.Name","titleType":"","description":"XC_WorkTypeCategory__c,Account.Name"}}';
        insert capConfig;

        test.startTest();
        TA_LCC257_CustomRecordBanner.initialize(workOrderTest.Id);
        test.stopTest();
    }

    @isTest
    static void test_initializeKO() {
        Account acc = new Account(
            Name = 'test123',
            PrimaryEmail__c = 'test@test.ad'
        );
        insert acc;

        WorkOrder workOrderTest = new WorkOrder(
            TA_Phase__c = 'checkIn',
            XC_WorkTypeCategory__c = 'Delivery & Installation',
            AccountId = acc.Id
        );
        insert workOrderTest;

        TA_Phase_Configuration__c phase = new TA_Phase_Configuration__c();
        phase.Name = 'TA_Phase_RecordBanner';
        phase.TA_DeveloperName__c = 'RecordBanner';
        phase.TA_Hidden__c = true;
        phase.TA_External_Id__c = 'phase1234';
        insert phase;

        TA_Capability_Configuration__c capConfig = new TA_Capability_Configuration__c();
        capConfig.TA_Configuration_Set__c = 'B2C_Italy_Set';
        capConfig.TA_DeveloperName__c = 'TA_LCP257_CustomRecordBanner';
        capConfig.TA_Index__c = 1;
        capConfig.TA_Phase__c = phase.Id;
        capConfig.TA_Type__c = 'RecordBanner';
        capConfig.TA_Value__c = 'RecordBanner';
        capConfig.TA_WorkType_Category__c = 'Delivery & Installation';
        capConfig.TA_External_Id__c = 'Cap1234';
        capConfig.TA_JSON_Param__c = '{"general":{"bgColor":"","bgImage":"","bgPosition":"","iconName":"standard:work_order","defaultTitle":"WorkOrderNumber,Account.Name","titleType":"","description":"XC_WorkTypeCategory__c,Account.Name"}}';
        insert capConfig;

        test.startTest();
        TA_LCC257_CustomRecordBanner.initialize(null);
        test.stopTest();
    }
}