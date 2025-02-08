/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  22/05/2019 
    * @description XC_TR_Contact_U_ConcatenatePhone_TEST – Test class for XC_TR_Contact_U_ConcatenatePhone
    */ 
    @isTest
public with sharing class XC_TR_Contact_U_ConcatenatePhone_TEST {
             // Test method for concatenatePhoneOnInsert 
     static testMethod void concatenatePhoneOnInsert(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
            List<Contact> contact = XC_DF_Contact.createCondominiumContacts(1);
            insert contact;
            contact[0].XC_PhonePrefix__c='+376' ;
            contact[0].XC_ContactPhone__c= '565656';
            contact[0].XC_MobilePrefix__c= '+213';
            contact[0].XC_ContactMobile__c= '121212';
            update contact; 
            System.assertEquals(1, contact.size());
            Test.stopTest(); 
     }


}