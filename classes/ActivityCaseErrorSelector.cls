/**
 * @author            : Sree Vamsi Nekkanti
 * @created date      : 15-04-2021
 * @description       : 
 * @testClasses       : TestActivityCaseErrorService
 * @last modified by  : Daniel Perrella
 * @last modified on  : 06-03-2023
**/

public with sharing class ActivityCaseErrorSelector {

    // public static List<Activity_Case_Error__c> getActivityCaseErrorsByServiceAppointmentIds(List<String> serviceAppointmentIds) {
    //     List<Activity_Case_Error__c> activityCaseErrors = [SELECT id FROM Activity_Case_Error__c WHERE Service_Appointment__c IN: serviceAppointmentIds];

    //     return activityCaseErrors;
    // }

    public static void deleteActivityCaseErrors(List<String> activityCaseErrorIds, Boolean allOrNone) {
        try {
            Database.DeleteResult[] results = Database.delete(activityCaseErrorIds, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at ActivityCaseErrorSelector.deleteActivityCaseErrors: ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    public static void deleteActivityCaseErrors(List<Activity_Case_Error__c> activityCaseErrors, Boolean allOrNone) {
        try {
            Database.DeleteResult[] results = Database.delete(activityCaseErrors, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at ActivityCaseErrorSelector.deleteActivityCaseErrors: ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    public static void insertActivityCaseErrors(List<Activity_Case_Error__c> activityCaseErrors, Boolean allOrNone) {
        try {
            Database.SaveResult[] results = Database.insert(activityCaseErrors, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at ActivityCaseErrorSelector.insertActivityCaseErrors: ' + e.getMessage());

            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }

    public static void updateActivityCaseErrors(List<Activity_Case_Error__c> activityCaseErrors, Boolean allOrNone) {
        try {
            Database.SaveResult[] results = Database.update(activityCaseErrors, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at ActivityCaseErrorSelector.insertActivityCaseErrors: ' + e.getMessage());

            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }
}