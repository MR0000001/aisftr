/**
 * @description       : XC_UTIL_SafetyPointsWalletManagement unit tests class
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 24-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_UTIL_SafetyPointsWalletManage_TEST {
    @TestSetup
    static void makeData(){
        XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense spl = new XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense('Italy', 'EnelSole', true, true, 50, 0, 5, 3, 3);
        XC_UTIL_SafetyPointsLicenseManagement.createNewSafetyPointsLicenseSettings(spl);

        XC_UTIL_SafetyPointsWalletManagement.SafetyPointsWallet spw = new XC_UTIL_SafetyPointsWalletManagement.SafetyPointsWallet('Italy','EnelSole',1,50,0,50,'Active');
        XC_UTIL_SafetyPointsWalletManagement.createNewSafetyPointWalletSettings(spw);

        List<Account> lstAccounts = XC_DF_Account.insertPartnerAccounts(1); 
        for (Account acc : lstAccounts) {
            acc.Gruppo_Merceologico__c = 'LCRI05';
            acc.XC_Partner_Contract_Standby__c = false;
            acc.XC_SafetyPointsLicenseEnabled__c = false;
            acc.XC_Country__c = 'Italy';
            acc.XC_PartnerType__c = 'Field Service;';
            acc.XC_Segment__c = 'B2C';
            acc.XC_ContractStatus__c = 'Active';
        }
        update lstAccounts;

        XC_SafetyPointWallet__c sfw = XC_UTIL_SafetyPointsWalletManagement.createSingleSafetyPointsWallet(lstAccounts[0].Id,1,40,'Active');//String accountId, Integer walletNumber, Integer balance,String status
        insert sfw;
    }

    @IsTest
    static void methodTestgetSafetyPointsWalletSettings(){
        Set<String> countries = new Set<String>();
        countries.add('Italy');
        Set<String> legalEntities = new Set<String>();
        legalEntities.add('EnelSole');

        Test.startTest();
        Map<String,XC_CS012_SafetyPointsWalletSettings__c> mapSettings = XC_UTIL_SafetyPointsWalletManagement.getSafetyPointsWalletSettings(countries, legalEntities);
        Test.stopTest();

        System.assertEquals(false, mapSettings.isEmpty());
    }

    @IsTest
    static void methodTestgetSpecificSafetyPointsWalletSettings(){
        
        Test.startTest();
        XC_CS012_SafetyPointsWalletSettings__c settings = XC_UTIL_SafetyPointsWalletManagement.getSpecificSafetyPointsWalletSettings('Italy','EnelSole',1);
        Test.stopTest();
        System.debug('settings ='+settings);
        System.assertEquals(true, settings != null);
    }

    @IsTest
    static void methodTestupdateSafetyPointsWalletSettings(){
        XC_UTIL_SafetyPointsWalletManagement.SafetyPointsWallet spw = new XC_UTIL_SafetyPointsWalletManagement.SafetyPointsWallet('Italy','EnelSole',1,30,0,50,'Active');
        
        Test.startTest();
        XC_UTIL_SafetyPointsWalletManagement.updateSafetyPointsWalletSettings(spw);
        Test.stopTest();

        XC_CS012_SafetyPointsWalletSettings__c settings = XC_UTIL_SafetyPointsWalletManagement.getSpecificSafetyPointsWalletSettings('Italy','EnelSole',1);
        System.assertEquals(30, settings.XC_InitialPoints__c);
        
    }

    @IsTest
    static void methodTestcreateSingleSafetyPointsWallet(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        XC_SafetyPointWallet__c sfw = XC_UTIL_SafetyPointsWalletManagement.createSingleSafetyPointsWallet(acc.Id,1,40,'To Be Active');//String accountId, Integer walletNumber, Integer balance,String status
        insert sfw;
        Test.stopTest();
        
        Integer numWallets = XC_UTIL_SafetyPointsWalletManagement.getAccountWalletsNumber(acc.Id);
        System.assertEquals(2, numWallets,'Should be 2 wallets, 1 created on setup already!');
    }

    @IsTest
    static void methodTestgetAccountWallets(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Set<Id> setAccountIds = new Set<Id>();
        setAccountIds.add(acc.Id);

        Test.startTest();
        List<XC_SafetyPointWallet__c> lstSFW = XC_UTIL_SafetyPointsWalletManagement.getAccountWallets(setAccountIds);
        Test.stopTest();
        
    }

    @IsTest
    static void methodTestgetNextAccountsWalletsToActivate(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Set<Id> setAccountIds = new Set<Id>();
        setAccountIds.add(acc.Id);
        
        Test.startTest();
        List<XC_SafetyPointWallet__c> lstSPW = new List<XC_SafetyPointWallet__c>();
        XC_SafetyPointWallet__c sfw1 = XC_UTIL_SafetyPointsWalletManagement.createSingleSafetyPointsWallet(acc.Id,1,50,'To Be Active');//String accountId, Integer walletNumber, Integer balance,String status
        XC_SafetyPointWallet__c sfw2 = XC_UTIL_SafetyPointsWalletManagement.createSingleSafetyPointsWallet(acc.Id,2,40,'To Be Active');//String accountId, Integer walletNumber, Integer balance,String status
        XC_SafetyPointWallet__c sfw3 = XC_UTIL_SafetyPointsWalletManagement.createSingleSafetyPointsWallet(acc.Id,3,20,'To Be Active');//String accountId, Integer walletNumber, Integer balance,String status
        lstSPW.add(sfw1);
        lstSPW.add(sfw2);
        lstSPW.add(sfw3);
        insert lstSPW;
        XC_UTIL_SafetyPointsWalletManagement.getNextAccountsWalletsToActivate(setAccountIds);
        Test.stopTest();
        
        
    }

    @IsTest
    static void methodTestcallFlowUpsertSafetyPointWallet(){
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        XC_UTIL_SafetyPointsWalletManagement.callFlowUpsertSafetyPointWallet(acc);
        Test.stopTest();
        
    }

    @isTest
    static void methodTestgetUsableWallets() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<XC_SafetyPointWallet__c> wallets = XC_UTIL_SafetyPointsWalletManagement.getUsableWallets(acc.Id);
        Test.stopTest();

        System.assertEquals(1, wallets.size(), 'Wallets retrived are different than just one');
        System.assertEquals(1, wallets.get(0).XC_SPW_Number__c, 'First wallet has not been retrieved');
    }

    @IsTest
    static void methodTestisSafetyPointWalletEligibleAccount(){
        List<Account> lstAccs = [SELECT Id,XC_Country__c,XC_ContractStatus__c,RecordTypeId,XC_Partner_Contract_Standby__c,XC_PartnerType__c,XC_Segment__c FROM Account LIMIT 1];
        Set<String> setCountries = new Set<String>();
        Map<String, XC_CS011_SafetyPointsLicenseSettings__c> mapSafetyPointsLicenseSettings = new Map<String, XC_CS011_SafetyPointsLicenseSettings__c>();

        for (Account acc : lstAccs) {
            setCountries.add(acc.XC_Country__c);
        }

        mapSafetyPointsLicenseSettings = XC_UTIL_SafetyPointsLicenseManagement.getSafetyPointsLicenseSettings(setCountries);
        Test.startTest();
        Boolean isEligible = XC_UTIL_SafetyPointsWalletManagement.isSafetyPointWalletEligibleAccount(lstAccs[0], mapSafetyPointsLicenseSettings);
        Test.stopTest();

        System.assertEquals(true, isEligible, 'The account should be eligible');
        
    }

    @IsTest
    static void methodTestgetAccountWalletsList(){
        List<Account> lstAccs = [SELECT Id,XC_Country__c,XC_ContractStatus__c,RecordTypeId,XC_Partner_Contract_Standby__c,XC_PartnerType__c,XC_Segment__c FROM Account LIMIT 1];
        Set<Id> accountIds = new Set<Id>();
        
        for (Account acc : lstAccs) {
            accountIds.add(acc.Id);
        }

        Test.startTest();
        Map<Id, List<XC_SafetyPointWallet__c>> mapAccountWallets = XC_UTIL_SafetyPointsWalletManagement.getAccountWalletsList(accountIds);
        Test.stopTest();
        
        System.assertEquals(false, mapAccountWallets.isEmpty(), 'Should contain wallets from account');
    }
}