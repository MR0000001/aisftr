/**
 * @description       : XC_BA007_KPIGoodBehaviorBonus_U unit tests class
 * @author            : rui.pedroteixeira@nttdata.com
 * @group             : 
 * @last modified on  : 30-06-2022
 * @last modified by  : rui.pedroteixeira@nttdata.com
**/
@isTest
public without sharing class XC_BA007_KPIGoodBehaviorBonus_TEST {
    @TestSetup
    static void makeData(){
        XC_CS011_SafetyPointsLicenseSettings__c setting = new XC_CS011_SafetyPointsLicenseSettings__c();
        setting.Name = 'EnelXItalia_Italy_1';
        setting.XC_Country__c = 'Italy';
        setting.XC_DefaultInitialPoints__c = 1;
        setting.XC_DefaultMinimumPoints__c = 0;
        setting.XC_DefaultMaximumPoints__c = 50;
        setting.XC_KPIGoodBehaviorBonusEnabled__c = true;
        setting.XC_SafetyPointsLicenseEnabled__c = true;
        insert setting;

        XC_CS016_KPIGoodBehavior__c settingKPIGoodBehavior = new XC_CS016_KPIGoodBehavior__c();
        settingKPIGoodBehavior.XC_NumberofDaystoCalculateBonus__c = 180;
        insert settingKPIGoodBehavior;

        Account account1 = new Account();
        account1.Name = 'Account Test 1';
        account1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
        account1.XC_SafetyPointsLicenseEnabled__c = true;
        account1.XC_SafetyPointLicenseActivationDate__c = System.now().addDays(-30);
        account1.Country__c = 'Italy';
        insert account1;

        List<XC_SafetyPointWallet__c> wallets = new List<XC_SafetyPointWallet__c>();
        for(Integer i = 1; i <= 3; i++) {
            XC_SafetyPointWallet__c w = new XC_SafetyPointWallet__c();
            w.XC_Account__c = account1.Id;
            w.XC_SPW_Number__c = i;
            w.XC_SPW_Balance__c = 25;
            w.XC_SPW_Status__c = i == 1 ? 'Active' : 'To be Active';
            w.XC_SPW_ActivationDate__c = i == 1 ? System.now().addDays(Integer.valueOf(-settingKPIGoodBehavior.XC_NumberofDaystoCalculateBonus__c)) : System.now();
            wallets.add(w);
        }
        insert wallets;

        Contract contract = new Contract();
        contract.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('giic_ContractforEnel_X').getRecordTypeId();
        contract.AccountId = account1.id;
        contract.Status = 'Draft';
        contract.StartDate = System.today();
        insert contract;

        List<XC_B2BG_QualityCheck__c> lstQualityCheck = new List<XC_B2BG_QualityCheck__c> ();
        XC_B2BG_QualityCheck__c qualityCheck = new XC_B2BG_QualityCheck__c();
        qualityCheck.RecordTypeId = Schema.SObjectType.XC_B2BG_QualityCheck__c.getRecordTypeInfosByDeveloperName().get('XC_B2BG_CAHome_Italy').getRecordTypeId();
        qualityCheck.XC_ContractorCompany__c = account1.id;
        qualityCheck.XC_Contract__c = contract.id;
        qualityCheck.XC_Referent__c = 'Enel';
        qualityCheck.XC_OperationUnit__c = 'HSEQ';
        qualityCheck.XC_ReportDiSopralluogoRedattoIl__c = System.today();
        qualityCheck.XC_StopWorkPolicy__c = false;
        qualityCheck.XC_Over15__c = 'No';
        qualityCheck.XC_Status__c = 'draft';
        qualityCheck.XC_KPI_Serious_NonCompliance__c = false;
        qualityCheck.XC_CheckDate__c = System.today();
        lstQualityCheck.add(qualityCheck);

        XC_B2BG_QualityCheck__c qualityCheck1 = new XC_B2BG_QualityCheck__c();
        qualityCheck1.RecordTypeId = Schema.SObjectType.XC_B2BG_QualityCheck__c.getRecordTypeInfosByDeveloperName().get('XC_B2BG_CAHome_Italy').getRecordTypeId();
        qualityCheck1.XC_ContractorCompany__c = account1.id;
        qualityCheck1.XC_Contract__c = contract.id;
        qualityCheck1.XC_Referent__c = 'Enel';
        qualityCheck1.XC_OperationUnit__c = 'HSEQ';
        qualityCheck1.XC_ReportDiSopralluogoRedattoIl__c = System.today();
        qualityCheck1.XC_StopWorkPolicy__c = false;
        qualityCheck1.XC_Over15__c = 'No';
        qualityCheck1.XC_Status__c = 'draft';
        qualityCheck1.XC_KPI_Serious_NonCompliance__c = false;
        qualityCheck1.XC_CheckDate__c = System.today();
        lstQualityCheck.add(qualityCheck1);
        
        insert lstQualityCheck;

        for (XC_B2BG_QualityCheck__c qualityCheckToUpdate : lstQualityCheck) {
            qualityCheckToUpdate.XC_Status__c = 'Validated';
        }

        update lstQualityCheck;
    }

    @IsTest
    static void methodTestBatch(){
        
        Test.startTest();
        XC_BA007_KPIGoodBehaviorBonus goodBehaviorBonusBatch = new XC_BA007_KPIGoodBehaviorBonus ();
        Database.executeBatch(goodBehaviorBonusBatch, 1);
        Test.stopTest();

        XC_SafetyPointWallet__c wallet = [ SELECT Id,XC_Account__c,XC_SPW_Status__c,XC_SPW_Balance__c FROM XC_SafetyPointWallet__c WHERE XC_SPW_Status__c = 'Active' LIMIT 1]; 

        System.debug('Updated balance: ' + wallet.XC_SPW_Balance__c);
        //System.assertEquals(35, wallet.XC_SPW_Balance__c);
    }
}