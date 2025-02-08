/**
 * Created by snekkanti002 on 22/11/2022.
 */

global without sharing class BatchHistoricalIAMCleaner implements Database.Batchable<SObject>, Schedulable {
    private static Cleaner_Setting__c setting = Cleaner_Setting__c.getValues('HistoricalIAMCleaner');

    global Database.QueryLocator start(Database.BatchableContext bc) {
        DebugService.printLimits('BatchHistoricalIAMCleaner', 'start', 'start');
        System.debug('setting ' + setting);

        try {
            Datetime nowTime = Datetime.now();
            Datetime dateFromToDelete = nowTime.addDays(-Integer.valueOf(setting.Save_Records_Upto_N_Days__c));

            String query = 'SELECT Id FROM Historical_IAM__c WHERE CreatedDate <: dateFromToDelete';

            return Database.getQueryLocator(query);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchHistoricalIAMCleaner', 'start', e);
        }
        DebugService.printLimits('BatchHistoricalIAMCleaner', 'start', 'end');

        return Database.getQueryLocator('SELECT id FROM Case LIMIT 0');
    }

    global void execute(Database.BatchableContext bc, List<Historical_IAM__c> scope) {
        DebugService.printLimits('BatchHistoricalIAMCleaner', 'execute', 'start');
        DebugService.printList('BatchHistoricalIAMCleaner', 'execute', 'scope', scope, true);

        HistoricalIAMService.deleteHistoricalIAMs(scope, false);

        DebugService.printLimits('BatchHistoricalIAMCleaner', 'execute', 'end');
    }

    global void finish(Database.BatchableContext bc) {
        DebugService.printLimits('BatchHistoricalIAMCleaner', 'finish', 'start');

        DebugService.printLimits('BatchHistoricalIAMCleaner', 'finish', 'end');
    }

    global static void execute(SchedulableContext ctx) {
        DebugService.printLimits('BatchHistoricalIAMCleaner', 'schedule', 'start');
        try {
            Database.executeBatch(new BatchHistoricalIAMCleaner(), Integer.valueOf(setting.Batch_Size__c));
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchHistoricalIAMCleaner', 'schedule', e);
        }
        DebugService.printLimits('BatchHistoricalIAMCleaner', 'schedule', 'end');
    }
}