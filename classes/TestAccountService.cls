/**
 * Created by snekkanti002 on 24/09/2021.
 */

@IsTest
public with sharing class TestAccountService {

    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createContacts(accounts);

        TestDataFactory.createCasesWithAccountContact(accounts[0].Id, contacts[0].Id);
    }

    @IsTest
    public static void getAccountsForGEDPdfByIds() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Map<String, String> caseIdAccountId = new Map<String, String>();
        caseIdAccountId.put(c.Id, acc.Id);

        Test.startTest();
        AccountService.getAccountsForGEDPdfByIds(caseIdAccountId);
        Test.stopTest();
    }

    @IsTest
    public static void getAccountIdsFromFiscalCode() {
        String fiscalCode = 'FRRGNN41S21G513Y';

        Test.startTest();
        AccountService.getAccountIdsFromFiscalCode(fiscalCode);
        Test.stopTest();
    }

    @IsTest
    public static void getBusinessAccountKeyMap() {
        List<String> businessAccountKeys = new List<String>{'FRRGNN41S21G513Y'};

        Test.startTest();
        AccountService.getBusinessAccountKeyMap(businessAccountKeys);
        Test.stopTest();
    }

    @IsTest
    public static void insertAccounts() {
        List<Account> accounts = new List<Account>();

        Account acc = new Account();

        accounts.add(acc);

        Test.startTest();
        AccountService.insertAccounts(accounts, false);
        AccountService.insertAccounts(accounts, true);
        Test.stopTest();
    }

    @IsTest
    public static void updateAccounts() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        AccountService.updateAccounts(accounts, false);
        AccountService.updateAccounts(new List<Account>{new Account()}, true);
        Test.stopTest();
    }

    @IsTest
    public static void postProcessIAMCallout() {
        List<Account> accounts = [SELECT Id FROM Account];

        Test.startTest();
        AccountService.postProcessIAMCallout(accounts, new ResponseIAM());
        Test.stopTest();
    }
}