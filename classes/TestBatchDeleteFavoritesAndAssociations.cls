/**
 * Created by SNEKKANTI00 on 03/06/2021.
 */

@IsTest
public with sharing class TestBatchDeleteFavoritesAndAssociations {
    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createBusinessContacts(accounts);
        List<Favorite__c> favorites = TestDataFactory.createFavorites();
        TestDataFactory.createFavoriteAssociations(favorites, contacts);
    }

    @IsTest
    public static void deleteFavorites() {
        TestDataFactory.createBatchDeleteFavoritesAndAssociations();

        Test.startTest();
        Database.executeBatch(new BatchDeleteFavoritesAndAssociations(), 200);
        System.schedule('TestBatchDeleteFavoritesAndAssociations', '0 17 * ? * * *', new BatchDeleteFavoritesAndAssociations());
        Test.stopTest();
    }

    @IsTest
    public static void deleteFavoritesException() {
        Test.startTest();
        Database.executeBatch(new BatchDeleteFavoritesAndAssociations(), 200);
        System.schedule('TestBatchDeleteFavoritesAndAssociations', '0 17 * ? * * *', new BatchDeleteFavoritesAndAssociations());
        Test.stopTest();
    }
}