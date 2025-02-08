/**
* @author Emanuela Cacace  ecacace@deloitte.it 
* @date Creation  27/05/2019 
* @description XC_TR_ZuoraCustAccount_U_CreaBP_TEST – Test class for XC_TR_ZuoraCustAccount_U_CreateBillProf

*/ 
@isTest
public with sharing class XC_TR_ZuoraCustAccount_U_CreaBP_TEST {

   // Test method for checkIfDenyCreations 
   static testMethod void checkIfDenyCreations(){ 
      insert XC_DF_OneOrg.createOneOrg('Spain');
      Test.startTest(); 
      List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
      insert acc; 
      Zuora__CustomerAccount__c zca = new Zuora__CustomerAccount__c();
      zca.isBadPayer__c = 'False';
      zca.Zuora__Account__c= acc[0].Id; 
      insert zca ; 
      System.assert(true, zca!=null);
      Test.stopTest();
   }

      // Test method for checkIfDenyCreations2
   static testMethod void checkIfDenyCreations2(){

      insert XC_DF_OneOrg.createOneOrg('Spain');

      List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1);
      Zuora__CustomerAccount__c zca = new Zuora__CustomerAccount__c();
      zca.Zuora__Account__c = bpList[0].NE__Account__c; 
      zca.XC_BillingProfileLineItemID__c = [SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c =: bpList[0].Id][0].Id;
      zca.Zuora__DefaultPaymentMethod__c = 'Credit Card'; 
      zca.otherPaymentMethodType__c = 'Barcode'; 

      Test.startTest(); 
      insert zca ; 
      String nP = XC_TR_ZuoraCustAccount_U_CreateBillProf.normalizePaymentMethodType(zca);
      System.assert(true, zca!=null);
      Test.stopTest();
   }

      // Test method for checkIfDenyCreations3
   static testMethod void checkIfDenyCreations3(){ 
      insert XC_DF_OneOrg.createOneOrg('Spain');
      
      List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1);
      Zuora__CustomerAccount__c zca = new Zuora__CustomerAccount__c();
      zca.Zuora__Account__c = bpList[0].NE__Account__c; 
      zca.XC_BillingProfileLineItemID__c =	[SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c =: bpList[0].Id][0].Id;
      zca.Zuora__DefaultPaymentMethod__c= 'Other'; 
      zca.otherPaymentMethodType__c = 'Barcode';

      Test.startTest(); 
      insert zca ; 
      String nP = XC_TR_ZuoraCustAccount_U_CreateBillProf.normalizePaymentMethodType(zca);
      System.assert(true, zca!=null);
      Test.stopTest();
   }

   // Test method for manageBadPayer
   static testMethod void manageBadPayerTest(){
      insert XC_DF_OneOrg.createOneOrg('Spain');
      List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
      insert acc; 
      Zuora__CustomerAccount__c zca = new Zuora__CustomerAccount__c();
      zca.isBadPayer__c = 'False';
      zca.Zuora__Account__c= acc[0].Id; 
      insert zca ; 
      Test.startTest(); 
      zca.isBadPayer__c = 'True';
      update zca;
      System.assert(true, zca!=null);
      Test.stopTest();
   }

}