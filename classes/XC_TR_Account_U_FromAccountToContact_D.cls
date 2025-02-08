/**
 * The Class XC_TR_Account_U_FromAccountToContact_D.
 *
 * @author Giulio Serra giserra@deloitte.it
 * @date Creation 20/12/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Account_U_FromAccountToContact_D - DAO for class XC_TR_Account_U_FromAccountToContact
 */
public without sharing class XC_TR_Account_U_FromAccountToContact_D {      
    
    /**
     * @description Gets the all accounts from contacts.
     *
     * @param residentialAccount the residential account
     * @return the all accounts from contacts
     */
    public static Map<Id,Contact> getAllAccountsFromContacts(List<Account> residentialAccount){
        
        Set<String> accountIds = new Set<String>(XC_UTIL_Sobject.getListFieldValues(residentialAccount,'Id'));  
        return new Map<Id,Contact>([
            SELECT Id,FirstName, LastName, Email,XC_Nationality__c,MobilePhone,XC_PhonePrefix__c,XC_ContactPhone__c,
            Phone,XC_ContactMobile__c,XC_MobilePrefix__c,XC_PrimaryContact__c,AccountId, Birthdate
            FROM Contact 
            WHERE AccountId =: accountIDs AND XC_PrimaryContact__c = true]);
    }
}