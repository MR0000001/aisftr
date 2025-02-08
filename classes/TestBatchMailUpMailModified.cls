/**
 * Created by SNEKKANTI00 on 27/04/2021.
 */

@isTest
public with sharing class TestBatchMailUpMailModified {

    @testSetup
    public static void setup() {
        TestDataFactory.createMailUpGroups();
        TestDataFactory.createCasesWithoutCities();
        TestDataFactory.createActivityCaseErrors();
        TestDataFactory.createMailUpMailWrappers();
    }

    @isTest
    public static void batchMailUpMailTest() {
        List<MailUpBatch_Settings__c> mailUpBatchSettings = TestDataFactory.createMailUpBatchSettings();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpCreateMail());

        Test.startTest();
        try {
            Database.executeBatch(new BatchMailUpMailModified(), Integer.valueOf(mailUpBatchSettings[0].Batch_Size__c));
            System.schedule('TestBatchMailUpMail', '0 17 * ? * * *', new BatchMailUpMailModified());
        } catch(Exception e) {
            System.debug('Exception at TestBatchMailUpMail: ' + e.getMessage());
        }
        Test.stopTest();
    }
}