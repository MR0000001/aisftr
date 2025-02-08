/**
 * Created by snekkanti002 on 16/03/2022.
 */

global without sharing class BatchCalloutLogCleaner implements Database.Batchable<SObject>, Schedulable {
    private static Cleaner_Setting__c setting = Cleaner_Setting__c.getValues('CalloutLogCleaner');

    global Database.QueryLocator start(Database.BatchableContext bc) {
        DebugService.printLimits('BatchCalloutLogCleaner', 'start', 'start');
        System.debug('setting: ' + setting);

        try {
            Datetime nowTime = Datetime.now();
            Datetime deleteFromDate = nowTime.addDays(-Integer.valueOf(setting.Save_Records_Upto_N_Days__c));

            String query = 'SELECT Id FROM Callout_Logger__c WHERE CreatedDate <: deleteFromDate';

            return Database.getQueryLocator(query);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchCalloutLogCleaner', 'start', e);
        }
        DebugService.printLimits('BatchCalloutLogCleaner', 'start', 'end');

        return Database.getQueryLocator('SELECT id FROM Callout_Logger__c LIMIT 0');
    }

    global void execute(Database.BatchableContext BC, List<Callout_logger__c> scope) {
        DebugService.printLimits('BatchCalloutLogCleaner', 'execute', 'start');
        DebugService.printList('BatchCalloutLogCleaner', 'execute', 'scope', scope, true);

        CalloutLoggerService.deleteCalloutLoggers(scope, false);

        DebugService.printLimits('BatchCalloutLogCleaner', 'execute', 'end');
    }

    global void finish(Database.BatchableContext BC) {
        DebugService.printLimits('BatchCalloutLogCleaner', 'finish', 'start');

        DebugService.printLimits('BatchCalloutLogCleaner', 'finish', 'end');
    }

    global static void execute(SchedulableContext ctx) {
        DebugService.printLimits('BatchCalloutLogCleaner', 'schedule execute', 'start');
        try {
            Database.executeBatch(new BatchCalloutLogCleaner(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchCalloutLogCleaner', 'schedule', e);
        }
        DebugService.printLimits('BatchCalloutLogCleaner', 'schedule execute', 'end');
    }
}