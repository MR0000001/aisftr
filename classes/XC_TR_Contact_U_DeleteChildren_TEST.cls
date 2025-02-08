/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  22/05/2019 
    * @description XC_TR_Contact_U_DeleteChildren_TEST – Test class for XC_TR_Contact_U_DeleteChildren
    */ 
    @isTest
public with sharing class XC_TR_Contact_U_DeleteChildren_TEST {
     // Test method for deletePersonalDocument 
     static testMethod void deletePersonalDocument(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
           List<Account> acc= XC_DF_Account.createResidentialAccounts(1);
            insert acc;
            List<Contact> contact = XC_DF_Contact.createResidentialContacts(acc);
            insert contact;
            XC_PersonalDocument__c docs = new XC_PersonalDocument__c();
            docs.XC_Account__c = acc[0].Id; 
            docs.XC_Contact__c= contact[0].Id;
            insert docs;  
            delete contact; 

            //System.assertEquals(1, contact.size());
            Test.stopTest();
     }

}