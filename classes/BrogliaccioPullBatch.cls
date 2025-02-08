/**
 * Created by SNEKKANTI00 on 21/06/2021.
 */

global without sharing class BrogliaccioPullBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {

    private static BrogliaccioBatch_Pull_Setting__c setting = BrogliaccioBatch_Pull_Setting__c.getValues(System.Label.BrogliaccioPull_StateMajor);
    private static BrogliaccioBatch_Pull_Setting__c genericSetting = BrogliaccioBatch_Pull_Setting__c.getValues('BrogliaccioPullBatch');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('START at BrogliaccioPullBatch');

        try {
            DateTime nowTime = datetime.now();
            DateTime lowestTime = nowTime.addHours(-Integer.valueOf(genericSetting.Lowest_Time_Hours__c));
            DateTime upperTime = nowTime.addMinutes(-Integer.valueOf(genericSetting.Upper_Time_Minutes__c));
            String status = genericSetting.Query_Status__c;
            String subStatus = genericSetting.Query_Sub_Status__c;

            String query = 'SELECT Id, Last_Batch_Date_Time__c, CreatedDate, Case_Specification__c, ExternalSystemId_Brogliaccio__c, '
                    + ' Comment_User__c, Sent_to_External__c, ClosedDate__c '
                    + 'FROM Case WHERE '
                    + 'Case.Status =: status AND Case.Sub_Status__c =: subStatus AND ExternalSystemId_Brogliaccio__c != null AND ExternalSystemId_Brogliaccio__c != \'0\' AND LastModifiedDate <: upperTime AND (Last_Batch_Date_Time__c >: lowestTime OR Last_Batch_Date_Time__c = null)';

            return Database.getQueryLocator(query);
        } Catch(Exception e) {
            System.debug('Exception at BrogliaccioPullBatch start: ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        return Database.getQueryLocator('SELECT Id FROM Case LIMIT 0');
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        System.debug('EXECUTE at BrogliaccioPullBatch');
        System.debug('@@@ scope '+ scope.size());
        System.debug('@@@ scope '+ scope);

        CaseService.processBrogliaccioPull(scope);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('FINISH at BrogliaccioPullBatch');
    }

    global static void execute(SchedulableContext ctx) {
        try {
            Database.executeBatch(new BrogliaccioPullBatch(), Integer.valueOf(genericSetting.Batch_Size__c));
        } catch (Exception e) {
            System.debug('Exception at BrogliaccioPullBatch.execute schedule: ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }
}