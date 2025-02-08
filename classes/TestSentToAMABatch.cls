@isTest
public with sharing class TestSentToAMABatch {
    @testSetup static void setup() {
        TestDataFactory.createWSO2Keys();
        TestDataFactory.createAMABatchSettings();
        TestDataFactory.createGroups();
    }

    @isTest
    public static void TestSentToAMABatchSingle() {
        List<Case> listCases = TestDataFactory.createSingleCasesWithoutCities();
        List<Case> listCasesQ = [select caseNumber, status, RecordTypeId, RecordType.Name, Sent_to_External__c, type, LastModifiedDate from case where id IN: listCases];
        listCasesQ[0].status = 'Nuovo';

        UPDATE listCasesQ;

        Test.setMock(HttpCalloutMock.class, new MockHttpAccessToken());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseInvioAvviso());

        Test.startTest();
        try {
            Database.executeBatch(new SendToAMABatch(), 10);
            System.schedule('TestSentToAMABatch', '0 17 * ? * * *', new SendToAMABatch());
        } catch(Exception e) {
            System.debug('Exception at TestSentToAMABatch: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void TestSentToAMABatchMass() {
        List<Case> listCases = TestDataFactory.createCasesWithoutCities();
        List<Case> listCasesQ = [select caseNumber, status, RecordTypeId, RecordType.Name, Sent_to_External__c, type, LastModifiedDate from case where id IN: listCases];

        for(Case c : listCasesQ) {
            c.Status = 'Nuovo';
        }
        UPDATE listCasesQ;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpAccessToken());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseInvioAvvisi(listCasesQ[0].caseNumber, listCasesQ[1].caseNumber));

        Test.startTest();
        try {
            Database.executeBatch(new SendToAMABatch(), 10);
            System.schedule('TestSentToAMABatch', '0 17 * ? * * *', new SendToAMABatch());
        } catch(Exception e) {
            System.debug('Exception at TestSentToAMABatch: ' + e.getMessage());
        }
        Test.stopTest();
    }
}