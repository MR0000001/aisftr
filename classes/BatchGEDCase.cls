/**
 * Created by SNEKKANTI00 on 14/07/2021.
 */

global without sharing class BatchGEDCase implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    private static GEDCaseBatch_Setting__c setting = GEDCaseBatch_Setting__c.getValues('BatchGEDCase');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('START at BatchGEDCase');
        try {
            Datetime nowTime = Datetime.now();
            Datetime lowestTime = nowTime.addHours(-Integer.valueOf(setting.Lowest_Time_Hours__c));
            Datetime upperTime = nowTime.addMinutes(-Integer.valueOf(setting.Upper_Time_Minutes__c));

            String query = 'SELECT CaseNumber, ToBeSentGED__c, Protocol_Number__c, DateTimeProtocol__c, GEDCasePDF__c, Status, Sent_to_External__c, All_Content_Versions_Integrated_GED__c, Last_Batch_Date_Time_GED__c, LastModifiedDate, COD_DOC__c, COD_SIS__c, DOC_LOGIC__c, ProtocolCFUser__c, Case_Business_Account__c, Account.Gender__pc, Account.Account_Fiscal_Code__c, Account.Partita_IVA__c, Account.Email_Account__c, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity, Account.BillingState, Account.FirstName, Account.LastName, Account.Name, Account.Fiscal_Code__pc, Account.PersonBirthdate, Account.PersonEmail, Account.PersonOtherStreet, Account.PersonOtherState, Account.PersonOtherPostalCode, Account.PersonOtherCity, Persona_Fisica__r.PersonBirthdate, Subject ' +
                    'FROM Case ' +
                    'WHERE ToBeSentGED__c = true AND Status != \'In Creazione\' AND ID_Protocollo__c = null AND LastModifiedDate <: upperTime AND (Last_Batch_Date_Time_GED__c >: lowestTime OR Last_Batch_Date_Time_GED__c = null) AND (ProtocolCFUser__c != null AND COD_SIS__c != null AND COD_DOC__c != null AND DOC_LOGIC__c != null)';

            return Database.getQueryLocator(query);
        } catch(Exception e) {
            DebugService.printException('BatchGEDCase', 'start', e);
            ErrorLogEventHandler.standardExceptionLog(e);

        }
        return Database.getQueryLocator('SELECT id FROM Case LIMIT 0');
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        System.debug('EXECUTE at BatchGEDCase start');
        DebugService.printList('BatchGEDCase', 'execute', 'scope', scope);
        try {
            CaseService.processGEDCases(scope);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchGEDCase', 'execute', e);
        }
        System.debug('EXECUTE at BatchGEDCase end');
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('FINISH at BatchGEDCase start');
        ContentVersionService.batchGEDContentVersion();
        System.debug('FINISH at BatchGEDCase end');
    }

    global static void execute(SchedulableContext ctx) {
        try {
            Database.executeBatch(new BatchGEDCase(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchGEDCase', 'schedule', e);
        }
    }
}