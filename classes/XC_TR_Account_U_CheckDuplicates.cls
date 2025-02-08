/**
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @date Creation 03/09/2018
 * @date Modification 07/05/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_TR_Account_U_CheckDuplicates – logic to prevent Account duplication
 */

public without sharing class XC_TR_Account_U_CheckDuplicates {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Account_U_CheckDuplicates');
    public static Boolean startFromTrigger = false;

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description wrapper for return error messages in a component
    */
    public class ResultWrapper {
        public Account ac = new Account();
        public String accountID = '';
        public Boolean success = false;
        public Boolean successConsent = false;
        public Boolean isDuplicate = false;
        public String errorMessage = '';
        public Boolean isInsert = true;
        public Contact existingContact;
        public Boolean isForB2B = false;
        public Account accountForB2B = new Account();
        public List<XC_LegalEntityConsent__c> listlegalEntityConsentForExistingContacts = new List<XC_LegalEntityConsent__c>();
        /* @description ResultWrapper constructor */
        public ResultWrapper(){} 

        /**
        * @param successValue boolean value
        * @description ResultWrapper constructor with boolean parameter
        */
        public ResultWrapper(Boolean successValue){
            success = successValue;
        }
    }

    /**
    * @description onUpdateduplicationCheck
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 21/8/2019
    * @param listNew the list new
    * @param mapOld the map old
    * @param mapNew the map new
    */
    public static void onUpdateduplicationCheck(List<Account> listNew, Map<id, Account> mapOld, Map<id, Account> mapNew){
        // Select for "GiveDataTo":
        List<String> listField = XC_UTIL_Sobject.getListAllFields('Account');
        List<String> giveDataToAdd = new List<String>();
        for(String fieldName : listField) {
            if(fieldName.contains('XC_GiveDataTo_')) {
                giveDataToAdd.add(fieldName);
            }
        }  
        startFromTrigger = true;
        List<String> fieldToCheck = new List<String> {'PrimaryEmail__c', 'IdentityType__c', 'IdentityNumber__c', 'XC_GDPRThirdPartiesRelated__c'};
        fieldToCheck.addAll(giveDataToAdd);
        List<Account> residentialAccountList = new List<Account>();
        List<Account> sohoCondAccountList = new List<Account>();

        listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        for (Account acc : listNew) {
            if (XC_UTIL_Account.isResidential(acc.RecordTypeId)){
                residentialAccountList.add(acc);
            }else if(XC_UTIL_Account.isCondominium(acc.RecordTypeId) || XC_UTIL_Account.isSoho(acc.RecordTypeId) || XC_UTIL_Account.isB2B(acc.RecordTypeId) || XC_UTIL_Account.isB2G(acc.RecordTypeId)){
                sohoCondAccountList.add(acc);
            }
        }

        onInsertDuplicationCheck(sohoCondAccountList);
        List<ResultWrapper> results = duplicationCheck(residentialAccountList);
        adderror(results);
    }

    /**
    * @description duplicationCheck
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 21/8/2019
    * @param listNew List<Account> 
    * @return List<ResultWrapper>
    */
    public static List<ResultWrapper> duplicationCheck(List<Account> listNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in duplicationCheck');
        List<ResultWrapper> listResultWrapper = new List<ResultWrapper>();
        List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> results = XC_UTIL_AccountDuplication.checkExistingAccounts(listNew, XC_UTIL_AccountDuplication.INSERT_ACCOUNT);
        return convertCheckAccountWrapperToResultWrapper(results);
    }

    /**
    * @description Method to convert wrapper
    * @param results - List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>
    * @return List<ResultWrapper>
    */
    private static List<ResultWrapper> convertCheckAccountWrapperToResultWrapper(List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> results){
        List<ResultWrapper> listResultWrapper = new List<ResultWrapper>();
        for (XC_UTIL_AccountDuplication_W.CheckAccountWrapper checkWrapper : results) {
            ResultWrapper resultWrapper = new ResultWrapper();
            resultWrapper.ac = checkWrapper.existingAccountForPrimaryContact;
            resultWrapper.accountID = '';
            resultWrapper.isDuplicate = checkWrapper.existingContact != null && checkWrapper.existingAccountForPrimaryContact != null;
            resultWrapper.success = checkWrapper.success;
            resultWrapper.successConsent = checkWrapper.successConsent;
            resultWrapper.errorMessage = checkWrapper.errorMessage;
            resultWrapper.existingContact = checkWrapper.existingContact;
            resultWrapper.isInsert = checkWrapper.isInsert;
            resultWrapper.listlegalEntityConsentForExistingContacts = checkWrapper.listlegalEntityConsentForExistingContacts;
            if(checkWrapper.isForB2B != null && checkWrapper.accountForB2B != null) {
                resultWrapper.accountForB2B = checkWrapper.accountForB2B;
                resultWrapper.isForB2B = checkWrapper.isForB2B;
            }
            listResultWrapper.add(resultWrapper);
        }
        return listResultWrapper;
    }

    /**
    * @description onInsertDuplicationCheck
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 21/8/2019
    * @param triggerNew List<Account>
    */
    public static void onInsertDuplicationCheck(List<Account> triggerNew){
        List<Account> listAccountToCheck = new List<Account>();
        for(Account acc : triggerNew) {
            if(!XC_UTIL_Account.isPartner(acc.RecordTypeId)) {
                listAccountToCheck.add(acc);
            }
        }

        if(listAccountToCheck.isEmpty()) {
            return;
        }

        if (XC_LCC003_NewAccount.accountContactWrapper == null) {
            startFromTrigger = true;
            XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkFieldWrapper = new XC_UTIL_AccountDuplication_W.CheckFieldWrapper();
            //  Mod CV.Task New005A_I
            // * Add Set of RecordTypeId
            Set<Id> setIdRecordType = new Set<Id>();

            for(Account acc : listAccountToCheck) {
                checkFieldWrapper.setId.add(acc.id);
                checkFieldWrapper.setEmail.add(acc.PrimaryEmail__c);
                checkFieldWrapper.setDocumentType.add(acc.IdentityType__c);
                checkFieldWrapper.setDocumentNumber.add(acc.IdentityNumber__c);
                //  Mod CV.Task New005A_I
                // * Add Set of RecordTypeId
                setIdRecordType.add(acc.RecordTypeId);
            }
            /*  Mod CV.Task New005A_I
            * @ Add RecordTypeId =: recordTypeID in th Select to check even the recordType in duplication -- AND RecordTypeId IN :setIdRecordType
            Start --> */
            List<Account> existingAccounts = new List<Account>([
            SELECT Id, XC_isGuestUser__c, RecordTypeId, Name, XC_RecordTypeDeveloperName__c, PrimaryEmail__c, IdentityType__c, IdentityNumber__c, XC_DocumentCountry__c
            FROM Account
            WHERE (Id NOT IN: checkFieldWrapper.setId) AND (((PrimaryEmail__c IN: checkFieldWrapper.setEmail AND PrimaryEmail__c != NULL)
            OR (/*IdentityType__c IN: checkFieldWrapper.setDocumentType AND IdentityType__c != NULL
            AND */IdentityNumber__c IN: checkFieldWrapper.setDocumentNumber AND IdentityNumber__c != NULL)) AND RecordTypeId IN :setIdRecordType)]);
            /*if(existingAccounts.isEmpty()) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Nessun record trovato');
                return;
            }*/
            List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> results = checkErrorDuplicates(listAccountToCheck, existingAccounts, checkFieldWrapper);
            List<ResultWrapper> rWrappers = convertCheckAccountWrapperToResultWrapper(results);
            addError(rWrappers);
        }
    }

    /**
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @param listAccount the list of account to update
    * @description method to add error in before update
    */
    private static void addError(List<ResultWrapper> listAccount){
        for (ResultWrapper rw : listAccount) {
            if (!rw.success && !Test.isRunningTest()) {
                rw.ac.addError(rw.errorMessage);
            }
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 09/09/2019
    * @param listAccounts - List<Account>
    * @description Method to retrieve no duplicates Account in a List
    * @return List<Account>
    */
    private static List<Account> cleanListAccount(List<Account> listAccounts){
        List<Account> listResult = new List<Account>();
        Integer sizeList = listAccounts.size();
        for(Integer i=0; i<sizeList; i++) {
            Account accTemp = listAccounts[i];
            Boolean found = false;
            for(Integer j=i+1; j<sizeList; j++) {
                if(accTemp.PrimaryEmail__c == listAccounts[j].PrimaryEmail__c ||
                    (accTemp.IdentityType__c == listAccounts[j].IdentityType__c && accTemp.IdentityNumber__c == listAccounts[j].IdentityNumber__c)) {
                        found = true;
                        listAccounts[j].addError(Label.XC_CL_AccountAlreadyExistsInBatch);
                        break;
                }
            }
            if(!found) {
                listResult.add(accTemp);
            }
        }
        return listResult;
    }

    /**
    * @date Modified 09/09/2019 -  Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param triggerNew - List<Account>
    * @param existingAccounts - List<Account>
    * @param checkFieldWrapper - XC_UTIL_AccountDuplication_W.CheckFieldWrapper
    * @description Method to check if Account is duplicated
    * @return List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>
    */
    public static List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> checkErrorDuplicates(List<Account> triggerNew, List<Account> existingAccounts, XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkFieldWrapper){
        List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> wrapperListToReturn = new List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>();
        List<Account> temp = cleanListAccount(triggerNew);
        for(Account acc : temp) {
            Integer i = 0;
            Account existingAccount;
            while (i < existingAccounts.size()) {
                existingAccount = existingAccounts.get(i);
                if(existingAccount.XC_isGuestUser__c != acc.XC_isGuestUser__c) {
                    i++;
                    continue;
                }
                if(checkSingleAccountDuplicated(acc, existingAccount)) { // TORNA TRUE SE SONO UGUALI
                    XC_UTIL_AccountDuplication_W.CheckAccountWrapper wrapper = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
                    Integer index = existingAccounts.indexOf(existingAccount);
                    String key = '';
                    if(existingAccount.IdentityNumber__c != null && acc.IdentityNumber__c != null && existingAccount.IdentityNumber__c == acc.IdentityNumber__c) {
                        key = existingAccount.IdentityType__c + ' - ' + existingAccount.IdentityNumber__c;
                    } else {
                        key = existingAccount.PrimaryEmail__c;
                    }
                    wrapper.errorMessage = Label.XC_CL_ActiveAccountExists + ' ' + key;
                    wrapper.success = false;
                    if(checkIfDuplicateIsNew(index, existingAccount, checkFieldWrapper)) {
                        existingAccounts.remove(index);
                        wrapper.existingAccountForPrimaryContact = existingAccount;
                        wrapperListToReturn.add(wrapper);
                    } else if(index > -1){
                        wrapper.existingAccountForPrimaryContact = acc;
                        wrapperListToReturn.add(wrapper);
                    }
                }
                i++;
            }
            /*for(Account existingAccount : existingAccounts) {
                if(existingAccount.XC_isGuestUser__c != acc.XC_isGuestUser__c) {
                    continue;
                }
                if(checkSingleAccountDuplicated(acc, existingAccount)) { // TORNA TRUE SE SONO UGUALI
                    XC_UTIL_AccountDuplication_W.CheckAccountWrapper wrapper = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
                    Integer index = existingAccounts.indexOf(existingAccount);

                    String key = acc.IdentityNumber__c != null ? (acc.IdentityType__c + ' - ' + acc.IdentityNumber__c) : acc.PrimaryEmail__c;
                    wrapper.errorMessage = Label.XC_CL_ActiveAccountExists + ' ' + key;
                    wrapper.success = false;
                    if(checkIfDuplicateIsNew(index, existingAccount, checkFieldWrapper)) {
                        existingAccounts.remove(index);
                        wrapper.existingAccountForPrimaryContact = existingAccount;
                        wrapperListToReturn.add(wrapper);
                    } else if(index > -1){
                        wrapper.existingAccountForPrimaryContact = acc;
                        wrapperListToReturn.add(wrapper);
                    }
                }
            }*/
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'wrapperListToReturn ' + wrapperListToReturn);
        return wrapperListToReturn;
    }

    /**
    * @param index - Integer
    * @param existingAccount - Account
    * @param checkFieldWrapper - XC_UTIL_AccountDuplication_W.CheckFieldWrapper
    * @description Method to check if duplicate is new
    * @return Boolean
    */
    private static Boolean checkIfDuplicateIsNew(Integer index, Account existingAccount, XC_UTIL_AccountDuplication_W.CheckFieldWrapper checkFieldWrapper){
        return index > -1 && (existingAccount.Id == NULL || checkFieldWrapper.setId.contains(existingAccount.Id));
    }

    /**
    * @param acc - Account
    * @param acc1 - Account
    * @description Method to check single duplication
    * @return Boolean
    */
    public static Boolean checkSingleAccountDuplicated(Account acc, Account acc1){
        List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper> checkSingleFieldWrapperList = new List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper>();

        if(XC_UTIL_Account.isResidential(acc.recordTypeId) || acc.XC_isGuestUser__c) {
            String email;
            String existingEmail;

            if(!String.isBlank(acc.PrimaryEmail__c)) {
                email = acc.PrimaryEmail__c;
                existingEmail = acc1.PrimaryEmail__c;
                checkSingleFieldWrapperList.add(new XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper(email, existingEmail));
            }

            if (acc.XC_isGuestUser__c) {
                return XC_UTIL_AccountDuplication_U.checkFields(checkSingleFieldWrapperList);
            }
        }
        checkSingleFieldWrapperList = checkDocuments(checkSingleFieldWrapperList, acc, acc1);
        return XC_UTIL_AccountDuplication_U.checkFields(checkSingleFieldWrapperList);
    }

    /**
    * @param checkSingleFieldWrapperList - List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper>
    * @param acc - Account
    * @param acc1 - Account
    * @description Method to check documents
    * @return List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper>
    */
    private static List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper> checkDocuments(List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper> checkSingleFieldWrapperList, Account acc, Account acc1){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ check document ' + acc.IdentityType__c + acc.IdentityNumber__c);
        if (checkDocumentsCondition(acc, acc1)) {
            if(!String.isBlank(acc.IdentityType__c) && !String.isBlank(acc.IdentityNumber__c)) {
                String docTypeNumberCountry = acc.IdentityType__c + acc.IdentityNumber__c;
                String existingDocTypeNumberCountry = acc1.IdentityType__c + acc1.IdentityNumber__c;
                checkSingleFieldWrapperList.add(new XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper(docTypeNumberCountry, existingDocTypeNumberCountry));
            }
        }

        return checkSingleFieldWrapperList;
    }

    /**
    * @param acc - Account
    * @param acc1 - Account
    * @description Method to check documents conditions
    * @return Boolean
    */
    private static Boolean checkDocumentsCondition(Account acc, Account acc1){
        List<String> listRecordTypeToCheck = new List<String>{acc.RecordTypeId};
        String recordTypeNewAccount = Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.RecordTypeId).getDeveloperName();
        if(recordTypeNewAccount == Label.XC_CL_Lead_GLOB2B || recordTypeNewAccount == Label.XC_CL_Lead_GLOB2G) {
            listRecordTypeToCheck.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_Soho).getRecordTypeId());
        }
        return acc1.RecordTypeId == acc.RecordTypeId;
    }
}