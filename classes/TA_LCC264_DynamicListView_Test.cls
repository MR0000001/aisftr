@isTest
public without sharing class TA_LCC264_DynamicListView_Test {
    
    @isTest
    static void getListViews() {
        Test.startTest();
        TA_LCC264_DynamicListView.getListViews('WorkOrder');
        Test.stopTest();
    }

    @isTest
    static void getListViews_Exception() {
        Test.startTest();
        TA_LCC264_DynamicListView.getListViews('workOrd');
        Test.stopTest();
    }

    @isTest
    static void getLitViewRecords() {
        Test.startTest();
        TA_LCC264_DynamicListView.getLitViewRecords(
            [SELECT Id FROM ListView WHERE SObjectType = 'WorkOrder' LIMIT 1].Id,
            'WorkOrder');
        Test.stopTest();
    }

    @isTest
    static void getLitViewRecords_Exception() {
        Test.startTest();
        TA_LCC264_DynamicListView.getLitViewRecords(
            null,
            'WorkOrder');
        Test.stopTest();
    }

    @isTest
    static void getPicklistValues() {
        Test.startTest();
        String response = TA_LCC264_DynamicListView.getPicklistValues();
        Test.stopTest();
    }

    @isTest
    static void getRelatedWorkOrders() {
        Account acc = new Account(Name = 'testAccount', PrimaryEmail__c = 'test@test.it');
        insert acc;
        insert new WorkOrder(AccountId = acc.Id,  XC_WorkTypeCategory__c = 'Delivery & Installation', Status = 'New');

        Test.startTest();
        String response = TA_LCC264_DynamicListView.getRelatedWorkOrders(acc.Id);
        Test.stopTest();
    }

    @isTest
    static void searchAccount() {
        Account acc = new Account(Name = 'testAccount', PrimaryEmail__c = 'test@test.it');
        insert acc;

        Test.startTest();
        String response = TA_LCC264_DynamicListView.searchAccount('testAccount');
        Test.stopTest();
    }
}