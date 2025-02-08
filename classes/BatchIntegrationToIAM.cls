/**
 * Created by snekkanti002 on 25/05/2022.
 */

global without sharing class BatchIntegrationToIAM implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    private static IAMBatch_Setting__c setting = IAMBatch_Setting__c.getValues('BatchIntegrationToIAM');

    global Database.QueryLocator start(Database.BatchableContext bc) {
        DebugService.printLimits('BatchIntegrationToIAM', 'start', 'start');
        try {
            Datetime nowTime = Datetime.now();
            Datetime lowestTime = nowTime.addDays(-Integer.valueOf(setting.Lowest_Time_Days__c));
            Datetime upperTime = nowTime.addMinutes(-Integer.valueOf(setting.Upper_Time_Minutes__c));

            String query = 'SELECT Date_Time_Sent_To_IAM__pc, ToBeSentIAM__pc, PersonEmail, PersonHomePhone, PersonMobilePhone, Fax, Fiscal_Code__pc ' +
                    'FROM Account ' +
                    'WHERE LastModifiedDate <: upperTime AND (Date_Time_Sent_To_IAM__pc >: lowestTime OR Date_Time_Sent_To_IAM__pc = null) AND ToBeSentIAM__pc = true ';

            return Database.getQueryLocator(query);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchIntegrationToIAM', 'start', e);
        }
        DebugService.printLimits('BatchIntegrationToIAM', 'start', 'end');
        
        return Database.getQueryLocator('SELECT id FROM Case LIMIT 0');
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        DebugService.printLimits('BatchIntegrationToIAM', 'execute', 'start');
        try {
            DebugService.printList('BatchIntegrationToIAM', 'execute', 'scope', scope, true);

            ResponseIAM responseIAM = IAMCallout.iamCallout(scope);
            if(responseIAM != null) {
                List<Historical_IAM__c> historicalIams = AccountService.postProcessIAMCallout(scope, responseIAM);
                HistoricalIAMService.insertHistoricalIAMs(historicalIams, false);
                AccountService.updateAccounts(scope, false);
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchIntegrationToIAM', 'execute', e);
        }
        DebugService.printLimits('BatchIntegrationToIAM', 'execute', 'end');
    }

    global void finish(Database.BatchableContext bc) {
        DebugService.printLimits('BatchIntegrationToIAM', 'finish', 'start');

        DebugService.printLimits('BatchIntegrationToIAM', 'finish', 'end');
    }

    global static void execute(SchedulableContext ctx) {
        DebugService.printLimits('BatchIntegrationToIAM', 'schedule', 'start');
        try {
            Database.executeBatch(new BatchIntegrationToIAM(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchIntegrationToIAM', 'schedule', e);
        }
        DebugService.printLimits('BatchIntegrationToIAM', 'schedule', 'end');
    }
}