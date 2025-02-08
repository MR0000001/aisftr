/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com 
* @date Creation 10/03/2021
* @date Modification 
* @description XC_TR_DocumentType_U_CreateSRSkills_TEST – Test class for XC_TR_DocumentType_U_CreateSRSkills
*/  

@isTest
public class XC_TR_DocumentType_U_CreateSRSkills_TEST {
    @TestSetup
    static void setup(){
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<Contact> contactList = XC_DF_Contact.createPartnerContacts(accountList);
        insert contactList;
        List<ServiceResource> srList = XC_DF_ServiceResource.createServiceResourcesFromAccount(accountList);
        for(ServiceResource sr : srList){
            sr.XC_Contact__c = contactList[0].Id;
        }
        update srList;
  	}
    
    static testMethod void onInsertAndUpdate(){
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        XC_DocumentType__c documentType = new XC_DocumentType__c();
        documentType.Category__c = 'SF_PES_QUALIFICATION';
        documentType.XC_Contact__c = cont.Id;
        insert documentType;
        documentType.XC_ExpirationDate__c = System.Today();
        update documentType;
        Test.stopTest();
    }
}