/**
* @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 03/07/2019
* @description XC_UTIL_AccountDuplication_W - Util class with wrappers for Account Duplication process
*/
public without sharing class XC_UTIL_AccountDuplication_W {
   
    /** @description CheckSingleFieldWrapper */
    public class CheckSingleFieldWrapper{
        public String newField; 
        public String oldField;

        /** 
        * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
        * @date Creation 03/07/2019
        * @description Method to compare 2 values
        * @param newField - first value to compare
        * @param oldField - second value to compare
        */
        public CheckSingleFieldWrapper(String newField, String oldField){
            this.newField = newField;
            this.oldField = oldField;
        }
    }

    /** @description CheckFieldWrapper */
    public class CheckFieldWrapper {
        public Set<String> setEmail = new Set<String>();
        public Set<String> setEmailAccount = new Set<String>();
        public Set<String> setPrefix = new Set<String>();
        public Set<String> setPhone = new Set<String>();
        public Set<String> setFirstName = new Set<String>();
        public Set<String> setLastName = new Set<String>();
        public Set<String> setDocumentType = new Set<String>();
        public Set<String> setDocumentNumber = new Set<String>();
        public Set<String> setPersonalDocumentType = new Set<String>();
        public Set<String> setPersonalDocumentNumber = new Set<String>();
        public Set<String> setProductCategories = new Set<String>();
        public Set<String> setAddresses = new Set<String>(); 
        public Set<String> setLegalEntity = new Set<String>(); 
        public Set<String> setId = new Set<String>();
        public Set<String> setIndividualId = new Set<String>();
        public Map<ID, List<XC_LegalEntityConsent__c>> mapConsent = new Map<ID, List<XC_LegalEntityConsent__c>>();
    }

    /** @description CheckAccountWrapper */
    public class CheckAccountWrapper { 
        public Boolean contactExists = false;
        public Boolean contactIsPrimary = false;
        public Boolean accountExistsForPrimary = false;
        public Boolean accountExistsForSecondary = false;
        //public Contact existingContact = new Contact();
        public Contact existingContact = null;
        public Boolean isInsert = true;
        public Boolean isForB2B = false;
        public Boolean success = true;
        public String errorMessage = '';
        public Boolean successConsent = true;   
        public Account account = new Account();
        public Account accountForB2B = new Account();
        public Account existingAccountForPrimaryContact = null;
        public List<String> listIdExistingAccountForSecondaryContact = new List<String>();
        public List<XC_LegalEntityConsent__c> listlegalEntityConsentForExistingContacts = new List<XC_LegalEntityConsent__c>();
    }
    
    /** @description ContactWrapper */
    public class ContactWrapper { 
        public List<XC_LegalEntityConsent__c> listConsent = new List<XC_LegalEntityConsent__c>();
        public List<XC_PersonalDocument__c> listPersonalDocument = new List<XC_PersonalDocument__c>();
        public Contact contact;
    }

    /** @description AccountSohoCondominiumWrapper */
    public class AccountSohoCondominiumWrapper { 
        public Account existingAccount = null;
        public List<Contact> listExistingContact = new List<Contact>();
        public Account newAccount = null;
        public Contact newContact = null;
    }

}