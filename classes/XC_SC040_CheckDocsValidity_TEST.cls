/**
* @author Marina Ciavarra - mciavarra@deloitte.it
* @date Creation 08/02/2021
* @description XC_SC040_CheckDocsValidity_TEST – XC_SC040_CheckDocumentationsValidity
*/ 

@isTest
public class XC_SC040_CheckDocsValidity_TEST {

    static testMethod void testBatch(){
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        List<Contact> contList = XC_DF_Contact.createPartnerContacts(accList);
        insert contList;
        XC_DocumentType__c documentA = new XC_DocumentType__c();
        XC_DocumentType__c documentC = new XC_DocumentType__c();
        documentA.XC_Account__c = accList[0].Id;
        documentA.XC_ExpirationDate__c = Date.today() - 1;
        documentC.XC_Contact__c = contList[0].Id;
        documentC.XC_ExpirationDate__c = Date.today() - 1;
        List<XC_DocumentType__c> documents = new List<XC_DocumentType__c>();
        documents.add(documentA);
        documents.add(documentC);
        insert documents;
        Test.startTest();
        String chron = '0 0 23 * * ?';
        system.schedule('Test Sched040', chron,  new XC_SC040_CheckDocumentationsValidity());
        Test.stopTest();
    }
}