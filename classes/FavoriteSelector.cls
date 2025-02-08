/**
 * Created by SNEKKANTI00 on 14/05/2021.
 */

public with sharing class FavoriteSelector {
    private static List<Favorite__c> favorites = new List<Favorite__c>();

    public static void deleteFavorites(List<String> favoriteIds, Boolean allOrNone) {
        try {
            Database.DeleteResult[] results = Database.delete(favoriteIds, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at FavoriteSelector.deleteFavorites: ' + e.getMessage());

            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }

    public static List<Favorite__c> getDeactivatedFavorites() {
        favorites = [SELECT Id FROM Favorite__c WHERE IsActive__c = false AND LastModifiedDate = TODAY];

        return favorites;
    }
}