/**
 * Created by snekkanti002 on 15/12/2022.
 */

global without sharing class BatchRemedyCasesPF implements Database.Batchable<SObject>, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DebugService.printLimits('BatchRemedyCasesPF', 'start', 'start');
        try {
            String query = 'SELECT Fiscal_Code__c, Fiscal_Code__pc FROM Account WHERE Fiscal_Code__c = null AND Fiscal_Code__pc != null AND RecordType.Name = \'Person Account Certificate\' ORDER BY CreatedDate limit 50000';

            return Database.getQueryLocator(query);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchRemedyCasesPF', 'start', e);
        }
        DebugService.printLimits('BatchRemedyCasesPF', 'start', 'end');

        return Database.getQueryLocator('SELECT id FROM Case LIMIT 0');
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        DebugService.printLimits('BatchRemedyCasesPF', 'execute', 'start');
        List<Database.SaveResult> results = new List<Database.SaveResult>();

        try {
            DebugService.printList('BatchRemedyCasesPF', 'execute', 'scope', scope, true);
            for(Account a : scope) {
                a.Fiscal_Code__c = a.Fiscal_Code__pc;
            }
            if(scope != null && !scope.isEmpty()) {
                System.debug(scope + ' is not null or empty');
                results = Database.update(scope, false);
                DebugService.printDatabaseResults('BatchRemedyCasesPF', 'execute', 'results', results);
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchRemedyCasesPF', 'execute', e);
        }
        DebugService.printLimits('BatchRemedyCasesPF', 'execute', 'end');
    }

    global void finish(Database.BatchableContext bc) {
        DebugService.printLimits('BatchRemedyCasesPF', 'finish', 'start');
        DebugService.printLimits('BatchRemedyCasesPF', 'finish', 'end');
    }

    global static void execute(SchedulableContext ctx) {
        DebugService.printLimits('BatchRemedyCasesPF', 'schedule', 'start');
        Database.executeBatch(new BatchRemedyCasesPF(), 2000);
        DebugService.printLimits('BatchRemedyCasesPF', 'schedule', 'end');
    }
}