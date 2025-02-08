/**
 * The Class XC_TR_Contact_U_CheckDuplicates.
 * @description  Class for XC_TR_Contact_U_CheckDuplicates
 */

public without sharing class XC_TR_Contact_U_CheckDuplicates {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Contact_U_CheckDuplicates');

    /**
     * @description The Class ResultWrapper.
     */
    /*public class ResultWrapper{ 
        public Contact ac = new Contact();
        public String contactID = '';
        public Boolean success = false;
        public Boolean isDuplicate = false;
        public String errorMessage = '';

        /**
        * @description Costructor
        */
     /*  public ResultWrapper(){
            XC_UTIL_Debug.debug(false, '');
        }

        /** 
        * @description Costructor
        * @param isSuccess value
        * @param message value
        */
      /*  public ResultWrapper(Boolean isSuccess, String message){
            success = isSuccess;
            errorMessage = message;
        }

        /** 
        * @description Costructor for success new Contact
        * @param contact the duplicated Contact
        */
     /*   public ResultWrapper(Contact contact){
            ac = contact;
            isDuplicate = true;
            contactID = String.valueOf(contact.Id);
            success = true;
            errorMessage = 'Update OK';
        }

        /** 
        * @description Costructor for success duplicated Contact
        * @param contactId the new Contact Id
        */
      /*  public ResultWrapper(String contactId){
            isDuplicate = false;
            contactID = contactId;
            success = true;
            errorMessage = 'Insert OK';
        }
    } */
    
    /**
     * @description Creates the wrapper.
     * @param ac the ac
     * @param contactID the contact ID
     * @param errorMessage the error message
     * @return the result wrapper
     */
    /*public static ResultWrapper createWrapperSuccess(Contact ac, String contactID, String errorMessage, Boolean isDuplicate){
        ResultWrapper rw = new ResultWrapper();
        rw.ac = ac;
        rw.isDuplicate = isDuplicate;
        rw.contactID = contactID;
        rw.success = true;
        rw.errorMessage = errorMessage;
        return rw;
    }*/

    /**
     * @description Creates the wrapper.
     * @param errorMessage the error message
     * @return the result wrapper
     */
   /* public static ResultWrapper createWrapperError(String errorMessage){
        System.debug('In createWrapperError con error = '+errorMessage);
        return new ResultWrapper(false,errorMessage);
        /*ResultWrapper rw = new ResultWrapper();
        rw.ac = null;
        rw.contactID = null;
        rw.success = false;
        rw.errorMessage = errorMessage;
        return rw;*/
    //}

    /**
     * @description Checkduplication contact and insert individual. 
     * @param newAccount the new account
     * @param inputData the data fields 
     * @return the result wrapper 
     */
    /*public static ResultWrapper checkduplicationContactAndInsertIndividual(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData) { //  String contactFields
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in checkduplicationContactAndInsertIndividual con contact: '+inputData.contactFields);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'E con account: '+newAccount);
        if(String.isBlank(newAccount.PrimaryEmail__c) && String.isBlank(newAccount.IdentityNumber__c)){
            return createWrapperError(Label.XC_CL_CPAB_ContErr1);
        }
        
        Contact frontEndcontactData = populateContactFieldsFromAccount(newAccount, inputData);
        //List<Contact> contactWithSameKey = XC_TR_Contact_U_CheckDuplicates_D.getAllContactByMailOrLastNameAndPhone(frontEndcontactData.Email, frontEndcontactData.FirstName,frontEndcontactData.LastName,frontEndcontactData.XC_ContactPhone__c);
        List<Contact> contactWithSameKey = XC_TR_Contact_U_CheckDuplicates_D.getAllContactByMailOrLastNameAndPhone(frontEndcontactData);
        System.debug('???COntact'+contactWithSameKey);
        if((inputData.accountCheckDuplicateRes == null || (inputData.accountCheckDuplicateRes != null && inputData.accountCheckDuplicateRes.existingContact != null)) || contactWithSameKey.isEmpty()){
            return manageNotExistingContact(newAccount, inputData);  //contactFields
        } else {
            return manageExistingContact(contactWithSameKey, newAccount, inputData);
        }  
    } */

    /**
     * @description manage new Contact to insert
     * @param newAccount the new account
     * @param inputData the data fields 
     * @param isPrimary indentify contact type
     * @return the result wrapper 
     */ 
    public static XC_UTIL_Sobject.WrapperResult manageNotExistingContact(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData, Boolean isPrimary){
        XC_UTIL_Sobject.WrapperResult resultWrapper = new XC_UTIL_Sobject.WrapperResult();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entro in manageNotExistingContact ');

        String recordTypeId = newAccount.RecordTypeId;
        newAccount.Id = !isPrimary && inputData.accountCheckDuplicateRes.existingContact != null ? inputData.accountCheckDuplicateRes.existingContact.AccountId : newAccount.Id;
        Contact c = populateContactFieldsFromAccount(newAccount, inputData); //contactFields
        Contact contact = removePrefixFromContact(c);
        contact.XC_PrimaryContact__c = isPrimary;
        //contact.XC_SkipInd__c = true;
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In manageNotExistingContact inserisco '+contact);
        XC_UTIL_Sobject.WrapperResult wrcontact = XC_UTIL_Sobject.insertRecord(contact);
        if(!wrcontact.success){
            System.debug('Error Message ---> '+ wrcontact.errorMessage);
            return wrcontact;
        }
        XC_UTIL_Sobject.WrapperResult wrapper = null;
        if(XC_UTIL_Account.isPartner(recordTypeId) && isPrimary) {
            newAccount.XC_ESP_Account_PrimaryContact__c = contact.Id;
            wrapper = XC_UTIL_Sobject.updateRecord(newAccount);
        }
       
        if(wrapper != null && !wrapper.success){
            return wrapper;
        } 
        
        XC_UTIL_Sobject.WrapperResult wrJO = null;
        List<AccountContactRelation> junctionObjList = XC_TR_Contact_U_CheckDuplicates_D.getAccountContactRelations(newAccount.Id, contact.Id);
        if(!junctionObjList.isEmpty()){
            AccountContactRelation acr = junctionObjList[0];
            acr.Roles = Label.XC_CL_AccountContactRel_Owner;
            wrJO = XC_UTIL_Sobject.updateRecord(acr);
        } 
        
        if(wrjo != null && !wrJO.success){
            return wrJO; 
        } 
        resultWrapper.success = true;
        return resultWrapper; //createWrapperSuccess(null,contact.Id,'Insert OK',false); 
    }

    /**
     * @description manage Existing Contact With Same Key 
     * @param contactWithSameKey 
     * @param newAccount 
     * @param inputData  
     * @return the result wrapper 
     */ 
 /*   private static ResultWrapper manageExistingContact(List<Contact> contactWithSameKey, Account newAccount,  XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entro in manageExistingContact con ACC ID = '+newAccount.Id);
    
        
        //////EXISTING CONTACT DUPLICATES//////
        Contact existingContact = contactWithSameKey[0];  //contactFields
        XC_UTIL_LegalEntityConsents.checkAvailableConsentForContact(newAccount,existingContact, inputData);
        ResultWrapper manageResult = new ResultWrapper();
        Boolean skipLegalConsent = false;
        
        // CONTROL FOR NEW SOHO WITHOUT PRIMARY CONTACT ASSOCIATED AN ANOTHER ACCOUNT
        if( XC_UTIL_Account.isSoho(newAccount.RecordTypeId) && (inputData.accountCheckDuplicateRes == null || !inputData.accountCheckDuplicateRes.isDuplicate)) {
            if(existingContact.XC_PrimaryContact__c){
                manageResult.success = false;
                manageResult.errorMessage = 'This contact already exist as primary of '+existingContact.Account.Name+'. You cannot create Soho without primary Contact!';
                return manageResult;
            }else{
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in aggancio contact not primary al Soho e vado avanti');
                existingContact.XC_PrimaryContact__c = true;
                existingContact.AccountId = newAccount.Id;
            }
        }
        //Account duplicato e Contact non primary legato ad altro Account
        else if (XC_UTIL_Account.isSoho(newAccount.RecordTypeId) && inputData.accountCheckDuplicateRes.isDuplicate && !existingContact.XC_PrimaryContact__c && existingContact.AccountId != newAccount.Id) {
            skipLegalConsent =true;
        }
        
        //CONTROL FOR ACCOUNT RESIDENTIAL E CONTACT LEGATO AD ALTRO tipo
        else if( XC_UTIL_Account.isResidential(newAccount.RecordTypeId) ) {
            if(XC_UTIL_Account.isSoho(existingContact.Account.RecordTypeId) || XC_UTIL_Account.isCondominium(existingContact.Account.RecordTypeId)){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in aggancio contact soho/condominium al residential e vado avanti');
            existingContact.XC_PrimaryContact__c = true;
            existingContact.AccountId = newAccount.Id;
            }else{
                manageResult.success = false;
                manageResult.errorMessage = 'Contact already exist!';
                return manageResult;

            }
        } 
        else if( (XC_UTIL_Account.isSoho(newAccount.RecordTypeId) &&  XC_UTIL_Account.isSoho(existingContact.Account.RecordTypeId) && existingContact.XC_PrimaryContact__c && newAccount.Id!=existingContact.AccountId) ||
        (XC_UTIL_Account.isSoho(newAccount.RecordTypeId) && !XC_UTIL_Account.isSoho(existingContact.Account.RecordTypeId))  ){
         
            skipLegalConsent =true;
        }
        // trovato Contact condominium legato a un altro account: impossibile
        else if(XC_UTIL_Account.isCondominium(newAccount.RecordTypeId) && XC_UTIL_Account.isCondominium(existingContact.Account.RecordTypeId)  && inputData.accountCheckDuplicateRes.isDuplicate ){
            if(newAccount.Id!=existingContact.AccountId){
             XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trovato condominium legato ad acc con != recordType');
             manageResult.errorMessage = 'Contact already exist!';
             manageResult.success = false;
             return manageResult;
            }
        }
          // trovato Contact condominium duplicato con account nuovo: impossibile
        else if(XC_UTIL_Account.isCondominium(newAccount.RecordTypeId) && XC_UTIL_Account.isCondominium(existingContact.Account.RecordTypeId) &&  !inputData.accountCheckDuplicateRes.isDuplicate ){
             XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trovato condominium legato ad acc con != recordType');
             manageResult.errorMessage = 'Contact already exist!';
             manageResult.success = false;
             return manageResult;
        }
        else if(XC_UTIL_Account.isPartner(newAccount.RecordTypeId) ){
             XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trovato partner legato ad acc con != recordType');
              manageResult.errorMessage = 'Contact already exist!';
              manageResult.success = false;
              return manageResult;
        }
        //Id individualContactId = existingContact.IndividualId; GS 21/02/18 
        
        existingContact.LastName = newAccount.XC_LastName__c;
        existingContact.FirstName = newAccount.XC_FirstName__c;
        existingContact.MobilePhone = newAccount.MainPhone__c;
        existingContact.Phone = newAccount.Phone;
        existingContact.Birthdate = newAccount.XC_BirthDate__c; 
        if(newAccount.XC_Salutation__c != null){
        	existingContact.Salutation = newAccount.XC_Salutation__c;
            System.debug('SALUTATION COMPILATO ' + newAccount.XC_Salutation__c);
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'newAccount.RecordTypeId='+newAccount.RecordTypeId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'existingContact.RecordTypeId='+existingContact.RecordTypeId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'existingContact.Account.RecordTypeId='+existingContact.Account.RecordTypeId);
        XC_UTIL_Sobject.WrapperResult wrcontact = XC_UTIL_Sobject.updateRecord(existingContact);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'UPDATE CONTACT RESULT'+wrcontact.errorMessage);
         XC_UTIL_Debug.debug(DEBUGACTIVE, 'UPDATE CONTACT RESULT'+wrcontact.success);
        if(!wrcontact.success){
            return createWrapperError(wrcontact.errorMessage); 
        }
        if(!skipLegalConsent){
            XC_UTIL_Sobject.WrapperResult leResult = XC_UTIL_LegalEntityConsents.updateLegalConsents(existingContact, newAccount, inputData);
            ResultWrapper legalResult = new ResultWrapper(leResult.success, leResult.errorMessage);
            legalResult.isDuplicate=true;
        }
       
        List<AccountContactRelation> junctionObjList = XC_TR_Contact_U_CheckDuplicates_D.getAccountContactRelations(newAccount.Id, existingContact.Id);
        if(junctionObjList.isEmpty()){
            AccountContactRelation acr = new AccountContactRelation();
            acr.AccountId = newAccount.Id;
            acr.ContactId = existingContact.Id;
            acr.Roles = Label.XC_CL_AccountContactRel_Owner;
            XC_UTIL_Sobject.WrapperResult wrJO = XC_UTIL_Sobject.insertRecord(acr);
            if(!wrJO.success){
                return createWrapperError(wrJO.errorMessage); 
            }
        } else {
            AccountContactRelation acr = junctionObjList[0];
            acr.Roles = Label.XC_CL_AccountContactRel_Owner;
            XC_UTIL_Sobject.WrapperResult wrJO = XC_UTIL_Sobject.updateRecord(acr);
            if(!wrJO.success){
                return createWrapperError(wrJO.errorMessage);  
            }
        } 
        return new ResultWrapper(existingContact); //createWrapperSuccess(existingContact,existingContact.Id,'Update OK', true);
    }*/

    /**
     * @description Populate contact fields from custom form on account. 
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @param contact the contact
     * @param fieldMap the contact fields map
     * @description method for populate contact fields from custom form on New Account component
     */

    private static void populateContactFieldsFromCustomFormOnAccount(Contact contact, Map<String,Object> fieldMap){ // String contactFields){
        //Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(contactFields);
        contact.FirstName = (String) fieldMap.get('FirstName');  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'contact LastName = '+(String) fieldMap.get('LastName'));
        contact.LastName = (String) fieldMap.get('LastName');
        contact.Email = (String) fieldMap.get('Email');
        //modify on 21/01/2019
        contact.XC_PhonePrefix__c = (String) fieldMap.get('PhonePrefix');
        contact.XC_ContactPhone__c = (String) fieldMap.get('ContactPhone');
        contact.XC_MobilePrefix__c =(String) fieldMap.get('MobilePrefix');
        contact.XC_ContactMobile__c = (String) fieldMap.get('ContactMobile');
        
        String releaseDate = (String) fieldMap.get('ReleaseDate');
        String expirationDate = (String) fieldMap.get('ExpirationDate');
        if(expirationDate!= null && expirationDate!= ''){
        contact.XC_ContactDocExpirationDate__c = Date.valueOf(expirationDate);
        }
        if(releaseDate!= null && releaseDate!= ''){
        contact.XC_ContactDocReleaseDate__c =  Date.valueOf(releaseDate);
        }
        contact.XC_ContactDocumentCountry__c = (String) fieldMap.get('DocumentCountry');
        contact.XC_ContactDocumentType__c = (String) fieldMap.get('DocumentType');
        contact.XC_ContactDocumentNumber__c =(String) fieldMap.get('DocumentID');
        contact.XC_Nationality__c = (String) fieldMap.get('Nationality');
        System.debug('@@@ Preferred Language -> ' + (String) fieldMap.get('PreferredLanguage'));
        contact.XC_Preferredlanguageofcontact__c = (String) fieldMap.get('PreferredLanguage');
    }

    /**
     * @description Populate contact fields from account. 
     * @param contact the contact
     * @param newAccount the new account
     */
    private static void populateContactFieldsFromAccountData(Contact contact, Account newAccount){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in populateContactFieldsFromAccountData');
        contact.FirstName = newAccount.XC_FirstName__c;
        contact.LastName= newAccount.XC_LastName__c;
        if(String.isNotBlank(String.valueOf(newAccount.XC_BirthDate__c))) {
            contact.Birthdate = newAccount.XC_BirthDate__c;
        }
        contact.Email = newAccount.PrimaryEmail__c;
        contact.XC_PhonePrefix__c = newAccount.XC_AccountPhonePrefix__c;
        contact.XC_ContactPhone__c = newAccount.XC_AccountPhone__c;
        if(contact.XC_MobilePrefix__c == null && contact.XC_ContactMobile__c==null){
            contact.XC_MobilePrefix__c = newAccount.XC_MainPhonePrefix__c;
            contact.XC_ContactMobile__c = newAccount.XC_AccountMainPhone__c;
        }
        contact.XC_ContactDocExpirationDate__c =  newAccount.XC_NIE_expiration_date__c;
        contact.XC_ContactDocReleaseDate__c    =  newAccount.XC_NIE_expedition_date__c;
        contact.XC_ContactDocumentCountry__c   =  newAccount.XC_DocumentCountry__c;
        contact.XC_ContactDocumentType__c      =  newAccount.IdentityType__c;
        contact.XC_ContactDocumentNumber__c    =  newAccount.IdentityNumber__c;
        contact.XC_Nationality__c = newAccount.XC_AccountNationality__c; 
        //contact.XC_Preferredlanguageofcontact__c = newAccount.XC_Preference_Language__c;
        if(newAccount.XC_Salutation__c != null){
            contact.Salutation = newAccount.XC_Salutation__c;
            System.debug('SALUTATION CONTATTO NUOVO');
        }
    }
    
    
     /**
* @description Remove Prefix
* @param fieldMap
*/
    private static void removePrefix(Map<String,Object> fieldMap) {
        if(fieldMap.get('XC_PhonePrefix__c')=='+34' && fieldMap.get('XC_ContactPhone__c')==null){ fieldMap.remove('XC_PhonePrefix__c'); }
        if(fieldMap.get('XC_MobilePrefix__c')=='+34' && fieldMap.get('XC_ContactMobile__c')==null){ fieldMap.remove('XC_MobilePrefix__c'); }
   }
    
    /**
    * @description Remove Prefix
    * @param c contact to modify
    * @return contact modified
    */
    public static Contact removePrefixFromContact(Contact c) {
        if((c.XC_PhonePrefix__c!=null||c.XC_PhonePrefix__c!='') && (c.XC_ContactPhone__c==null || c.XC_ContactPhone__c=='') ){ c.XC_PhonePrefix__c=null; }
        if((c.XC_MobilePrefix__c!=null||c.XC_MobilePrefix__c!='') && (c.XC_ContactMobile__c==null || c.XC_ContactMobile__c=='') ){ c.XC_MobilePrefix__c=null; }
        return c;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Creates a new contact populating fields from account. 
     * @param newAccount the new account
     * @param inputData the input data wrapper
     * @return the new contact 
     */
    public static Contact populateContactFieldsFromAccount(Account newAccount, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData){ // String contactFields
         XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in populateContactFieldsFromAccount');
        String recordTypeId = newAccount.RecordTypeId;
        Contact contact = new Contact();
        contact.XC_SkipDuplication__c = 0;
        contact.MailingCountry = UserInfo.getLocale();
        contact.AccountId =  newAccount.Id;     
       // contact.XC_GDPRThirdParties__c = newAccount.XC_GDPRThirdPartiesRelated__c;
        // contact.XC_GiveDataTo__c = true;
        contact.XC_GiveDataToNew__c =  'Yes';
        contact.XC_SkipTriggerIndividual__c	= true;
        Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(inputData.contactFields);
        removePrefix(fieldMap);
        
        if(String.isNotBlank((String) fieldMap.get('Birthdate'))) {
            String Birthdate = (String) fieldMap.get('Birthdate');
            contact.Birthdate = Date.valueOf(Birthdate);
        }
        //String mainLegalEntityValue = getMainLegalEntityValue(inputData.consentsLE); //dpalamides
        String mainLegalEntityValue = getMainLegalEntityValue(inputData.consentsWrapper); //dpalamides
        //contact.XC_CountryLegalEntity__c = getCountryLegalEntity(inputData.consentsLE);//dpalamides
        contact.XC_CountryLegalEntity__c = getCountryLegalEntity(inputData.consentsWrapper);//dpalamides
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@@@@ mainLegalEntityValue = '+mainLegalEntityValue);
        if(mainLegalEntityValue!=null){
            contact.XC_MainLegalEntity__c = mainLegalEntityValue;
        }
        contact.XC_Preferredlanguageofcontact__c = (String) fieldMap.get('PreferredLanguage');
        //NR1214 - mciavarra@deloitte.it
        if(String.isNotBlank((String) fieldMap.get('Sex'))) {
            contact.XC_Sex__c = (String) fieldMap.get('Sex');
        }
        if(String.isNotBlank((String) fieldMap.get('MobilePrefix'))) {
            contact.XC_MobilePrefix__c = (String) fieldMap.get('MobilePrefix');
        }if(String.isNotBlank((String) fieldMap.get('Mobile'))) {
            contact.XC_ContactMobile__c = (String) fieldMap.get('Mobile');
        }
        if(String.isNotBlank((String) fieldMap.get('Citizenship'))) {
            contact.XC_Citizenship__c = (String) fieldMap.get('Citizenship');
        }
        if(String.isNotBlank((String) fieldMap.get('BirthPlace'))) {
            contact.XC_Birth_Place__c = (String) fieldMap.get('BirthPlace');
        }
        if(String.isNotBlank((String) fieldMap.get('BirthProvince'))) {
            contact.XC_Birth_Province__c = (String) fieldMap.get('BirthProvince');
        }
        if(String.isNotBlank((String) fieldMap.get('BirthCountry'))) {
            contact.XC_Birth_Country__c = (String) fieldMap.get('BirthCountry');
        }
        //NR1214 - mciavarra@deloitte.it

        if(XC_UTIL_Account.isPartner(recordTypeId)){
            populateContactFieldsFromCustomFormOnAccount(contact, fieldMap); //contactFields);
            contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId(); 
        }else if(XC_UTIL_Account.isResidential(recordTypeId)){
            populateContactFieldsFromAccountData(contact, newAccount);
            contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Residential').getRecordTypeId();                    
            contact.XC_PrimaryContact__c = true;
        }else if(XC_UTIL_Account.isSoho(recordTypeId)){
            populateContactFieldsFromCustomFormOnAccount(contact, fieldMap); //contactFields);
            contact.XC_PrimaryContact__c = true;
            contact.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Soho').getRecordTypeId();
        }else if(XC_UTIL_Account.isCondominium(recordTypeId)){
            populateContactFieldsFromCustomFormOnAccount(contact, fieldMap); //contactFields);
            if(inputData.accountCheckDuplicateRes == null || !inputData.accountCheckDuplicateRes.isDuplicate){
                contact.XC_PrimaryContact__c = true;
            }
            contact.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId();
        }else if(XC_UTIL_Account.isGlobalB2B(recordTypeId)){
            populateContactFieldsFromCustomFormOnAccount(contact, fieldMap); //contactFields);
            if(inputData.accountCheckDuplicateRes == null || !inputData.accountCheckDuplicateRes.isDuplicate){
                contact.XC_PrimaryContact__c = true;
            }
            contact.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        }else if(XC_UTIL_Account.isGlobalB2G(recordTypeId)){
            populateContactFieldsFromCustomFormOnAccount(contact, fieldMap); //contactFields);
            if(inputData.accountCheckDuplicateRes == null || !inputData.accountCheckDuplicateRes.isDuplicate){
                contact.XC_PrimaryContact__c = true;
            }
            contact.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
        }else if(XC_UTIL_Account.isSFMAccount(recordTypeId)){
            populateContactFieldsFromCustomFormOnAccount(contact, fieldMap); //contactFields);
            if(inputData.accountCheckDuplicateRes == null || !inputData.accountCheckDuplicateRes.isDuplicate){
                contact.XC_PrimaryContact__c = true;
            }
            String accountRT = XC_UTIL_SObject.retrieveRecordTypNameFromId(recordTypeId);
            String contactRT = accountRT.replace('Account', 'Contact');
            contact.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRT).getRecordTypeId();
        }
            
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Acc recordType='+newAccount.RecordTypeID);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Contact recordType='+contact.RecordTypeID);
        return contact;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description return the main LE value (the first)
     * @param consentsLE inserted LEConsents
     * @return the main LE Value
     */
   private static String getMainLegalEntityValue(String consentsLE){
        if(consentsLE!=null && String.isNotEmpty(consentsLE)){
            //dpalamides
            /*List<Object> consentsLEList = (List<Object>) JSON.deserializeUntyped(consentsLE);
            for(Object obj : consentsLEList){
                Map<String,Object> item = (Map<String,Object>)obj;
                return (String)item.get('XC_LegalEntity__c');
            }*/
            List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> lcc163Wrapper = (List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>) JSON.deserialize(consentsLE,List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>.class);

            XC_LCC163_CreateConsents.GetLegalEntitiesResponse createConsentsWrapper = (lcc163Wrapper!=null && !lcc163Wrapper.isEmpty() && lcc163Wrapper[0]!=null) ? lcc163Wrapper[0] : new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();

            return createConsentsWrapper.legalEntity;
        }
        return null;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Return the main LE country (the first)
     * @param consentsLE - String
     * @return String
     */
   private static String getCountryLegalEntity(String consentsLE) {
        if(consentsLE != null && String.isNotEmpty(consentsLE)) {
            /*List<Object> consentsLEList = (List<Object>) JSON.deserializeUntyped(consentsLE);
            for(Object obj : consentsLEList){
                Map<String,Object> item = (Map<String,Object>)obj;
                return (String)item.get('XC_LeCountry__c');
            }*/
            List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> lcc163Wrapper = (List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>) JSON.deserialize(consentsLE,List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>.class);
            XC_LCC163_CreateConsents.GetLegalEntitiesResponse createConsentsWrapper = (lcc163Wrapper!=null && !lcc163Wrapper.isEmpty() && lcc163Wrapper[0]!=null) ? lcc163Wrapper[0] : new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();

            return createConsentsWrapper.country;
        }
        return null;
    }

}