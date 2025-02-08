/**
 * Created by SNEKKANTI00 on 14/05/2021.
 */

@IsTest
public with sharing class TestFavoriteService {

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
        FavoriteService.deleteFavorites(favoriteIds, false);
        Test.stopTest();
    }

    @IsTest
    public static void appendChildlessDeactivatedFavorites() {
        List<Favorite__c> favorites = [SELECT id FROM Favorite__c];
        List<String> favoriteIds = new List<String>();

        for(Favorite__c fav : favorites) {
            favoriteIds.add(fav.Id);
        }

        Test.startTest();
        FavoriteService.appendChildlessDeactivatedFavorites(new Set<String>(favoriteIds));
        Test.stopTest();
    }
}