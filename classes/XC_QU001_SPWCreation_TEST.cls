/**
 * @description       : XC_QU001_SafetyPointsWalletsCreation unit tests class
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 18-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_QU001_SPWCreation_TEST {
    @TestSetup
    static void makeData(){
        List<Account> lstAccounts = XC_DF_Account.insertPartnerAccounts(1);

        for (Account acc : lstAccounts) {
            acc.Gruppo_Merceologico__c = 'LCRI05';
            acc.XC_Partner_Contract_Standby__c = false;
            acc.XC_SafetyPointsLicenseEnabled__c = false;
            acc.XC_Country__c = 'Italy';
            acc.XC_ContractStatus__c = 'Active';
        }
        update lstAccounts;
    }

    @IsTest
    static void methodTestQueueable(){
        List<Account> lstAccounts = [SELECT Id,XC_Status__c,Gruppo_Merceologico__c,XC_Partner_Contract_Standby__c,XC_ContractStatus__c,XC_Country__c FROM Account LIMIT 1];
        
        Test.startTest();
        System.enqueueJob(new XC_QU001_SafetyPointsWalletsCreation(lstAccounts));
        Test.stopTest();
        
    }
}