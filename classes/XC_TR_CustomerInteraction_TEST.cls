/**
 * The Class XC_TR_CustomerInteraction_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 20/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_TR_CustomerInteraction_Handler
 **/


@isTest
public without sharing class XC_TR_CustomerInteraction_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    /* static testMethod void doDML(){
        Test.startTest(); 
        
        List<XC_Customer_Interaction__c> custInterList = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        insert  custInterList;
        update custInterList;
        delete custInterList;
  
        System.assertEquals(true, custInterList!=null, 'Wrong assert result');
        Test.stopTest();
    } */
    
    @IsTest
    static void methodTestInsert(){
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.Name = 'Test Ci xxxxx';
        ci.XC_ContactId__c = cList[0].Id;
        ci.XC_AccountId__c = aList[0].Id;
        ci.XC_Communication_Type__c = 'Lead_Welcome_Email';

        Test.startTest();
        insert  ci;
        Test.stopTest();
        
    }

    @IsTest
    static void methodTestUpdate(){
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.Name = 'Test Ci xxxxx';
        ci.XC_ContactId__c = cList[0].Id;
        ci.XC_AccountId__c = aList[0].Id;
        ci.XC_Communication_Type__c = 'Lead_Welcome_Email';
        insert ci;

        Test.startTest();
        update ci;
        Test.stopTest();
        
    }

    @IsTest
    static void methodDelete(){
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.Name = 'Test Ci xxxxx';
        ci.XC_ContactId__c = cList[0].Id;
        ci.XC_AccountId__c = aList[0].Id;
        ci.XC_Communication_Type__c = 'Lead_Welcome_Email';
        insert ci;

        Test.startTest();
        delete ci;
        Test.stopTest();
        
    }
}