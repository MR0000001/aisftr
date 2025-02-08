/**
 * Created by SNEKKANTI00 on 14/05/2021.
 */

@IsTest
public with sharing class TestFavoriteAssociationService {

    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createBusinessContacts(accounts);
        List<Favorite__c> favorites = TestDataFactory.createFavorites();
        TestDataFactory.createFavoriteAssociations(favorites, contacts);
    }

    @IsTest
    public static void deleteFavoriteAssociationsAndGetFavoriteIds() {
        List<String> favoriteIds = new List<String>();
        List<FavoriteAssociation__c> favoriteAssociations = [SELECT id, FavoriteId__r.Id FROM FavoriteAssociation__c];

        Test.startTest();
        FavoriteAssociationService.deleteFavoriteAssociationsAndGetFavoriteIds(favoriteAssociations, false);
        Test.stopTest();
    }
}