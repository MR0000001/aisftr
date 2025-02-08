@IsTest
public with sharing class TestBatchDeleteInactiveFavoriteAssoc {

    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createAccounts();
        List<Contact> listContact = new List<Contact>();
        Contact con = new Contact();
        con.LastName = 'Tester';
        con.Persona_Fisica__c = accounts[0].Id;
        insert con;
        listContact.add(con);
        List<Favorite__c> listFavorite = TestDataFactory.createFavorite(1);
        List<FavoriteAssociation__c> listFavoriteAssociations = TestDataFactory.createFavoriteAssociations(listFavorite, listContact);
        for (FavoriteAssociation__c singleFav : listFavoriteAssociations) {
            singleFav.IsActive__c = false;
        }
        update listFavoriteAssociations;
    }

    @IsTest
    public static void TestBatchDeleteInactiveFavoriteAssociation() {
        Test.startTest();
        BatchDeleteFavoritesAndAssociations__c setting = TestDataFactory.createBatchDeleteFavoritesAndAssociations();
        Database.executeBatch(new BatchDeleteInactiveFavoriteAssociation(), Integer.valueOf(setting.Batch_Size__c));
        System.schedule('TestBatchDeleteInactiveFavoriteAssoc', '0 1 * ? * * *', new BatchDeleteInactiveFavoriteAssociation());
        Test.stopTest();
    }
}