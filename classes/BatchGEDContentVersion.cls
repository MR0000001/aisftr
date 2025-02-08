/**
 * Created by snekkanti002 on 15/07/2021.
 */

global without sharing class BatchGEDContentVersion implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private static GEDCaseBatch_Setting__c setting = GEDCaseBatch_Setting__c.getValues('BatchGEDCase');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('START at BatchGEDContentVersion');
        try {
            Datetime timeBefore = System.now() - setting.Number_of_Days_Before_to_Consider__c;

            String query = 'SELECT ToBeSentGED__c, Protocol_Number__c, YearProtocol__c, ID_Protocollo__c, DateTimeProtocol__c, GEDCasePDF__c, Status, Sent_to_External__c, All_Content_Versions_Integrated_GED__c, Last_Batch_Date_Time__c, LastModifiedDate, COD_DOC__c, COD_SIS__c, DOC_LOGIC__c, ProtocolCFUser__c, Account.Gender__pc, Account.Name, Account.Fiscal_Code__pc, Account.PersonBirthdate, Account.PersonEmail, Account.PersonOtherStreet, Account.PersonOtherState, Account.PersonOtherPostalCode, Account.PersonOtherCity, Subject ' +
                    'FROM Case WHERE ID_Protocollo__c != null AND Status != \'In Creazione\' AND ToBeSentGED__c = true AND All_Content_Versions_Integrated_GED__c = false AND (DateTimeProtocol__c >: timeBefore)';

            System.debug('query -> '+ query);
            return Database.getQueryLocator(query);
        } catch(Exception e) {
            DebugService.printException('BatchGEDContentVersion', 'start', e);
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        return Database.getQueryLocator('SELECT id FROM Case LIMIT 0');
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        System.debug('EXECUTE at BatchGEDContentVersion start');
        System.debug(scope[0].DateTimeProtocol__c);
        System.debug('scope -> ' + scope);

        if (scope != null && scope.size() > 0) {
            try {
                System.debug('Entered try');
                ContentVersionService.processBatchGEDContentVersions(scope);
            } catch (Exception e) {
                System.debug('Entered catch');
                DebugService.printException('BatchGEDContentVersion', 'execute', e);
                ErrorLogEventHandler.standardExceptionLog(e);
            }
        }
        System.debug('EXECUTE at BatchGEDContentVersion end');
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('FINISH at BatchGEDContentVersion start');
        List<SendContentVersionToGed__e> sendContentVersionToGeds = new List<SendContentVersionToGed__e>();
        sendContentVersionToGeds.add(new SendContentVersionToGed__e());
        DebugService.printList('BatchGEDContentVersion', 'Finish', 'sendContentVersionToGeds', sendContentVersionToGeds);
        List<Database.SaveResult> results = EventBus.publish(sendContentVersionToGeds);
        DebugService.printDatabaseResults('BatchGEDContentVersion', 'Finish', 'sendContentVersionToGeds', results);
        System.debug('FINISH at BatchGEDContentVersion end');
    }
}