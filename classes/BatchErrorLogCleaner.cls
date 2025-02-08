/**
 * Created by snekkanti002 on 16/03/2022.
 */

global without sharing class BatchErrorLogCleaner implements Database.Batchable<SObject>, Schedulable {
    private static Cleaner_Setting__c setting = Cleaner_Setting__c.getValues('ErrorLogCleaner');

    global Database.QueryLocator start(Database.BatchableContext bc) {
        DebugService.printLimits('BatchErrorLogCleaner', 'start', 'start');
        System.debug('setting: ' + setting);

        try {
            Datetime nowTime = Datetime.now();
            Datetime deleteFromDate = nowTime.addDays(-Integer.valueOf(setting.Save_Records_Upto_N_Days__c));

            String query = 'SELECT Id FROM Error_Log__c WHERE CreatedDate <: deleteFromDate';

            return Database.getQueryLocator(query);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchErrorLogCleaner', 'start', e);
        }
        DebugService.printLimits('BatchErrorLogCleaner', 'start', 'end');

        return Database.getQueryLocator('SELECT id FROM Error_Log__c LIMIT 0');
    }

    global void execute(Database.BatchableContext BC, List<Error_Log__c> scope) {
        DebugService.printLimits('BatchErrorLogCleaner', 'execute', 'start');
        DebugService.printList('BatchErrorLogCleaner', 'execute', 'scope', scope, true);

        ErrorLogService.deleteErrorLogs(scope, false);

        DebugService.printLimits('BatchErrorLogCleaner', 'execute', 'end');
    }

    global void finish(Database.BatchableContext BC) {
        DebugService.printLimits('BatchErrorLogCleaner', 'finish', 'start');

        DebugService.printLimits('BatchErrorLogCleaner', 'finish', 'end');
    }

    global static void execute(SchedulableContext ctx) {
        DebugService.printLimits('BatchErrorLogCleaner', 'schedule execute', 'start');
        try {
            Database.executeBatch(new BatchErrorLogCleaner(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchErrorLogCleaner', 'schedule', e);
        }
        DebugService.printLimits('BatchErrorLogCleaner', 'schedule execute', 'end');
    }
}