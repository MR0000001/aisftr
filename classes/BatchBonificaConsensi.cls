/**
 * Created by snekkanti002 on 19/05/2022.
 */

global without sharing class BatchBonificaConsensi implements Database.Batchable<SObject>, Schedulable {
    private static ConsentsBatch_Setting__c setting = ConsentsBatch_Setting__c.getValues('BatchBonificaConsensi');

    global Database.QueryLocator start(Database.BatchableContext bc) {
        DebugService.printLimits('BatchBonificaConsensi', 'start method', 'start');
        Date numDays = System.today() - Integer.valueOf(setting.Consents_Expiry_Num_Days__c);
        System.debug('numDays: ' + numDays);
        try {
            String query = 'SELECT Privacy_Newsletter__pc, Date_Privacy_Newsletter__pc, Origin_Privacy_Newsletter__pc, Privacy_Profiling__pc, Date_Privacy_Profiling__pc, Origin_Privacy_Profiling__pc, Privacy_Personal_Data__pc, Date_Privacy_Personal_Data__pc, Origin_Privacy_Personal_Data__pc  ' +
                    'FROM account ' +
                    'WHERE (Privacy_Newsletter__pc = true AND Date_Privacy_Newsletter__pc <=: numDays) OR (Privacy_Profiling__pc = true AND Date_Privacy_Profiling__pc <=: numDays) OR (Privacy_Personal_Data__pc = true AND Date_Privacy_Personal_Data__pc <=: numDays)';

            return Database.getQueryLocator(query);
        } catch(Exception e) {
            DebugService.printException('BatchBonificaConsensi', 'start', e);
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        DebugService.printLimits('BatchBonificaConsensi', 'start method', 'end');
        return Database.getQueryLocator('SELECT id FROM Case LIMIT 0');
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        DebugService.printLimits('BatchBonificaConsensi', 'execute', 'start');
        DebugService.printList('BatchBonificaConsensi', 'execute', 'scope', scope, true);
        Date numDays = System.today() - Integer.valueOf(setting.Consents_Expiry_Num_Days__c);

        for(Account acc : scope) {
            if(acc.Privacy_Newsletter__pc && acc.Date_Privacy_Newsletter__pc <= numDays) {
                System.debug('in privacy newsletter');
                acc.Privacy_Newsletter__pc = false;
                acc.Date_Privacy_Newsletter__pc = null;
                acc.Origin_Privacy_Newsletter__pc = null;
            }
            if(acc.Privacy_Profiling__pc && acc.Date_Privacy_Profiling__pc <= numDays) {
                System.debug('in privacy profiling');
                acc.Privacy_Profiling__pc = false;
                acc.Date_Privacy_Profiling__pc = null;
                acc.Origin_Privacy_Profiling__pc = null;
            }
            if(acc.Privacy_Personal_Data__pc && acc.Date_Privacy_Personal_Data__pc <= numDays) {
                System.debug('in privacy personal data');
                acc.Privacy_Personal_Data__pc = false;
                acc.Date_Privacy_Personal_Data__pc = null;
                acc.Origin_Privacy_Personal_Data__pc = null;
            }
        }
        AccountService.updateAccounts(scope, false);
        DebugService.printLimits('BatchBonificaConsensi', 'execute', 'end');
    }

    global void finish(Database.BatchableContext bc) {
        DebugService.printLimits('BatchBonificaConsensi', 'finish', 'start');

        DebugService.printLimits('BatchBonificaConsensi', 'finish', 'end');
    }

    global static void execute(SchedulableContext ctx) {
        DebugService.printLimits('BatchBonificaConsensi', 'schedule', 'start');
        try {
            Database.executeBatch(new BatchBonificaConsensi(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchBonificaConsensi', 'schedule', e);
        }
        DebugService.printLimits('BatchBonificaConsensi', 'schedule', 'end');
    }
}