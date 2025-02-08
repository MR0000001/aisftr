/**
* The Class XC_LCC007_ContactSelection
* @author Roberta Cossiga - rcossiga@deloitte.it
* @description XC_LCC007_ContactSelection 
*/

public with sharing class XC_LCC007_ContactSelection {

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

        Map<Id,Contact> contactMap = new Map<Id,Contact>( [Select Id,Name,Account.Name,AccountId,Email 
            From Contact Where AccountId =: accountId ]);


        List<Contact> contactList = contactMap.values();

        return contactList;
    }
}