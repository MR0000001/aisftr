/**
 * Created by snekkanti002 on 16/03/2022.
 */

public without sharing class ErrorLogService {

    public static Database.DeleteResult[] deleteErrorLogs(List<Error_Log__c> errorLogs, Boolean allOrNone) {
        DebugService.printLimits('ErrorLogService', 'deleteErrorLogs', 'start');
        Database.DeleteResult[] results = new List<Database.DeleteResult>();

        if(errorLogs != null && !errorLogs.isEmpty()) {
            try {
                results = Database.delete(errorLogs, allOrNone);
                ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
            } catch(Exception e) {
                ErrorLogEventHandler.standardExceptionLog('ErrorLogService', 'deleteErrorLogs', e);
            }
        }

        DebugService.printList('ErrorLogService', 'deleteErrorLogs', 'results', results, true);
        DebugService.printLimits('ErrorLogService', 'deleteErrorLogs', 'end');

        return results;
    }

}