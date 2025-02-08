public without sharing class ManageFavoritesToCitizensController {

    @AuraEnabled
    public static List<List<Object>> getFavorities(String PersonContactId) {
        String table1Type = 'Municipio';
        String table2Type = 'Aree Tematiche';

        List<Favorite__c> favoriteList = [SELECT Id, Type__c, Name__c FROM Favorite__c WHERE IsActive__c = true ORDER BY Sorting__c ASC, Name__c ASC NULLS LAST];
        system.debug('favoriteList -> '+favoriteList);
        List<FavoriteAssociation__c> favoriteAssociationList = [SELECT Id, FavoriteId__r.Type__c, FavoriteId__c FROM FavoriteAssociation__c WHERE IsActive__c = true AND ContactId__c =: PersonContactId];
        system.debug('favoriteAssociationList -> '+ favoriteAssociationList);

        List<Favorite__c> table1List = new List<Favorite__c>();
        List<String> selected1List = new List<String>();
        List<Favorite__c> table2List = new List<Favorite__c>();
        List<String> selected2List = new List<String>();

        for (Favorite__c singleFavorite : favoriteList) {
            if ( singleFavorite.Type__c.equals(table1Type) ) {
                table1List.add(singleFavorite);
            } else if ( singleFavorite.Type__c.equals(table2Type) ) {
                table2List.add(singleFavorite);
            }
        }

        for (FavoriteAssociation__c singleFavoriteAssociation : favoriteAssociationList) {
            if ( singleFavoriteAssociation.FavoriteId__r.Type__c.equals(table1Type) ) {
                selected1List.add(singleFavoriteAssociation.FavoriteId__c);
            } else if ( singleFavoriteAssociation.FavoriteId__r.Type__c.equals(table2Type) ) {
                selected2List.add(singleFavoriteAssociation.FavoriteId__c);
            }
        }

        List<List<Object>> finalList = new List<List<Object>>();
        finalList.add(table1List);
        system.debug('table1List -> ' + table1List);
        finalList.add(selected1List);
        system.debug('selected1List -> ' + selected1List);

        finalList.add(table2List);
        system.debug('table2List -> ' + table2List);
        finalList.add(selected2List);
        system.debug('selected2List -> ' + selected2List);
        system.debug('finalList -> ' + finalList);

        return finalList;
    }

    @AuraEnabled
    public static Boolean saveFavorities(List<List<String>> originalSelected, List<List<String>> finalSelected, String PersonContactId) {
        system.debug('originalSelected -> ' + originalSelected);
        system.debug('finalSelected -> ' + finalSelected);
        system.debug('PersonContactId -> ' + PersonContactId);
        List<String> removedItems = new List<String>();
        List<String> addedItems = new List<String>();
        

        for (Integer step = 0; step <= originalSelected.size()-1; step++ ) {
            system.debug('originalSelected[step] -> '+ originalSelected[step]);
            system.debug('finalSelected[step] -> '+ finalSelected[step]);
            Set<String> oStrings = new Set<String>(originalSelected[step]);
            Set<String> ooriginalStrings = new Set<String>(originalSelected[step]);
            Set<String> fStrings = new Set<String>(finalSelected[step]);
            Set<String> foriginalStrings = new Set<String>(finalSelected[step]);
            oStrings.removeAll(foriginalStrings);
            fStrings.removeAll(ooriginalStrings);
            removedItems.addAll(oStrings);
            addedItems.addAll(fStrings);
        }


        system.debug('removedItems -> '+ removedItems);
        system.debug('addedItems -> '+ addedItems);
        if ( removedItems.size() > 0 ) {
            List<FavoriteAssociation__c> listToIdsToDelete = [SELECT Id FROM FavoriteAssociation__c WHERE FavoriteId__c IN: removedItems AND ContactId__c =: PersonContactId];
            if ( !listToIdsToDelete.isEmpty() ) {
                Database.DeleteResult[] resDel = Database.delete(listToIdsToDelete, false);
                system.debug('resDel -> ' + resDel);
            }
        }

        if ( addedItems.size() > 0 ) {
            List<FavoriteAssociation__c> listFavoriteAssociation = new List<FavoriteAssociation__c>();
            List<FavoriteAssociation__c> listFavoriteToUpdate = new List<FavoriteAssociation__c>();
            Map<Id, FavoriteAssociation__c> mapFavoriteAssociation = new Map<Id, FavoriteAssociation__c>([SELECT Id, IsActive__c, FavoriteId__c FROM FavoriteAssociation__c WHERE FavoriteId__c IN: addedItems AND ContactId__c =: PersonContactId AND IsActive__c = false]);           
            Map<String, Id> setFav = new Map<String, Id>();
            for (String key : mapFavoriteAssociation.keySet()) {
                setFav.put(mapFavoriteAssociation.get(key).FavoriteId__c, mapFavoriteAssociation.get(key).Id);
            }
            for ( String singleItems : addedItems) {
                system.debug('mapFavoriteAssociation -> ' + mapFavoriteAssociation);
                system.debug('singleItems -> ' + singleItems);
                if ( setFav != null && setFav.containsKey(singleItems) ) {
                    FavoriteAssociation__c favUpdate = new FavoriteAssociation__c();
                    favUpdate.Id = setFav.get(singleItems);
                    favUpdate.IsActive__c = true;
                    listFavoriteToUpdate.add(favUpdate);
                } else {
                    FavoriteAssociation__c favAdd = new FavoriteAssociation__c();
                    favAdd.ContactId__c = PersonContactId;
                    favAdd.FavoriteId__c = singleItems;
                    favAdd.isActive__c = true;
                    listFavoriteAssociation.add(favAdd);
                }
            }
            // inserimento
            if ( listFavoriteAssociation != null && listFavoriteAssociation.size() > 0 ) {
                Database.SaveResult[] resAdd = Database.insert(listFavoriteAssociation, false);
                system.debug('resAdd -> ' + resAdd);
            }
            // aggiornamento
            if ( listFavoriteToUpdate != null && listFavoriteToUpdate.size() > 0 ) {
                Database.SaveResult[] updateResult = Database.update(listFavoriteToUpdate, false);
                system.debug('updateResult -> ' + updateResult);
            }            
        }

        return true;
    }

}