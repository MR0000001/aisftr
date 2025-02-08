/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation  06/02/2020 
* @description XC_TR_NbaNbo_TEST – Test class for XC_TR_NbaNbo_Handler
*/ 
@isTest
public class XC_TR_NbaNbo_TEST {
    @isTest
    static void insertTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        XC_NbaNbo__c nbanbo = new XC_NbaNbo__c(XC_AccountId__c = accList[0].Id, XC_Reason__c = 'XCMOT001', XC_Subcause__c = 'ATCL010');
        insert nbanbo;
        Test.stopTest();
        System.assertEquals(false, nbanbo.Id == null);
    }
    
    @isTest
    static void insertTest2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;       
        XC_NbaNbo__c nbanbo = new XC_NbaNbo__c(XC_AccountId__c = accList[0].Id, XC_Reason__c = 'XCMOT001');
        insert nbanbo;
        Test.stopTest();
        System.assertEquals(false, nbanbo.Id == null);
    }
    
     @isTest
    static void updateTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;  
        XC_NbaNbo__c nbanbo = new XC_NbaNbo__c(XC_AccountId__c = accList[0].Id, XC_Reason__c = 'XCMOT001', XC_Subcause__c = 'ATCL010');
        insert nbanbo;   
        update nbanbo;
        Test.stopTest();
        System.assertEquals(false, nbanbo.Id == null);
    }

    @isTest
    static void updateTest2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;         
        XC_NbaNbo__c nbanbo = new XC_NbaNbo__c(XC_AccountId__c = accList[0].Id, XC_Reason__c = 'XCMOT001');
        insert nbanbo;
        nbanbo.XC_Reason__c = 'XCMOT001';
        update nbanbo;
        Test.stopTest();
        System.assertEquals(false, nbanbo.Id == null);
    }
    
    @isTest
    static void deleteTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;       
        XC_NbaNbo__c nbanbo = new XC_NbaNbo__c(XC_AccountId__c = accList[0].Id, XC_Reason__c = 'XCMOT001');
        insert nbanbo;
		delete nbanbo;     
        Test.stopTest();
        System.assertEquals(false, nbanbo.Id == null); 
    }
}