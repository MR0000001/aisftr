/**
 * Created by SNEKKANTI00 on 20/04/2021.
 */

public with sharing class SMSSelector {
    public static void insertSMSs(List<SMS__c> smsList, Boolean allOrNone) {
        try {
            Database.SaveResult[] results = Database.insert(smsList, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at SMSSelector.insertSMSs: ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
}