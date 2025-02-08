/**
 * Created by snekkanti002 on 09/09/2021.
 */

public without sharing class OpenDataSelector {

    public static void insertOpenDataLogs(List<Opendata_log__c> opendataLogs, Boolean allOrNone) {
        try {
            Database.SaveResult[] results = Database.insert(opendataLogs, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at OpenDataSelector.insertOpenDataLogs: ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }
}