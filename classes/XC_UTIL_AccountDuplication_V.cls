/**
* @author Domenico Del Prete domenicodelprete@nttdata.com
* @date Creation 21/08/2019
* @description XC_UTIL_AccountDuplication_Z - Util class for Account/Contact Duplication process (for Soho/Condominium)
*/

public without sharing class XC_UTIL_AccountDuplication_V {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_AccountDuplication_V');

    /**
    * @description Util method for Soho Condominium Account
    * @author Del Prete Domenico | 21/8/2019
    * @param wrapper XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper 
    * @return XC_UTIL_AccountDuplication_W.CheckAccountWrapper 
    */
    public static XC_UTIL_AccountDuplication_W.CheckAccountWrapper notExistingAccount(XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper){
        XC_UTIL_AccountDuplication_W.CheckAccountWrapper resultWrapper = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
        if(wrapper.listExistingContact.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check Account duplication Soho: Account and Contact doesn\'t exist');
            List<XC_UTIL_AccountDuplication_Z.LegalEntityWrapper> leList = XC_UTIL_AccountDuplication_Z.checkLegalEntity(wrapper.newAccount);
            boolean allFound = true;
            for(XC_UTIL_AccountDuplication_Z.LegalEntityWrapper legalEntity : leList){
                if(!legalEntity.allFound){
                    allFound = false;
                    break;
                }
            }
            resultWrapper.successConsent = !allFound;
            resultWrapper.existingAccountForPrimaryContact = wrapper.existingAccount;
        }
        // Account doesn't exists but Contact (fot other Account) exists (7a3): 
        else {
            Contact anotherContactWithSameRecordType = contactWithDifferentRt(wrapper);

            if(anotherContactWithSameRecordType.XC_PrimaryContact__c) {
                resultWrapper.success = false;
                resultWrapper.errorMessage = Label.XC_CL_ContactDocumentExists + anotherContactWithSameRecordType.XC_ContactDocumentType__c + ' ' + anotherContactWithSameRecordType.XC_ContactDocumentNumber__c;
            } else {
                resultWrapper.success = true;
                if (wrapper.newAccount != null){
                    List<XC_UTIL_AccountDuplication_Z.LegalEntityWrapper> leList = XC_UTIL_AccountDuplication_Z.checkLegalEntity(wrapper.newAccount);
                    boolean allFound = true;
                    for(XC_UTIL_AccountDuplication_Z.LegalEntityWrapper legalEntity : leList){
                        if(!legalEntity.allFound){
                            allFound = false;
                            break;
                        }
                    }
                    resultWrapper.successConsent = !allFound;
                }
            }
            resultWrapper.existingContact = anotherContactWithSameRecordType;
        }
        return resultWrapper;
    }

    /**
    * @description Account and Contact exist, but it is Primary of another Account util class for Account Duplication
    * @author Del Prete Domenico | 21/8/2019
    * @param XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper
    * @param  wrapper XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper 
    * @param  selectedContact Contact
    * @return XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    */
    public static XC_UTIL_AccountDuplication_W.CheckAccountWrapper accountContactExistButPrimaryAnotherAccount(XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper, Contact selectedContact){
        XC_UTIL_AccountDuplication_W.CheckAccountWrapper resultWrapper = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
        resultWrapper.isInsert = false;
        resultWrapper.existingAccountForPrimaryContact = wrapper.existingAccount;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check Account duplication Soho: Account doesn\'t exist but Contact exists (it is Primary of another Account)');
        AccountContactRelation accountContact = new AccountContactRelation(
                AccountId = wrapper.existingAccount.Id,
                ContactId = selectedContact.Id
        );
        XC_UTIL_Sobject.WrapperResult wrResult = XC_UTIL_Sobject.insertRecord(accountContact);
        if(!wrResult.success) {
            resultWrapper.success = false;
            resultWrapper.errorMessage = Label.XC_CL_Account_ErrorJunctionObj;
        }
        resultWrapper.errorMessage = Label.XC_CL_Account_JunctionObj;
        return resultWrapper;
    }

    /**
    * @description
    * @author Del Prete Domenico | 21/8/2019
    * @param wrapper XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper 
    * @return XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    */
    public static XC_UTIL_AccountDuplication_W.CheckAccountWrapper accountContactExists(XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper){
        XC_UTIL_AccountDuplication_W.CheckAccountWrapper resultWrapper = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
        if(!wrapper.listExistingContact.isEmpty()) {
            Contact contactForExistingAccount;
            List<Contact> anotherContactWithDifferentRecordType = new List<Contact>();
            Contact anotherContactWithSameRecordType;
            for(Contact contact : wrapper.listExistingContact) {
                XC_UTIL_AccountDuplication_Z.ExistingContactWrapper inputWrapperForExistingContact = new XC_UTIL_AccountDuplication_Z.ExistingContactWrapper();
                inputWrapperForExistingContact.contact = contact;
                inputWrapperForExistingContact.wrapper = wrapper;
                XC_UTIL_AccountDuplication_Z.checkForExtistingContact(inputWrapperForExistingContact);
                contactForExistingAccount = inputWrapperForExistingContact.contactForExistingAccount;
                anotherContactWithSameRecordType = inputWrapperForExistingContact.anotherContactWithSameRecordType;
                anotherContactWithDifferentRecordType = inputWrapperForExistingContact.anotherContactWithDifferentRecordType;
            }

            XC_UTIL_AccountDuplication_Z.ExistingContactWrapper inputWrapperForExistingAccount = new XC_UTIL_AccountDuplication_Z.ExistingContactWrapper();
            inputWrapperForExistingAccount.contactForExistingAccount = contactForExistingAccount;
            inputWrapperForExistingAccount.anotherContactWithDifferentRecordType = anotherContactWithDifferentRecordType;
            inputWrapperForExistingAccount.anotherContactWithSameRecordType = anotherContactWithSameRecordType;
            inputWrapperForExistingAccount.wrapper = wrapper;
            XC_UTIL_AccountDuplication_Z.checkForExtistingAccount(inputWrapperForExistingAccount);
            resultWrapper = inputWrapperForExistingAccount.wrapperOutput;
        }
        // Account exists but Contact doesn't exist (3):
        else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check Account duplication Soho: Account exists but Contact doesn\'t exist');
            resultWrapper = XC_UTIL_AccountDuplication_Z.createSecondaryContactOnExistingAccount(wrapper);
        }
        return resultWrapper;
    }

    private static Contact contactWithDifferentRt(XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check Account duplication Soho: Account doesn\'t exists but Contact (fot other Account) exists');
        Contact anotherContactWithSameRecordType = new Contact();
        for(Contact contact : wrapper.listExistingContact) {
            if(checkContactAnotherAccount(contact, wrapper)) {
                anotherContactWithSameRecordType = contact;
            }
        }
        return anotherContactWithSameRecordType;
    }

    /**
    * @description
    * @param contact - Contact 
    * @param wrapper - XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper 
    * @return Boolean
    */
    private static Boolean checkContactAnotherAccount(Contact contact, XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper){
        return (((contact.Email == wrapper.newContact.Email) || (contact.XC_ContactDocumentNumber__c == wrapper.newContact.XC_ContactDocumentNumber__c && contact.XC_ContactDocumentType__c == wrapper.newContact.XC_ContactDocumentType__c))
                && ((contact.XC_RecordTypeDeveloperName__c == Label.XC_CL_Contact_Soho && wrapper.newContact.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Soho').getRecordTypeId())
                || (contact.XC_RecordTypeDeveloperName__c == Label.XC_CL_Contact_Condominium && wrapper.newContact.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId())));
    }

    /**
    * @description
    * @author Del Prete Domenico | 21/8/2019
    * @param cnt Contact 
    * @param wrapper XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper 
    * @return Boolean
    */
    public static Boolean checkEmailExistingContact(Contact cnt, XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper){
        List<String> listRtSohoToCheck = new List<String>{
            Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_Soho).getRecordTypeId(),
            Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2B).getRecordTypeId(),
            Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2G).getRecordTypeId()
        };
        return (cnt.Email == wrapper.newContact.Email && (
                    (listRtSohoToCheck.contains(cnt.RecordTypeId) && listRtSohoToCheck.contains(wrapper.newContact.RecordTypeId)) ||
                    (cnt.XC_RecordTypeDeveloperName__c == Label.XC_CL_Contact_Condominium && wrapper.newContact.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId())
                ));
    }

    /**
    * @description
    * @author Del Prete Domenico | 21/8/2019
    * @param inputWrapper XC_UTIL_AccountDuplication_Z.ExistingContactWrapper 
    * @return Boolean
    */
    public static Boolean checkDocumentContact(XC_UTIL_AccountDuplication_Z.ExistingContactWrapper inputWrapper){
        return (inputWrapper.contact.XC_ContactDocumentNumber__c == inputWrapper.wrapper.newContact.XC_ContactDocumentNumber__c && inputWrapper.contact.XC_ContactDocumentType__c == inputWrapper.wrapper.newContact.XC_ContactDocumentType__c
                && ((inputWrapper.contact.XC_RecordTypeDeveloperName__c == Label.XC_CL_Contact_Soho && inputWrapper.wrapper.newContact.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Soho').getRecordTypeId())
                || (inputWrapper.contact.XC_RecordTypeDeveloperName__c == Label.XC_CL_Contact_Condominium && inputWrapper.wrapper.newContact.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId())));
    }

    /**
    * @description
    * @author Del Prete Domenico | 21/8/2019
    * @param inputWrapper XC_UTIL_AccountDuplication_Z.ExistingContactWrapper 
    * @return Boolean
    */
    public static Boolean checkDocumentContactDifferentRT(XC_UTIL_AccountDuplication_Z.ExistingContactWrapper inputWrapper){
        return (inputWrapper.contact.XC_ContactDocumentNumber__c == inputWrapper.wrapper.newContact.XC_ContactDocumentNumber__c && inputWrapper.contact.XC_ContactDocumentType__c == inputWrapper.wrapper.newContact.XC_ContactDocumentType__c
                && ((inputWrapper.contact.XC_RecordTypeDeveloperName__c != Label.XC_CL_Contact_Soho && inputWrapper.wrapper.newContact.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Soho').getRecordTypeId())
                || (inputWrapper.contact.XC_RecordTypeDeveloperName__c != Label.XC_CL_Contact_Condominium && inputWrapper.wrapper.newContact.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId())));
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/08/2019
    * @description Method to check for Primary Contact
    * @param wrapper
    * @param listParentForContacts 
    * @return Contact 
    */
    public static Contact checkForPrimaryContact(XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper, List<String> listParentForContacts) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ a ---> ' + wrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ b ---> ' + listParentForContacts);
        Boolean check = (wrapper.existingAccount != null && !wrapper.listExistingContact.isEmpty() && !listParentForContacts.contains(wrapper.existingAccount.Id));
        if(check) {
            for(Contact contact : wrapper.listExistingContact) {
                if(((contact.XC_RecordTypeDeveloperName__c == Label.XC_CL_Contact_Soho && wrapper.newContact.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Soho').getRecordTypeId()) ||
                        (contact.XC_RecordTypeDeveloperName__c == Label.XC_CL_Contact_Condominium && wrapper.newContact.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId()))|| ((contact.XC_RecordTypeDeveloperName__c == 'XC_GLO_B2B' && wrapper.newContact.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId()) ||
                        (contact.XC_RecordTypeDeveloperName__c == 'XC_GLO_B2G' && wrapper.newContact.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId()))) {
                    return contact;
                }
            }
            return null;
        } else {
            return null;
        }
    }

    /**
    * @description
    * @author Del Prete Domenico | 22/8/2019
    * @param accToCheck Account 
    * @param existingContacts List<Contact> 
    * @param newContact Contact 
    * @return XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper
    */
    public static XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper checkInputData(Account accToCheck, List<Contact> existingContacts, Contact newContact){
        XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper = new XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper();
        wrapper.existingAccount = accToCheck;
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = XC_LCC003_NewAccount.accountContactWrapper;
        if (inputData != null){
            wrapper.listExistingContact = existingContacts;
            wrapper.newContact = newContact;
        }
        return wrapper;
    }

    /**
    * @description
    * @author Del Prete Domenico | 22/8/2019
    * @param newAccount Account 
    * @param newContact Contact 
    * @param existingContacts List<Contact> 
    * @return List<Contact> 
    */
    public static List<Contact> getExistingContacts(Account newAccount, Contact newContact, List<Contact> existingContacts){
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = XC_LCC003_NewAccount.accountContactWrapper;
        if (inputData != null){
            String recordTypeId = newAccount.RecordTypeId;
            Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(inputData.contactFields);
            newContact.Email = (String) fieldMap.get('Email');
            newContact.XC_ContactDocumentType__c = (String) fieldMap.get('DocumentType');
            newContact.XC_ContactDocumentNumber__c =(String) fieldMap.get('DocumentID');
            if(XC_UTIL_Account.isCondominium(recordTypeId)){
                newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId();
            }else if(XC_UTIL_Account.isSoho(recordTypeId)){
                newContact.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Soho').getRecordTypeId();
            }


            existingContacts = new List<Contact>([
                    SELECT ID, IndividualId, XC_CountryLegalEntity__c, XC_GiveDataToNew__c, XC_RecordTypeDeveloperName__c, AccountId, XC_ContactDocumentType__c, XC_ContactDocumentNumber__c, XC_PrimaryContact__c, XC_MainLegalEntity__c, Email, RecordTypeId, XC_ContactDocumentCountry__c,
                    (SELECT Id, XC_MainDocument__c, XC_Contact__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_Account__c, XC_Country__c
                    FROM Personal_Documents__r)
                    FROM Contact
                    WHERE (Email <> null AND Email = :newContact.Email) OR
                    (XC_ContactDocumentType__c = :newContact.XC_ContactDocumentType__c AND XC_ContactDocumentNumber__c = :newContact.XC_ContactDocumentNumber__c AND
                    XC_ContactDocumentType__c != NULL AND XC_ContactDocumentNumber__c != NULL)]);
        }
        return existingContacts;
    }

    /**
    * @description
    * @author Del Prete Domenico | 22/8/2019
    * @param residentialAccountList List<Account> 
    * @return XC_UTIL_AccountDuplication_W.CheckFieldWrapper
    */
    public static XC_UTIL_AccountDuplication_W.CheckFieldWrapper getCheckFieldWrapper(List<Account> residentialAccountList){
        XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkFieldWrapper = new XC_UTIL_AccountDuplication_W.CheckFieldWrapper();
        for(Account acc : residentialAccountList){
            checkFieldWrapper.setId.add(acc.id);
            checkFieldWrapper.setEmail.add(acc.PrimaryEmail__c);
            checkFieldWrapper.setDocumentType.add(acc.IdentityType__c);
            checkFieldWrapper.setDocumentNumber.add(acc.IdentityNumber__c);
        }
        return checkFieldWrapper;
    }

    /**
    * @description
    * @author Del Prete Domenico | 22/8/2019
    * @param listContact List<Contact> 
    * @param checkFieldWrapper XC_UTIL_AccountDuplication_W.CheckFieldWrapper 
    * @param residentialAccountList List<Account>
    * @return List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>
    */
    public static List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> getErrorDuplicates(List<Contact> listContact, XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkFieldWrapper, List<Account> residentialAccountList){
        List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> toReturn = new List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>();
        if(listContact.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE,'Nessun record trovato');
            toReturn.add(new XC_UTIL_AccountDuplication_W.CheckAccountWrapper());
        } else{
            for(Contact con : listContact){
                checkFieldWrapper.setIndividualId.add(con.IndividualId);
                checkFieldWrapper.setId.add(con.Id);
            }
            checkFieldWrapper = getConsents(checkFieldWrapper);

            List<XC_UTIL_AccountDuplication_W.ContactWrapper> contactWrapperList = new List<XC_UTIL_AccountDuplication_W.ContactWrapper>();
            for (Contact con : listContact){
                XC_UTIL_AccountDuplication_W.ContactWrapper contactWrapper = new XC_UTIL_AccountDuplication_W.ContactWrapper();
                contactWrapper.contact = con;
                contactWrapper.listConsent = !checkFieldWrapper.mapConsent.isEmpty() ? checkFieldWrapper.mapConsent.get(con.IndividualId) : new List<XC_LegalEntityConsent__c>();
                contactWrapperList.add(contactWrapper);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE,'contactWrapperList ' + contactWrapperList);
            return XC_UTIL_AccountDuplication_U.checkErrorDuplicates(residentialAccountList, contactWrapperList);
        }
        return toReturn;
    }

    /**
* @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 28/06/2019
* @description Method to populate XC_UTIL_AccountDuplication_W.CheckFieldWrapper.mapConsent
* @param wrapper - wrapper to populate
* @return XC_UTIL_AccountDuplication_W.CheckFieldWrapper
*/
    public static XC_UTIL_AccountDuplication_W.CheckFieldWrapper getConsents(XC_UTIL_AccountDuplication_W.CheckFieldWrapper wrapper){
        if (wrapper.mapConsent.isEmpty()){
            List<XC_LegalEntityConsent__c> consentList = new List<XC_LegalEntityConsent__c>([SELECT ID, XC_Individual__c, XC_LeCountry__c, XC_LegalEntity__c,
                    XC_IndividualLegalEntity__c, XC_IndividualId__c, XC_GiveDataToNew__c,
                    XC_UpdateAboutProducts__c, XC_ConsentToDataProcessing__c, XC_CompanyConsentVersion__c,
                    XC_MarketingConsentVersion__c, XC_ProfilingConsentVersion__c
            FROM XC_LegalEntityConsent__c
            WHERE XC_Individual__c IN:wrapper.setIndividualId]);
            for (XC_LegalEntityConsent__c con : consentList) {
                List<XC_LegalEntityConsent__c> conList;
                if (wrapper.mapConsent.get(con.XC_Individual__c) != null){
                    conList = wrapper.mapConsent.get(con.XC_Individual__c);
                }else {
                    conList = new List<XC_LegalEntityConsent__c>();
                }

                conList.add(con);
                wrapper.mapConsent.put(con.XC_Individual__c, conList);
            }
        }
        return wrapper;
    }
}