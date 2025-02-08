/**
 * @description Gets the contacts list.
 * The Class XC_LCC001_SearchContact.
 */
public without sharing class XC_LCC001_SearchContact {
	
    /**
     * Gets the contacts list.
     *
     * @param documentType the document type
     * @description Gets the contacts list.
     * @param documentNumber the document number
     * @param email the email
     * @return the contacts list
     */
    @AuraEnabled
    public static List<Contact> getContactsList(String documentType, String documentNumber, String email){
        String searchKeyEmail = '%' + email + '%';
        if(!Schema.SObjectType.Contact.isAccessible()) {
            return new List<Contact>();
        }
        
        Map<Id,Contact> contactListMap = new Map<Id,Contact>([Select id,Name,Email, Account.Name,AccountId From 
        Contact Where email LIKE: searchKeyEmail LIMIT 20]);
        
        List<Contact> contactList = contactListMap.values();


        return contactList;
    }

}