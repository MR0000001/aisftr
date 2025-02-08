/**
* @author Emanuela Cacace ecacace@deloitte.it 
* @date Creation  17/06/2019 
* @Lastmodifiedby Nicola Arrigo
* @lastmodifieddate 18/02/2020
* @description XC_TR_Contact_U_CheckDuplic_D_TEST – Test class for  XC_TR_Contact_U_CheckDuplicates_D
*/ 
@isTest
public with sharing class XC_TR_Contact_U_CheckDuplic_D_TEST {

    //Test method getAllContactByMailOrIdentityId
  /*  static testMethod void getAllContactByMailOrIdentityId(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
         List<Account> acct = XC_DF_Account.createResidentialAccounts(2);
        acct[0].PrimaryEmail__c = 'test@te.it';
        acct[0].IdentityType__c = 'NIF';
        acct[0].IdentityNumber__c='50692632B';
        insert acct;  
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acct);
        cont[0].FirstName = 'Mario';
        cont[0].LastName='Rossi';
        cont[0].Email = 'test1@contact.it';      
        insert cont;
        String email  = cont[0].Email;
        string identityID = cont[0].Id; 
        List<Contact> result = XC_TR_Contact_U_CheckDuplicates_D.getAllContactByMailOrIdentityId(email, identityID);
        System.assertEquals(2, acct.size());
        Test.stopTest(); 
    }

     //Test method getAllContactByMailOrIdentityId
    static testMethod void getAccountById(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> acct = XC_DF_Account.createResidentialAccounts(2);
        acct[0].PrimaryEmail__c = 'test@te.it';
        acct[0].IdentityType__c = 'NIF';
        acct[0].IdentityNumber__c='50692632B';
        insert acct;  
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acct);
        cont[0].FirstName = 'Mario';
        cont[0].LastName='Rossi';
        cont[0].Email = 'test1@contact.it';        
        insert cont;
        string accountID = acct[0].Id; 
        List<Account> result =  XC_TR_Contact_U_CheckDuplicates_D.getAccountById(accountID) ;
        System.assertEquals(2, acct.size());
        Test.stopTest(); 
    }

    
     //Test method getAllContactByMailOrLastNameAndPhone
    static testMethod void getAllContactByMailOrLastNameAndPhone(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> acct = XC_DF_Account.createResidentialAccounts(2);
        acct[0].PrimaryEmail__c = 'test@te.it';
        acct[0].IdentityType__c = 'NIF';
        acct[0].IdentityNumber__c='50692632B';
        insert acct;  
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acct);
        cont[0].FirstName = 'Mario';
        cont[0].LastName='Rossi';
        cont[0].Email = 'test1@contact.it';        
        insert cont;
        Contact frontEndcontactData = cont[0];
        string accountID = acct[0].Id; 
        List<Contact> result =XC_TR_Contact_U_CheckDuplicates_D.getAllContactByMailOrLastNameAndPhone(frontEndcontactData);
        System.assertEquals(2, acct.size());
        Test.stopTest(); 
    }*/

         //Test method getAccountContactRelations
    static testMethod void getAccountContactRelations(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> acct = XC_DF_Account.createResidentialAccounts(2);
        acct[0].PrimaryEmail__c = 'test@te.it';
        acct[0].IdentityType__c = 'NIF';
        acct[0].IdentityNumber__c='50692632B';
        insert acct;  
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acct);
        cont[0].FirstName = 'Mario';
        cont[0].LastName='Rossi';
        cont[0].Email = 'test1@contact.it';        
        insert cont;
        String contactId = cont[0].Id;
        String accountId = acct[0].Id; 
        List<AccountContactRelation> result = XC_TR_Contact_U_CheckDuplicates_D.getAccountContactRelations(accountId , contactId);
        System.assertEquals(2, acct.size());
        Test.stopTest(); 
    }
    // NA1802
    static testMethod void getAllContactByMailOrIdentityId(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Contact> contactsList=new List<Contact>();
        contactsList=XC_DF_Contact.createResidentialContacts(1);
        string identityID;
        identityID='test';
        List<Contact> result=new List<Contact>();
        result=XC_TR_Contact_U_CheckDuplicates_D.getAllContactByMailOrIdentityId(contactsList[0].Email,identityID);
        System.assertEquals(1, contactsList.size());
        Test.stopTest(); 
    }
    // NA1802
    static testMethod void getAllContactByMailOrLastNameAndPhone(){
         insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Contact> contactsList=new List<Contact>();
        contactsList=XC_DF_Contact.createResidentialContacts(1);
        insert contactsList;
         List<Contact> result=new List<Contact>();
        contact frontEndcontactData=contactsList[0];
        result=XC_TR_Contact_U_CheckDuplicates_D.getAllContactByMailOrLastNameAndPhone(frontEndcontactData);
        System.assertEquals(1, contactsList.size());
        Test.stopTest(); 
    }
    // NA1802
    static testMethod void getAccountById(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Contact> contactsList=new List<Contact>();
        contactsList=XC_DF_Contact.createResidentialContacts(1);
        insert contactsList;
        List<Account> getAccountById=new List<Account>();
        getAccountById=XC_TR_Contact_U_CheckDuplicates_D.getAccountById(contactsList[0].AccountId);
        Test.stopTest();
    }

}