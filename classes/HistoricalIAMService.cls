/**
 * Created by snekkanti002 on 26/05/2022.
 */

public without sharing class HistoricalIAMService {
    public static List<Database.SaveResult> insertHistoricalIAMs(List<Historical_IAM__c> historicalIAMs, Boolean allOrNone) {
        DebugService.printLimits('HistoricalIAMService', 'insertHistoricalIAMs', 'start');
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        if(historicalIAMs != null && !historicalIAMs.isEmpty()) {
            System.debug('historicalIAMs is not null or empty');
            try {
                results = Database.insert(historicalIAMs, allOrNone);
            } catch(Exception e) {
                ErrorLogEventHandler.standardExceptionLog('HistoricalIAMService', 'insertHistoricalIAMs', e);
            }
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
            DebugService.printDatabaseResults('HistoricalIAMService', 'insertHistoricalIAMs', 'results', results);
        }
        DebugService.printLimits('HistoricalIAMService', 'insertHistoricalIAMs', 'end');

        return results;
    }

    public static List<Database.DeleteResult> deleteHistoricalIAMs(List<Historical_IAM__c> historicalIAMs, Boolean allOrNone) {
        DebugService.printLimits('HistoricalIAMService', 'deleteHistoricalIAMs', 'start');
        List<Database.DeleteResult> results = new List<Database.DeleteResult>();
        if(historicalIAMs != null && !historicalIAMs.isEmpty()) {
            System.debug('historicalIAMs is not null or empty');
            try {
                results = Database.delete(historicalIAMs, allOrNone);
            } catch(Exception e) {
                ErrorLogEventHandler.standardExceptionLog('HistoricalIAMService', 'deleteHistoricalIAMs', e);
            }
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
            DebugService.printDatabaseResults('HistoricalIAMService', 'deleteHistoricalIAMs', 'results', results);
        }
        DebugService.printLimits('HistoricalIAMService', 'deleteHistoricalIAMs', 'end');

        return results;
    }
}