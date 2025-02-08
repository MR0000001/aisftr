/**
 * Created by SNEKKANTI00 on 14/05/2021.
 */

global without sharing class BatchDeleteFavoritesAndAssociations implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private Set<String> favoriteIds = new Set<String>();
    private static BatchDeleteFavoritesAndAssociations__c setting = BatchDeleteFavoritesAndAssociations__c.getValues('BatchDeleteFavoritesAndAssociations');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('START at BatchDeleteFavoritesAndAssociations');
        try {
            String query = 'SELECT id, FavoriteAssociation__c.FavoriteId__r.Id FROM FavoriteAssociation__c WHERE FavoriteId__r.IsActive__c = false AND FavoriteId__r.LastModifiedDate = TODAY';

            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Exception at BatchDeleteFavoritesAndAssociations.start ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        return Database.getQueryLocator('SELECT id FROM FavoriteAssociation__c LIMIT 0');
    }

    global void execute(Database.BatchableContext BC, List<FavoriteAssociation__c> scope) {
        System.debug('EXECUTE at BatchDeleteFavoritesAndAssociations');
        System.debug('scope.size() ' + scope.size());
        try {
            favoriteIds.addAll(FavoriteAssociationService.deleteFavoriteAssociationsAndGetFavoriteIds(scope, false));
        } catch(Exception e) {
            System.debug('Exception at BatchDeleteFavoritesAndAssociations.execute ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('FINISH at BatchDeleteFavoritesAndAssociations');
        System.debug('favoriteIds.size() from execute ' + favoriteIds.size());

        FavoriteService.appendChildlessDeactivatedFavorites(favoriteIds);
        System.debug('favoriteIds.size() from childless ' + favoriteIds.size());

        FavoriteService.deleteFavorites(new List<String>(favoriteIds), false);
    }

    global static void execute(SchedulableContext sc) {
        System.debug('SCHEDULE at BatchDeleteFavoritesAndAssociations');
        try {
            Database.executeBatch(new BatchDeleteFavoritesAndAssociations(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            System.debug('Exception at BatchDeleteFavoritesAndAssociations scheduled: ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }
}