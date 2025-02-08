/**
 * Created by SNEKKANTI00 on 07/01/2021.
 */

@isTest
private with sharing class TestSearchAccountController {

    @testSetup static void setup() {
        TestDataFactory.createWSO2Keys();
        TestDataFactory.createOrgManagementSettings();
    }

    @isTest
    private static void searchAccountControllerTest() {
        List<Account> accounts = TestDataFactory.createAccounts();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAnagrafica());

        Test.startTest();
        SearchAccountController.searchAccount(null, null, null, null, null);
        SearchAccountController.searchAccount(null, null, null, 'PZZGPP45P30F848X', null);
        SearchAccountController.getPersonAccountGenderPicklist();
        SearchAccountController.getRecordTypeForPersonAccount();
        Test.stopTest();
    }

    @isTest
    private static void miscTest() {
        List<Account> accounts = TestDataFactory.createAccounts();

        Test.startTest();
        SearchAccountController.getPersonAccountGenderPicklist();
        SearchAccountController.getRecordTypeForPersonAccount();
        SearchAccountController.updateAccountDraftField(accounts[0].Id);
        Test.stopTest();
    }

    @isTest
    private static void searchAccountControllerMultipleTest() {
        List<Account> accounts = TestDataFactory.createAccounts();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAnagraficaMultiple());

        Test.startTest();
        SearchAccountController.searchAccount(null, null, null, null, null);
        SearchAccountController.searchAccount(null, null, null, 'PZZGPP45P30F848X', null);
        Test.stopTest();
    }
}