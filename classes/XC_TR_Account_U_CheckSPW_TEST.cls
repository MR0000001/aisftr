/**
 * @description       : XC_TR_Account_U_CheckSPW unit test class
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 18-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_TR_Account_U_CheckSPW_TEST {

    @TestSetup
    static void makeData(){
        XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense spl = new XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense('Italy', 'EnelSole', true, true, 50, 0, 5, 3, 3);
        XC_UTIL_SafetyPointsLicenseManagement.createNewSafetyPointsLicenseSettings(spl);
    }

    @IsTest
    static void methodTestSetSafetyPointWalletFlag(){
        
        Test.startTest();
        Account accountToInsert = new Account();
        accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
        accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
        accountToInsert.PrimaryEmail__c = 'test_partner' + (Math.random()*Math.random()) + '@email.com';
        accountToInsert.XC_Status__c = 'Active'; 
        accountToInsert.IdentityType__c='Passport';
        accountToInsert.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
        accountToInsert.Gruppo_Merceologico__c = 'LCRI05';
        accountToInsert.XC_Partner_Contract_Standby__c = false;
        accountToInsert.XC_Country__c = 'Italy';
        accountToInsert.XC_PartnerType__c = 'Field Service;';
        accountToInsert.XC_Segment__c = 'B2C';
        accountToInsert.XC_ContractStatus__c = 'Active';
        insert accountToInsert;
        Test.stopTest();

        Account acc = [SELECT Id,XC_SafetyPointsLicenseEnabled__c FROM Account LIMIT 1]; 
        System.assertEquals(true,acc.XC_SafetyPointsLicenseEnabled__c,'Safety Point License flag should be true');
        
    }

    @IsTest
    static void methodTestCreateSafetyPointsWallets(){
        
        Test.startTest();
        Account accountToInsert = new Account();
        accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
        accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
        accountToInsert.PrimaryEmail__c = 'test_partner' + (Math.random()*Math.random()) + '@email.com';
        accountToInsert.XC_Status__c = 'Active'; 
        accountToInsert.IdentityType__c='Passport';
        accountToInsert.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
        accountToInsert.Gruppo_Merceologico__c = 'LCRI05';
        accountToInsert.XC_Partner_Contract_Standby__c = false;
        accountToInsert.XC_Country__c = 'Italy';
        accountToInsert.XC_PartnerType__c = 'Field Service;';
        accountToInsert.XC_Segment__c = 'B2C';
        accountToInsert.XC_ContractStatus__c = 'Active';
        insert accountToInsert;
        Test.stopTest();
        
    }
}