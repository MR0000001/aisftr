/**
 * @author Giulio Serra giserra@deloitte.it
 * @date Creation 06/11/2018
 * @description XC_TR_Contact_U_FromContactToAccount - Copy the info of the primary contact on the father account
 */

public class XC_TR_Contact_U_FromContactToAccount {
    
    /**
     * @description Check field to copy
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkFieldToCopy(List<Contact> listNew, Map<Id,Contact> mapOld, Map<Id,Contact> mapNew){
        List<String> fieldList = new List<String> {
            'Email',
            'XC_Nationality__c',
            'XC_MobilePrefix__c',
            'XC_ContactMobile__c',
            'XC_PhonePrefix__c',
            'XC_ContactPhone__c',
            'FirstName',
            'LastName',
            'Birthdate'
        };
        List<Contact> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if (!listChanged.isEmpty()) {
            onContactInfoChanged(listChanged);
        }
    }
    
    /**
     * @description On contact info changed
     * @param contacts the contacts 
     */
    public static void onContactInfoChanged(List<Contact> contacts){
        List<Account> accountToUpdate = new List<Account>();
        List<Contact> primaryContacts = XC_UTIL_Contact.getPrimaryContacts(contacts);           
        Map<Id,Account> accountsToModify = XC_TR_Contact_U_FromContactToAccount_D.getAccountsFromContacts(primaryContacts);
        
        for(Contact contact : primaryContacts){
            Account father = accountsToModify.get(contact.AccountId);
            System.debug('@@@@@@' + contact + ' ' + '@@@@' + father);
            if(father != null) {
                Boolean accUpdated = false;
                if(father.PrimaryEmail__c != contact.Email) {
                    father.PrimaryEmail__c = contact.Email;
                    accUpdated = true;
                }        
                if(father.XC_FirstName__c != contact.FirstName){
                    father.XC_FirstName__c = contact.FirstName;
                    father.Name = contact.FirstName + ' ' + contact.LastName;
                    accUpdated = true; 
                }
                if(father.XC_LastName__c != contact.LastName){
                    father.XC_LastName__c = contact.LastName;
                    father.Name = contact.FirstName + ' ' + contact.LastName;
                    accUpdated = true;
                }                
                if(String.isNotEmpty(father.XC_AccountNationality__c)) {
                    father.XC_AccountNationality__c = contact.XC_Nationality__c;
                    accUpdated = true;
                }                
                if(String.isNotEmpty(father.XC_MainPhonePrefix__c)) {
                    father.XC_MainPhonePrefix__c = contact.XC_MobilePrefix__c;
                    accUpdated = true;
                }                
                if(String.isNotEmpty(father.XC_AccountMainPhone__c)) {
                    father.XC_AccountMainPhone__c = contact.XC_ContactMobile__c;
                    accUpdated = true;
                }                
                if(String.isNotEmpty(father.XC_AccountPhonePrefix__c)) {
                    father.XC_AccountPhonePrefix__c = contact.XC_PhonePrefix__c;
                    accUpdated = true;
                }                
                if(String.isNotEmpty(father.XC_AccountPhone__c)) {
                    father.XC_AccountPhone__c = contact.XC_ContactPhone__c;
                    accUpdated = true;
                } 
                if(contact.Birthdate != father.XC_Birthdate__c){
                    father.XC_Birthdate__c = contact.Birthdate;
                    accUpdated = true;
                }

                if(accUpdated) {
                    accountToUpdate.add(father);
                }
            }
        }
        
        System.debug('From contact to account' + accountToUpdate);
        List<XC_UTIL_SObject.WrapperResult> results = XC_UTIL_SObject.updateListRecords(accountToUpdate);
        manageResults(results,primaryContacts);
    }
    
    /**
     * @author Giulio Serra giserra@deloitte.it
     * @param results the results
     * @param contacts the contacts
     * @description manage the results of the update of the accounts father of the contacts
     */
    private static void manageResults(List<XC_UTIL_SObject.WrapperResult> results,List<Contact> contacts){
        for(XC_UTIL_SObject.WrapperResult wrapper : results){
            if(!wrapper.success){
                System.debug('error found!' + wrapper.errorMessage + 'wrapperId' + wrapper.errorObjectId);
                Contact cont = XC_UTIL_Contact.getContactsFromaAccountId(wrapper.errorObjectId,contacts)[0];
                cont.addError(wrapper.errorMessage);
            }
        }
    }
    
}