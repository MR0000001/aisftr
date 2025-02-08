/**
 * Created by SNEKKANTI00 on 27/04/2021.
 */

@IsTest
public with sharing class TestBatchMailUpSMSModified {

    @TestSetup
    public static void setup() {

        // TestDataFactory.createServiceAppointments();
        TestDataFactory.createMailUpGroups();
        TestDataFactory.createActivityCaseErrors();
    }

    @IsTest
    public static void testScheduledBatchMailUpSMS() {
        TestDataFactory.createOrgManagementSettings();

        List<MailUpBatch_Settings__c> mailUpBatchSettings = TestDataFactory.createMailUpBatchSettings();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpCreateSMS());

        Test.startTest();
        try {
            Database.executeBatch(new BatchMailUpSMSModified(), Integer.valueOf(mailUpBatchSettings[0].Batch_Size__c));
            System.schedule('TestBatchMailUpSMS', '0 17 * ? * * *', new BatchMailUpSMSModified());
        } catch(Exception e) {
            System.debug('Exception at TestBatchMailUpSMS: ' + e.getMessage());
        }
        Test.stopTest();
    }


    @IsTest
    public static void testScheduledBatchMailUpSMSException() {

        List<MailUpBatch_Settings__c> mailUpBatchSettings = TestDataFactory.createMailUpBatchSettings();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpCreateSMS());

        Test.startTest();
        try {
            Database.executeBatch(new BatchMailUpSMSModified(), Integer.valueOf(mailUpBatchSettings[0].Batch_Size__c));
            System.schedule('TestBatchMailUpSMS', '0 17 * ? * * *', new BatchMailUpSMSModified());
        } catch(Exception e) {
            System.debug('Exception at TestBatchMailUpSMS: ' + e.getMessage());
        }
        Test.stopTest();
    }
}