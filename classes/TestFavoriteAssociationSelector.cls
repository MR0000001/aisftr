/**
 * Created by SNEKKANTI00 on 14/05/2021.
 */

@IsTest
public with sharing class TestFavoriteAssociationSelector {

    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createBusinessContacts(accounts);
        List<Favorite__c> favorites = TestDataFactory.createFavorites();
        TestDataFactory.createFavoriteAssociations(favorites, contacts);
    }

    @IsTest
    public static void deleteFavoriteAssociations() {
        List<FavoriteAssociation__c> favoriteAssociations = [SELECT id FROM FavoriteAssociation__c];

        Test.startTest();
        FavoriteAssociationSelector.deleteFavoriteAssociations(favoriteAssociations, false);
        FavoriteAssociationSelector.deleteFavoriteAssociations(favoriteAssociations, true);
        Test.stopTest();
    }
}