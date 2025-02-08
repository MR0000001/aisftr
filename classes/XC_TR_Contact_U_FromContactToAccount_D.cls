/**
 * The Class XC_TR_Contact_U_FromContactToAccount_D.
 *
 * @author Giulio Serra giserra@deloitte.it
 * @date Creation 06/11/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Contact_U_FromContactToAccount_D - DAO for class XC_TR_Contact_U_FromContactToAccount
 */
public without sharing class XC_TR_Contact_U_FromContactToAccount_D {
    
    /**
     * Gets the accounts from contacts.
     *
     * @author Giulio Serra giserra@deloitte.it
     * @param primaryContacts the primary contacts
     * @return the accounts from contacts
     * @description get all the residential accounts from a list of primary contacts
     */
    public static Map<Id,Account> getAccountsFromContacts(List<Contact> primaryContacts){
        Id residentialRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        Set<String> toQuery = new Set<String>(XC_UTIL_Sobject.getListFieldValues(primaryContacts,'AccountId'));
        return new Map<Id,Account>([
            SELECT Id,MainPhone__c,XC_LastName__c,XC_FirstName__c,XC_AccountNationality__c,Phone,IdentityNumber__c,XC_AccountPhonePrefix__c,XC_AccountPhone__c,IdentityType__c,
                XC_MainPhonePrefix__c,XC_AccountMainPhone__c,PrimaryEmail__c,   XC_NIE_expiration_date__c,XC_NIE_expedition_date__c,  RecordTypeId ,
                XC_Birthdate__c
            FROM Account
            WHERE Id =: toQuery AND RecordTypeId =: residentialRecordTypeId]);
    } 
}