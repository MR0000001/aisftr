/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 17/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_SPLicenseAccount_TEST – Test class for XC_UTIL_SPLicenseAccount class
 */
@IsTest
private without sharing class XC_UTIL_SPLicenseAccount_TEST {
    
    @TestSetup
    private static void testSetup() {
        List<Account> accounts = new List<Account>();
        Account account1 = new Account();
        account1.Name = 'Account Test 1';
        account1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
        account1.XC_SafetyPointsLicenseEnabled__c = true;
        account1.XC_SafetyPointLicenseActivationDate__c = System.now();
        account1.Country__c = 'Italy';
        accounts.add(account1);
        insert accounts;

    }

    @IsTest
    private static void checkActivationDateBetweenRangeTest() {
        Account licenseEnabledAcc = [SELECT Id, XC_SafetyPointLicenseActivationDate__c FROM Account WHERE XC_SafetyPointLicenseActivationDate__c != NULL LIMIT 1];

        Test.startTest();
        Boolean insideRange = XC_UTIL_SPLicenseAccount.checkActivationDateBetweenRange(licenseEnabledAcc, System.today().addDays(-1), System.today().addDays(1));
        Boolean outsideRange = XC_UTIL_SPLicenseAccount.checkActivationDateBetweenRange(licenseEnabledAcc, System.today().addDays(-10), System.today().addDays(-5));
        Test.stopTest();

        System.assertEquals(true, insideRange, 'Activation data inside range not detected');
        System.assertEquals(false, outsideRange, 'Activation data outside range not detected');
    }
}