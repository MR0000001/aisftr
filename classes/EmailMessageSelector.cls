/**
 * Created by SNEKKANTI00 on 15/04/2021.
 */

public with sharing class EmailMessageSelector {
    public static void insertEmailMessages(List<EmailMessage> emailMessages, Boolean allOrNone) {
        try {
            Database.SaveResult[] results = Database.insert(emailMessages, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch (Exception e) {
            System.debug('Exception at EmailMessageSelector.insertEmailMessages: ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
}