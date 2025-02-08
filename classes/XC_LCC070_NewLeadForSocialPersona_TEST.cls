/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  17/05/2019 
* @description XC_LCC070_NewLeadForSocialPersona_TEST – Test class for XC_LCC070_NewLeadForSocialPersona
*/ 
@isTest
public with sharing class XC_LCC070_NewLeadForSocialPersona_TEST { 
     //Test Method checkLeadLookup
    static testMethod void checkLeadLookup(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
    insert acc;
    SocialPersona sp = new SocialPersona();
    sp.Name='Test';
    sp.ParentId= acc[0].Id;
    sp.Provider='Facebook' ; 
    insert sp;
    String spId = sp.Id;
    Boolean result = XC_LCC070_NewLeadForSocialPersona.checkLeadLookup(spId);
    System.assertEquals(true, result);
    Test.stopTest();
    }


    //Test Method checkLeadLookup2
    static testMethod void checkLeadLookup2(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();

    List<Lead> l = XC_DF_Lead.createResidentialLeads(1);
    insert l; 
    SocialPersona sp = new SocialPersona();
    sp.Name='Test';
    sp.ParentId= l[0].Id;
    sp.Provider='Facebook' ;
    sp.XC_LeadId__c=l[0].Id;
    insert sp;
    String spId = sp.Id;
    Boolean result = XC_LCC070_NewLeadForSocialPersona.checkLeadLookup(spId);
    System.assertEquals(false, result);
    Test.stopTest();
    }

}