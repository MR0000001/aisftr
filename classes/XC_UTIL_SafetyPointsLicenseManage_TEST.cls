/**
 * @description       : XC_UTIL_SafetyPointsLicenseManagement unit tests class
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 17-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_UTIL_SafetyPointsLicenseManage_TEST {
    @TestSetup
    static void makeData(){
    
        XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense spl = new XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense('Italy', 'EnelSole', true, true, 50, 0, 5, 3, 3);
        XC_UTIL_SafetyPointsLicenseManagement.createNewSafetyPointsLicenseSettings(spl);
    }

    @IsTest
    static void methodTestgetSpecificSafetyPointsLicenseSettings(){
        
        Test.startTest();
        XC_CS011_SafetyPointsLicenseSettings__c settings = XC_UTIL_SafetyPointsLicenseManagement.getSpecificSafetyPointsLicenseSettings('Italy');
        Test.stopTest();

        System.assertEquals(true, settings != null);
        
    }

    @IsTest
    static void methodTestgetSafetyPointsLicenseSettings(){
        Set<String> countries = new Set<String>();
        countries.add('Italy');

        Test.startTest();
        Map<String,XC_CS011_SafetyPointsLicenseSettings__c> mapSettings = XC_UTIL_SafetyPointsLicenseManagement.getSafetyPointsLicenseSettings(countries);
        Test.stopTest();

        System.assertEquals(false, mapSettings.isEmpty());
        
    }

    @IsTest
    static void methodTestsafetyPointsLicenseIsEnabled(){
        
        Test.startTest();
        XC_UTIL_SafetyPointsLicenseManagement.safetyPointsLicenseIsEnabled('Italy');
        Test.stopTest();
        
        XC_CS011_SafetyPointsLicenseSettings__c settings = XC_UTIL_SafetyPointsLicenseManagement.getSpecificSafetyPointsLicenseSettings('Italy');

        System.assertEquals(true, settings.XC_SafetyPointsLicenseEnabled__c);
    }
    @IsTest
    static void methodTestkpiPlaningPerformanceIsEnabled(){
        
        Test.startTest();
        XC_UTIL_SafetyPointsLicenseManagement.kpiPlaningPerformanceIsEnabled('Italy');
        Test.stopTest();
        
        XC_CS011_SafetyPointsLicenseSettings__c settings = XC_UTIL_SafetyPointsLicenseManagement.getSpecificSafetyPointsLicenseSettings('Italy');

        System.assertEquals(true, settings.XC_KPIPlanningPerformanceEnabled__c);
    }
    @IsTest
    static void methodTestgetSafetyPointsLicenseMaxWallet(){
        
        Test.startTest();
        XC_UTIL_SafetyPointsLicenseManagement.getSafetyPointsLicenseMaxWallet('Italy');
        Test.stopTest();

        XC_CS011_SafetyPointsLicenseSettings__c settings = XC_UTIL_SafetyPointsLicenseManagement.getSpecificSafetyPointsLicenseSettings('Italy');

        System.assertEquals(3, settings.XC_MaxWallets__c);
        
    }
}