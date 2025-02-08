@IsTest
public with sharing class TestSendToRSMBatch {
    @TestSetup static void setup() {
        TestDataFactory.createGroups();
        List<Account> accounts = TestDataFactory.createAccounts();
        Contact c = [SELECT Id FROM Contact WHERE Account.Id =: accounts[1].Id];
        TestDataFactory.createCasesWithAccountContact(accounts[0].Id, c.Id);

        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    public static void TestSendToRSMBatch() {
        TestDataFactory.createRSMBatchSettings();

        List<Case> listCasesQ = [SELECT CaseNumber, Status, RecordTypeId, RecordType.Name, Sent_to_External__c, Type, LastModifiedDate FROM Case];

        for(Case c : listCasesQ) {
            c.Status = 'Nuovo';
        }
        update listCasesQ;

        Test.setMock(HttpCalloutMock.class, new MockHttpAccessToken());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseInvioSegnalazione());
        Test.startTest();
        Database.executeBatch(new SendToRSMBatch(), 10);
        System.schedule('TestSendToRSMBatch', '0 17 * ? * * *', new SendToRSMBatch());
        Test.stopTest();
    }


    @IsTest
    public static void TestSendToRSMBatchException() {
        List<Case> listCasesQ = [SELECT CaseNumber, Status, RecordTypeId, RecordType.Name, Sent_to_External__c, Type, LastModifiedDate FROM Case];

        for(Case c : listCasesQ) {
            c.Status = 'Nuovo';
        }
        update listCasesQ;

        Test.setMock(HttpCalloutMock.class, new MockHttpAccessToken());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseInvioSegnalazione());
        Test.startTest();
        Database.executeBatch(new SendToRSMBatch(), 10);
        System.schedule('TestSendToRSMBatch', '0 17 * ? * * *', new SendToRSMBatch());
        Test.stopTest();
    }
}