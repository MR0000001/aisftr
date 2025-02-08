/**
 * Created by FMARCHEGIA00 on 09/02/2021.
 */

global with sharing class BatchDeleteAccountDraft implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id, isDraft__c FROM Account WHERE isDraft__c = TRUE]);
    }

    global void execute(Database.BatchableContext context,  List<Account> accountsToDelete) {

        System.debug('[BatchDeleteAccountDraft]::[execute]:: accountsToDelete -> ' + accountsToDelete);
        Set<Id> setAllIdsAccountToDelete = new Set<Id>();
        Map<Id, Account> mapAccountsToUpdate = new Map<Id, Account>();

        for (Account singleAccount: accountsToDelete) {
            setAllIdsAccountToDelete.add(singleAccount.Id);
            singleAccount.isDraft__c = false;
            mapAccountsToUpdate.put(singleAccount.Id, singleAccount);
        }

        List<Case> allCasesRealted = [SELECT Id, AccountId FROM Case WHERE AccountId IN: setAllIdsAccountToDelete];
        System.debug('[BatchDeleteAccountDraft]::[execute]:: allCasesRealted -> ' + allCasesRealted);

        for ( Case singleCase : allCasesRealted ) {
            if ( setAllIdsAccountToDelete.contains(singleCase.AccountId) ) {
                setAllIdsAccountToDelete.remove(singleCase.AccountId);
            }
        }

        List<Id> listAllIdsAccountToDelete = new List<Id>();
        List<Account> listAllAccountToUpdate = new List<Account>();
        listAllIdsAccountToDelete.addAll(setAllIdsAccountToDelete);

        for (String key : mapAccountsToUpdate.keySet()) {
            if ( !setAllIdsAccountToDelete.contains(key) ) {
                listAllAccountToUpdate.add(mapAccountsToUpdate.get(key));
            }
        }

        System.debug('[BatchDeleteAccountDraft]::[execute]:: listAllIdsAccountToDelete -> ' + listAllIdsAccountToDelete);
        Database.DeleteResult[] results = Database.delete(listAllIdsAccountToDelete, false);
        System.debug('results -> ' + results);
        List<Error_Log_Event__e> errorLogEvents = new List<Error_Log_Event__e>();
        for(Database.DeleteResult sr : results) {
            if(!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Errore nella cancellazione dell\'account -> ' + err.getStatusCode() + ': ' + err.getMessage());
                    errorLogEvents.add(ErrorLogEventHandler.createEvent(err.getMessage(), true));
                }
            }
        }

        System.debug('[BatchDeleteAccountDraft]::[execute]:: listAllAccountToUpdate -> ' + listAllAccountToUpdate);
        List<Database.SaveResult> upsertResults = Database.update(listAllAccountToUpdate);
        System.debug('results -> ' + upsertResults);
    }

    global void finish(Database.BatchableContext context) {
        System.debug('Batch BatchDeleteAccountDraft finish');
    }

}