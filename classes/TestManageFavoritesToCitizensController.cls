/**
 * Created by FMARCHEGIA00 on 23/07/2021.
 */

@IsTest
private class TestManageFavoritesToCitizensController {

    private static Integer numberOfFavorities = 1;

    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createContacts(accounts);


        List<Favorite__c> listFavorite = TestDataFactory.createFavorite(numberOfFavorities);
        listFavorite[0].IsActive__c = true;
        listFavorite[1].IsActive__c = false;
        update listFavorite;

        TestDataFactory.createFavoriteAssociations(listFavorite, contacts);
    }

    @IsTest
    static void testgetFavorities() {
        Test.startTest();
        Contact resContact = (Contact) [SELECT Id, Name FROM Contact];
        List<List<Object>> resgetFavorities = ManageFavoritesToCitizensController.getFavorities(resContact.Id);
        List<Favorite__c> listFavorite = [SELECT Id, Type__c, Name__c, IsActive__c FROM Favorite__c];
        System.assert(resgetFavorities[0].size() > 0);

        listFavorite[0].IsActive__c = false;
        listFavorite[1].IsActive__c = true;
        update listFavorite;
        resgetFavorities = ManageFavoritesToCitizensController.getFavorities(resContact.Id);
        System.assert(resgetFavorities[0].size() > 0);
        Test.stopTest();
    }

    @IsTest
    static void testsaveFavorities() {
        Test.startTest();
//        List<List<String>> listss = new List<List<String>>( ((a0Y7a00000I7NdpEAF), (a0Y7a00000IQexGEAT)));
        List<List<String>> listsFirstEmpty = new List<List<String>>{
                new List<String>(),
                new List<String>{'a0Y7a00000IQexGEAT'}
        };
        List<List<String>> listsSecondEmpty = new List<List<String>>{
                new List<String>{'a0Y7a00000I7NdpEAF'},
                new List<String>()
        };
        List<List<String>> listsAllFull = new List<List<String>>{
                new List<String>{'a0Y7a00000I7NdpEAF'},
                new List<String>{'a0Y7a00000IQexGEAT'}
        };
        Contact resContact = (Contact) [SELECT Id FROM Contact];
        Boolean ressaveFavorities = ManageFavoritesToCitizensController.saveFavorities(listsFirstEmpty, listsAllFull, resContact.Id);
        ressaveFavorities = ManageFavoritesToCitizensController.saveFavorities(listsSecondEmpty, listsAllFull, resContact.Id);
        Test.stopTest();
    }
}