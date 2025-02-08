/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
* @date Creation 27/06/2019
* @description XC_UTIL_AccountDuplication - Util class for Account/Contact Duplication process
*/

public without sharing class XC_UTIL_AccountDuplication {

    public static final Integer LEAD_CONVERSION = 1;
    public static final Integer INSERT_ACCOUNT = 1;
    public static List<Account> accountToCheckList = new List<Account>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_AccountDuplication');

    /** @description UpertedContactWrapper */
    public class UpertedContactWrapper {
        public List<XC_UTIL_Sobject.WrapperResult> listResult = new List<XC_UTIL_Sobject.WrapperResult>();
        public List<Contact> listContact = new List<Contact>();
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date Creation 27/06/2019
    * @description Method to check if Account exists
    * @param account - Account
    * @param operation - operation type
    * @return XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    */
    public static XC_UTIL_AccountDuplication_W.CheckAccountWrapper checkExistingAccount(Account account, Integer operation) {
        List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> listWrapper = checkExistingAccounts(new List<Account>{account}, operation);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For operation -> ' + operation);
        if(listWrapper.isEmpty()) {
            return new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Wrapper is not empty');
            return listWrapper[0];
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date Creation 27/06/2019
    * @description Method to check if Accounts exist
    * @param accountList - List<Account>
    * @param operation - operation type
    * @return List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>
    */
    public static List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> checkExistingAccounts(List<Account> accountList, Integer operation) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In method checkExistingAccounts');
        List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> toReturn = new List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>();
        List<Account> residentialAccountList = new List<Account>();
        List<Account> sohoCondAccountList = new List<Account>();
        for (Account acc : accountList) {
            if (XC_UTIL_Account.isResidential(acc.RecordTypeId)){
                residentialAccountList.add(acc);
            }else if(XC_UTIL_Account.isCondominium(acc.RecordTypeId) || XC_UTIL_Account.isSoho(acc.RecordTypeId) || XC_UTIL_Account.isB2B(acc.RecordTypeId) || XC_UTIL_Account.isB2G(acc.RecordTypeId)){
                sohoCondAccountList.add(acc);
            }
        }

        if(!sohoCondAccountList.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For account residential');
            List<XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper> sohoCondList = getSohoCondominiumWrapper(sohoCondAccountList);
            if (!sohoCondList.isEmpty()){
                toReturn.addAll(XC_UTIL_AccountDuplication_Z.checkForSohoCondominium(sohoCondList));

            }else {
                toReturn.add(new XC_UTIL_AccountDuplication_W.CheckAccountWrapper());
            }
        }

        if (!residentialAccountList.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For account not residential');
            accountToCheckList = residentialAccountList;
            XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkFieldWrapper = XC_UTIL_AccountDuplication_V.getCheckFieldWrapper(residentialAccountList);
            List<Contact> listContact = new List<Contact>();
            List<String> listField = XC_UTIL_Sobject.getListAllFields('Account');
            String query = 'SELECT Id, XC_RecordTypeDeveloperName__c, XC_ContactDocumentType__c, XC_ContactDocumentNumber__c, IndividualId, Account.XC_GDPRThirdPartiesRelated__c, Account.XC_isGuestUser__c, Name, XC_PrimaryContact__c, FirstName, LastName, Phone,  AccountId, XC_MainLegalEntity__c, XC_PhonePrefix__c, Email, RecordTypeId, Account.RecordTypeId, Account.Name, Account.XC_RecordTypeDeveloperName__c, Account.PrimaryEmail__c, Account.XC_AccountPhonePrefix__c, Account.Phone, Account.IdentityType__c, Account.IdentityNumber__c, Account.XC_DocumentCountry__c ';
            // Select for "GiveDataTo":
            for(String fieldName : listField) {
                if(fieldName.contains('XC_GiveDataTo_')) {
                    query += ', Account.' + fieldName + ' ';
                }
            }
            Set<String> setIds = checkFieldWrapper.setId;
            Set<String> setEmails = checkFieldWrapper.setEmail;
            Set<String> setDocNumbers = checkFieldWrapper.setDocumentNumber;
            query += ', (SELECT Id, XC_MainDocument__c, XC_Contact__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_Account__c, XC_Country__c FROM Personal_Documents__r), (SELECT Id, AccountId, ContactId FROM AccountContactRelations) ';
            query += ' FROM Contact WHERE AccountId NOT IN: setIds AND (((Email IN :setEmails AND Email != NULL) OR (Account.PrimaryEmail__c IN :setEmails AND Account.PrimaryEmail__c != NULL)) ';
            query += ' OR (Account.IdentityNumber__c IN :setDocNumbers AND Account.IdentityNumber__c != NULL) ';
            query += ' OR (XC_ContactDocumentNumber__c IN :setDocNumbers AND XC_ContactDocumentNumber__c != NULL))';
            listContact = Database.query(String.escapeSingleQuotes(query));
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ List contact found: ' + listContact);
            toReturn.addAll(XC_UTIL_AccountDuplication_V.getErrorDuplicates(listContact, checkFieldWrapper, residentialAccountList));
        }
        return toReturn;
    }

    /**
    * @description Method to build Wrapper for Soho/Condominium
    * @param accountList - List<Account>
    * @return List<XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper>
    */
    private static List<XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper> getSohoCondominiumWrapper(List<Account> accountList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In method getSohoCondominiumWrapper');
        List<XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper> wrapperList = new List<XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper>();
        XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkFieldWrapper = new XC_UTIL_AccountDuplication_W.CheckFieldWrapper();
        for(Account acc : accountList){
            checkFieldWrapper.setId.add(acc.id);
            //checkFieldWrapper.setEmail.add(acc.PrimaryEmail__c);
            checkFieldWrapper.setDocumentType.add(acc.IdentityType__c);
            checkFieldWrapper.setDocumentNumber.add(acc.IdentityNumber__c);
        }

        List<Account> checkedAccount = new List<Account>();
        List<String> listField = XC_UTIL_Sobject.getListAllFields('Account');
        String query = 'SELECT Id, XC_FirstName__c, XC_AccountPhone__c, XC_MainPhonePrefix__c, XC_Preference_Language__c, XC_Salutation__c, XC_AccountNationality__c, XC_AccountMainPhone__c, XC_NIE_expedition_date__c, XC_NIE_expiration_date__c, XC_LastName__c, XC_RecordTypeDeveloperName__c, XC_GDPRThirdPartiesRelated__c, RecordTypeId, Name, PrimaryEmail__c, XC_AccountPhonePrefix__c, Phone, IdentityType__c, IdentityNumber__c, XC_DocumentCountry__c ';
        // Select for "GiveDataTo":
        for(String fieldName : listField) {
            if(fieldName.contains('XC_GiveDataTo_')) {
                query += ', ' + fieldName + ' ';
            }
        }
        Set<String> setDocNumber = checkFieldWrapper.setDocumentNumber;
        Set<String> setIdAcc = checkFieldWrapper.setId;
        query += ' FROM Account WHERE IdentityNumber__c IN :setDocNumber AND IdentityNumber__c != NULL AND Id NOT IN :setIdAcc';
        checkedAccount = Database.query(String.escapeSingleQuotes(query));

        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = XC_LCC003_NewAccount.accountContactWrapper;
        List<Contact> existingContacts;
        Contact newContact = new Contact();
        Account newAccount = accountList[0];
        existingContacts = XC_UTIL_AccountDuplication_V.getExistingContacts(newAccount, newContact, existingContacts);
        existingContacts = existingContacts == null ? new List<Contact>() : existingContacts;
        for (Account acc : accountList) {
            if (!checkedAccount.isEmpty()){
                for (Account accToCheck : checkedAccount) {
                    String docTypeNumber = acc.IdentityType__c + acc.IdentityNumber__c;
                    String existingDocTypeNumber = accToCheck.IdentityType__c + accToCheck.IdentityNumber__c;
                    if (docTypeNumber == existingDocTypeNumber){
                        XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper = XC_UTIL_AccountDuplication_V.checkInputData(accToCheck, existingContacts, newContact);
                        wrapper.newAccount = newAccount;
                        wrapperList.add(wrapper);
                        break;
                    }
                }
            }else if(inputData != null && !existingContacts.isEmpty() ){
                XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper wrapper = new XC_UTIL_AccountDuplication_W.AccountSohoCondominiumWrapper();
                wrapper.listExistingContact = existingContacts;
                wrapper.newContact = newContact;
                wrapper.newAccount = newAccount;
                wrapperList.add(wrapper);
            }

        }
        return wrapperList;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date Creation 27/06/2019
    * @description Method to check if Contact exists
    * @param checkFieldWrapper - XC_UTIL_AccountDuplication_W.CheckFieldWrapper
    * @param operation - operation type
    * @param recordTypeId - String
    * @return XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    */
    public static XC_UTIL_AccountDuplication_W.CheckAccountWrapper checkExistingContact(XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkFieldWrapper, Integer operation, String recordTypeId) {
        List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> listWrapper = checkExistingContacts(checkFieldWrapper, operation, new List<String>{recordTypeId});
        if(listWrapper.isEmpty()) {
            return new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
        } else {
            return listWrapper[0];
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 27/06/2019
    * @description Method to check if Contact exists with a list of recordtype
    * @param checkFieldWrapper - XC_UTIL_AccountDuplication_W.CheckFieldWrapper
    * @param operation - operation type
    * @param recordTypeId - List<String>
    * @return XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    */
    public static XC_UTIL_AccountDuplication_W.CheckAccountWrapper checkExistingContact(XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkFieldWrapper, Integer operation, List<String> recordTypeId) {
        List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> listWrapper = checkExistingContacts(checkFieldWrapper, operation, recordTypeId);
        if(listWrapper.isEmpty()) {
            return new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
        } else {
            return listWrapper[0];
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date Creation 27/06/2019
    * @description Method to check if Contact exists
    * @param checkFieldWrapper - XC_UTIL_AccountDuplication_W.CheckFieldWrapper
    * @param operation - operation type
    * @param recordTypeId - List<String>
    * @return XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    */
    public static List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> checkExistingContacts(XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkFieldWrapper, Integer operation, List<String> recordTypeId) {

        List<Contact> listOfContact = new List<Contact>([
        SELECT Id, IndividualId,  Account.XC_isGuestUser__c, XC_PrimaryContact__c, Name, FirstName, LastName, Phone,  AccountId, XC_MainLegalEntity__c,
        XC_PhonePrefix__c, Email, RecordTypeId, Account.Name, Account.PrimaryEmail__c, Account.XC_AccountPhonePrefix__c, Account.Phone,
        Account.IdentityType__c, Account.IdentityNumber__c, Account.XC_DocumentCountry__c, Account.XC_GiveDataTo_JuicenetLimited__c, XC_ContactPhone__c,
        Account.XC_GiveDataTo_EndesaX__c, Account.XC_MainPhonePrefix__c, Account.XC_AccountMainPhone__c/*,
        (SELECT Id, XC_MainDocument__c, XC_Contact__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_Account__c, XC_Country__c
        FROM  Personal_Documents__r)//, (SELECT Id, AccountId, ContactId FROM AccountContactRelations) */
        FROM Contact
        WHERE (RecordTypeId IN :recordTypeId) AND
        (((LastName IN: checkFieldWrapper.setLastName
        AND FirstName IN: checkFieldWrapper.setFirstName
        AND Phone IN: checkFieldWrapper.setPhone) AND
        (LastName <> null
        AND FirstName <> null
        AND Phone <> null))
        OR (Email <> null AND Email IN: checkFieldWrapper.setEmail)
        OR ((XC_ContactDocumentType__c <> null AND XC_ContactDocumentNumber__c <> null) AND
        (XC_ContactDocumentType__c IN :checkFieldWrapper.setPersonalDocumentType AND XC_ContactDocumentNumber__c IN :checkFieldWrapper.setPersonalDocumentNumber)))]);

        if (listOfContact.isEmpty()){
            return new List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>();
        }
        return populateCheckAccountWrapper(listOfContact, operation);
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 28/06/2019
    * @description Method to retrieve Account for Secondary Contact
    * @param checkAccountWrapperToAdd - XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    * @param con - Contact
    */
    private static void checkForSecondaryContact(XC_UTIL_AccountDuplication_W.CheckAccountWrapper checkAccountWrapperToAdd, Contact con) {
        for(AccountContactRelation rel : con.AccountContactRelations) {
            if(rel.AccountId != con.AccountId) {
                checkAccountWrapperToAdd.listIdExistingAccountForSecondaryContact.add(rel.AccountId);
            }
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date Creation 27/06/2019
    * @description Method to populate XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    * @param listOfContact - List<Contact>
    * @param operation - operation type
    * @return XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    */
    private static List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> populateCheckAccountWrapper(List<Contact> listOfContact, Integer operation) {
        List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> listOfLeadWrapper = new List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>();
        if(operation == LEAD_CONVERSION){
            XC_UTIL_AccountDuplication_W.CheckAccountWrapper checkAccountWrapperToAdd = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
            for(Contact con : listOfContact){
                checkAccountWrapperToAdd = getWrapperForExistingContact(con, checkAccountWrapperToAdd);
                listOfLeadWrapper.add(checkAccountWrapperToAdd);
            }
            return listOfLeadWrapper;
        }
        return null;
    }

    /**
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 01/07/2019
    * @description Method to get Wrapper For Existing Contact
    * @param con - Contact needed for check duplicate
    * @param checkAccountWrapperToAdd - XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    * @return XC_UTIL_AccountDuplication_W.CheckAccountWrapper
    */
    public static XC_UTIL_AccountDuplication_W.CheckAccountWrapper getWrapperForExistingContact(Contact con, XC_UTIL_AccountDuplication_W.CheckAccountWrapper checkAccountWrapperToAdd){
        checkAccountWrapperToAdd.existingContact = con;
        checkAccountWrapperToAdd.contactExists = true;
        checkAccountWrapperToAdd.contactIsPrimary = con.XC_PrimaryContact__c;
        if(!String.isBlank(con.AccountId) && con.XC_PrimaryContact__c == true) {
            checkAccountWrapperToAdd.accountExistsForPrimary = true;
        }
        if(con.AccountContactRelations.size() > 1) {
            checkAccountWrapperToAdd.accountExistsForSecondary = true;
            checkForSecondaryContact(checkAccountWrapperToAdd, con);
        }
        return checkAccountWrapperToAdd;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 11/03/2020
    * @description Method to manage existing Contact or to manage new Contact
    * @param listContact - List<Contact>
    * @param listDocKey - List<String>
    * @return UpertedContactWrapper
    */
    public static UpertedContactWrapper upsertContacts(List<Contact> listContact, List<String> listDocKey) {
        // Split list Contact to check for insert and Contact to update:
        String conditionGuestContact = 'Yes';
        List<Contact> listContactToManage = new List<Contact>();
        List<Contact> listContactToUpdate = new List<Contact>();
        List<Contact> listContactWithDuplicateError = new List<Contact>();
        Set<String> setEmailsGuest = new Set<String>();
        Set<String> setDocumentTypeGuest = new Set<String>();
        Set<String> setDocumentNumberGuest = new Set<String>();
        Set<String> setEmailsNoGuest = new Set<String>();
        Set<String> setDocumentTypeNoGuest = new Set<String>();
        Set<String> setDocumentNumberNoGuest = new Set<String>();
        Integer i=0;
        Map<String, Boolean> mapContactDocAlreadyExists = new Map<String, Boolean>();
        String contactType = '';
        for(Contact cnt : listContact) {
            // Populate list/set for check:
            if(String.isBlank(cnt.Id)) {
                // Populate doc info for Contacts:
                if(listDocKey[i].contains('_')) {
                    List<String> docInfo = listDocKey[i].split('_');
                    cnt.XC_ContactDocumentType__c = String.isNotBlank(docInfo[0]) ? docInfo[0] : '';
                    cnt.XC_ContactDocumentNumber__c = String.isNotBlank(docInfo[1]) ? docInfo[1] : '';
                }
                listContactToManage.add(cnt);
            } else {
                listContactToUpdate.add(cnt);
            }
            if(cnt.XC_isGuestContact__c == conditionGuestContact) {
                setEmailsGuest.add(cnt.Email);
                setDocumentTypeGuest.add(cnt.XC_ContactDocumentType__c);
                setDocumentNumberGuest.add(cnt.XC_ContactDocumentNumber__c);
            } else {
                setEmailsNoGuest.add(cnt.Email);
                setDocumentTypeNoGuest.add(cnt.XC_ContactDocumentType__c);
                setDocumentNumberNoGuest.add(cnt.XC_ContactDocumentNumber__c);
            }
            contactType = cnt.RecordTypeId;
            i++;
        }

        contactType = SObjectType.Contact.getRecordTypeInfosById().get(contactType).getName();
        // Management Contact to insert:
        List<Contact> listContactToInsert = new List<Contact>();
        if(!listContactToManage.isEmpty()) {
            // Query existing Contact for email OR document:
            String queryPersonalDocument = ' (SELECT Id, XC_Contact__c, XC_Country__c, XC_DocumentNumber__c, XC_DocumentType__c FROM Personal_Documents__r) ';
            String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('Contact') + ', ' + queryPersonalDocument;
            query += ' FROM Contact ';
            query += ' WHERE (XC_isGuestContact__c = :conditionGuestContact AND Email <> null AND Email IN: setEmailsGuest) OR ';
            query += ' (XC_isGuestContact__c != :conditionGuestContact AND ((Email <> null AND Email IN: setEmailsNoGuest) OR (RecordType.Name =: contactType AND (XC_ContactDocumentType__c IN :setDocumentTypeNoGuest AND XC_ContactDocumentNumber__c IN :setDocumentNumberNoGuest))))';
            List<Contact> listExistingContactTemp = Database.query(String.escapeSingleQuotes(query));
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listExistingContactTemp -> ' + listExistingContactTemp);

            // Filter for two cases (guest or not):
            Map<String, Contact> mapExistingContacts = new Map<String, Contact>();
            for(Contact cntInput : listContact) {
                for(Contact cntQueried : listExistingContactTemp) {
                    /*if( !mapExistingContacts.containsKey(cntQueried.Id) &&
                    cntInput.XC_isGuestContact__c == conditionGuestContact && cntQueried.XC_isGuestContact__c == conditionGuestContact && String.isNotBlank(cntInput.Email) && setEmailsGuest.contains(cntInput.Email) ||
                    cntInput.XC_isGuestContact__c != conditionGuestContact && cntQueried.XC_isGuestContact__c != conditionGuestContact && ((String.isNotBlank(cntInput.Email) && setEmailsNoGuest.contains(cntInput.Email)) || (String.isNotBlank(cntInput.XC_ContactDocumentNumber__c) && setDocumentNumberNoGuest.contains(cntInput.XC_ContactDocumentNumber__c)))) { // fix setEmailsNoGuest*/
                        // *@ Mod CV.Task New005A_I : added check on XC_RecordTypeName__c
                        if( !mapExistingContacts.containsKey(cntQueried.Id) &&
                        cntInput.XC_isGuestContact__c == conditionGuestContact && cntQueried.XC_isGuestContact__c == conditionGuestContact && String.isNotBlank(cntInput.Email) && cntInput.Email==cntQueried.Email ||
                        cntInput.XC_isGuestContact__c != conditionGuestContact && cntQueried.XC_isGuestContact__c != conditionGuestContact && (String.isNotBlank(cntInput.Email) && cntInput.Email==cntQueried.Email) && cntInput.XC_RecordTypeName__c==cntQueried.XC_RecordTypeName__c || (String.isNotBlank(cntInput.XC_ContactDocumentNumber__c) && cntInput.XC_ContactDocumentNumber__c==cntQueried.XC_ContactDocumentNumber__c) && cntInput.XC_RecordTypeName__c==cntQueried.XC_RecordTypeName__c ) { // fix setEmailsNoGuest
                            mapExistingContacts.put(cntQueried.Id, cntQueried);
                            break;
                        }
                    }
                }

                List<Contact> listExistingContact = mapExistingContacts.values();
                Map<String, List<Contact>> mapEmailContact = new Map<String, List<Contact>>();
                Map<String, List<Contact>> mapDocContact = new Map<String, List<Contact>>();
                for(Contact cntQueried : listExistingContact) {
                    if(String.isNotBlank(cntQueried.Email)) {
                        if(!mapEmailContact.containsKey(cntQueried.Email)) {
                            mapEmailContact.put(cntQueried.Email, new List<Contact>());
                        }
                        mapEmailContact.get(cntQueried.Email).add(cntQueried);
                    }
                    if(String.isNotBlank(cntQueried.XC_ContactDocumentType__c) && String.isNotBlank(cntQueried.XC_ContactDocumentNumber__c)) {
                        String key = cntQueried.XC_ContactDocumentType__c + cntQueried.XC_ContactDocumentNumber__c;
                        if(!mapDocContact.containsKey(key)) {
                            mapDocContact.put(key, new List<Contact>());
                        }
                        mapDocContact.get(key).add(cntQueried);
                    }
                }
                List<Contact> listContactWithoutDuplicateError = new List<Contact>();

                for(Contact cntInput : listContactToManage) {
                    List<Contact> cntPossibleDuplicateByEmail = mapEmailContact.get(cntInput.Email);
                    List<Contact> cntPossibleDuplicateByDoc = mapDocContact.get(cntInput.XC_ContactDocumentType__c+cntInput.XC_ContactDocumentNumber__c);
                    if((cntPossibleDuplicateByEmail != null && cntPossibleDuplicateByEmail.size() > 1) || (cntPossibleDuplicateByDoc != null && cntPossibleDuplicateByDoc.size() > 1)) {
                        listContactWithDuplicateError.add(cntInput);
                    }/*else if(cntInput.XC_isGuestContact__c != conditionGuestContact && cntPossibleDuplicateByEmail != null && cntPossibleDuplicateByEmail.size() >= 1) { // fix == 1
                        listContactWithDuplicateError.add(cntInput);
                    } else if(cntInput.XC_isGuestContact__c == conditionGuestContact && cntPossibleDuplicateByEmail != null && cntPossibleDuplicateByEmail.size() >= 1) { // fix == 1
                        listContactWithDuplicateError.add(cntInput);
                    }*/
                    else if(cntInput.XC_isGuestContact__c != conditionGuestContact && cntPossibleDuplicateByEmail != null && cntPossibleDuplicateByDoc != null && cntPossibleDuplicateByEmail.size() == 1 && cntPossibleDuplicateByDoc.size() == 1 && cntPossibleDuplicateByEmail[0].Id != cntPossibleDuplicateByDoc[0].Id) {
                        listContactWithDuplicateError.add(cntInput);
                    }
                    // NM - LR 10.04.2020
                    else if(cntPossibleDuplicateByEmail != null && String.isNotBlank(cntPossibleDuplicateByEmail[0].XC_ContactDocumentNumber__c) && String.isNotBlank(cntInput.XC_ContactDocumentNumber__c) && cntInput.XC_ContactDocumentNumber__c != 'null' && cntPossibleDuplicateByEmail[0].XC_ContactDocumentNumber__c != cntInput.XC_ContactDocumentNumber__c) {
                        listContactWithDuplicateError.add(cntInput);
                    } else if(cntPossibleDuplicateByDoc != null &&  String.isNotBlank(cntPossibleDuplicateByDoc[0].Email) && String.isNotBlank(cntInput.Email) && cntPossibleDuplicateByDoc[0].Email != cntInput.Email && cntInput.XC_isGuestContact__c == 'No') {
                        listContactWithDuplicateError.add(cntInput);
                    } 
                    
                    //
                    /*  Mod CV.Task New005A_I
                    * @ Description duplication check with identity Number-Type and Email (Soho)
                    Start --> */
                    else if(cntInput.XC_RecordTypeName__c == 'Soho' && cntInput.XC_PrimaryContact__c && 
                           (cntPossibleDuplicateByDoc != null && cntPossibleDuplicateByDoc[0].XC_PrimaryContact__c || cntPossibleDuplicateByEmail != null && cntPossibleDuplicateByEmail[0].XC_PrimaryContact__c) && 
                    (
                    //Check primary email
                    (cntPossibleDuplicateByEmail != null && (String.isNotBlank(cntInput.Email) && cntPossibleDuplicateByEmail[0].Email == cntInput.Email
                    ))
                    // OR Check document
                    ||
                    cntPossibleDuplicateByDoc != null && cntInput.XC_ContactDocumentNumber__c == cntPossibleDuplicateByDoc[0].XC_ContactDocumentNumber__c && cntInput.XC_ContactDocumentType__c == cntPossibleDuplicateByDoc[0].XC_ContactDocumentType__c
                    //Check if is primary
                    /*&& (cntPossibleDuplicateByDoc != null && cntPossibleDuplicateByDoc[0].XC_PrimaryContact__c || cntPossibleDuplicateByEmail != null && cntPossibleDuplicateByEmail[0].XC_PrimaryContact__c)*/
                    //Check guest
                    &&  cntInput.XC_isGuestContact__c == 'No') ){
                        //Statement
                        listContactWithDuplicateError.add(cntInput);
                    }
                    //End <--
                    else {
                        listContactWithoutDuplicateError.add(cntInput);
                    }
                }

                // Split Duplicated Contact and Not Duplicated Contact:
                List<Contact> listContactDuplicated = new List<Contact>();
                Map<String, Contact> mapIdExistingContactWithNew = new Map<String, Contact>();
                for(Contact contactToManage : listContactWithoutDuplicateError) {
                    Boolean found = false;
                    Contact contactFound;
                    for(Contact contactQueried : listExistingContact) {
                        if(checkContactMatching(contactToManage, contactQueried)) {
                            found = true;
                            contactFound = contactQueried;
                            mapIdExistingContactWithNew.put(contactQueried.Id, contactToManage);
                            break;
                        }
                    }
                    if(found) {
                        if(String.isNotBlank(contactFound.XC_ContactDocumentType__c) && String.isNotBlank(contactFound.XC_ContactDocumentNumber__c)) {
                            mapContactDocAlreadyExists.put(contactFound.Id, true);
                        } else {
                            mapContactDocAlreadyExists.put(contactFound.Id, false);
                        }
                        listContactDuplicated.add(contactFound);
                    } else {
                        listContactToInsert.add(contactToManage);
                    }
                }

                // Manage Duplicated Contact:
                if(!listContactDuplicated.isEmpty()) {
                    List<AccountContactRelation> listRelatationToInsert = new List<AccountContactRelation>();
                    for(Contact existingContact : listContactDuplicated) {
                        Contact inputContact = mapIdExistingContactWithNew.get(existingContact.Id);
                        Map<String, Object> mapInputContactTemp = inputContact.getPopulatedFieldsAsMap();
                        // Link this Contact like Secondary of old Account:
                        if(existingContact.XC_PrimaryContact__c && (mapInputContactTemp.containsKey('AccountId') && mapInputContactTemp.get('AccountId') != existingContact.AccountId)) {
                            AccountContactRelation accountContact = new AccountContactRelation(
                            //AccountId = existingContact.AccountId,
                            AccountId = String.valueof(mapInputContactTemp.get('AccountId')),
                            ContactId = existingContact.Id
                            );
                            listRelatationToInsert.add(accountContact);
                        }

                        // Check if fields must be updated:
                        Boolean updated = false;
                        Set<String> fieldToCheck = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().keySet();
                        Map<String, Object> mapExistingContactTemp = existingContact.getPopulatedFieldsAsMap();
                        Map<String, Object> mapExistingContact = new Map<String, Object>();
                        Map<String, Object> mapInputContact = new Map<String, Object>();
                        for(String key : mapExistingContactTemp.keySet()) {
                            mapExistingContact.put(key.toLowerCase(), mapExistingContactTemp.get(key));
                        }
                        for(String key : mapInputContactTemp.keySet()) {
                            mapInputContact.put(key.toLowerCase(), mapInputContactTemp.get(key));
                        }

                        // Update fields:
                        for(String field : fieldToCheck) {
                            if(field == 'xc_mainlegalentity__c' && mapInputContact.get('xc_mainlegalentity__c') != mapExistingContact.get('xc_mainlegalentity__c')) {
                                mapInputContact.remove('xc_mainlegalentity__c');
                                mapInputContact.remove('xc_countrylegalentity__c');
                                mapInputContact.remove('xc_givedatatonew__c');
                                existingContact.XC_MainLegalEntity__c = (String) mapExistingContact.get('xc_mainlegalentity__c');
                                existingContact.XC_CountryLegalEntity__c = (String) mapExistingContact.get('xc_countrylegalentity__c');
                                existingContact.XC_GiveDataToNew__c = (String) mapExistingContact.get('xc_givedatatonew__c');
                                continue;
                            }
                            if(checkInsertDuplicateField(field, mapInputContact, mapExistingContact)) {
                                updated = true;
                                existingContact.put(field, inputContact.get(field.toLowerCase()));
                            }
                        }
                        if(updated) {
                            // Delete Doc info:
                            Boolean documentAlreadyExist = mapContactDocAlreadyExists.get(existingContact.Id);
                            if(!documentAlreadyExist) {
                                existingContact.XC_ContactDocumentType__c = '';
                                existingContact.XC_ContactDocumentNumber__c = '';
                            }
                            listContactToUpdate.add(existingContact);
                        }
                    }
                    XC_UTIL_Sobject.insertListRecords(listRelatationToInsert);
                }
            }

            // Delete Doc info:
            List<Contact> finalListContactToInsert = new List<Contact>();
            for(Contact cntToInt : listContactToInsert) {
                cntToInt.XC_ContactDocumentType__c = '';
                cntToInt.XC_ContactDocumentNumber__c = '';
                finalListContactToInsert.add(cntToInt);
            }

            // Update/Insert contacts and management response:
            List<XC_UTIL_Sobject.WrapperResult> listResult = new List<XC_UTIL_Sobject.WrapperResult>();
            if(!listContactToUpdate.isEmpty()) {
                listResult.addAll(XC_UTIL_Sobject.updateListRecords(listContactToUpdate));
            }
            if(!finalListContactToInsert.isEmpty()) {
                listResult.addAll(XC_UTIL_Sobject.insertListRecords(finalListContactToInsert));
            }
            if(!listContactWithDuplicateError.isEmpty()) {
                for(Contact cntDuplicateError : listContactWithDuplicateError) {
                    XC_UTIL_Sobject.WrapperResult errorRes = new XC_UTIL_Sobject.WrapperResult();
                    errorRes.success = false;
                    if(cntDuplicateError.XC_isGuestContact__c == conditionGuestContact) {
                        errorRes.errorMessage = Label.XC_CL_ErrorUpsertContact_OnlyEmail;
                    } else {
                        errorRes.errorMessage = Label.XC_CL_ErrorUpsertContact;
                    }
                    listResult.add(errorRes);
                }
            }
            // Populate wrapper result:
            UpertedContactWrapper resWrapper = new UpertedContactWrapper();
            resWrapper.listResult = listResult;
            resWrapper.listContact.addAll(listContactToUpdate);
            resWrapper.listContact.addAll(finalListContactToInsert);

            return resWrapper;
        }

        /**
        * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
        * @date Creation 11/03/2020
        * @description Method to check if 2 Contact are equal
        * @param cnt1 - Contact
        * @param cnt2 - Contact
        * @return Boolean
        */
        public static Boolean checkContactMatching(Contact cnt1, Contact cnt2) {
            return (String.isNotBlank(cnt1.Email) && String.isNotBlank(cnt2.Email) && cnt1.Email == cnt2.Email) ||
            (
            (String.isNotBlank(cnt1.XC_ContactDocumentType__c) && String.isNotBlank(cnt1.XC_ContactDocumentNumber__c)) &&
            (String.isNotBlank(cnt2.XC_ContactDocumentType__c) && String.isNotBlank(cnt2.XC_ContactDocumentNumber__c)) &&
            (cnt1.XC_ContactDocumentType__c == cnt2.XC_ContactDocumentType__c && cnt1.XC_ContactDocumentNumber__c == cnt2.XC_ContactDocumentNumber__c  && cnt1.XC_isGuestContact__c == cnt2.XC_isGuestContact__c)
            );
        }

        /**
        * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
        * @date Creation 11/03/2020
        * @description Method to check if 2 Contact are equal
        * @param cnt1 - Contact
        * @param cnt2 - Contact
        * @param listDocInfo - List<String>
        * @return Boolean
        */
        public static Boolean checkContactMatching(Contact cnt1, Contact cnt2, List<String> listDocInfo) {
            if(listDocInfo.size() != 2) {
                return false;
            }
            return (String.isNotBlank(cnt1.Email) && String.isNotBlank(cnt2.Email) && cnt1.Email == cnt2.Email) ||
            (
            (String.isNotBlank(cnt1.XC_ContactDocumentType__c) && String.isNotBlank(cnt1.XC_ContactDocumentNumber__c)) &&
            (String.isNotBlank(listDocInfo[0]) && String.isNotBlank(listDocInfo[1])) &&
            (cnt1.XC_ContactDocumentType__c == listDocInfo[0] && cnt1.XC_ContactDocumentNumber__c == listDocInfo[1])
            );
        }

        /**
        * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
        * @date Creation 03/04/2020
        * @description Method to check if field has to updated
        * @param field - String
        * @param mapInputContact - Map<String, Object>
        * @param mapExistingContact - Map<String, Object>
        * @return Boolean
        */
        public static Boolean checkInsertDuplicateField(String field, Map<String, Object> mapInputContact, Map<String, Object> mapExistingContact) {
            List<String> listFieldsKey = new List<String>{'Email', 'XC_ContactDocumentCountry__c', 'XC_ContactDocumentType__c', 'XC_ContactDocumentNumber__c'};
            List<String> listFieldsKeyLower = new List<String>();
            for(String key : listFieldsKey) {
                listFieldsKeyLower.add(key.toLowerCase());
            }
            //Boolean primaryCheck = (field == 'XC_PrimaryContact__c'.toLowerCase() && (mapExistingContact.containsKey('XC_PrimaryContact__c'.toLowerCase())));
            Boolean primaryCheck = (field == 'XC_PrimaryContact__c'.toLowerCase() && mapInputContact.get(field.toLowerCase()) != null && Boolean.valueOf(mapInputContact.get(field.toLowerCase())) == false);
            Boolean isKey = listFieldsKeyLower.contains(field);
            Boolean fieldExistsForInputContact = mapInputContact.containsKey(field.toLowerCase());
            Boolean fieldExistsForExistingContact = mapExistingContact.containsKey(field.toLowerCase());
            Boolean fieldNotAlreadyExists = String.isBlank(String.valueOf(mapExistingContact.get(field.toLowerCase())));
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkInsertDuplicateField for field ' + field + ' -> isKey:' + isKey + ' fieldExistsForInputContact:' + fieldExistsForInputContact + ' fieldExistsForExistingContact:' + fieldExistsForExistingContact + ' fieldNotAlreadyExists:' + fieldNotAlreadyExists);

            XC_UTIL_Debug.debug(DEBUGACTIVE, 'field: ' + field.toLowerCase());
            if(field == 'XC_PrimaryContact__c'.toLowerCase()) {
                System.debug('input XC_PrimaryContact__c: ' + mapInputContact.get(field.toLowerCase()));
                System.debug('existing XC_PrimaryContact__c: ' + mapExistingContact.get(field.toLowerCase()));
                System.debug('primaryCheck: ' + primaryCheck);
                System.debug('fieldExistsForInputContact: ' + fieldExistsForInputContact);
                System.debug('isKey: ' + isKey);
                System.debug(LoggingLevel.FINEST, '@@@ checkInsertDuplicateField for field ' + field + ' -> isKey:' + isKey + ' fieldExistsForInputContact:' + fieldExistsForInputContact + ' fieldExistsForExistingContact:' + fieldExistsForExistingContact + ' fieldNotAlreadyExists:' + fieldNotAlreadyExists);
            }

            if(field == 'AccountId'.toLowerCase() && mapExistingContact.get('XC_PrimaryContact__c'.toLowerCase()) != null && Boolean.valueOf(mapExistingContact.get('XC_PrimaryContact__c'.toLowerCase())) == true) {
                return false;
            }

            return (!primaryCheck && fieldExistsForInputContact && (!isKey || (isKey && (!fieldExistsForExistingContact || (fieldExistsForExistingContact && fieldNotAlreadyExists)))));
        }

    }