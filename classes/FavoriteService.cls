/**
 * Created by SNEKKANTI00 on 14/05/2021.
 */

public with sharing class FavoriteService {
    public static void deleteFavorites(List<String> favoriteIds, Boolean allOrNone) {
        if(favoriteIds != null && !favoriteIds.isEmpty()) {
            FavoriteSelector.deleteFavorites(favoriteIds, false);
        }
    }

    public static void appendChildlessDeactivatedFavorites(Set<String> favoriteIds) {
        List<Favorite__c> favorites = FavoriteSelector.getDeactivatedFavorites();

        if(favorites != null && !favorites.isEmpty()) {
            for(Favorite__c fav : favorites) {
                favoriteIds.add(fav.Id);
            }
        }
    }
}