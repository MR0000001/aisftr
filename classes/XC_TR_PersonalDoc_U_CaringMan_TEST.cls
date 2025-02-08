/**
    * @author Dario Tramontin dtramontin@deloitte.it
    * @date Creation  10/10/2019
    * @date Modification 
    * @description XC_TR_PersonalDoc_U_CaringMan_TEST – Test class for XC_TR_PersonalDoc_U_CaringManagement
    */ 
@isTest
public with sharing class XC_TR_PersonalDoc_U_CaringMan_TEST {

    @TestSetup
	static void setup(){
	    insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        
        List<Contact> cntList = XC_DF_Contact.createResidentialContacts(accList);
        insert cntList;
        
        List<XC_PersonalDocument__c> personalDocList = new List<XC_PersonalDocument__c>();
        XC_PersonalDocument__c perDoc = new XC_PersonalDocument__c();
        perDoc.XC_Contact__c = cntList[0].Id;
        perDoc.XC_MainDocument__c = true;
        perDoc.XC_Country__c = 'Spain';
        perDoc.XC_DocumentType__c = 'NIF';
        perDoc.XC_DocumentNumber__c = '68180010Y';
        personalDocList.add(perDoc);
        insert personalDocList; 
    }

           	
    @isTest
    static void updateAdressFieldsTest(){
        List<XC_PersonalDocument__c> perDoc= [Select Id from XC_PersonalDocument__c LIMIT 1 ];
        test.startTest();
        perDoc[0].XC_Country__c = 'United Kingdom';
        perDoc[0].XC_DocumentType__c = 'Passport';
        perDoc[0].XC_DocumentNumber__c = 'BBBB';
        perDoc[0].XC_ExpirationDate__c = Date.Today();
        perDoc[0].XC_ReleaseDate__c = perDoc[0].XC_ExpirationDate__c.addYears(-1);
        update perDoc;
        test.stopTest();
        System.assert(!perDoc.isEmpty(), 'Assert error updateAdressFieldsTest');         
    }
}