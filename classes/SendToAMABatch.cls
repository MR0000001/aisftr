global with sharing class SendToAMABatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{

    private static AMABatch_Setting__c setting = AMABatch_Setting__c.getValues('SendToAMABatch');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('START at SendToAMABatch');
        try {
            //AMA_Batch__c settings = [SELECT Batch_Size__c, Lowest_Time_Hours__c, Upper_Time_Minutes__c FROM AMA_Batch__c LIMIT 1];
            DateTime nowTime = datetime.now();
            DateTime lowestTime = nowTime.addHours(-Integer.valueOf(setting.Lowest_Time_Hours__c));
            DateTime upperTime = nowTime.addMinutes(-Integer.valueOf(setting.Upper_Time_Minutes__c));
            String query = 'SELECT Id, Estimated_Queue__c, Current_Queue__c, Prior_Queue__c, checkAnonymous__c, ExternalSystemId_AMALV__c, Last_Batch_Date_Time__c, CaseNumber,Account.FirstName,Account.LastName,ContactPhone,ContactEmail,Case_Theme_Area__c,Street_Address__c,Number_Address__c,Letter_Address__c,CreatedDate,Description,Strada_KO__c,Case_Specification__c, Case_Business_Account__c, Account.Name ' +
                    'FROM Case ' +
                    'WHERE Case.Status != \'Closed\' AND Case.Status != \'In Creazione\' AND Strada_KO__c != true AND LastModifiedDate <: upperTime AND (Last_Batch_Date_Time__c >: lowestTime OR Last_Batch_Date_Time__c = null) AND RecordType.DeveloperName = \'Anomaly\' ' +
                    'AND Case.Type = \'AMA LineaVerde\' AND (Sent_to_External__c = \'Not Sync\' OR Sent_to_External__c = \'To Be Sync\')';

            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Exception at SendToAMABatch start: ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        return Database.getQueryLocator('SELECT id FROM Case LIMIT 0');
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        System.debug('EXECUTE at SendToAMABatch');
        System.debug('@@@ scope '+ scope.size());
        System.debug('@@@ scope '+ scope);
        if(!scope.isEmpty()) {
            try {
                String amaQueueId = GroupsSelector.getGroupByName(setting.group_name__c).Id;
                List<Case> cases = AMACallout.AMACallout(scope, false);
                system.debug('@@@ cases '+cases);
                system.debug('@@@ cases '+cases.size()  );
                for(Case caseSent : cases) {
                    if(caseSent.Last_Batch_Date_Time__c == null) caseSent.Last_Batch_Date_Time__c = Datetime.now();
                    if(String.isNotBlank(caseSent.ExternalSystemId_AMALV__c)) {
                        caseSent.Sent_to_External__c = setting.Sent_to_External__c;
                        caseSent.Status = setting.Status__c;
                        caseSent.Sub_Status__c = setting.Sub_Status__c;
                        //caseSent.Integration_Update_From_WSO2__c = 'AMA Linea Verde';
                        caseSent.OwnerId = amaQueueId;
                        caseSent.Prior_Queue__c = caseSent.Current_Queue__c;
                        caseSent.Current_Queue__c = caseSent.Estimated_Queue__c;
                    }
                }
                CaseService.updateCases(cases, false);
            } catch(Exception e) {
                System.debug('Exception at SendToAMABatch execute: ' + e.getMessage());
                ErrorLogEventHandler.standardExceptionLog(e);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('FINISH at SendToAMABatch');
    }

    global static void execute(SchedulableContext ctx) {
        try {
            //AMA_Batch__c settings = [SELECT Batch_Size__c, Lowest_Time_Hours__c, Upper_Time_Minutes__c FROM AMA_Batch__c LIMIT 1];
            Database.executeBatch(new SendToAMABatch(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            System.debug('Exception at SendToAMABatch execute schedule: ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }
}