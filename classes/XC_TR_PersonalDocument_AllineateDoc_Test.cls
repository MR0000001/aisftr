/**
* @author Nicola Arrigo - narrigo@deloitte.it  
* @date Creation  11/03/2020 
* @description XC_TR_Opportunity_Handler_Test – Test class for XC_TR_Opportunity_Handler
*/
@isTest
public with sharing class XC_TR_PersonalDocument_AllineateDoc_Test {
    /**
    * test trigger Opp create 
    */
    public static testMethod void populateAccountDocumentOnUpdate(){
      insert XC_DF_OneOrg.createOneOrg('Spain');
        Map<Id,Account> mapOld=new map<id,Account>();
        Map<Id,Account> mapNew=new map<id,account>();
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);        
        insert accounts;
       List<Contact> listContacts=XC_DF_Contact.createResidentialContacts(accounts);
        listContacts[0].XC_PrimaryContact__c=true;
        insert listContacts;
        for(Account acc:accounts){
          mapOld.put(acc.id,acc);    
        }
        XC_PersonalDocument__c perDoc = new XC_PersonalDocument__c(XC_Account__c= accounts[0].Id);
        perdoc.XC_MainDocument__c=true;
        insert perdoc;
        for(Account acc:accounts){
            acc.IdentityNumber__c='X3845318V';
            acc.IdentityType__c='NIE';
            acc.XC_NIE_expiration_date__c =system.today();
            acc.XC_NIE_expedition_date__c=system.today();
        }
        update accounts;        
         mapNew.put(accounts[0].id,accounts[0]);
        test.startTest();
        XC_TR_PersonalDocument_AllineateDoc.populateAccountDocumentOnUpdate(accounts,mapNew,mapOld);
        XC_TR_PersonalDocument_AllineateDoc.createDocumentInAccountEdit(accounts, mapOld,mapNew);
       // XC_TR_PersonalDocument_AllineateDoc.populatePersonalDocumentFromAccount(accounts);
       test.stopTest();
    }
    public static testMethod void checkIfAccountFieldNeedPop(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);        
        insert accounts;
        Map<Id, XC_PersonalDocument__c> mapOld= new Map<Id, XC_PersonalDocument__c>(); 
        List<XC_PersonalDocument__c> listNew=new List<XC_PersonalDocument__c>();
        XC_PersonalDocument__c perDoc = new XC_PersonalDocument__c();
        perDoc.XC_AccountId__c=accounts[0].Id;
        perDoc.XC_DocumentNumber__c=accounts[0].IdentityNumber__c;
        perDoc.XC_Country__c=accounts[0].XC_DocumentCountry__c; 
       // perDoc.XC_ExpirationDate__c='';
        perDoc.XC_DocumentType__c=accounts[0].IdentityType__c;
        perDoc.XC_MainDocument__c=true;
        insert perDoc;
        listNew=[SELECT Id,XC_AccountId__c,XC_DocumentNumber__c,XC_Country__c,XC_DocumentType__c,XC_MainDocument__c,XC_ExpirationDate__c,XC_ReleaseDate__c from XC_PersonalDocument__c];
        mapOld.put(perDoc.id,perDoc);
        test.startTest();
        system.debug('Test Nic'+' '+perDoc.XC_Account__c+'&& MainDocument'+' '+perDoc.XC_MainDocument__c);
        XC_TR_PersonalDocument_AllineateDoc.checkIfAccountFieldNeedPop(listNew);
        XC_TR_PersonalDocument_AllineateDoc.checkPossibilityToDelete(listNew,mapOld);
        test.stopTest();
    }
}