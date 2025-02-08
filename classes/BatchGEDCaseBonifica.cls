/**
 * Created by snekkanti002 on 13/06/2022.
 */

global without sharing class BatchGEDCaseBonifica implements Database.Batchable<SObject>, Schedulable {
    private static GEDCaseBatch_Setting__c setting = GEDCaseBatch_Setting__c.getValues('BatchGEDCaseBonifica');

    global Database.QueryLocator start(Database.BatchableContext bc) {
        DebugService.printLimits('BatchGEDCaseBonifica', 'start', 'start');
        try {
            Datetime timeBefore = System.now() - setting.Number_of_Days_Before_to_Consider__c;

            String query = 'SELECT ToBeSentGED__c, Protocol_Number__c, YearProtocol__c, ID_Protocollo__c, DateTimeProtocol__c, GEDCasePDF__c, Status, Sent_to_External__c, All_Content_Versions_Integrated_GED__c, Last_Batch_Date_Time__c, LastModifiedDate, COD_DOC__c, COD_SIS__c, DOC_LOGIC__c, ProtocolCFUser__c, Account.Gender__pc, Account.Name, Account.Fiscal_Code__pc, Account.PersonBirthdate, Account.PersonEmail, Account.PersonOtherStreet, Account.PersonOtherState, Account.PersonOtherPostalCode, Account.PersonOtherCity, Subject ' +
                    'FROM Case WHERE ID_Protocollo__c != null AND Status != \'In Creazione\' AND ToBeSentGED__c = true AND All_Content_Versions_Integrated_GED__c = false AND (DateTimeProtocol__c >: timeBefore)';

            system.debug('query: '+ query);
            DebugService.printLimits('BatchGEDCaseBonifica', 'start', 'end');

            return Database.getQueryLocator(query);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchGEDContentVersion', 'start', e);
        }
        DebugService.printLimits('BatchGEDCaseBonifica', 'start', 'end exception');
        return Database.getQueryLocator('SELECT id FROM Case LIMIT 0');
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        DebugService.printLimits('BatchGEDCaseBonifica', 'execute', 'start');
        DebugService.printList('BatchGEDCaseBonifica', 'execute', 'scope', scope, true);
        try {
            CaseService.updateAllAttachmentsIntegratedGED(scope);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchGEDContentVersion', 'execute', e);
        }
        DebugService.printLimits('BatchGEDCaseBonifica', 'execute', 'end');
    }

    global void finish(Database.BatchableContext bc) {
        DebugService.printLimits('BatchGEDCaseBonifica', 'finish', 'start');
        DebugService.printLimits('BatchGEDCaseBonifica', 'finish', 'end');
    }

    global static void execute(SchedulableContext ctx) {
        try {
            Database.executeBatch(new BatchGEDCaseBonifica(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchGEDCaseBonifica', 'schedule', e);
        }
    }
}