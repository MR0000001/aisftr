global with sharing class BatchInCreationCaseDelete implements Database.Batchable<SObject>,Schedulable {

    private static FisicalDeleteBatch_Setting__c setting = FisicalDeleteBatch_Setting__c.getValues('BatchInCreationCaseDelete');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime lowestTime = System.now().addDays(-Integer.valueOf(setting.days__c)).addHours(-Integer.valueOf(setting.days__c));
        DateTime upperTime = System.now().addHours(-Integer.valueOf(setting.days__c)); //interessa solo il valore di days__c
        System.debug('lowestTime ' + lowestTime);
        System.debug('upperTime ' + upperTime);
        String query = 'SELECT Id FROM Case WHERE LastModifiedDate <=: upperTime AND LastModifiedDate >=: lowestTime AND Status=\'In Creazione\'';
        system.debug('query -> ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        system.debug('BatchInCreationCaseDelete execute');
        system.debug('@@@ scope '+scope);
        if(!scope.isEmpty()) {
            try {
                CaseService.deleteCases(scope, false);
            } catch (Exception e) {ErrorLogEventHandler.standardExceptionLog(e);}
        }
    }

    global void finish(Database.BatchableContext BC){
        system.debug('BatchInCreationCaseDelete finish');
    }

    global static void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchInCreationCaseDelete(), Integer.valueOf(setting.Batch_Size__c));
    }
}