/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  24/05/2019 
* @description XC_TR_Contact_FillChildrenInfo_TEST – Test class for XC_TR_Contact_FillChildrenInfo
*/
@isTest
public class XC_TR_Contact_FillChildrenInfo_TEST {
    //Test Method updateChildrenInfo
    @isTest
    static void updateChildrenInfo(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Contact> listc = XC_DF_Contact.createResidentialContacts(1);
        insert listc;
        
        listc[0].FirstName= 'test';
        update listc;
        
        System.assertEquals(true, listc!=null);
        Test.stopTest();
        
    }
    
    //Test Method updateChildrenInfo1
    @isTest
    static void updateChildrenInfo1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Contact> listc = XC_DF_Contact.createResidentialContacts(1);
        insert listc;
        
        listc[0].XC_TypeOfContact__c= 'Technician';
        update listc;
        
        System.assertEquals(true, listc!=null);
        Test.stopTest();
        
    }
    
    //Test Method updateChildrenInfo2
    @isTest
    static  void updateChildrenInfo2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 

        User u = [select id, ContactId, Contact.accountId, Contact.RecordTypeId, ProfileId, UserRoleId from user WHERE profile.Name = 'XC_ESP_SalesAgentPartner' and contactid != ''][0];
		User u2 = [select id, AccountId, ContactId, Contact.accountId, Contact.RecordTypeId, ProfileId, UserRoleId from user WHERE profile.Name = 'XC_ESP_SalesAgentPartner' and AccountId != ''][0];
        
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        insert listAccount;

        Account a = new Account(Id = u2.AccountId);
        a.RecordTypeId = [select id from recordtype where DeveloperName =: Label.XC_CL_Account_ResindentialRt ][0].id;
         a.PrimaryEmail__c='del@ee.it';
        a.Phone= '3333427423';
        update a; 
        Account account = [SELECT Id,  PrimaryEmail__c FROM Account WHERE Id = :listAccount[0].Id LIMIT 1];
        contact c = new contact();
        c.id = u.ContactId;
        c.AccountId =  u2.AccountId; 
        c.XC_TypeOfContact__c = '';
        c.XC_GiveDataToNew__c = 'Yes';
        c.XC_MainLegalEntity__c = 'EndesaX';
        c.XC_CountryLegalEntity__c = 'SPAIN';
        c.XC_SkipTriggerIndividual__c = true; 
        c.Email = account.PrimaryEmail__c;
        c.XC_ContactDocumentCountry__c = 'Spain';
        c.XC_ContactDocumentNumber__c = '4344545';
        c.XC_ContactDocumentType__c = 'Passport';
        c.RecordTypeId = [select id from recordtype where DeveloperName =: Label.XC_CL_Contact_Residential ][0].id;
        update c;
        
        c.XC_TypeOfContact__c = 'Technician';
        update c;
        
        System.assertEquals(true, c!=null);
        Test.stopTest();
        
    }
    

}