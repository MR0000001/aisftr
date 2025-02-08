/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Andrea Bravaccino - andrea.bravaccino@nttdata.com
* @date Creation 14/08/2019
* @description XC_UTIL_AccountDuplication_Z - Util class for Account/Contact Duplication process (for Soho/Condominium)
*/

public without sharing class XC_UTIL_AccountDuplication_Z {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_AccountDuplication_Z');

    /** @description LegalEntityWrapper */
    public class LegalEntityWrapper {
        public Boolean allFound = true;
        public String listlegalEntityToInsert;
        public XC_LegalEntityConsent__c consent;
    } 

    /** @description ExistingContactWrapper */
    public class ExistingContactWrapper {
        public Contact contact;
        public XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper;
        public Contact contactForExistingAccount;
        public Contact anotherContactWithSameRecordType;
        public List<Contact> anotherContactWithDifferentRecordType = new List<Contact>();
        public XC_UTIL_AccountDuplication_W.CheckAccountWrapper wrapperOutput = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
    }

    /** @description AccountB2BWrapper */
    private class AccountB2BWrapper {
        Map<Integer, Account> mapAccountToInsert = new Map<Integer, Account>();
        Map<Integer, Contact> mapContactToInsert = new Map<Integer, Contact>();
        Map<Integer, Contact> mapExistingContactToInsert = new Map<Integer, Contact>();
    } 

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @date Creation 14/08/2019
    * @description Method to check Account Duplication for Soho and Condominium
    * @param inputListWrapper - List<XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper>
    * @return List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>
    */
    public static List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> checkForSohoCondominium(List<XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper> inputListWrapper) {
        List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> listResultWrapper = new List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>();
        Integer indexMap = 0;
        AccountB2BWrapper b2bWrapper = new AccountB2BWrapper();
        for(XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper : inputListWrapper) {
            List<String> listParentForContacts = XC_UTIL_Sobject.getListFieldValues(wrapper.listExistingContact, 'AccountId'); 
            // Check record type for new contact:
            if(String.isBlank(wrapper.newContact.RecordTypeId)) {
                if(wrapper.newAccount.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2B).getRecordTypeId()) {
                    wrapper.newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
                } else if(wrapper.newAccount.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2G).getRecordTypeId()) {
                    wrapper.newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2G).getRecordTypeId();
                }
            }

            Boolean found = false;
            Contact contactFounded = new Contact();
            Contact matchingContactWithSameKeyDifferentRt = new Contact();
            Boolean foundWithDifferentRecordType = false;
            List<String> listRtSohoToCheck = new List<String>{
                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_Soho).getRecordTypeId(),
                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2B).getRecordTypeId(),
                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2G).getRecordTypeId()
            };
            for(Contact cnt : wrapper.listExistingContact) {
                // Contact exists but with existing email (6)
                if(XC_UTIL_AccountDuplication_V.checkEmailExistingContact(cnt, wrapper)) {
                    found = true;
                    contactFounded = cnt;
                    break; 
                }
                // Contact exists but with different record type:
                if((cnt.Email == wrapper.newContact.Email || (cnt.XC_ContactDocumentNumber__c == wrapper.newContact.XC_ContactDocumentNumber__c && cnt.XC_ContactDocumentType__c == wrapper.newContact.XC_ContactDocumentType__c)) &&
                    listRtSohoToCheck.contains(wrapper.newContact.RecordTypeId) && !listRtSohoToCheck.contains(cnt.RecordTypeId)) {
                        foundWithDifferentRecordType = true;
                        matchingContactWithSameKeyDifferentRt = cnt;
                        break; 
                    }
            }
            List<String> lisrRecordTypeToCheck = new List<String>{
                Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2B).getRecordTypeId(),
                Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2G).getRecordTypeId()
            };
            if(found || foundWithDifferentRecordType) {
                List<String> listCountrytoSkipForB2B = new List<String>{'Colombia', 'Chile'};
                Boolean isActiveComplexProduct = false;
                if(wrapper.newAccount.XC_Segment__c == 'B2B' ||wrapper.newAccount.XC_Segment__c == 'B2G'){
                    List<XC_CM_LegalEntity_Configuration__mdt> complexProduct = [SELECT  XC_Country__c, XC_ComplexProductActive__c, XC_Stream__c FROM  XC_CM_LegalEntity_Configuration__mdt WHERE XC_Country__c = : wrapper.newAccount.XC_Country__c AND XC_Stream__c =: wrapper.newAccount.XC_Segment__c AND XC_OrgId__c =: UserInfo.getOrganizationId() ];
                    if(! complexProduct.isEmpty()){
                        isActiveComplexProduct = complexProduct[0].XC_ComplexProductActive__c;
                    }
                }
                // For B2C:
                if(!lisrRecordTypeToCheck.contains(wrapper.newAccount.RecordTypeId) || ((listCountrytoSkipForB2B.contains(wrapper.newAccount.XC_Country__c)&& !isActiveComplexProduct)  && !lisrRecordTypeToCheck.contains(wrapper.newAccount.RecordTypeId))) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check Account duplication Soho: Contact exists but with existing email');
                    XC_UTIL_AccountDuplication_W.CheckAccountWrapper resultWrapper = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
                    resultWrapper.success = false;
                    resultWrapper.isInsert = false;
                    if(foundWithDifferentRecordType && !found) {
                        resultWrapper.errorMessage = Label.XC_CL_AccDuplicationNoMatchinfRt;
                        if(wrapper.newContact.Email == matchingContactWithSameKeyDifferentRt.Email) {
                            resultWrapper.errorMessage += ' ' + wrapper.newContact.Email;
                        } else {
                            resultWrapper.errorMessage += ' ' + wrapper.newContact.XC_ContactDocumentNumber__c;
                        }
                    } else {
                        resultWrapper.errorMessage = 'Contact exists with this email: ' + wrapper.newContact.Email;
                        resultWrapper.existingAccountForPrimaryContact = wrapper.existingAccount;
                    }
                    listResultWrapper.add(resultWrapper); 
                    continue; 
                } 
                // For B2B/B2G
                else if(wrapper.existingAccount == null && lisrRecordTypeToCheck.contains(wrapper.newAccount.RecordTypeId)) {
                    if(String.isBlank(wrapper.newAccount.PrimaryEmail__c)) {
                        XC_UTIL_AccountDuplication_W.CheckAccountWrapper caw = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
                        caw.isInsert = false;
                        caw.success = false;
                        caw.errorMessage = Label.XC_CL_LeadConv_ErrorAccountEmail;
                        listResultWrapper.add(caw);
                        continue;  
                    } else {
                        manageAccountDuplicationForB2BB2G(b2bWrapper, indexMap, wrapper, contactFounded);
                        indexMap++;
                        continue;
                    }
                }
            }

            Contact selectedContact = XC_UTIL_AccountDuplication_V.checkForPrimaryContact(wrapper, listParentForContacts);

            if(wrapper.existingAccount == null) {
                // Account and Contact doesn't exist (1)(7a1):
                XC_UTIL_AccountDuplication_W.CheckAccountWrapper resultWrapper = XC_UTIL_AccountDuplication_V.notExistingAccount(wrapper);
                resultWrapper.isForB2B = wrapper.newAccount.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2B).getRecordTypeId() || wrapper.newAccount.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2G).getRecordTypeId();
                listResultWrapper.add(resultWrapper);    
                continue;
            }

            // Account and Contact exist, but it is Primary of another Account (4) (5c)
            else if(selectedContact != null) {
                XC_UTIL_AccountDuplication_W.CheckAccountWrapper resultWrapper = XC_UTIL_AccountDuplication_V.accountContactExistButPrimaryAnotherAccount(wrapper, selectedContact);
                listResultWrapper.add(resultWrapper);
                continue; 
            }

            // Account and Contact exist:
            else if(wrapper.existingAccount != null) {
                XC_UTIL_AccountDuplication_W.CheckAccountWrapper resultWrapper = XC_UTIL_AccountDuplication_V.accountContactExists(wrapper);
                listResultWrapper.add(resultWrapper);
            }
        }

        // For B2B/B2G:
        Boolean successB2B = false;
        if(!b2bWrapper.mapAccountToInsert.values().isEmpty() && !b2bWrapper.mapContactToInsert.values().isEmpty()) {
            XC_UTIL_AccountDuplication_W.CheckAccountWrapper rw = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
            rw.success = true;
            rw.isInsert = false;
            rw.isForB2B = true;
            // Insert new Account for B2B/B2G:
            List<XC_UTIL_Sobject.WrapperResult> listDMLAccount = XC_UTIL_Sobject.insertListRecords(b2bWrapper.mapAccountToInsert.values());
            if(XC_UTIL_Sobject.checkDMLResults(listDMLAccount)){  
                // Insert new Contact for B2B/B2G:
                for(Integer indexForMap : b2bWrapper.mapAccountToInsert.keySet()) {
                    b2bWrapper.mapContactToInsert.get(indexForMap).AccountId = b2bWrapper.mapAccountToInsert.get(indexForMap).Id;
                }
                List<XC_UTIL_Sobject.WrapperResult> listDMLContact = XC_UTIL_Sobject.insertListRecords(b2bWrapper.mapContactToInsert.values());
                if(XC_UTIL_Sobject.checkDMLResults(listDMLContact)){  
                    // Creation Junction Object:
                    List<AccountContactRelation> listRelationToInsert = new List<AccountContactRelation>();
                    for(Integer indexForMap : b2bWrapper.mapAccountToInsert.keySet()) {
                        listRelationToInsert.add(
                            new AccountContactRelation(
                                AccountId = b2bWrapper.mapAccountToInsert.get(indexForMap).Id,
                                ContactId = b2bWrapper.mapExistingContactToInsert.get(indexForMap).Id
                            )
                        );
                    }
                    List<XC_UTIL_Sobject.WrapperResult> listDMLAccountContact = XC_UTIL_Sobject.insertListRecords(listRelationToInsert);
                    if(!XC_UTIL_Sobject.checkDMLResults(listDMLAccountContact)){  
                        rw.success = false;
                        rw.errorMessage = listDMLAccountContact[0].errorMessage;   
                        listResultWrapper.add(rw);     
                    } else {
                        successB2B = true;    
                    }
                } else {
                    rw.success = false;
                    rw.errorMessage = listDMLContact[0].errorMessage;
                    listResultWrapper.add(rw);
                }        
            } else {
                rw.success = false;
                rw.errorMessage = listDMLAccount[0].errorMessage;
                listResultWrapper.add(rw);
            }
        }
        if(successB2B) {
            for(Account accInsertedB2B : b2bWrapper.mapAccountToInsert.values()) {
                XC_UTIL_AccountDuplication_W.CheckAccountWrapper rwB2B = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
                rwB2B.success = true;
                rwB2B.isInsert = false;
                rwB2B.isForB2B = true;
                rwB2B.accountForB2B = accInsertedB2B;
                rwB2B.contactIsPrimary = true;
                listResultWrapper.add(rwB2B);
            }
        }

        return listResultWrapper;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date 26/05/2020
    * @description Method to manage new Account/Contact for B2B/B2G
    * @param resultWrapper - AccountB2BWrapper 
    * @param indexMap - Integer
    * @param wrapper - XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper
    * @param contactFounded - Contact
    */
    private static AccountB2BWrapper manageAccountDuplicationForB2BB2G(AccountB2BWrapper resultWrapper, Integer indexMap, XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper, Contact contactFounded) {
        // Creation Account:
        resultWrapper.mapAccountToInsert.put(indexMap, wrapper.newAccount);
        // Creation Contact:
        String recordTypeIdContact;
        if(wrapper.newAccount.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2B).getRecordTypeId()) {
            recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2B).getRecordTypeId();
        } else if(wrapper.newAccount.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2G).getRecordTypeId()) {
            recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2G).getRecordTypeId();
        }
        Contact contactToInsert = new Contact();
        contactToInsert.FirstName                      = wrapper.newAccount.Name;
        contactToInsert.LastName                       = wrapper.newAccount.Name;
        contactToInsert.Email                          = wrapper.newAccount.PrimaryEmail__c;
        contactToInsert.XC_PhonePrefix__c              = wrapper.newAccount.XC_AccountPhonePrefix__c;
        contactToInsert.XC_ContactPhone__c             = wrapper.newAccount.XC_AccountPhone__c;
        contactToInsert.XC_MobilePrefix__c             = wrapper.newAccount.XC_MainPhonePrefix__c;
        contactToInsert.XC_ContactMobile__c            = wrapper.newAccount.XC_AccountMainPhone__c;
        contactToInsert.XC_ContactDocExpirationDate__c = wrapper.newAccount.XC_NIE_expiration_date__c;
        contactToInsert.XC_ContactDocReleaseDate__c    = wrapper.newAccount.XC_NIE_expedition_date__c;
        contactToInsert.XC_ContactDocumentCountry__c   = wrapper.newContact.XC_ContactDocumentCountry__c;
        contactToInsert.XC_ContactDocumentType__c      = wrapper.newContact.XC_ContactDocumentType__c;
        contactToInsert.XC_ContactDocumentNumber__c    = wrapper.newContact.XC_ContactDocumentNumber__c;
        contactToInsert.XC_Nationality__c              = wrapper.newAccount.XC_AccountNationality__c; 
        contactToInsert.XC_PrimaryContact__c           = true;
        contactToInsert.RecordTypeId                   = recordTypeIdContact;
        contactToInsert.Country__c                     = wrapper.newAccount.XC_Country__c;
        contactToInsert.XC_SFMTechnicalField__c        = 'SFM';
        if(String.isNotBlank(wrapper.newAccount.XC_Salutation__c)) {
            contactToInsert.Salutation = wrapper.newAccount.XC_Salutation__c;
        }
        if(String.isNotBlank(String.valueOf(wrapper.newAccount.XC_BirthDate__c))) {
            contactToInsert.Birthdate = wrapper.newAccount.XC_BirthDate__c;
        }
        //contactToInsert.AccountId = accountToInsert.Id;
        resultWrapper.mapContactToInsert.put(indexMap, contactToInsert);
        resultWrapper.mapExistingContactToInsert.put(indexMap, contactFounded);
        return resultWrapper;
    }

    // (3)
    /**
    * @description createSecondaryContactOnExistingAccount
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 19/8/2019
    * @param wrapper XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper 
    * @return XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    */
    public static XC_UTIL_AccountDuplication_W.CheckAccountWrapper createSecondaryContactOnExistingAccount(XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper){
        XC_UTIL_AccountDuplication_W.CheckAccountWrapper resultWrapper = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = XC_LCC003_NewAccount.accountContactWrapper;
        Account acc = wrapper.existingAccount;

        List<LegalEntityWrapper> lew = checkLegalEntity(acc);
        if (!allFound(lew)){
            resultWrapper.success = false;
            resultWrapper.errorMessage = Label.XC_CL_Account_ErrorLegalEntity + ' ' + acc.PrimaryEmail__c;
            return resultWrapper;
        }

        Contact c = XC_TR_Contact_U_CheckDuplicates.populateContactFieldsFromAccount(acc, inputData); //contactFields
        Contact contact = XC_TR_Contact_U_CheckDuplicates.removePrefixFromContact(c);
        contact.XC_PrimaryContact__c = false;
        
        XC_UTIL_Sobject.WrapperResult wrcontact = XC_UTIL_Sobject.insertRecord(contact);
        if(!wrcontact.success){
            resultWrapper.success = false;
            resultWrapper.errorMessage = wrcontact.errorMessage;
            return resultWrapper;
        }
         
        XC_UTIL_Sobject.WrapperResult wrJO = null;
        List<AccountContactRelation> junctionObjList = XC_TR_Contact_U_CheckDuplicates_D.getAccountContactRelations(acc.Id, contact.Id);
        if(!junctionObjList.isEmpty()){
            AccountContactRelation acr = junctionObjList[0];
            acr.Roles = Label.XC_CL_AccountContactRel_Owner;
            wrJO = XC_UTIL_Sobject.updateRecord(acr);
        } 
        
        if(wrjo != null && !wrJO.success){
            resultWrapper.success = false;
            resultWrapper.errorMessage = wrJO.errorMessage;
            return resultWrapper; 
        } 
        Map<Id,Contact> rows = new Map<Id,Contact>([SELECT Id, IndividualId FROM Contact WHERE Id = :contact.Id]);
        XC_UTIL_Sobject.WrapperResult leDmlResult =  XC_LCC002_NewLead_U.insertLegalEntityConsents(rows.get(contact.Id).IndividualId, inputData.consentsLE);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@leDmlResult@@@' + leDmlResult);
        if (!leDmlResult.success) {
            resultWrapper.success = false;
            resultWrapper.errorMessage = wrJO.errorMessage;
            return resultWrapper; 
        }
        resultWrapper.success = true;
        resultWrapper.isInsert = false;
        resultWrapper.errorMessage = Label.XC_CL_Account_ExistingAccount + ' ' + acc.Name;
        resultWrapper.existingAccountForPrimaryContact = acc;
        return resultWrapper;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 14/08/2019
    * @description Method to check legal entity
    * @param account - Account
    * @return LegalEntityWrapper
    */
    public static List<LegalEntityWrapper> checkLegalEntity(Account account) {
        List<LegalEntityWrapper> outputWrapper = new List<LegalEntityWrapper>();
        XC_UTIL_DEBUG.debug(DEBUGACTIVE, '@@@ Check legal entity');
        List<XC_LegalEntityConsent__c> consents = XC_LCC003_NewAccount_Related.populateLEWrapper(XC_LCC003_NewAccount.accountContactWrapper.consentsLE);
        boolean isChecked = true;
        for(XC_LegalEntityConsent__c legalEntity : consents){
            if(!(Boolean)account.get('XC_GiveDataTo_'+legalEntity.XC_LegalEntity__c+'__c')){
                LegalEntityWrapper le = new LegalEntityWrapper();
                le.allFound = false;
                le.listlegalEntityToInsert = legalEntity.XC_LegalEntity__c;
                le.consent = legalEntity;
                outputWrapper.add(le);
            }
        }
        return outputWrapper;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/08/2019
    * @description Method to check for Existing Contact
    * @param anotherContactWithDifferentRecordType
    * @param anotherContactWithSameRecordType
    * @param wrapper
    * @return XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    */
    @TestVisible
    private static XC_UTIL_AccountDuplication_W.CheckAccountWrapper checkForContact(List<Contact> anotherContactWithDifferentRecordType, Contact anotherContactWithSameRecordType, XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper) {
        XC_UTIL_AccountDuplication_W.CheckAccountWrapper outputWrapper = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
        // Existing contact (not for existing Account) has the same Record Type (5b):
        if(anotherContactWithSameRecordType != null) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check Account duplication Soho: Existing contact (not for existing Account) has the same Record Type:');
            outputWrapper.success = false; 
            outputWrapper.isInsert = false;
            outputWrapper.errorMessage = Label.XC_CL_Account_ExistingContact + ' ' + anotherContactWithSameRecordType.Email;
        } 
        // Existing contact (not for existing Account) has other Record Type (5a):
        else if(!anotherContactWithDifferentRecordType.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check Account duplication Soho: Existing contact (not for existing Account) has other Record Type');
            return createSecondaryContactOnExistingAccount(wrapper);
        }
        return outputWrapper;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/08/2019
    * @description Method to check for Existing Contact
    * @param inputWrapper - ExistingContactWrapper
    */
    public static void checkForExtistingContact(ExistingContactWrapper inputWrapper) {
        if(inputWrapper.contact.AccountId == inputWrapper.wrapper.existingAccount.Id) {
            inputWrapper.contactForExistingAccount = inputWrapper.contact;
        }
        else if(XC_UTIL_AccountDuplication_V.checkDocumentContact(inputWrapper)) {
            inputWrapper.anotherContactWithSameRecordType = inputWrapper.contact;
        } 
        else if(XC_UTIL_AccountDuplication_V.checkDocumentContactDifferentRT(inputWrapper)) {
            inputWrapper.anotherContactWithDifferentRecordType.add(inputWrapper.contact); 
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/08/2019
    * @description Method to check for Existing Account
    * @param inputWrapper - ExistingContactWrapper
    */
    public static void checkForExtistingAccount(ExistingContactWrapper inputWrapper) {
        // Existing contact is not Contact for existing Account (a Secondary Contact Exists)
        if(inputWrapper.contactForExistingAccount == null) {
            inputWrapper.wrapperOutput = checkForContact(inputWrapper.anotherContactWithDifferentRecordType, inputWrapper.anotherContactWithSameRecordType, inputWrapper.wrapper);
        }
        // Account and Contact exist (2) (7a2) 
        else { 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check Account duplication Soho: Account Exists and existing Contact has Soho Record Type');
            inputWrapper.wrapperOutput.isInsert = false;
            List<LegalEntityWrapper> legalWrapper = checkLegalEntity(inputWrapper.wrapper.existingAccount);
            if(!allFound(legalWrapper)) {
                List<XC_LegalEntityConsent__c> legalToInsert = new List<XC_LegalEntityConsent__c>();
                List<Account> listAccountToUpdate = new List<Account>();
                for(LegalEntityWrapper legalEntity : legalWrapper) {
                    XC_LegalEntityConsent__c newLegalEntity = legalEntity.consent;
                    newLegalEntity.XC_Individual__c = inputWrapper.contactForExistingAccount.IndividualId;
                    newLegalEntity.XC_IndividualId__c = inputWrapper.contactForExistingAccount.IndividualId;
                    newLegalEntity.XC_GiveDataToNew__c = newLegalEntity.XC_GiveDataToNew__c == null ? 'Yes' : newLegalEntity.XC_GiveDataToNew__c;
                    legalToInsert.add(newLegalEntity);

                    Account accountToUpdate = new Account();
                    accountToUpdate.Id = inputWrapper.wrapper.existingAccount.Id;
                    accountToUpdate.put('XC_GiveDataTo_'+legalEntity.listlegalEntityToInsert+'__c', true);
                    listAccountToUpdate.add(accountToUpdate);
                }
                List<XC_UTIL_Sobject.WrapperResult> resWrLegal = !Test.isRunningTest() ? XC_UTIL_Sobject.insertListRecords(legalToInsert) : null;
                List<XC_UTIL_Sobject.WrapperResult> resWrAcc = !Test.isRunningTest() ? XC_UTIL_Sobject.updateListRecords(listAccountToUpdate) : null;
                if(checkDMLResults(resWrLegal)) {
                    setErrorOnInputWrapper(inputWrapper, resWrLegal);
                    return;
                } else if(checkDMLResults(resWrAcc)) {
                    setErrorOnInputWrapper(inputWrapper, resWrAcc);
                    return;
                }
            }
            
            inputWrapper.wrapperOutput.success = true;
            inputWrapper.wrapperOutput.existingAccountForPrimaryContact = inputWrapper.wrapper.existingAccount;
            inputWrapper.wrapperOutput.errorMessage = Label.XC_CL_Account_ErrorDuplication;
        }
    }  

    private static Boolean allFound(List<LegalEntityWrapper> leList){
        for(LegalEntityWrapper legalEntity : leList){
            if(!legalEntity.allFound){
                return legalEntity.allFound;
            }
        }
        return true;
    }

    private static Boolean checkDMLResults(List<XC_UTIL_Sobject.WrapperResult> wrList){
        return wrList != null && !XC_UTIL_Sobject.checkDMLResults(wrList);
    }
    
    @TestVisible
    private static void setErrorOnInputWrapper(ExistingContactWrapper inputWrapper, List<XC_UTIL_Sobject.WrapperResult> wrList){
        inputWrapper.wrapperOutput.success = false; 
        inputWrapper.wrapperOutput.errorMessage = wrList[0].errorMessage;
    }
}