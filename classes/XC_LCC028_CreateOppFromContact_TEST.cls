/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  14/05/2019 
* @description XC_LCC028_CreateOppFromContact_TEST – Test class for XC_LCC028_CreateOppFromContact
*/
@isTest
public class XC_LCC028_CreateOppFromContact_TEST {
    //Test Method getVisibleRecordType
    static testMethod void getVisibleRecordType(){
        List<Contact> cont = XC_DF_Contact.createCondominiumContacts(1);
        insert cont;
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<RecordType> rt = XC_LCC028_CreateOppFromContact.getVisibleRecordType('Contact', cont[0].id); 
        System.assertEquals(true, rt!=null);
        Test.stopTest();
    } 
    
    //Test Method getCurrentContactData
    static testMethod void getCurrentContactData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
         
        Account a = new Account();
        a.Name='Paolo';
        a.PrimaryEmail__c  = 'test@test.it';
        insert a;
        
        Contact c = new Contact();
        c.FirstName ='Mario';
        c.LastName = 'Rossi';
        c.Country__c = 'SPAIN';
        c.AccountId=a.Id;
    	c.Email = 'test@test.it';
        c.XC_SkipTriggerIndividual__c = true;
        c.XC_MainLegalEntity__c = 'EndesaX';
        c.XC_CountryLegalEntity__c = 'SPAIN';
        c.XC_GiveDataToNew__c = 'Yes';
        insert c;
        
        /*List<Account> accList =  XC_DF_Account.createResidentialAccounts(5);
        List<Contact> lstcnt = XC_DF_Contact.createResidentialContacts(accList);
        contact c = lstcnt[0];*/
        
        XC_LCC028_CreateOppFromContact.ResultWrapper rw = XC_LCC028_CreateOppFromContact.getCurrentContactData(c.Id);
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
        
    }
    
    //Test Method getContactId
    static testMethod void getContactId(){
        insert XC_DF_OneOrg.createOneOrg('Spain');      
        
        Account a = new Account(); 
        a.Name='Paolo';
        a.PrimaryEmail__c  = 'test@test.it';
        insert a;
        
        Contact c = new Contact();
        c.FirstName ='Mario';
        c.LastName = 'Rossi';
        c.Country__c = 'SPAIN';
        c.AccountId=a.Id;
        c.XC_CountryLegalEntity__c = 'Spain';
        c.XC_GiveDataToNew__c = 'Yes';
        c.XC_SkipTriggerIndividual__c = true;
        c.XC_MainLegalEntity__c = 'EndesaX';
        c.Email = 'test@test.it';
        insert c;
        
        Test.startTest(); 
        XC_UTIL_ResultWrapper rw = XC_LCC028_CreateOppFromContact.getContactId (c.Id);  
        rw = XC_LCC028_CreateOppFromContact.getContactId (a.Id);  
        Test.stopTest();
    }

    static testMethod void getContactIdByCase(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        Account a = new Account();
       
        a.Name='Paolo';
        a.PrimaryEmail__c  = 'test@test.it';
        insert a;
        
        Contact c = new Contact();
        c.FirstName ='Mario';
        c.LastName = 'Rossi';
        c.Country__c = 'SPAIN';
        c.AccountId=a.Id;
        c.XC_CountryLegalEntity__c = 'Spain';
        c.XC_GiveDataToNew__c = 'Yes';
        c.XC_SkipTriggerIndividual__c = true;
        c.XC_MainLegalEntity__c = 'EndesaX';
        c.Email = 'test@test.it';
        insert c;
        
        List<Case> listCs = XC_DF_Case.createCases(1);
        Case cs = listCs[0];
        cs.Status = 'ESTA001';
        cs.AccountId = null;
        insert cs;
        
        Test.startTest(); 
        XC_UTIL_ResultWrapper rw = XC_LCC028_CreateOppFromContact.getContactId (cs.Id);
        cs.ContactId = c.Id;
        update cs; 
        
        rw = XC_LCC028_CreateOppFromContact.getContactId (cs.Id); 
        Test.stopTest();
    }

    static testMethod void getContactIdByWoId(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        Account a = new Account();
       
        a.Name='Paolo';
        a.PrimaryEmail__c  = 'test@test.it';
        insert a;
        
        Contact c = new Contact();
        c.FirstName ='Mario';
        c.LastName = 'Rossi';
        c.Country__c = 'SPAIN';
        c.AccountId=a.Id;
        c.XC_CountryLegalEntity__c = 'Spain';
        c.XC_GiveDataToNew__c = 'Yes';
        c.XC_SkipTriggerIndividual__c = true;
        c.XC_MainLegalEntity__c = 'EndesaX';
        c.Email = 'test@test.it';
        insert c;
        
        List<Case> listCs = XC_DF_Case.createCases(1);
        Case cs = listCs[0];
        cs.Status = 'ESTA001';
        cs.AccountId = null;
        insert cs;
        
        Test.startTest(); 
        insert XC_DF_WorkOrder.CreateWorkOrders(1,'Commercial Visit');
        WorkOrder w = [SELECT Id FROM WorkOrder][0];
        w.ContactId = c.Id;
        update w;
        
        XC_UTIL_ResultWrapper rw = XC_LCC028_CreateOppFromContact.getContactId ([SELECT Id FROM WorkOrder][0].Id);       
        Test.stopTest();
    }
    
    static testMethod void getCurrentContactData_FromAccount(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        insert contList;
        
        XC_LCC028_CreateOppFromContact.ResultWrapper rw = XC_LCC028_CreateOppFromContact.getCurrentContactData(accountList[0].Id);
        
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    static testMethod void getCurrentContactDataForCase(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Case> cases = XC_DF_Case.createCases(1);
        insert cases;
        
        XC_LCC028_CreateOppFromContact.ResultWrapper rw = XC_LCC028_CreateOppFromContact.getCurrentContactDataForCase(cases[0].Id);
        
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    static testMethod void canCreateOptyTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Account a = new Account();       
        a.Name='Paolo';
        a.PrimaryEmail__c  = 'test@test.it';
        insert a;
        
        Test.startTest(); 
        XC_LCC028_CreateOppFromContact.canCreateOpty(a.Id); 
        Test.stopTest();
    }
}