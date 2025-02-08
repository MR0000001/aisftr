/**
* The Class XC_LCC124_SelectPrimaryContact
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @description XC_LCC124_SelectPrimaryContact 
*/

public with sharing class XC_LCC124_SelectPrimaryContact {
	
    public class WrapperContactAdministrator{ 
        @AuraEnabled
        public List<Contact> contacts;
        @AuraEnabled
        public String administratorId;
    }
    
    /**
     * Gets the contact list from account.
     * @description get Contact List From Account
     * @param accountId the account id
     * @return the contact list from account
     */
    @AuraEnabled
    public static List<Contact> getContactListFromAccount(String accountId){
        if(!Schema.SObjectType.Contact.isAccessible()) {
            return new List<Contact>();
        }

        Map<Id,Contact> contactMap = new Map<Id,Contact>( [Select Id,Name,Account.Name,AccountId,Email,XC_PrimaryContact__c
            From Contact Where AccountId =: accountId ]);


        List<Contact> contactList = contactMap.values();

        return contactList;
    }
    
    /**
     * Gets the contact list from account.
     * @description get Contact List From Account
     * @param accountId the account id
     * @return the contact list from account
     */
    @AuraEnabled
    public static WrapperContactAdministrator getContactListFromAccountWithAdministrator(String accountId){
        WrapperContactAdministrator wr = new WrapperContactAdministrator();
        if(!Schema.SObjectType.Contact.isAccessible()) {
            return wr;
        }

        Map<Id,Contact> contactMap = new Map<Id,Contact>( [SELECT Id,Name,Account.Name,AccountId,Email,XC_PrimaryContact__c
                                                           FROM Contact Where AccountId =: accountId ]);


        List<Contact> contactList = contactMap.values();
		wr.contacts = contactList;
        List<AccountContactRelation> accList = [SELECT id,AccountId,ContactId,Roles FROM AccountContactRelation WHERE AccountId =:accountId AND Roles ='Administrator'];
        if(!accList.isEmpty()){
            wr.administratorId = accList[0].ContactId;
        }
        return wr;
    }
    
    /**
     * Gets set the Primary Contact for an Account.
     * @description get Contact List From Account
     * @param accountId the account id
     * @return the contact list from account
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updatePrimaryContact(String contactId, String accountId){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        List<Contact> contactToDowngradeNotPrimary = new  List<Contact>();
        List<Account> accList = [SELECT id, (SELECT id,XC_PrimaryContact__c from Contacts where XC_PrimaryContact__c = true) FROM Account WHERE Id =:accountId];
        for(Contact contact : accList[0].Contacts){
            contact.XC_PrimaryContact__c = false;
            contactToDowngradeNotPrimary.add(contact);
        }
        List<XC_UTIL_Sobject.WrapperResult> updateRes = XC_UTIL_Sobject.updateListRecords(contactToDowngradeNotPrimary);
        if(updateRes[0].success){
        Contact c = new Contact(id=contactId);
        c.XC_PrimaryContact__c=true;
        c.AccountId=accountId;
        XC_UTIL_Sobject.WrapperResult insertRes = XC_UTIL_Sobject.updateRecord(c);
        wr = new XC_UTIL_ResultWrapper(insertRes);
        System.debug('updatePrimaryContact result = '+wr);
       
        }
        
        return wr;
        
    }
     /**
     * Gets set the Administrator for an Account.
     * @description get Contact List From Account
     * @param accountId the account id
     * @return the contact list from account
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updateAdministrator(String contactId, String accountId){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        List<AccountContactRelation> acrToDowngradeNotAdmin = new List<AccountContactRelation>();
        List<AccountContactRelation> accList = [SELECT id,AccountId,ContactId,Roles FROM AccountContactRelation WHERE AccountId =:accountId];
        
        for(AccountContactRelation acr : accList){
            acr.Roles = null;
            acrToDowngradeNotAdmin.add(acr);
        }
        List<XC_UTIL_Sobject.WrapperResult> updateRes = XC_UTIL_Sobject.updateListRecords(acrToDowngradeNotAdmin);
        
        if(updateRes[0].success){
        AccountContactRelation c = [SELECT id,AccountId,ContactId,Roles FROM AccountContactRelation WHERE AccountId =:accountId AND ContactId=:contactId limit 1];
        c.Roles = 'Administrator';
        XC_UTIL_Sobject.WrapperResult insertRes = XC_UTIL_Sobject.updateRecord(c);
        wr = new XC_UTIL_ResultWrapper(insertRes);
        System.debug('updatePrimaryContact result = '+wr);
       
        }
        
        return wr;
        
    }
    
    
}