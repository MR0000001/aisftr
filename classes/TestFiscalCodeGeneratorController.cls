/**
 * Created by SNEKKANTI00 on 13/01/2021.
 */

@isTest
private with sharing class TestFiscalCodeGeneratorController {
    @testSetup static void setup() {
        TestDataFactory.createCommunities();
    }

    @isTest private static void fiscalCodeGeneratorControllerTest() {
        List<Account> accounts = TestDataFactory.createAccounts();
        List<Account> businessAccounts = TestDataFactory.createBusinessAccounts();

        Test.startTest();
        try {
            FiscalCodeGeneratorController.getComputedFiscalCode(businessAccounts[0].Id);
        } catch(Exception e) {
            System.debug('Exception at TestFiscalCodeGeneratorController: ' + e.getMessage());
        }
        try {
            FiscalCodeGeneratorController.getComputedFiscalCode(accounts[1].Id);
        } catch(Exception e) {
            System.debug('Exception at TestFiscalCodeGeneratorController: ' + e.getMessage());
        }

        try {
            FiscalCodeGeneratorController.getExistingAccount('1');
        } catch(Exception e) {
            System.debug('Exception at TestFiscalCodeGeneratorController: ' + e.getMessage());
        }

        Test.stopTest();
    }
}