/**
 * @description       : XC_BA005_SetupSafetyPointWallets unit tests class
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 18-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_BA005_SetupSafetyPointWallets_TEST {
    @TestSetup
    static void makeData(){
        XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense spl = new XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense('Italy', 'EnelSole', true, true, 50, 0, 5, 3, 3);
        XC_UTIL_SafetyPointsLicenseManagement.createNewSafetyPointsLicenseSettings(spl);

        List<Account> lstAccounts = XC_DF_Account.insertPartnerAccounts(50);

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

    }

    @IsTest
    static void methodTestBatch(){
        
        Test.startTest();
        XC_BA005_SetupSafetyPointWallets setupBatch = new XC_BA005_SetupSafetyPointWallets();
        Database.executeBatch(setupBatch,200);
        Test.stopTest();
        
        Integer scopeSize = [SELECT COUNT() 
                             FROM Account 
                             WHERE XC_SafetyPointsLicenseEnabled__c = true 
                             AND  XC_Partner_Contract_Standby__c = false 
                             AND Gruppo_Merceologico__c = 'LCRI05'];
        System.assertEquals(50, scopeSize, 'Should be 50');
    }

    @IsTest
    private static void executeBatchWithParamsTest() {
        List<Account> accounts = [SELECT Id FROM Account];
        Set<String> accountIds = new Set<String>();
        for(Account a : accounts) {
            accountIds.add(a.Id);
        }
        
        Test.startTest();
        Database.executeBatch(new XC_BA005_SetupSafetyPointWallets(accountIds));
        Test.stopTest();
        
        Integer scopeSize = [SELECT COUNT() 
                             FROM Account 
                             WHERE XC_SafetyPointsLicenseEnabled__c = true 
                             AND  XC_Partner_Contract_Standby__c = false 
                             AND Gruppo_Merceologico__c = 'LCRI05'];
        System.assertEquals(50, scopeSize, 'Should be 50');
    }

    @IsTest
    static void methodTestSchedule(){
        
        Test.startTest();
        XC_BA005_SetupSafetyPointWallets setupBatch = new XC_BA005_SetupSafetyPointWallets();
        String cron = '0 0 * * * ?';
        String jobId = System.schedule('Test Batch Schedule',cron,setupBatch);
        Test.stopTest();
        
        CronTrigger ct = [SELECT TimesTriggered, NextFireTime,CronExpression
                          FROM CronTrigger 
                          WHERE Id = :jobID];
        System.assertEquals(cron, ct.CronExpression, 'Should schedule!');
    }
}