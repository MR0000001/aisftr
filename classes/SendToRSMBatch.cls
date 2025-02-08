global with sharing class SendToRSMBatch implements Database.Batchable<SObject>, Database.AllowsCallouts,Schedulable{

    private static RSMBatch_Setting__c setting = RSMBatch_Setting__c.getValues('SendToRSMBatch');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('START at SendToRSMBatch');
        try {
            //RSM_Batch__c settings = [SELECT Batch_Size__c, Lowest_Time_Hours__c, Upper_Time_Minutes__c FROM RSM_Batch__c LIMIT 1];
            DateTime nowTime = datetime.now();
            DateTime lowestTime = nowTime.addHours(-Integer.valueOf(setting.Lowest_Time_Hours__c));
            DateTime upperTime = nowTime.addMinutes(-Integer.valueOf(setting.Upper_Time_Minutes__c));
            String query = 'SELECT Id, Estimated_Queue__c, Current_Queue__c, Prior_Queue__c, Start_Day_Access__c,OwnerId,Status,Sub_Status__c,Closed_Reason__c,Finish_Day_Access__c,CaseNumber,License_plate__c, Concession_Number__c,Concession_Municipality__c,ID_Comune__c, Sent_to_External__c, Last_Batch_Date_Time__c ' +
                    'FROM Case ' +
                    'WHERE  Case.Status != \'Closed\' AND Case.Status != \'In Creazione\' AND checkAnonymous__c = false AND LastModifiedDate <: upperTime AND (Last_Batch_Date_Time__c >: lowestTime OR Last_Batch_Date_Time__c = null) AND RecordType.DeveloperName = \'ZTL\' AND (Sent_to_External__c = \'Not Sync\' OR Sent_to_External__c = \'To Be Sync\')';
                    

            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Exception at SendToRSMBatch start: ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        return Database.getQueryLocator('SELECT id FROM Case LIMIT 0');
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        System.debug('EXECUTE at SendToRSMBatch');
        System.debug('@@@ scope '+ scope);
        System.debug('@@@ scope '+ scope.size());
        if(!scope.isEmpty()) {
            try {
                String rsmQueueId = GroupsSelector.getGroupByName(setting.group_name__c).Id;
                List<Case> cases = RSMCallout.RSMCallout(scope);
                system.debug('@@@ cases '+cases);
                system.debug('@@@ cases '+cases.size());
                if(cases.isEmpty()) {
                    for(Case caseSent : scope) {
                        if(caseSent.Last_Batch_Date_Time__c == null) caseSent.Last_Batch_Date_Time__c = Datetime.now();
                        caseSent.Sent_to_External__c = 'Not Sync';
                    }
                }
                for(Case caseSent : cases) {
                    if(caseSent.Last_Batch_Date_Time__c == null) caseSent.Last_Batch_Date_Time__c = Datetime.now();
                    if(caseSent.Sent_to_External__c.equalsIgnoreCase(setting.Sent_to_External__c)) {
                        caseSent.Sent_to_External__c = setting.Sent_to_External__c;
                        caseSent.Status = setting.Status__c;
                        caseSent.Sub_Status__c = setting.Sub_Status__c;
                        caseSent.Closed_Reason__c = setting.Closed_Reason__c;
                        caseSent.OwnerId = rsmQueueId;
                        caseSent.Prior_Queue__c = caseSent.Current_Queue__c;
                        caseSent.Current_Queue__c = caseSent.Estimated_Queue__c;
                        caseSent.is_from_batch__c = true;
                    }
                }
                CaseService.updateCases(cases, false);
            } catch(Exception e) {
                System.debug('Exception at SendToRSMBatch execute: ' + e.getMessage());
                ErrorLogEventHandler.standardExceptionLog(e);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('FINISH at SendToRSMBatch');
    }
    global static void execute(SchedulableContext ctx) {
        System.debug('EXECUTE at SendToRSMBatch schedule');
        try {
            //RSM_Batch__c settings = [SELECT Batch_Size__c, Lowest_Time_Hours__c, Upper_Time_Minutes__c FROM RSM_Batch__c LIMIT 1];
            Database.executeBatch(new SendToRSMBatch(),  Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            System.debug('Exception at SendToRSMBatch  execute schedule: ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }
}