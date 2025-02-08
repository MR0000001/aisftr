@IsTest
public with sharing class TestAMARequestController {
    @TestSetup static void setup() {
        TestDataFactory.createWSO2Keys();
        TestDataFactory.createCities();
    }

    @IsTest
    public static void sendRequestAvvisiTest() {
        TestDataFactory.createCases();
        List<Case> cases = [SELECT Estimated_Queue__c, Current_Queue__c, Prior_Queue__c, checkAnonymous__c, ExternalSystemId_AMALV__c, Last_Batch_Date_Time__c, CaseNumber,Account.FirstName,Account.LastName,ContactPhone,ContactEmail,Case_Theme_Area__c,Street_Address__c,Number_Address__c,Letter_Address__c,CreatedDate,Description,Strada_KO__c,Case_Specification__c, Case_Business_Account__c, Account.Name FROM Case];
        Test.setMock(HttpCalloutMock.class, new MockHttpAccessToken());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAvviso());
        Test.startTest();
        List<Case> casesSuccess = AMACallout.AMACallout(cases);
        Test.stopTest();
    }

    @IsTest
    public static void sendRequestTest() {
        List<Case> cases = TestDataFactory.createCases();
        Test.setMock(HttpCalloutMock.class, new MockHttpAccessToken());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAvviso());
        Test.startTest();
        List<Case> casesSuccess = AmaRequestController.sendRequest(cases[0].Id);
        Test.stopTest();
    }

    @IsTest
    public static void sendRequestKOTest() {
        TestDataFactory.createCases();
        List<Case> cases = [SELECT Estimated_Queue__c, Current_Queue__c, Prior_Queue__c, checkAnonymous__c, ExternalSystemId_AMALV__c, Last_Batch_Date_Time__c, CaseNumber,Account.FirstName,Account.LastName,ContactPhone,ContactEmail,Case_Theme_Area__c,Street_Address__c,Number_Address__c,Letter_Address__c,CreatedDate,Description,Strada_KO__c,Case_Specification__c, Case_Business_Account__c, Account.Name FROM Case];

        Test.setMock(HttpCalloutMock.class, new MockHttpAccessToken());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAvvisoKO());
        Test.startTest();
        List<Case> caseKO = AMACallout.AMACallout(cases, false);
        Test.stopTest();
    }

    @IsTest
    public static void getAmaQueueTest() {
        Test.startTest();
        try {
            String resp = AmaRequestController.getAmaQueue();
            System.assertNotEquals(resp , null);
        } catch(Exception e) {
            System.debug('Exception at TestAMARequestController.getRsmQueueTest ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void getAnonymousIds() {
        Test.startTest();
        try {
            AmaRequestController.getAnonymousIds();
        } catch(Exception e) {
            System.debug('Exception at TestAMARequestController.getOrgManagementCustomSettingTest ' + e.getMessage());
        }
        Test.stopTest();
    }
}