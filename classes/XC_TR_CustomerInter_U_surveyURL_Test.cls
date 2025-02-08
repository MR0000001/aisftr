/*
*@author: Marco Ottaviano mottaviano@deloitte.it
* @CreationDate: 16/10/2019
* @Test Class for XC_TR_CustomerInteraction_U_surveyURL,XC_TR_CustomerInteraction_U_surveyUtil //
*/

@isTest
public with sharing class XC_TR_CustomerInter_U_surveyURL_Test {
    //testsetup
    @TestSetup
    static void testSetup(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
       
    }

    @isTest
    static void test01() {

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc; 
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont; 
        List<XC_Address__c> address =  XC_DF_Address.createAddress(acc);
        insert address;
        List<Lead> leadlist = XC_DF_Lead.createResidentialLeads(1);
        For(Lead l : leadlist) {
            l.XC_DocumentCountry__c='Spain';
            l.XC_Country__c ='Spain';
            l.XC_ProductCategoryOfInterest__c ='Caldera';
        }
        insert leadlist;
        XC_Customer_Interaction__c cI=  new XC_Customer_Interaction__c();
        cI.Name = 'Test Ci';
        ci.XC_LeadId__c = leadlist[0].Id;
        cI.XC_ContactId__c = cont[0].Id;
        cI.XC_AccountId__c = acc[0].Id;
        cI.XC_Communication_Type__c = 'Lead_Welcome_Email';
        cI.XC_Channel__c ='Email';
        cI.XC_LegalEntity__c='EndesaX';
        cI.XC_SurveyId__c ='S0';
        cI.XC_Preferredlanguageofcontact__c='English';
        
        Test.startTest();
             insert cI; 
             System.assertEquals('Email', cI.XC_Channel__c); 
        Test.stopTest();
    }
}