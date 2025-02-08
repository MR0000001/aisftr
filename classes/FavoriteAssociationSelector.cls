/**
 * Created by SNEKKANTI00 on 14/05/2021.
 */

public with sharing class FavoriteAssociationSelector {

    public static void deleteFavoriteAssociations(List<FavoriteAssociation__c> favoriteAssociations, Boolean allOrNone) {
        try {
            Database.DeleteResult[] results = Database.delete(favoriteAssociations, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at FavoriteAssociationSelector.deleteFavoriteAssociations: ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }
}