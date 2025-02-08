/**
* @author Nicolò Leonardi - nleonardi@deloitte.it & Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/08/2018
* @description XC_LCC003_NewAccount – Apex Controller for XC_LCP003_NewAccount
*/

public without sharing class XC_LCC003_NewAccount {  

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC003_NewAccount');
    public static XC_LCC003_NewAccount_W.AccountInputDataWrapper accountContactWrapper;
    public static List<String> countryIsoListemobility = new List<String>{'ESP','USA','GBR'}; //Per Romania sono stati creati i FieldSet 

    /** @description FieldSetWrapper */
    public class FieldSetWrapper {
        List<FieldSetMember> fsType = new List<FieldSetMember>();
        List<FieldSetMember> fsPersonalData = new List<FieldSetMember>();
        List<FieldSetMember> fsDocumentData = new List<FieldSetMember>();
        //List<FieldSetMember> fsDirection = new  List<FieldSetMember>();   
        List<FieldSetMember> fsOpportunity = new List<FieldSetMember>();
        List<FieldSetMember> fsConsents = new List<FieldSetMember>();
        List<String> brands = new List<String>();
        String listMandatory = '';
        String recordTypeName = '';
        String userCountry = '';
        String defaultPhonePrefix ='';
        String defaultPrefLanguage = '';
        String defaultNationality='';
        Account existingRecord = new Account();
        List<String> documentTypes = new List<String>();
    }

    /** @description AccountInputDataWrapper */
    /*private class AccountInputDataWrapper{
        public String contactFields;
        public String addressFields;
        public Boolean thirdPartiesCheck;
        public String thirdPartiesCheckNew;
        public String thirdPartiesVersion;
        public String consentsLE;
    }*/

    /**
     * @description Create Account record
     * @param mapAccountString - String to deserialize to get fields
     * @return XC_LCC003_NewAccount_W.InsertResultWrapper
     */
    @AuraEnabled
    public static XC_LCC003_NewAccount_W.InsertResultWrapper createRecord(String mapAccountString) {
        if(String.isBlank(mapAccountString)) {
            return XC_LCC003_NewAccount_U.createWrapperError('Error in Controller', '', null);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '>>>>>>>>>>> START createRecord Account.... ');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '>>>>>>>>>>> START mapAccountString.... ' + mapAccountString);
        return createAccountRecord(mapAccountString);
    }

    //JJP 22/12/2021 - Start
    @AuraEnabled
    public static boolean isSpain() {
        boolean respuesta;
        String country = XC_UTIL_User.getCountryFromUser(UserInfo.getUserId()).toLowerCase();
        if(country == 'spain'){
            respuesta = true;
        }else{
            respuesta = false;
        }
        return respuesta;
    }
    //JJP 22/12/2021 - End
    /** 
     * @description Gets the skip check duplicates
     * @param mapAccountString - String to deserialize to get fields
     * @return XC_LCC003_NewAccount_W.InsertResultWrapper
     */
    private static XC_LCC003_NewAccount_W.InsertResultWrapper createAccountRecord(String mapAccountString) {
        Map<String, Object> mapAddress = (Map<String, Object>) JSON.deserializeUntyped(mapAccountString);
        Account newAccount = new Account();
        String fieldMapStringAccount = (String) mapAddress.get('fieldMapStringAccount');
        Boolean assignRecord = Boolean.valueOf(mapAddress.get('assignRecord'));
        String recordTypeId = (String) mapAddress.get('recordTypeId');
        String contactFields = (String) mapAddress.get('contactFields');
        String addressFields = String.valueOf(mapAddress.get('addressFields'));
        Boolean addressNoValidate;
        if (mapAddress.get('withoutValidate') != null) {
            addressNoValidate = Boolean.valueOf(mapAddress.get('withoutValidate'));
        } //tbd else*
        Boolean isCommunity = Boolean.valueOf(mapAddress.get('isCommunity'));
        //Boolean thirdPartiesCheck = Boolean.valueOf(mapAddress.get('thirdPartiesCheck'));
        //Boolean robinsonCustomer = (Boolean) mapAddress.get('robinsonCustomer'); dpalamides
        String thirdPartiesCheck = String.valueOf(mapAddress.get('thirdPartiesCheck'));
        String thirdPartiesVersion = String.valueOf(mapAddress.get('thirdPartiesVersion'));
        String consentsLE = (String) mapAddress.get('consentsLE');
        String release = (String) mapAddress.get('releaseDate');
        String brand = (String) mapAddress.get('brandString');
        Boolean confirmationByTheCustomer = (Boolean) mapAddress.get('confirmationByTheCustomer');
        if(confirmationByTheCustomer!=null){
            newAccount.XC_ConfirmationByCustomer__c = confirmationByTheCustomer;
        }
        if (brand != NULL && !String.isBlank(brand) && brand != '--None--') {
            newAccount.XC_Brand__c = brand;
        }
        System.debug('RELEASE = ' + release);
        if (release != null) {
            newAccount.XC_NIE_expedition_date__c = Date.valueOf(release);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'fieldMapStringAccount->' + fieldMapStringAccount);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'addressFields->' + addressFields);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'contactFields->' + contactFields);
        XC_UTIL_Debug.debug(DEBUGACTIVE, ' recordTypeId=' + recordTypeId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ thirdPartiesCheck -> ' + thirdPartiesCheck + ' - version ' + thirdPartiesVersion);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsLE -> ' + consentsLE);
        /*if(isCommunity){
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();                                               
        }*/
        if(String.isBlank(fieldMapStringAccount)) {
            return XC_LCC003_NewAccount_U.createWrapperError('Unknown Error', '', null);
        }
        Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(fieldMapStringAccount);


        populateName(newAccount, fieldMap, recordTypeId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'newAccountName->' + newAccount.Name);


        XC_UTIL_Debug.debug(DEBUGACTIVE, 'newAccount->' + newAccount);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordTypeId->' + recordTypeId);
        if (!String.isBlank(recordTypeId)) {
            newAccount.RecordTypeId = recordTypeId;
        }
        XC_LCC003_NewAccount_U.populateFields(newAccount, fieldMap);
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();
        inputData.contactFields = contactFields;
        inputData.addressFields = addressFields;
        inputData.addressNoValidate = addressNoValidate;
        //inputData.robinsonCustomer = robinsonCustomer; dpalamides
        inputData.thirdPartiesCheckNew = thirdPartiesCheck;
        inputData.thirdPartiesVersion = thirdPartiesVersion;
        inputData.consentsLE = consentsLE;
        inputData.consentsWrapper = (String) mapAddress.get('consentsWrapper');
        return checkDuplicatesAndInsertRecord(newAccount, inputData);
    }

    private static void populateName(Account newAccount, Map<String, Object> fieldMap, String recordTypeId) {
        /*if(fullName== null || String.isBlank(fullName)){
            newAccount.XC_FirstName__c = (String) fieldMap.get('XC_FirstName__c');
            newAccount.XC_LastName__c = (String) fieldMap.get('XC_LastName__c');
            newAccount.Name = newAccount.XC_FirstName__c + ' ' + newAccount.XC_LastName__c;
        }*/
        if (XC_UTIL_Account.isSoho(recordTypeId) || XC_UTIL_Account.isGlobalB2B(recordTypeId)|| XC_UTIL_Account.isGlobalB2G(recordTypeId) || XC_UTIL_Account.isSFMAccount(recordTypeId)) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordTypeId-->' + recordTypeId);
            newAccount.Name = (String) fieldMap.get('Company__c');
            newAccount.XC_LastName__c = (String) fieldMap.get('Company__c');
        } else if (XC_UTIL_Account.isCondominium(recordTypeId)) {
            newAccount.Name = (String) fieldMap.get('XC_CondominiumName__c');
            newAccount.XC_LastName__c = (String) fieldMap.get('XC_CondominiumName__c');
        } else if (XC_UTIL_Account.isPartner(recordTypeId)) {
            newAccount.Name = (String) fieldMap.get('XC_PartnerName__c');
            newAccount.XC_LastName__c = (String) fieldMap.get('XC_PartnerName__c');
        } else {
            //newAccount.Name = fullName;
            newAccount.XC_FirstName__c = (String) fieldMap.get('XC_FirstName__c');
            newAccount.XC_LastName__c = (String) fieldMap.get('XC_LastName__c');
            newAccount.XC_Salutation__c = (String) fieldMap.get('XC_Salutation__c');
            newAccount.Name = newAccount.XC_Salutation__c + ' ' + newAccount.XC_FirstName__c + ' ' + newAccount.XC_LastName__c;
            System.debug('SALUTATION ACCOUNT ' + newAccount.XC_Salutation__c);
        }
    }

    private static Map<String,String> getLegalEntityGroupAssociations(List<String> leList){
        Map<String,String> ret = new Map<String,String>();
        List<XC_CM_CountryLegalEntityAssociation__mdt> allMetadata = new List<XC_CM_CountryLegalEntityAssociation__mdt>();
        if (Schema.sObjectType.XC_CM_CountryLegalEntityAssociation__mdt.isAccessible()) {
            allMetadata = [
                    select Id,XC_LegalEntity__c, XC_Country__c, XC_LegalEntityGroup__c,DeveloperName
                    from XC_CM_CountryLegalEntityAssociation__mdt
                    Where XC_LegalEntity__c in :leList
            ];
        }
        for(XC_CM_CountryLegalEntityAssociation__mdt le : allMetadata){
            ret.put(le.XC_LegalEntity__c,le.XC_LegalEntityGroup__c);
        }
        return ret;
    }

    private static Map<String,XC_CM_CountryLegalEntityAssociation__mdt> getLegalEntityInfo(String legalEntity) {
        Map<String,XC_CM_CountryLegalEntityAssociation__mdt> ret = new Map<String,XC_CM_CountryLegalEntityAssociation__mdt>();
        List<XC_CM_CountryLegalEntityAssociation__mdt> allMetadata = new List<XC_CM_CountryLegalEntityAssociation__mdt>();
        if (Schema.sObjectType.XC_CM_CountryLegalEntityAssociation__mdt.isAccessible()) {
            allMetadata = [
                    select Id,XC_LegalEntity__c, XC_Country__c, XC_LegalEntityGroup__c,DeveloperName,XC_PhonePrefix__c,XC_Nationality__c,XC_Preferredlanguageofcontact__c
                    from XC_CM_CountryLegalEntityAssociation__mdt
                    Where XC_LegalEntity__c =:legalEntity
            ];
        }
        for(XC_CM_CountryLegalEntityAssociation__mdt le : allMetadata){
            ret.put(le.XC_LegalEntity__c,le);
        }
        return ret;
    }

    private static void setLEFields(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData){
        System.debug('inputData: '+inputData+', newAccount: '+newAccount);
        if(newAccount.XC_ConfirmationByCustomer__c) {
            List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> lcc163Wrapper = (List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>) JSON.deserialize(inputData.consentsWrapper, List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>.class);
            List<String> leList = new List<String>();
            for (XC_LCC163_CreateConsents.GetLegalEntitiesResponse currWrapper : lcc163Wrapper) {
                XC_LCC163_CreateConsents.GetLegalEntitiesResponse createConsentsWrapper = (currWrapper != null) ? currWrapper : new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
                leList.add(createConsentsWrapper.legalEntity);
                newAccount.put('XC_GiveDataTo_' + createConsentsWrapper.legalEntity + '__c', true);
            }
            Map<String, String> groupMap = getLegalEntityGroupAssociations(leList);
            for (String currGroup : groupMap.values()) {
                newAccount.put('XC_GiveDataTo_' + currGroup + '__c', true);
            }
        }
        //return newAccount;
    }

    /**
     * @description Check duplicates and insert record
     * @param newAccount the new account
     * @param inputData map with object used on insert
     * @return the insert result wrapper
     */
    private static XC_LCC003_NewAccount_W.InsertResultWrapper checkDuplicatesAndInsertRecord(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData) {
        accountContactWrapper = inputData;

        ////List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> lcc163Wrapper = (List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>) JSON.deserialize(inputData.consentsWrapper,List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>.class);
        ////XC_LCC163_CreateConsents.GetLegalEntitiesResponse createConsentsWrapper = (lcc163Wrapper[0]!=null) ? lcc163Wrapper[0] : new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();

        setLEFields(newAccount,inputData);
        //XC_LCC002_NewLead_U.populateListOfLegalEntities(newLead, inputData.consentsLE);  dpalamides

        //dpalamides List<XC_LegalEntityConsent__c> consents = XC_LCC003_NewAccount_Related.populateLEWrapper(inputData.consentsLE);
        ////List<XC_LegalEntityConsent__c> consents = new List<XC_LegalEntityConsent__c>();
        ////newAccount.put('XC_GiveDataTo_' + createConsentsWrapper.legalEntity + '__c', true);

        ////for (XC_LegalEntityConsent__c legalEnt : consents) {
        ////    newAccount.put('XC_GiveDataTo_' + legalEnt.XC_LegalEntity__c + '__c', true);
        ////}
        System.Savepoint beforeInsertSavepoint = Database.setSavepoint();
        List<XC_TR_Account_U_CheckDuplicates.ResultWrapper> rwList =
                XC_TR_Account_U_CheckDuplicates.duplicationCheck(new List<Account>{
                        newAccount
                });

        /*  for (XC_LegalEntityConsent__c legalEnt : consents){
              newAccount.put('XC_GiveDataTo_' + legalEnt.XC_LegalEntity__c + '__c', false);
          }*/

        if (!rwList.isEmpty()) {
            XC_TR_Account_U_CheckDuplicates.ResultWrapper result = rwList[0];
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'INSERT result->' + result);
            Boolean b = result.success && result.isInsert;
            if (b) {
                inputData.accountCheckDuplicateRes = rwList[0];
                //modifica new Duplication
                XC_LCC003_NewAccount_W.InsertResultWrapper toReturn = result.isDuplicate ? insertRecord(result.ac, inputData) : insertRecord(newAccount, inputData);
                return toReturn;
            } else if (!result.success) {
                String accountId = (result.ac != null) && String.isNotBlank(result.ac.Id) ? result.ac.Id : result.existingContact.AccountId;
                Database.rollback(beforeInsertSavepoint);
                createConsensForExistingAccount(result, inputData);
                return XC_LCC003_NewAccount_U.createWrapperError(result.errorMessage, '', accountId);
            } else {
                if(!result.isForB2B) {
                    String accountId = (result.ac != null) ? result.ac.Id : null;
                    XC_LCC003_NewAccount_W.InsertResultWrapper res = new XC_LCC003_NewAccount_W.InsertResultWrapper(accountId);
                    res.errorMessage = result.errorMessage;
                    res.existingAccId = accountId;
                    return res;
                } else {
                    return XC_LCC003_NewAccount_Related.saveRelatedObjects(result.accountForB2B, inputData, beforeInsertSavepoint, true);
                }
            }
        } else {
            return insertRecord(newAccount, inputData);
        }
        // return XC_LCC003_NewAccount_U.createWrapperError('Unknown Error','', null);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Method for new consens for existing account/contact
     * @param inputWrapper - XC_TR_Account_U_CheckDuplicates.ResultWrapper result    
     * @param inputData - XC_LCC003_NewAccount_W.AccountInputDataWrapper      
     * @return Boolean
    */
    public static Boolean createConsensForExistingAccount(XC_TR_Account_U_CheckDuplicates.ResultWrapper inputWrapper, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData) {
        if(String.isNotBlank(inputWrapper.existingContact.AccountId)) {
            List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> lcc163Wrapper = (List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>) JSON.deserialize(inputData.consentsWrapper, List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>.class);
            if(!lcc163Wrapper.isEmpty() && String.isNotBlank(lcc163Wrapper[0].legalEntity)) {
                String newLegalEntity = lcc163Wrapper[0].legalEntity;
                List<XC_LegalEntityConsent__c> listlegalEntityConsentForExistingContacts = inputWrapper.listlegalEntityConsentForExistingContacts;
                Boolean found = false;
                for(XC_LegalEntityConsent__c lec : listlegalEntityConsentForExistingContacts) {
                    if(newLegalEntity == lec.XC_LegalEntity__c) {
                        found = true;
                        break;
                    }
                }
                if(!found) {
                    try {
                        Account accToUpdate = new Account(Id = inputWrapper.existingContact.AccountId);
                        accToUpdate.put('XC_GiveDataTo_' + newLegalEntity + '__c', true);
                        XC_UTIL_Sobject.updateRecord(accToUpdate);
                        String individualId = inputWrapper.existingContact.IndividualId;
                        XC_LegalEntityConsent__c legalEntity = new XC_LegalEntityConsent__c();
                        legalEntity.XC_Individual__c = individualId;
                        legalEntity.XC_GiveDataToNew__c = 'Yes';
                        legalEntity.XC_LegalEntity__c = newLegalEntity;
                        legalEntity.XC_LeCountry__c = lcc163Wrapper[0].consentsData.personalInfo.countryLE;
                        legalEntity.XC_CompanyConsentVersion__c = lcc163Wrapper[0].consentsData.thirdPartiesConsent.consentVersion;
                        legalEntity.XC_MarketingConsent__c = lcc163Wrapper[0].consentsData.marketingConsent.consentValue;
                        legalEntity.XC_LECollectedMarketingConsents__c = lcc163Wrapper[0].consentsData.personalInfo.currentLE;
                        legalEntity.XC_CollectionDateMarketing__c = lcc163Wrapper[0].consentsData.marketingConsent.collectionDate;
                        legalEntity.XC_CollectionChannelMarketing__c = lcc163Wrapper[0].consentsData.marketingConsent.collectionChannel;
                        legalEntity.XC_CollectionUserMarketing__c = lcc163Wrapper[0].consentsData.marketingConsent.collectionUser;
                        legalEntity.XC_MarketingConsentVersion__c = lcc163Wrapper[0].consentsData.marketingConsent.consentVersion;
                        legalEntity.XC_ConsentDescription__c = lcc163Wrapper[0].consentsData.marketingConsent.consentDescriptionLookup;
                        legalEntity.XC_ProfilingConsent__c = lcc163Wrapper[0].consentsData.profilingConsent.consentValue;
                        legalEntity.XC_LECollectedProfilingConsents__c = lcc163Wrapper[0].consentsData.personalInfo.currentLE;
                        legalEntity.XC_CollectionDateProfiling__c = lcc163Wrapper[0].consentsData.profilingConsent.collectionDate;
                        legalEntity.XC_CollectionChannelProfiling__c = lcc163Wrapper[0].consentsData.profilingConsent.collectionChannel;
                        legalEntity.XC_CollectionUserProfiling__c = lcc163Wrapper[0].consentsData.profilingConsent.collectionUser;
                        legalEntity.XC_ProfilingConsentVersion__c = lcc163Wrapper[0].consentsData.profilingConsent.consentVersion;
                        legalEntity.XC_ConsentDescription__c = lcc163Wrapper[0].consentsData.marketingConsent.consentDescriptionLookup;
                        if(String.isNotBlank(lcc163Wrapper[0].consentsData.notCustomerConsent.consentDescriptionLookup)) {
                            legalEntity.XC_NotCustomerConsent__c = lcc163Wrapper[0].consentsData.notCustomerConsent.consentValue;
                            legalEntity.XC_LECollectedNotCustomerConsents__c = lcc163Wrapper[0].consentsData.personalInfo.currentLE;
                            legalEntity.XC_CollectionDateNotCustomer__c = lcc163Wrapper[0].consentsData.notCustomerConsent.collectionDate;
                            legalEntity.XC_CollectionChannelNotCustomer__c = lcc163Wrapper[0].consentsData.notCustomerConsent.collectionChannel;
                            legalEntity.XC_CollectionUserNotCustomer__c = lcc163Wrapper[0].consentsData.notCustomerConsent.collectionUser;
                            legalEntity.XC_NotCustomerConsentVersion__c = lcc163Wrapper[0].consentsData.notCustomerConsent.consentVersion;
                            legalEntity.XC_ConsentDescription__c = lcc163Wrapper[0].consentsData.marketingConsent.consentDescriptionLookup;
                        }

                        if(String.isNotBlank(lcc163Wrapper[0].consentsData.thPartiesMarketingConsent.consentDescriptionLookup)) {
                            legalEntity.XC_ThirdProductsMarketingConsent__c = lcc163Wrapper[0].consentsData.thPartiesMarketingConsent.consentValue;
                            legalEntity.XC_LECollectedThirdProductsMarketingCons__c = lcc163Wrapper[0].consentsData.personalInfo.currentLE;
                            legalEntity.XC_CollectionDateThirdProductsMarketing__c = lcc163Wrapper[0].consentsData.thPartiesMarketingConsent.collectionDate;
                            legalEntity.XC_CollectionChannelThirdProdMarketing__c = lcc163Wrapper[0].consentsData.thPartiesMarketingConsent.collectionChannel;
                            legalEntity.XC_CollectionUserThirdProductsMarketing__c = lcc163Wrapper[0].consentsData.thPartiesMarketingConsent.collectionUser;
                            legalEntity.XC_ThirdProductsMarketingConsentVersion__c = lcc163Wrapper[0].consentsData.thPartiesMarketingConsent.consentVersion;
                            legalEntity.XC_ConsentDescription__c = lcc163Wrapper[0].consentsData.marketingConsent.consentDescriptionLookup;
                        }
                        XC_UTIL_Sobject.insertRecord(legalEntity);
                    } catch(Exception e) {
                        return false;
                    }
                }
            }
        }
        return true;
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to removeDocumentType
     * @param newAccount        
    */
    private static void removeDocumentType(Account newAccount) {
        if (newAccount.IdentityNumber__c == null || newAccount.IdentityNumber__c == '') {
            System.debug('@@@@@ IN removeDocumentType ');
            newAccount.IdentityNumber__c = null;
            newAccount.IdentityType__c = null;
            newAccount.XC_DocumentCountry__c = null;
        }
    }

    /**
     * @description Insert record
     * @param newAccount the new account
     * @param inputData map with object used on insert
     * @return the insert result wrapper
     */
    private static XC_LCC003_NewAccount_W.InsertResultWrapper insertRecord(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData) {
        if (XC_UTIL_Account.isResidential(newAccount.RecordTypeId)) {
            removeDocumentType(newAccount);
        }
        System.Savepoint beforeInsertSavepoint = Database.setSavepoint();
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# insertRecord ---> ' + inputData.accountCheckDuplicateRes.isDuplicate );
        //se non ho account duplicato lo inserisco
        if (XC_LCC003_NewAccount_Related.checkAccountDuplication(inputData)) {
            XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.insertRecord(newAccount);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# newAccount ---> ' + newAccount + ' @#@#@@#@# WR INSERT ---> ' + wr);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# Id ---> ' + newAccount.Id);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# recordTypeId ---> ' + newAccount.recordTypeId);
            if (!wr.success || String.isBlank(newAccount.recordTypeId)) {
                return XC_LCC003_NewAccount_U.doRollback(wr, beforeInsertSavepoint);
            }
        }

        Boolean isAccountToUpd = false;
        if (XC_UTIL_Account.isPartner(newAccount.recordTypeId)) {
            newAccount.isPartner = true;
            isAccountToUpd = true;
            /*XC_UTIL_Sobject.WrapperResult rootTerritoryResult = XC_LCC003_NewAccount_U.insertRootTerritory(newAccount);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# rootTerritoryResult ---> ' + rootTerritoryResult);
            if (!rootTerritoryResult.success){
                return XC_LCC003_NewAccount_U.doRollback(rootTerritoryResult, beforeInsertSavepoint); 
            }*/
        }

        /*if(inputData.thirdPartiesCheck!=null){
        	newAccount.XC_GDPRThirdPartiesRelated__c = Boolean.valueOf(inputData.thirdPartiesCheck);
            isAccountToUpd = true;
        }*/

        if (isAccountToUpd) {
            XC_UTIL_Sobject.WrapperResult updWr = XC_LCC003_NewAccount_U.updateAccount(newAccount);
            if (!updWr.success) {
                return XC_LCC003_NewAccount_U.doRollback(updWr, beforeInsertSavepoint);
            }
        }


        return XC_LCC003_NewAccount_Related.saveRelatedObjects(newAccount, inputData, beforeInsertSavepoint);
    }

    /**
     * @description Insert the Social Persona association and record. 
     * @param newAccount the new account
     * @param inputData map with data to save
     * @param beforeInsertSavepoint point to rollback if needs
     * @return the insert result wrapper
     */
    /*private static XC_LCC003_NewAccount_W.InsertResultWrapper saveRelatedObjects(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData, System.Savepoint beforeInsertSavepoint){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# NewAccount - saveConsents ---> newAccount = ' + newAccount);

        if(XC_UTIL_Account.isResidential(newAccount.recordTypeId)){ 
            XC_UTIL_Sobject.WrapperResult docResult = XC_LCC003_NewAccount_U.insertDocuments(newAccount);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# docResult ---> ' + docResult);
            if (!docResult.success){
                return XC_LCC003_NewAccount_U.doRollback(docResult, beforeInsertSavepoint); 
            }
        }

        XC_UTIL_Sobject.WrapperResult addressResult = XC_LCC003_NewAccount_U.insertAddress(newAccount, inputData.addressFields, newAccount.recordTypeId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# addressResult ---> ' + addressResult);
        if (!addressResult.success){
            return XC_LCC003_NewAccount_U.doRollback(addressResult, beforeInsertSavepoint); 
        }

        XC_TR_Contact_U_CheckDuplicates.ResultWrapper resultFromIndividual; 
        resultFromIndividual= XC_TR_Contact_U_CheckDuplicates.checkduplicationContactAndInsertIndividual(newAccount, inputData.contactFields);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@# resultFromIndividual ---> ' + resultFromIndividual);
        if(!resultFromIndividual.success){
            //return XC_LCC003_NewAccount_U.createWrapperError(resultFromIndividual.errorMessage, '', null);
            return XC_LCC003_NewAccount_U.doRollback(resultFromIndividual.errorMessage, beforeInsertSavepoint); 
        }
        
        //List<Account> newAccountAllFields = XC_UTIL_Sobject.selectAllFields(newAccount.Id);
        
        return new XC_LCC003_NewAccount_W.InsertResultWrapper(newAccount.Id);
    }*/

    /** ---------------------------------         ONE ORG CONFIGURATION - START      ---------------------------------*. */
    public static List<String> fieldSetList = new List<String>{
            'XC_ESP_Account_New_PersonalData',
            //'XC_ESP_Account_New_Direction',
            'XC_ESP_Account_New_Opportunity',
            'XC_ESP_Account_New_Consents'
    };

    /** The field set list partner. */
    public static List<String> fieldSetListPartner = new List<String>{
            'XC_ESP_AccountPartner_New_PersonalData',
            //'XC_ESP_AccountPartner_New_Direction',
            'XC_ESP_AccountPartner_New_Consents'
    };

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Retrieve data
     * @param recordId the record id
     * @param recordTypeId the record type id
     * @return the string
     */
    @AuraEnabled
    public static String retrieveData(Id recordId, String recordTypeId) {
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Schema.RecordTypeInfo defaultRecordType;
        for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            if(rti.isDefaultRecordTypeMapping()) {
                defaultRecordType = rti;
            }
        }
        if(recordTypeId == null){
            recordTypeId=defaultRecordType.recordTypeId;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordId->' + recordId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordTypeId->' + recordTypeId);
        FieldSetWrapper wrapper = new FieldSetWrapper();
        /* String country = 'ESP';*/
        /*if(mapCountryDocumentType.containsKey(country)){
            wrapper.documentTypes = mapCountryDocumentType.get(country);
        }*/

        populateBrands(wrapper);
        if (!String.isBlank(recordTypeId)) {
            String recordTypeName = XC_UTIL_Sobject.retrieveRecordTypNameFromId(recordTypeId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ recordTypeName : ' + recordTypeName);
            wrapper.recordTypeName = recordTypeName;
        }

        String legalEntity = XC_UTIL_User.getLegalEntityFromUser();
        XC_CM_CountryLegalEntityAssociation__mdt cmLegalEntityConfig=getLegalEntityInfo(legalEntity).get(legalEntity);
        String country = XC_UTIL_User.getCountryFromUser(UserInfo.getUserId());
        XC_CM_CountryLegalEntityAssociation__mdt userLE = XC_UTIL_User.getLegalEntityMetadataFromUserByRT(XC_UTIL_Sobject.retrieveRecordTypNameFromId(recordTypeId));
        if (XC_UTIL_Account.isPartner(recordTypeId)) {
            wrapper = populateWrapperPartner(wrapper,userLE);
        }
        else if (XC_UTIL_Account.isCondominium(recordTypeId)) {
            wrapper = populateWrapperCondominium(wrapper,userLE);
        }
        else if (XC_UTIL_Account.isResidential(recordTypeId)) {
            wrapper = populateWrapperResidential(wrapper,userLE);
        }
        else if (XC_UTIL_Account.isSoho(recordTypeId)) {
            wrapper = populateWrapperSoho(wrapper,userLE);
        }
        else if (XC_UTIL_Account.isSupplier(recordTypeId)) {
            wrapper = populateWrapperSupplier(wrapper,userLE);
        }else if(XC_UTIL_Account.isGlobalB2B(recordTypeId)){
            wrapper = populateWrapperGlobalB2B(wrapper,userLE);
        }else if(XC_UTIL_Account.isGlobalB2G(recordTypeId)){
            wrapper = populateWrapperGlobalB2G(wrapper,userLE);
        }  
        else if(XC_UTIL_Account.isSFMAccount(recordTypeId)){
            wrapper = populateWrapperSFM(wrapper, XC_UTIL_Sobject.retrieveRecordTypNameFromId(recordTypeId));
            String userId = UserInfo.getUserId();
            List<User> userList = [SELECT id, Country__c FROM User WHERE Id=:userId];
            if(userList[0].Country__c == null){
                return JSON.serialize(wrapper);
            }
            XC_CM_CountryLegalEntityAssociation__mdt userInformation =  [select  XC_PhonePrefix__c,XC_Nationality__c,XC_Preferredlanguageofcontact__c from XC_CM_CountryLegalEntityAssociation__mdt where XC_Country__c = :userList[0].Country__c AND XC_Stream__c = 'B2B' limit 1];
            wrapper.defaultPhonePrefix= (userInformation!=null && String.isNotBlank(userInformation.XC_PhonePrefix__c)) ? userInformation.XC_PhonePrefix__c : '';
            wrapper.defaultNationality = (userInformation!=null && String.isNotBlank(userInformation.XC_Nationality__c)) ? userInformation.XC_Nationality__c : '';
            wrapper.defaultPrefLanguage= (userInformation!=null && String.isNotBlank(userInformation.XC_Preferredlanguageofcontact__c)) ? userInformation.XC_Preferredlanguageofcontact__c : '';
            wrapper.userCountry = userList[0].Country__c;
            return JSON.serialize(wrapper);
        }

        if (!String.isBlank(recordId)) {
            wrapper.existingRecord = (Account) XC_UTIL_Sobject.selectAllFields(recordId)[0]; //retrieveAccountEdit(recordId);
        }

        //String countryFinal = country.toLowerCase();
        wrapper.userCountry = /*country;//countryFinal.capitalize();*/  (userLE!=null && String.isNotBlank(userLE.XC_Country__c)) ? userLE.XC_Country__c : '';
        wrapper.defaultPhonePrefix= (userLE!=null && String.isNotBlank(userLE.XC_PhonePrefix__c)) ? userLE.XC_PhonePrefix__c : '';
        wrapper.defaultNationality = (userLE!=null && String.isNotBlank(userLE.XC_Nationality__c)) ? userLE.XC_Nationality__c : '';
        Schema.DescribeFieldResult describeContactLang = Contact.XC_Preferredlanguageofcontact__c.getDescribe();
        List<Schema.PicklistEntry> pickValsLangContact = describeContactLang.getPicklistValues();
        for(Schema.PicklistEntry pv: pickValsLangContact) {
            if(pv.isDefaultValue()) {
                wrapper.defaultPrefLanguage = pv.getValue();
                break;
            }
        }
        wrapper.defaultPrefLanguage = (userLE!=null && String.isNotBlank(userLE.XC_Preferredlanguageofcontact__c)) ? userLE.XC_Preferredlanguageofcontact__c : wrapper.defaultPrefLanguage;
        return JSON.serialize(wrapper);
    }

    private static void populateBrands(FieldSetWrapper wrapper) {
        List<AggregateResult> results = new List<AggregateResult>([SELECT XC_Brand__c from NE__Catalog_Item__c group by XC_Brand__c]);
        wrapper.brands.add('--None--');
        for (AggregateResult ar : results) {
            String brand = (String) ar.get('XC_Brand__c');
            if (!String.isBlank(brand)) {
                wrapper.brands.add(brand);
            }

        }
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Populate wrapper partner
     * @param wrapper the wrapper
     * @return the field set wrapper
     */
    @testVisible
    private static FieldSetWrapper populateWrapperPartner(FieldSetWrapper wrapper,XC_CM_CountryLegalEntityAssociation__mdt userLE) {
        String countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
        String userLEString = userLE.XC_Category__c;
        if (countryIsoListemobility.contains(countryIso)) {
            wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_AccountPartner_New_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_AccountPartner_New_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_AccountPartner_New_Direction').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_AccountPartner_New_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_ESP_AccountPartner_New_Mandatory'));
        }
        else{
            wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewPartner_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewPartner_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_AccountPartner_New_Direction').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewPartner_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_'+countryIso+'_'+userLEString+'_NewPartner_Required'));

        }
        return wrapper;
    }
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Populate wrapper soho
     * @param wrapper the wrapper
     * @return the field set wrapper
     */
    @testVisible
    private static FieldSetWrapper populateWrapperGlobalB2B(FieldSetWrapper wrapper,XC_CM_CountryLegalEntityAssociation__mdt userLE) {
        String countryIso = '';
        String userLEString = '';
        if(Test.isRunningTest()) {
            userLEString = 'B2C';
            countryIso = 'ESP';
        } else {
            countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
            userLEString = userLE.XC_Category__c;
        }
        
        if (countryIsoListemobility.contains(countryIso)) {
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_B2B_NewSoho_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Direction').getFields();
            //wrapper.fsOpportunity = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Opportunity').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_B2B_NewSoho_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_ESP_B2B_NewSoho_Required'));
        }
        else{
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_AccountPartner_New_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewSoho_PersonalData').getFields();
            System.debug('countryIso is:'+countryIso);
            System.debug('userLEString is:'+userLEString);
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_AccountPartner_New_Direction').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewSoho_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_'+countryIso+'_'+userLEString+'_NewSoho_Required'));
        }
        return wrapper;
    }

        /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Populate wrapper soho
     * @param wrapper the wrapper
     * @return the field set wrapper
     */
    @testVisible
    private static FieldSetWrapper populateWrapperGlobalB2G(FieldSetWrapper wrapper,XC_CM_CountryLegalEntityAssociation__mdt userLE) {
        String countryIso = '';
        String userLEString = '';
        if(Test.isRunningTest()) {
            userLEString = 'B2C';
            countryIso = 'ESP';
        } else {
            countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
            userLEString = userLE.XC_Category__c;
        }
        
        if (countryIsoListemobility.contains(countryIso)) {
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Type').getFields();
            //wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Soho_PersonalData').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_B2G_NewSoho_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Direction').getFields();
            //wrapper.fsOpportunity = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Opportunity').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_ESP_Account_New_Soho_Mandatory'));
        }
        else{
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_AccountPartner_New_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewSoho_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_AccountPartner_New_Direction').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewSoho_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_'+countryIso+'_'+userLEString+'_NewSoho_Required'));

        }
        return wrapper;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Populate wrapper soho
     * @param wrapper the wrapper
     * @return the field set wrapper
     */
    @testVisible
    private static FieldSetWrapper populateWrapperSoho(FieldSetWrapper wrapper,XC_CM_CountryLegalEntityAssociation__mdt userLE) {
        String countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
        String userLEString = userLE.XC_Category__c;
        if (countryIsoListemobility.contains(countryIso)) {
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Soho_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Direction').getFields();
            //wrapper.fsOpportunity = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Opportunity').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_ESP_Account_New_Soho_Mandatory'));
        }
        else{
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_AccountPartner_New_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewSoho_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_AccountPartner_New_Direction').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewSoho_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_'+countryIso+'_'+userLEString+'_NewSoho_Required'));

        }
        return wrapper;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Populate wrapper soho
     * @param wrapper the wrapper
     * @return the field set wrapper
     */
    @testVisible
    private static FieldSetWrapper populateWrapperSupplier(FieldSetWrapper wrapper,XC_CM_CountryLegalEntityAssociation__mdt userLE) {
        String countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
        String userLEString = userLE.XC_Category__c;
        if (countryIsoListemobility.contains(countryIso)) {
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Soho_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Direction').getFields();
            //wrapper.fsOpportunity = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Opportunity').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_ESP_Account_New_Soho_Mandatory'));
        }
        else {
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_AccountPartner_New_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewSoho_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_AccountPartner_New_Direction').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewSoho_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_'+countryIso+'_'+userLEString+'_NewSoho_Required'));

        }
        return wrapper;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Populate wrapper condominium
     * @param wrapper the wrapper
     * @return the field set wrapper
     */
    @testVisible
    private static FieldSetWrapper populateWrapperCondominium(FieldSetWrapper wrapper,XC_CM_CountryLegalEntityAssociation__mdt userLE) {
        String countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
        String userLEString = userLE.XC_Category__c;
        if (countryIsoListemobility.contains(countryIso)) {
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Condominium_Personal').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Direction').getFields();
            //wrapper.fsOpportunity = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Opportunity').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_ESP_Condominium_New_Mandatory'));
        }
        else{
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_AccountPartner_New_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewCondominium_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_AccountPartner_New_Direction').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewCondominium_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_'+countryIso+'_'+userLEString+'_NewCondominium_Required'));

        }
        return wrapper;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Populate wrapper residential
    * @param wrapper the wrapper
    * @return the field set wrapper
    */
    @testVisible
    private static FieldSetWrapper populateWrapperResidential(FieldSetWrapper wrapper,XC_CM_CountryLegalEntityAssociation__mdt userLE) {
        String countryIso = '';
        String userLEString = '';
        if(Test.isRunningTest()) {
            userLEString = 'B2C';
            countryIso = 'ESP';
        } else {
            countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
            userLEString = userLE.XC_Category__c;
        }
        
        if (countryIsoListemobility.contains(countryIso)) {
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Type').getFields();
            wrapper.fsDocumentData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_Residential_DocumentInfo').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Direction').getFields();
            // wrapper.fsOpportunity = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Opportunity').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_Account_New_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_ESP_Account_New_Mandatory'));
        }
        else{
            wrapper.fsDocumentData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewResidential_DocumentInfo').getFields();
            //wrapper.fsType = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_AccountPartner_New_Type').getFields();
            wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewResidential_PersonalData').getFields();
            //wrapper.fsDirection = Schema.SObjectType.Account.fieldSets.getMap().get('XC_ESP_AccountPartner_New_Direction').getFields();
            wrapper.fsConsents = Schema.SObjectType.Account.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_NewResidential_Consents').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_'+countryIso+'_'+userLEString+'_NewResidential_Required'));

        }
        return wrapper;
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description getListViews
     *@return ListView
    */
    @AuraEnabled
    public static ListView getListViews() {
        List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Account' AND Name = 'Recently Viewed Accounts' LIMIT 1];
        // Perform isAccessible() check here
        return listviews[0];
    }
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Populate wrapper residential
    * @param wrapper the wrapper
    * @return the field set wrapper
    */
    @testVisible
    private static FieldSetWrapper populateWrapperSFM(FieldSetWrapper wrapper, String recordTypeName) {
        String countryISOCode = 'ARG';
        if(recordTypeName.length()>6){
            countryISOCode = recordTypeName.substring(3,6);
        }
        wrapper.fsPersonalData = Schema.SObjectType.Account.fieldSets.getMap().get('XC_SFM_'+ countryISOCode +'_PersonalData').getFields();
        wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Account', 'XC_SFM_'+ countryISOCode +'_Required'));
        return wrapper;
    }
    /**
    * @description Call to address validation
    * @param leadId the lead id
    * @param inputFields the input fields
    * @return the x C RES T address validation. result wrapper
    * @author: Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description : Method for retrive the response of the XC_REST_AddressValidation class
    */
    /* @AuraEnabled
     public static XC_REST_AddressValidation.ResultWrapper callToAddressValidation(String leadId, string inputFields) {
         XC_UTIL_Debug.debug(DEBUGACTIVE, 'quaa'+inputFields);
         Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(inputFields);
         XC_UTIL_Address.AddressWrapper aw = new XC_UTIL_Address.AddressWrapper();
         XC_REST_AddressValidation.ResultWrapper result = new XC_REST_AddressValidation.ResultWrapper();*/
    /*
   if(fieldMap.get('Pod')!=null) aw.pod = (String) fieldMap.get('Pod');
   if(fieldMap.get('Address')!=null ) aw.address = (String) fieldMap.get('Address');
   if(fieldMap.get('StreetNumber')!=null) aw.streetNumber =  (String) fieldMap.get('StreetNumber');
   if(fieldMap.get('ZipCode')!=null) aw.zipCode = (String) fieldMap.get('ZipCode');
   if(fieldMap.get('Province')!=null) aw.province = (String) fieldMap.get('Province');
   if(fieldMap.get('City')!=null) aw.city = (String) fieldMap.get('City');
   if(fieldMap.get('StreetType')!=null) aw.streetType  = (String) fieldMap.get('StreetType');
  */
    /*   result = XC_REST_AddressValidation.callToAddressValidation(aw);
       return result;
   }*/

    /*public static Map<String, Map<String, List<String>>> mapCountryRecordTypeFieldSets = new Map<String, Map<String, List<String>>>{
         'ESP' => new Map<String, List<String>>{
             'XC_Account_Customer' => fieldSetList,
             'XC_Account_Partner' => fieldSetListPartner
         }
     };*/

    /* public static Map<String, List<String>> mapCountryDocumentType = new Map<String, List<String>>{
         'ESP' => new List<String>{
             'NIF'
         }
     };*/
    /**---------------------------------
      ONE ORG CONFIGURATION - END
  ---------------------------------**/
    /**
   * @description Checks if is mobile experience
   * @return true, if is mobile experience
   */
    /* @AuraEnabled
     public static boolean isMobileExperience() {
         boolean isMobileExperience = false;
         string info = UserInfo.getUiTheme();
         if(info=='Theme4t'){
             isMobileExperience=true;
         }
         return isMobileExperience;
     }*/

    /**
     * @description Populate soho
     * @param recordId the record id
     * @param recordTypeId the record type id
     * @return the string
     */
    /*   @AuraEnabled
       public static String populateSoho(Id recordId, String recordTypeId) {
           XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordId->' + recordId);
           XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordTypeId->' + recordTypeId);
           FieldSetWrapper wrapper = new FieldSetWrapper();
           /* String country = 'ESP';*/
    /*  if(mapCountryDocumentType.containsKey(country)){
        wrapper.documentTypes = mapCountryDocumentType.get(country);
    }*/
    /*if(!String.isBlank(recordTypeId)){
        String recordTypeName = XC_UTIL_Sobject.retrieveRecordTypNameFromId(recordTypeId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ recordTypeName : '+recordTypeName);
        wrapper.recordTypeName = recordTypeName;
    }

        wrapper = populateWrapperSoho(wrapper);

    if(!String.isBlank(recordId)){
        wrapper.existingRecord = (Account) XC_UTIL_Sobject.selectAllFields(recordId)[0]; //retrieveAccountEdit(recordId);
    }

    return JSON.serialize(wrapper);
}*/

}