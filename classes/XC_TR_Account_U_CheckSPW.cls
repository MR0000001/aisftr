/**
 * @description       : class that contains the logic to activate safety points license and create safety points wallets
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 24-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_TR_Account_U_CheckSPW {

    /**
    * @description activates de safety points license for the accounts on BEFORE INSERT
    * @author pedro.danielalmeida@nttdata.com | 09-05-2022 
    * @param lstNew 
    **/
    public static void setSafetyPointWalletFlag(List<Account> lstNew){
        Set<Id> setAcountsInsertWallets = new Set<Id>();
        Set<String> setCountries = new Set<String>();
        Map<String, XC_CS011_SafetyPointsLicenseSettings__c> mapSafetyPointsLicenseSettings = new Map<String, XC_CS011_SafetyPointsLicenseSettings__c>();
        
        //get Safety Points License settings
        for (Account acc : lstNew) {
            setCountries.add(acc.XC_Country__c);
        }

        mapSafetyPointsLicenseSettings = XC_UTIL_SafetyPointsLicenseManagement.getSafetyPointsLicenseSettings(setCountries);

        //activate flag if account is eligible
        for (Account acc : lstNew) {
            if (XC_UTIL_SafetyPointsWalletManagement.isSafetyPointWalletEligibleAccount(acc,mapSafetyPointsLicenseSettings)) {
                if (acc.Gruppo_Merceologico__c != 'LCRI05') continue;
                acc.XC_SafetyPointsLicenseEnabled__c = true;
                acc.XC_SafetyPointLicenseActivationDate__c = System.now();
            }
        }
    }

    /**
    * @description call flow to create wallets AFTER INSERT on Partner Accounts
    * @author pedro.danielalmeida@nttdata.com | 11-05-2022 
    * @param lstNew 
    **/
    public static void createSafetyPointsWallets(List<Account> lstNew){
        List<Account> lstAccToCreateWallets = new List<Account>();
        for (Account acc : lstNew) {
            if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId()) {
                lstAccToCreateWallets.add(acc);
            }
        }

        //call flows in queueable class
        if (!lstAccToCreateWallets.isEmpty()) {
            System.enqueueJob(new XC_QU001_SafetyPointsWalletsCreation(lstAccToCreateWallets));
        }
    }
}