/**
 * Created by SNEKKANTI00 on 03/06/2021.
 */

@IsTest
public with sharing class TestFavoriteSelector {

    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createBusinessContacts(accounts);
        List<Favorite__c> favorites = TestDataFactory.createFavorites();
        TestDataFactory.createFavoriteAssociations(favorites, contacts);
    }

    @IsTest
    public static void deleteFavorites() {
        List<Favorite__c> favorites = [SELECT id FROM Favorite__c];
        List<String> favoriteIds = new List<String>();

        for(Favorite__c fav : favorites) {
            favoriteIds.add(fav.Id);
        }

        Test.startTest();
        FavoriteSelector.deleteFavorites(favoriteIds, false);
        FavoriteSelector.deleteFavorites(favoriteIds, true);
        Test.stopTest();
    }

    public static void getDeactivatedFavorites() {
        List<Favorite__c> favorites = [SELECT Id FROM Favorite__c];

        Test.startTest();
        List<Favorite__c> result = FavoriteSelector.getDeactivatedFavorites();
        System.assertEquals(favorites.size(), result.size());
        Test.stopTest();
    }
}