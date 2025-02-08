/**
 * Created by SNEKKANTI00 on 20/04/2021.
 */

@isTest
public with sharing class TestActivityCaseErrorService {

    @TestSetup
    public static void setup() {
        // TestDataFactory.createServiceAppointments();
        TestDataFactory.createActivityCaseErrors();
    }

    @isTest
    public static void deleteActivityCaseErrors() {
        List<String> activityCaseErrorIds = new List<String>();
        for(Activity_Case_Error__c ace : [SELECT id FROM Activity_Case_Error__c]) {
            activityCaseErrorIds.add(ace.Id);
        }

        Test.startTest();
        ActivityCaseErrorService.deleteActivityCaseErrors(activityCaseErrorIds, false);
        ActivityCaseErrorService.deleteActivityCaseErrors(activityCaseErrorIds, true);
        Test.stopTest();
    }

    // @isTest
    // public static void deleteActivityCaseErrorsFromServiceAppointmentIds() {
    //     List<String> serviceAppointmentIds = new List<String>();
    //     for(ServiceAppointment sa : [SELECT id FROM ServiceAppointment]) {
    //         serviceAppointmentIds.add(sa.Id);
    //     }

    //     Test.startTest();
    //     ActivityCaseErrorService.deleteActivityCaseErrorsFromServiceAppointmentIds(serviceAppointmentIds, false);
    //     ActivityCaseErrorService.deleteActivityCaseErrorsFromServiceAppointmentIds(serviceAppointmentIds, true);
    //     Test.stopTest();
    // }

    @isTest
    public static void insertActivityCaseErrorsFromMail() {
        List<MailUpMailWrapper> wrappers = TestDataFactory.createMailUpMailWrappers();
        System.debug('wrappers ' + wrappers);

        Test.startTest();
        ActivityCaseErrorService.insertActivityCaseErrors(wrappers[0], false);
        ActivityCaseErrorService.insertActivityCaseErrors(wrappers[0], true);
        Test.stopTest();
    }

    @isTest
    public static void insertActivityCaseErrorsFromSMS() {
        List<SMSWrapper> wrappers = TestDataFactory.createSMSWrapper();
        // List<ServiceAppointment> serviceAppointments = [SELECT id FROM ServiceAppointment];

        Test.startTest();
        ActivityCaseErrorService.insertActivityCaseErrors(wrappers[0], false);
        ActivityCaseErrorService.insertActivityCaseErrors(wrappers[0], true);
        Test.stopTest();
    }

    @isTest
    public static void deleteActivityCaseErrorsSimple() {
        List<Activity_Case_Error__c> activityCaseErrors = [SELECT id FROM Activity_Case_Error__c];
        Test.startTest();
        ActivityCaseErrorSelector.deleteActivityCaseErrors(activityCaseErrors, false);
        ActivityCaseErrorSelector.deleteActivityCaseErrors(activityCaseErrors, true);
        Test.stopTest();
    }
}