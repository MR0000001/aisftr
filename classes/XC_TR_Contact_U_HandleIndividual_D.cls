/**
 * The Class XC_TR_Contact_U_HandleIndividual_D.
 *
 * @author Giulio Serra - giserra@deloitte.it
 * @date Creation 03/09/2018
 * @date Modification dd/mm/yyyy
 * @description  XC_TR_Contact_U_HandleIndividual_D DAO class for XC_TR_Contact_U_HandleIndividual
 */
public without sharing class XC_TR_Contact_U_HandleIndividual_D {
	
    /**
     * @description Gets the individual from contacts.
     * @param contacts the contacts
     * @return the individual from contacts
     */
    public static Map<Id,Individual> getIndividualFromContacts(List<Contact> contacts){
        List<id> contactIds =  XC_UTIL_SObject.getListFieldValues(contacts,'id');
        return new Map<Id,Individual>([SELECT Id,FirstName,LastName,XC_ThirdPartyConsentVersion__c,XC_RobinsonCustomer__c,XC_GiveDataToThirdParties__c,XC_ChildContact__c FROM Individual WHERE XC_ChildContact__c IN :contactIds]);
    }

     /**
      * Gets the editable contacts.
      *
      * @author Giulio Serra - giserra@deloitte.it
      * @param contacts the contacts
      * @return the editable contacts
      * @description return a list of editables contacts from an input list of contacts(to use in after upadre trigger)
      */
    public static List<Contact> getEditableContacts(List<Contact> contacts){
        List<String> contactID = XC_UTIL_SObject.getListFieldValues(contacts,'id');
        List<Contact> contactList = new List<Contact>();
        if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.LastName.isAccessible() )
        {
            contactList = [SELECT Id,FirstName,IndividualId,LastName,XC_SkipTriggerIndividual__c,XC_GiveDataToThirdParties__c,XC_MainLegalEntity__c, Account.Id, Account.name, Account.XC_Country__c, XC_ThirdPartiesConsentVersion__c, Account.XC_ConfirmationByCustomer__c
                                    FROM Contact 
                                    WHERE Id IN: contactId];
        }
        return contactList;
    }
    
    
    /**
     * @description Gets the contact from indiduals.
     * @param individuals the individuals
     * @return the contact from indiduals
     */
    public static Map<Id,Contact> getContactFromIndiduals(List<Individual> individuals){
        List<String> contactID = XC_UTIL_SObject.getListFieldValues(individuals,'XC_ChildContact__c');
		return new Map<Id,Contact>([SELECT Id,FirstName,IndividualId,LastName, XC_GiveDataToThirdParties__c, 
        XC_ThirdPartiesConsentVersion__c, XC_RobinsonCustomer__c FROM Contact WHERE Id IN: contactId]);
    }
}