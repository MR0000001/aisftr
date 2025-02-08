@isTest
public with sharing class TestRSMRequestController {
    @testSetup static void setup() {
        TestDataFactory.createGroups();
        TestDataFactory.createCities();
        TestDataFactory.createCases();
        WSO2Keys__c wso2k = TestDataFactory.createWSO2Keys();
        TestDataFactory.createOrgManagementSettings();
    }


    @isTest
    public static void sendRequestKOTest() {
        String CaseId = [SELECT Id FROM Case WHERE Concession_Municipality__c = 'Roma' LIMIT 1].Id;
        Test.setMock(HttpCalloutMock.class, new MockHttpAccessToken());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseInvioSegnalazioneKO());
        Test.startTest();
        Boolean resp = RSMRequestController.sendRequest(CaseId);
        Test.stopTest();
        system.assertEquals(resp , false);
    }

    @isTest
    public static void sendRequestTest() {
        String CaseId = [SELECT Id FROM Case WHERE Concession_Municipality__c = 'Roma' LIMIT 1].Id;
        Test.setMock(HttpCalloutMock.class, new MockHttpAccessToken());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseInvioSegnalazione());
        Test.startTest();
        Boolean resp = RSMRequestController.sendRequest(CaseId);
        Test.stopTest();
        system.assertEquals(resp , true);
    }

    @isTest
    public static void getRsmQueueTest() {
        Test.startTest();
        String resp = RSMRequestController.getRsmQueue();
        Test.stopTest();
        system.assertNotEquals(resp , null);
    }

    @isTest
    public static void getAnonymousIdsTest() {
        Test.startTest();
        try {
            RSMRequestController.getAnonymousIds();
        } catch(Exception e) {
            System.debug('Exception at TestAMARequestController.getOrgManagementCustomSettingTest ' + e.getMessage());
        }
        Test.stopTest();
    }
}