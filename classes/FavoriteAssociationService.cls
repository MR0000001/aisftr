/**
 * Created by SNEKKANTI00 on 14/05/2021.
 */

public with sharing class FavoriteAssociationService {

    public static Set<String> deleteFavoriteAssociationsAndGetFavoriteIds(List<FavoriteAssociation__c> favoriteAssociations, Boolean allOrNone) {
        Set<String> favoriteIds = getFavoriteIdsFromFavorites(favoriteAssociations);

        deleteFavoriteAssociations(favoriteAssociations, allOrNone);

        return favoriteIds;
    }


    public static void deleteFavoriteAssociations(List<FavoriteAssociation__c> favoriteAssociations, Boolean allOrNone) {
        if(favoriteAssociations != null && !favoriteAssociations.isEmpty()) {
            FavoriteAssociationSelector.deleteFavoriteAssociations(favoriteAssociations, allOrNone);
        }
    }

    public static Set<String> getFavoriteIdsFromFavorites(List<FavoriteAssociation__c> favoriteAssociations) {
        Set<String> favoriteIds = new Set<String>();
        for(FavoriteAssociation__c favoriteAssociation : favoriteAssociations) {
            favoriteIds.add(favoriteAssociation.FavoriteId__r.Id);
        }
        return favoriteIds;
    }
}