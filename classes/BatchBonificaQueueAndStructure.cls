/**
 * @author            : Davide Desideri
 * @created date      : 
 * @description       : 
 * @testClasses       : TestBatchBonificaQueueAndStructure
 * @last modified by  : Davide Desideri
 * @last modified on  : 07-02-2023
**/
global with sharing class BatchBonificaQueueAndStructure implements Database.Batchable<sObject>,Schedulable{
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DebugService.printLimits('BatchBonificaQueueAndStructure', 'start method', 'start');
        
            String query = 'SELECT id, Estimated_Queue__c, Estimated_Queue_CDC__c, Estimated_Structure__c FROM Case WHERE Estimated_Queue__c != null AND Estimated_Queue_CDC__c = NULL AND Status != \'In Creazione\' AND Current_Queue_CDC__c != null  order by Createddate asc limit 100000';
            return Database.getQueryLocator(query);   
    }

    global void execute(Database.BatchableContext bc, List<Case> scope){
        Map<String,QueueTranscoding__c> mapTransCode = new Map<String,QueueTranscoding__c>();
        for(QueueTranscoding__c t : [SELECT id, Name_Queue_CDC__c, Name_Queue_SFDC__c, Struttura_CDC__c FROM QueueTranscoding__c]){
            mapTransCode.put(t.Name_Queue_SFDC__c,t);
        }

       
            for(Case c : scope){
                if(mapTransCode.containsKey(c.Estimated_Queue__c)){
                    c.Estimated_Queue_CDC__c = mapTransCode.get(c.Estimated_Queue__c).Name_Queue_CDC__c;
                    c.Estimated_Structure__c = mapTransCode.get(c.Estimated_Queue__c).Struttura_CDC__c;
                }
            }
        Database.update(scope, false);
    }

    global void finish(Database.BatchableContext bc) {
        DebugService.printLimits('BatchBonificaQueueAndStructure', 'finish', 'start');

        DebugService.printLimits('BatchBonificaQueueAndStructure', 'finish', 'end');
    }

    global static void execute(SchedulableContext ctx) {
        try {
            Database.executeBatch(new BatchBonificaQueueAndStructure(), 100);
        } catch (Exception e) {
            ErrorLogEventHandler.standardExceptionLog('BatchBonificaQueueAndStructure', 'schedule', e);
        }
    }
    
}