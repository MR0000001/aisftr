/**
* @description Gets the user from contacts.
* @param contactIDs the contact I ds
* @return the user from contacts
*/
public without sharing class XC_TR_Contact_FillChildrenInfo_D {

    /**
     * @description Gets the user from contacts.
     * @param contactIDs the contact I ds
     * @return the user from contacts
     */
    public static Map<ID,User> getUserFromContacts(Set<Id> contactIDs){
        return new Map<ID,User>([SELECT Id, UserRole.Name, ProfileId,Profile.UserLicense.Name,Contact.Account.Name,Contact.XC_TypeOfContact__c,Contact.Id  from User WHERE contactId IN: contactIds]);
    }
}