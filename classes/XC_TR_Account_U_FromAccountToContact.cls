/**
* The Class XC_TR_Account_U_FromAccountToContact.
*
* @author Giulio Serra giserra@deloitte.it
* @date Creation 20/12/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_Account_U_FromAccountToContact - Copy all the information from an account to a primary Contact
*/
public class XC_TR_Account_U_FromAccountToContact {
    
    /**
* Check field to copy.
*
* @param listNew the list new
* @param mapOld the map old
* @param mapNew the map new
* @description check Fields To Copy
*/
    public static void checkFieldToCopy(List<Account> listNew, Map<Id,Account> mapOld, Map<Id,Account> mapNew){
        List<String> fieldList = new List<String> {
            'XC_AccountNationality__c',
            'PrimaryEmail__c',
            'XC_MainPhonePrefix__c',
            'XC_AccountMainPhone__c',
            'XC_AccountPhonePrefix__c',
            'XC_AccountPhone__c',
            'XC_FirstName__c',
            'XC_LastName__c',
            'XC_Birthdate__c'
        };
        List<Account> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if (!listChanged.isEmpty()) {
            copyInfoFromAccountToContact(listChanged);
        }
    }
    
    /**
* Copy info from account to contact.
* @description copy Info From Account To Contact
* @param accounts the accounts
*/
    public static void copyInfoFromAccountToContact(List<Account> accounts){
        
        List<Contact> contactToUpdate = new List<Contact>();
        
        List<Account> residentialAccount = XC_UTIL_Account.getAllResidentialAccount(accounts);
        Map<Id,Account> accountMap = new Map<Id,Account>(residentialAccount);
        
        Map<Id,Contact> primaryContact =  XC_TR_Account_U_FromAccountToContact_D.getAllAccountsFromContacts(residentialAccount); // Id -> Contact
        Map<Id,List<Contact>> accountToContact = getMapAccountContact(primaryContact); // AccountId -> List Contact
        
        System.debug('primaryContact arance' + primaryContact);
        System.debug('accountToContact' + accountToContact);
        
        for(Account acc : accountMap.values()){
            List<Contact> contactOfAccount = accountToContact.get(acc.Id);
            if(contactOfAccount != null && contactOfAccount.size() != 0){
                contactToUpdate.addAll(copyInfoFromAccountToContact2(acc,contactOfAccount));
            }
        }
        
        System.debug('Contact to update arancione ' + contactToUpdate);
        XC_Util_Sobject.updateListRecords(contactToUpdate);
        
    }
    
    /**
* Copy info from account to contact 2.
* @description copy Info From Account To Contact
* @param acc the acc
* @param contacts the contacts
* @return List<Contact>
*/
    @TestVisible
    private static List<Contact> copyInfoFromAccountToContact2(Account acc, List<Contact> contacts){
        List<Contact> toUpdate = new List<Contact>();
        for(Contact contact : contacts){
            if(!contact.XC_PrimaryContact__c){
                continue;
            }
            Boolean shouldAdd = populateContactPhones(acc,contact);
            if(shouldAdd){
                toUpdate.add(contact);
            } 
        }
        return toUpdate;
        
    }
    
    /**
* Gets the map account contact.
* @description populate Contact phone numbers
* @param acc
* @param contact
* @return the map account contact
*/
    private static Boolean populateContactPhones (Account acc, Contact contact){
        Boolean shouldAdd = false;
        if(acc.XC_FirstName__c != contact.FirstName || acc.XC_LastName__c != contact.LastName){
            contact.FirstName = acc.XC_FirstName__c;
            contact.LastName = acc.XC_LastName__c;
            shouldAdd = true;
        }
        if(String.isNotEmpty(acc.XC_AccountNationality__c) && contact.XC_Nationality__c != acc.XC_AccountNationality__c){
            contact.XC_Nationality__c = acc.XC_AccountNationality__c;
            shouldAdd = true;
        }   
        if(String.isNotEmpty(acc.PrimaryEmail__c) && contact.Email != acc.PrimaryEmail__c){
            contact.Email = acc.PrimaryEmail__c;
            shouldAdd = true;
        }        
        if(String.isNotEmpty(acc.XC_MainPhonePrefix__c) && contact.XC_MobilePrefix__c != acc.XC_MainPhonePrefix__c){
            contact.XC_MobilePrefix__c = acc.XC_MainPhonePrefix__c;
            shouldAdd = true;
        } 
         if(contact.BirthDate!= acc.XC_BirthDate__c){
            contact.BirthDate= acc.XC_BirthDate__c;
            shouldAdd = true;
        }    
        populateContactPhones2(acc, contact, shouldAdd);
        
        return shouldAdd;
    }
    
    /**
* Gets the map account contact.
* @description populate contact phones numbers
* @param acc
* @param contact
* @param shouldAdd
*/
    private static void populateContactPhones2 (Account acc, Contact contact, Boolean shouldAdd){
        if(String.isNotEmpty(acc.XC_AccountMainPhone__c) && contact.XC_ContactMobile__c != acc.XC_AccountMainPhone__c){
            contact.XC_ContactMobile__c = acc.XC_AccountMainPhone__c;
            shouldAdd = true;
        }           
        if(String.isNotEmpty(acc.XC_AccountPhonePrefix__c) && contact.XC_PhonePrefix__c != acc.XC_AccountPhonePrefix__c){
            contact.XC_PhonePrefix__c = acc.XC_AccountPhonePrefix__c;
            shouldAdd = true;
        }             
        if(String.isNotEmpty(acc.XC_AccountPhone__c)  && contact.XC_ContactPhone__c != acc.XC_AccountPhone__c){
            contact.XC_ContactPhone__c = acc.XC_AccountPhone__c;
            shouldAdd = true;
        }
    }
    
    /**
* Gets the map account contact.
* @description Gets the map account contact.
* @param contactsMap the contacts map
* @return the map account contact
*/
    private static Map<Id,List<Contact>> getMapAccountContact(Map<Id,Contact> contactsMap) {
        
        Map<Id,List<Contact>> accountIdToContact = new Map<Id,List<Contact>>();
        
        for(Contact contact : contactsMap.values()){
            if(accountIdToContact.keySet().contains(contact.AccountId)){
                accountIdToContact.get(contact.AccountId).add(contact);
            }else{
                List<Contact> contactList = new List<Contact>();
                contactList.add(contact);
                accountIdToContact.put(contact.AccountId,contactList);
            }
        }
        
        return accountIdToContact;
    }

}