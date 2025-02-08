/**
 * Created by snekkanti002 on 18/10/2021.
 */

@IsTest
public with sharing class TestAccountSelector {

    @TestSetup
    public static void setup() {
        TestDataFactory.createBusinessAccounts();
    }

    @IsTest
    public static void getAccountById() {
        String accId = [SELECT Id FROM Account LIMIT 1].Id;

        Test.startTest();
        AccountSelector.getAccountById(accId);
        Test.stopTest();
    }

    @IsTest
    public static void getAccountByFiscalCode() {
        String fiscalCode = 'FRRGNN41S21G513Y';

        Test.startTest();
        try {
            AccountSelector.getAccountByFiscalCode(fiscalCode);
        } catch(Exception e) {
            System.debug('Exception '+ e);
        }
        Test.stopTest();
    }

    @IsTest
    public static void getAccountsByFiscalCode() {
        String fiscalCode = 'FRRGNN41S21G513Y';

        Test.startTest();
        AccountSelector.getAccountsByFiscalCode(fiscalCode);
        Test.stopTest();
    }

    @IsTest
    public static void getAccountIdsFromFiscalCode() {
        List<String> businessAccountKeys = new List<String>{'FRRGNN41S21G513Y'};

        Test.startTest();
        AccountSelector.getAccountsByBusinessAccountKeys(businessAccountKeys);
        Test.stopTest();
    }

    @IsTest
    public static void getBussinessAccountId() {
        Test.startTest();
        AccountSelector.getBussinessAccountId();
        Test.stopTest();
    }

    @IsTest
    public static void getAccountsForGEDPdfByIds() {
        String accId = [SELECT Id FROM Account LIMIT 1].Id;

        Test.startTest();
        try {
            AccountSelector.getAccountsForGEDPdfByIds(new List<String>{accId});
        } catch(Exception e) {
            System.debug('Exception ' + e);
        }
        Test.stopTest();
    }

    @IsTest
    public static void getAccountWithGenericConditions() {
        String accId = [SELECT Id FROM Account LIMIT 1].Id;

        Test.startTest();
        try {
            AccountSelector.getAccountWithGenericConditions(new List<String>(), new List<String>(), System.today());
        } catch(Exception e) {
            System.debug('Exception ' + e);
        }
        Test.stopTest();
    }
}