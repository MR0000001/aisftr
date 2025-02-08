/**
 * Created by SNEKKANTI00 on 01/06/2021.
 */

@IsTest
public with sharing class TestActivityCaseErrorSelector {

    @TestSetup
    public static void setup() {
        TestDataFactory.createActivityCaseErrors();
    }

    // @IsTest
    // public static void getActivityCaseErrorsByServiceAppointmentIds() {
    //     Test.startTest();
    //     try {
    //         ActivityCaseErrorSelector.getActivityCaseErrorsByServiceAppointmentIds(null);
    //     } catch(Exception e) {
    //         System.debug('Exception at TestActivityCaseErrorSelector.getActivityCaseErrorsByServiceAppointmentIds ' + e.getMessage());
    //     }
    //     Test.stopTest();
    // }

    @IsTest
    public static void deleteActivityCaseErrors() {
        Test.startTest();
        List<Activity_Case_Error__c> activityCaseErrors = [SELECT id FROM Activity_Case_Error__c];
        List<String> activityCaseErrorIds = new List<String>();
        for(Activity_Case_Error__c ace : activityCaseErrors) {
            activityCaseErrorIds.add(ace.id);
        }

        ActivityCaseErrorSelector.deleteActivityCaseErrors(activityCaseErrors, false);
        ActivityCaseErrorSelector.deleteActivityCaseErrors(activityCaseErrors, true);
        ActivityCaseErrorSelector.deleteActivityCaseErrors(activityCaseErrorIds, true);
        ActivityCaseErrorSelector.deleteActivityCaseErrors(activityCaseErrorIds, false);
        Test.stopTest();
    }

    @IsTest
    public static void insertActivityCaseErrors() {
        Activity_Case_Error__c activityCaseError = new Activity_Case_Error__c();
        List<Activity_Case_Error__c> activityCaseErrors = new List<Activity_Case_Error__c>();

        activityCaseErrors.add(activityCaseError);

        ActivityCaseErrorSelector.insertActivityCaseErrors(activityCaseErrors, true);
    }

    @IsTest
    public static void updateActivityCaseErrors() {
        List<Activity_Case_Error__c> activityCaseErrors = [SELECT id FROM Activity_Case_Error__c];

        ActivityCaseErrorSelector.updateActivityCaseErrors(activityCaseErrors, true);
    }
}