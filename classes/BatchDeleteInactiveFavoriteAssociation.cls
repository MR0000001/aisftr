/**
 * Created by FaMa on 25/05/2021.
 */

global with sharing class BatchDeleteInactiveFavoriteAssociation implements Database.Batchable<SObject>, Schedulable {

    private static BatchDeleteFavoritesAndAssociations__c setting = BatchDeleteFavoritesAndAssociations__c.getValues('BatchDeleteFavoritesAndAssociations');


    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('START at BatchDeleteInactiveFavoriteAssociation');
        String query = 'SELECT Id FROM FavoriteAssociation__c WHERE isActive__c = false';
        system.debug('query -> ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<FavoriteAssociation__c> scope) {
        System.debug('EXECUTE at BatchDeleteInactiveFavoriteAssociation');
        Database.delete(scope, false);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('FINISH at BatchDeleteInactiveFavoriteAssociation');
    }

    global static void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchDeleteInactiveFavoriteAssociation(), Integer.valueOf(setting.Batch_Size__c));
    }
}