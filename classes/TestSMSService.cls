/**
 * Created by SNEKKANTI00 on 27/04/2021.
 */

@isTest
public with sharing class TestSMSService {

    @TestSetup
    public static void setup() {
        TestDataFactory.createSms();
    }

    @isTest
    public static void createSMSs() {
        List<SMSWrapper> smsWrappers = TestDataFactory.createSMSWrapper();
        List<SMS__c> smsList = [SELECT id FROM SMS__c];

        Test.startTest();
        SMSService.createSMSs(smsWrappers[0]);
        SMSService.insertSMSs(smsList, true);
        SMSService.insertSMSs(smsList, false);
        Test.stopTest();
    }
}