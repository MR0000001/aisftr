/**
* @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it 
* @date Creation  28/08/2018
* @date Modification 22/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC002_NewLead – Controller new lead
*/

public without sharing class XC_LCC002_NewLead {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC002_NewLead');

    /** @description The Class FieldSetWrapper */
    public class FieldSetWrapper {
        List<FieldSetMember> fsPersonalData = new List<FieldSetMember>();
        List<FieldSetMember> fsContactData = new List<FieldSetMember>();
        List<FieldSetMember> fsDocumentData = new List<FieldSetMember>();
        List<FieldSetMember> fsOpportunity  = new List<FieldSetMember>();
        List<FieldSetMember> fsConsents     = new List<FieldSetMember>();
        List<FieldSetMember> fsSource       = new List<FieldSetMember>();
        List<FieldSetMember> fsCampaign     = new List<FieldSetMember>();
        String listMandatory = '';
        String defaultPhonePrefix ='';
        String defaultPrefLanguage = '';
        String defaultNationality='';
        Lead existingRecord = new Lead();
        String recordTypeName = '';
    }

    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it 
    * @description Retrieve data for the Wrapper. 
    * @param recordId the record id
    * @param recordTypeId the record type id
    * @return the serialized data 
    */
    @AuraEnabled
    public static String retrieveData(Id recordId, String recordTypeId) {
        Schema.DescribeSObjectResult dsr = Lead.SObjectType.getDescribe();
        Schema.RecordTypeInfo defaultRecordType;
        for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            if(rti.isDefaultRecordTypeMapping()) {
                defaultRecordType = rti;
            }
        }
        if(recordTypeId == null && defaultRecordType!=null){
            recordTypeId=defaultRecordType.recordTypeId;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordId->' + recordId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordTypeId->' + recordTypeId);
        FieldSetWrapper wrapper = new FieldSetWrapper();
        wrapper.recordTypeName = XC_UTIL_Sobject.retrieveRecordTypNameFromId(recordTypeId);
        populateWrapper(wrapper, recordTypeId);
        return JSON.serialize(wrapper);
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    * @description Checks if is system admin. 
    * @return the boolean
    */
    @AuraEnabled
    public static Boolean isSystemAdmin(){
        return XC_UTIL_Environment.isSystemAdmin();
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    * @description Gets the channel from user. 
    * @return the channel from user
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getChannelFromUser(){
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        result.success = true;
        String channel =  XC_UTIL_User.getChannelFromUser(UserInfo.getUserId());
        String country =  XC_UTIL_User.getCountryFromUser(UserInfo.getUserId());
        String countryFinal = '';
        if(country.contains(' ')){
            for(String word : country.split(' ')){
                countryFinal = countryFinal + word.toLowerCase().capitalize() + ' ';
            }
            countryFinal = countryFinal.removeEnd(' ');
        }else{
            countryFinal = country.toLowerCase().capitalize();
        }
        result.fieldName = channel;
        result.objectInfo = countryFinal;
        return result;
    }

    /**
    * @description Creates the record. 
    * @param mapLeadString - String to deserialize to get fields 
    * @date Mod. 22/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @return the insert result wrapper
    */
    @AuraEnabled
    public static XC_LCC002_NewLead_W.InsertResultWrapper createRecord(String mapLeadString) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapLeadString: ' + mapLeadString);
        if(String.isBlank(mapLeadString)){
            return new XC_LCC002_NewLead_W.InsertResultWrapper('Unknown Error','');
        }
        Map<String,Object> mapLead = (Map<String, Object>) JSON.deserializeUntyped(mapLeadString);
        String fieldMapStringLead = (String) mapLead.get('fieldMapStringLead');
        if(String.isBlank(fieldMapStringLead)){
            return new XC_LCC002_NewLead_W.InsertResultWrapper('Unknown Error','');
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ fieldMapStringLead -> ' + fieldMapStringLead);
        return createLead(mapLead, fieldMapStringLead);
    }

    /**
    * @description Creates the Lead
    * @date Mod. 22/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param mapLead - String to deserialize to get fields 
    * @param fieldMapStringLead - String to deserialize to get Lead fields
    * @return the insert result wrapper
    */
    private static XC_LCC002_NewLead_W.InsertResultWrapper createLead(Map<String,Object> mapLead, String fieldMapStringLead) {
        Lead newLead = new Lead();
        Boolean assignLead = (Boolean) mapLead.get('assignLead');
        String recordTypeId = (String) mapLead.get('recordTypeId');
        String existingLeadId = (String) mapLead.get('existingLeadId');
        String fullName = (String) mapLead.get('fullName');
        String addressFields = (String) mapLead.get('addressFields');
        String release = (String) mapLead.get('releaseDate');
        if(String.isNotBlank(release)){
            newLead.XC_NIE_expedition_date__c = Date.valueOf(release);
        }
        Boolean addressNoValidate = (Boolean) mapLead.get('withoutValidate');
        Boolean robinsonCustomer = (Boolean) mapLead.get('robinsonCustomer');
        String thirdPartiesCheck = String.valueOf(mapLead.get('thirdPartiesCheck'));
        String thirdPartiesVersion = String.valueOf(mapLead.get('thirdPartiesVersion'));
        String consentsLE = (String) mapLead.get('consentsLE');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ assignLead -> ' + assignLead);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ recordTypeId -> '+ recordTypeId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ existingLeadId -> ' + existingLeadId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ addressNoValidate -> ' + addressNoValidate);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ addressFields -> ' + addressFields);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ robinsonCustomer -> ' + robinsonCustomer);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ thirdPartiesCheck -> ' + thirdPartiesCheck + ' - version '+thirdPartiesVersion);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsLE -> ' + consentsLE);

        Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(fieldMapStringLead);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'fieldMap->'+fieldMap);

        XC_LCC002_NewLead_U.populateName(recordTypeId, newLead, fieldMap);
        XC_LCC002_NewLead_U.populateSocialPersona(newLead, mapLead);
        XC_LCC002_NewLead_U.populateCaseLookup(newLead, mapLead);
        populateFields(newLead, fieldMap, addressFields);
        newLead = XC_LCC002_NewLead_U.populateAddress(newLead, addressFields);
        if(XC_UTIL_Lead.isResidential(recordTypeId)) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ COMPANY is ' + fieldMap.get('FirstName'));
            newLead.Company = fieldMap.get('FirstName') + ' ' + fieldMap.get('LastName');
        }
        newLead.XC_AddressLeadNotValidated__c = (addressNoValidate != null) ? addressNoValidate : false;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ newLead -> ' + newLead);

        XC_LCC002_NewLead_W.LeadInputDataWrapper inputData = new XC_LCC002_NewLead_W.LeadInputDataWrapper();
        inputData.recordTypeId = recordTypeId;
        inputData.assignLead = assignLead;
        inputData.robinsonCustomer = robinsonCustomer;
        inputData.thirdPartiesCheckNew = thirdPartiesCheck;
        inputData.thirdPartiesVersion = thirdPartiesVersion;
        inputData.consentsLE = consentsLE;
        inputData.consentsWrapper = (String) mapLead.get('consentsWrapper');
        return checkDuplicatesAndInsertRecord(newLead, inputData);
    }

    /**
    * @description Populate fields
    * @param newLead the new lead
    * @param fieldMap the field map
    * @param addressFields the address fields
    */
    public static void populateFields(Lead newLead, Map<String,Object> fieldMap, String addressFields) {
        XC_LCC002_NewLead_U.removeAddress(fieldMap);
        XC_LCC002_NewLead_U.removePrefix(fieldMap);
        XC_LCC002_NewLead_U.removeReleaseDate(fieldMap);
        List<String> fieldList = XC_UTIL_Sobject.getListAllFields('Lead');
        for(String fieldName : fieldList){
            if(fieldName=='XC_Birthdate__c' || fieldName=='XC_NIE_expedition_date__c' || fieldName=='XC_NIE_expiration_date__c' || fieldName=='XC_ContactDocumentExpirationDate__c' || fieldName=='XC_ContacDocumentReleaseDate__c') {
                XC_LCC002_NewLead_U.populateDateFields(fieldName, fieldMap);
            }
            if(fieldName!='Name' && fieldMap.containsKey(fieldName) && fieldMap.get(fieldName) != null) {
                if((String.valueOf(fieldMap.get(fieldName)).contains('displayValue=null'))) {
                    Object v = ((Map<String,Object>)fieldMap.get(fieldName)).get('value');
                    System.debug('@@@ convVal -> ' + v);
                    newLead.put(fieldName, v);
                } else {
                    newLead.put(fieldName, fieldMap.get(fieldName));
                }
            }
        }
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
    * @description Check duplicates and insert record. 
    * @param newLead the new lead
    * @param inputData 
    * @return the insert result wrapper
    */
    public static XC_LCC002_NewLead_W.InsertResultWrapper checkDuplicatesAndInsertRecord(Lead newLead, XC_LCC002_NewLead_W.LeadInputDataWrapper inputData) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkDuplicatesAndInsertRecord -> inputData = ' + inputData);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordTypeId->' + inputData.recordTypeId);
        String recordTypeName ='';
        if (!String.isBlank(inputData.recordTypeId)) {
            newLead.RecordTypeId = inputData.recordTypeId;
            recordTypeName = Schema.SObjectType.Lead.getRecordTypeInfosById().get(newLead.RecordTypeId).getDeveloperName();
        }
        newLead.Status = Label.XC_CL_Lead_Assigned;
        /*if(inputData.thirdPartiesCheck!=null){
        	newLead.XC_GDPRThirdPartiesRelated__c = Boolean.valueOf(inputData.thirdPartiesCheck);
        }*/
        newLead.Salutation = newLead.XC_Salutation__c;

        //String productCategory = (String) newLead.get('XC_ProductCategoryOfInterest__c');
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'productCategory->' + productCategory);
        //String address = (String) newLead.get('XC_Address__c');
        /*if(!String.isBlank(productCategory) && hasCommercialVisit(productCategory) && !String.isBlank(address)){
            assignLead = false; 
            newLead.put('Status', Label.XC_CL_Lead_PendingScheduling);
        }*/
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'assignLead->' + inputData.assignLead); 
        /*List<XC_TR_Lead_U_CheckDuplicates.ResultWrapper> rwList = XC_TR_Lead_U_CheckDuplicates.duplicationCheckInsert(new List<Lead>{newLead});
        
        if(rwList.isEmpty()){
            return new InsertResultWrapper('Unknown Error',''); 
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'result->' + result); 
        */
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> lcc163Wrapper = (List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>) JSON.deserialize(inputData.consentsWrapper, List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>.class);
        List<String> leList = new List<String>();
        for (XC_LCC163_CreateConsents.GetLegalEntitiesResponse currWrapper : (lcc163Wrapper != null ? lcc163Wrapper : new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>())) {
            XC_LCC163_CreateConsents.GetLegalEntitiesResponse createConsentsWrapper = (currWrapper != null) ? currWrapper : new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
            leList.add(String.escapeSingleQuotes(createConsentsWrapper.legalEntity));
        }
        if(!recordTypeName.contains('SFM')){ 
            //XC_LCC002_NewLead_U.populateListOfLegalEntities(newLead, inputData.consentsLE);  dpalamides
            XC_LCC002_NewLead_U.populateListOfLegalEntities(newLead, String.escapeSingleQuotes(JSON.serialize(leList)));
        }
        List<Lead> listLeadInput = new List<Lead>();
        listLeadInput.add(newLead);
        List<XC_LCC002_NewLead_W.InsertResultWrapper> wrapperList = XC_UTIL_LeadDuplication.checkDuplicates(listLeadInput);
        System.debug('@@@checkDuplicatesAndInsertRecord wrapperList ' + wrapperList);
        try {
            if ((!wrapperList.isEmpty() && wrapperList[0].success) || wrapperList.isEmpty()) {
                XC_LCC002_NewLead_W.InsertResultWrapper retVal = insertRecord(newLead, inputData);
                if (retVal.success) {
                    for (XC_LCC163_CreateConsents.GetLegalEntitiesResponse currWrapper : lcc163Wrapper) {
                        XC_LCC163_CreateConsents.GetLegalEntitiesResponse createConsentsWrapper = (currWrapper != null) ? currWrapper : new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();

                        System.debug('@@@ DP->' + inputData.consentsWrapper);
                        newLead.Country__c = createConsentsWrapper.consentsData.personalInfo.theLead.Country__c;
                        createConsentsWrapper.consentsData.personalInfo.theLead = (Lead) XC_UTIL_Sobject.selectAllFields(newLead.Id)[0];
                        createConsentsWrapper.consentsData.personalInfo.theContactIndividual = (Individual) XC_UTIL_Sobject.selectAllFields(createConsentsWrapper.consentsData.personalInfo.theLead.IndividualId)[0];
                        System.debug('@@@ DP->' + createConsentsWrapper);
                        XC_LCC163_CreateConsents.createLegalEntities(JSON.serialize(createConsentsWrapper));
                    }
                    return retVal;
                } else {
                    return retVal;
                }
            } else {
                XC_UTIL_Sobject.updateRecord(wrapperList[0].leadToUpdate);
                return wrapperList[0];
            }
        } catch(Exception e){
            System.debug(e);
            return null;
        }




        /*if(result.success){  
            return insertRecord(newLead, assignLead); 
        } else {
            return new InsertResultWrapper(result.errorMessage,'');
        }*/
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    * @description Remove Document Type
    * @param newLead Lead
    */
    private static void removeDocumentType(Lead newLead) {
        if(newLead.XC_DocumentNumber__c== null || newLead.XC_DocumentNumber__c == ''){
            System.debug('@@@ In removeDocumentType');
            newLead.XC_DocumentNumber__c= null;
            newLead.XC_DocumentType__c= null;
            // newLead.XC_DocumentCountry__c = null;
        }
    }

    /**
    * @description Insert record
    * @param newLead the new lead
    * @param inputData  
    * @return the insert result wrapper
    */
    @TestVisible
    private static XC_LCC002_NewLead_W.InsertResultWrapper insertRecord(Lead newLead, XC_LCC002_NewLead_W.LeadInputDataWrapper inputData) {
        /*if(inputData.assignLead){
            XC_UTIL_LeadAssignment.assignLead(new List<Lead>{newLead}, inputData.consentsLE);
        }*/
        System.Savepoint beforeInsertSavepoint = Database.setSavepoint();
        if(XC_UTIL_Lead.isResidential(newLead.RecordTypeId)){
            removeDocumentType(newLead);
        }
        XC_LCC002_NewLead_W.RollBackWrapper rollBackWrapper = XC_UTIL_InsertNewLead.checkForInsertRollBack(newLead, beforeInsertSavepoint);
        if(rollBackWrapper.isRollBack) {
            return rollBackWrapper.resultWrapper;
        }
        List<Lead> newLeadAllFields = XC_UTIL_Sobject.selectAllFields(newLead.Id);
        Lead newLeadToUpdate = newLeadAllFields[0];
        if(!String.isBlank(newLeadToUpdate.XC_Address__c) && !String.isBlank(newLeadToUpdate.XC_Country__c) && newLeadToUpdate.XC_Country__c != null){
            XC_UTIL_Sobject.WrapperResult addressResult = XC_LCC002_NewLead_U.insertAddress(newLeadToUpdate);
            if(!addressResult.success){
                return XC_LCC002_NewLead_Related.doRollback(addressResult, beforeInsertSavepoint);
            }
            newLeadToUpdate.XC_LeadAddress__c = addressResult.recordId;
        }
        newLeadToUpdate.XC_LeadId__c = newLeadToUpdate.Id;

        /*XC_LCC002_NewLead_W.InsertResultWrapper relObjResult = XC_LCC002_NewLead_Related.saveSocialPersonaAndConsents(newLeadToUpdate, inputData, beforeInsertSavepoint);
        if(!relObjResult.success){
            return relObjResult;
        } */ //dpalamides Robinson
        //XC_UTIL_InsertNewLead.processLeadAssignment(newLeadToUpdate, inputData.assignLead); Deprecated -> Now in before insert
        XC_UTIL_Sobject.WrapperResult updateResult = XC_UTIL_Sobject.updateRecord(newLeadToUpdate);
        if(!updateResult.success){
            return XC_LCC002_NewLead_Related.doRollback(updateResult, beforeInsertSavepoint);
        }
        return new XC_LCC002_NewLead_W.InsertResultWrapper(newLeadToUpdate.Id);
    }

    /** -------------------------------------------------     ONE ORG CONFIGURATION - START      ---------------------------------------------*/

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    * @description Populate wrapper
    * @param wrapper the wrapper
    * @param recordTypeId the record type id
    */
    private static void populateWrapper(FieldSetWrapper wrapper, String recordTypeId) {
        String recordTypeName = XC_UTIL_Sobject.retrieveRecordTypNameFromId(recordTypeId);
        if(recordTypeName.contains('SFM')){
            String countryIso = 'ARG';
            if(recordTypeName.length()> 6 ){
                countryIso =  recordTypeName.substring(3,6);
            }
            wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_SFM_'+ countryIso +'_AccountInformation').getFields();
            wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_SFM_'+ countryIso +'_New_ContactInformation').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_SFM_'+ countryIso +'_MandatoryAccount'));
            wrapper.fsOpportunity = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_SFM_'+ countryIso +'_New_Opportunity').getFields();
            wrapper.fsSource = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_SFM_'+ countryIso +'_New_Source').getFields();
            String userId = UserInfo.getUserId();
            List<User> userList = [SELECT id, Country__c FROM User WHERE Id=:userId];
            if(userList[0].Country__c == null){
                return;
            }
             //JJP - 20/12/2021 - Start
            XC_CM_CountryLegalEntityAssociation__mdt userLE =  [select  XC_PhonePrefix__c,XC_Nationality__c,XC_Preferredlanguageofcontact__c from XC_CM_CountryLegalEntityAssociation__mdt where XC_Country__c = :userList[0].Country__c AND (XC_Stream__c = 'B2B' OR XC_Stream__c = 'B2G') limit 1];
             //JJP - 20/12/2021 - End
            wrapper.defaultPhonePrefix= (userLE!=null && String.isNotBlank(userLE.XC_PhonePrefix__c)) ? userLE.XC_PhonePrefix__c : '';
            wrapper.defaultNationality = (userLE!=null && String.isNotBlank(userLE.XC_Nationality__c)) ? userLE.XC_Nationality__c : '';
            wrapper.defaultPrefLanguage= (userLE!=null && String.isNotBlank(userLE.XC_Preferredlanguageofcontact__c)) ? userLE.XC_Preferredlanguageofcontact__c : '';
            return;
        }
        XC_CM_CountryLegalEntityAssociation__mdt userLE = XC_UTIL_User.getLegalEntityMetadataFromUserByRT(recordTypeName);
        String countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
        String userLEString = userLE.XC_Category__c;

        if (countryIso == 'ESP') {
            if(XC_UTIL_Lead.isCondominium(recordTypeId)){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_PersonalData_Condominium').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_ESP_Lead_New_Mandatory_ContactInforma'));
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_Lead_New_PersonalData_Condominium').getFields();
            } else if(XC_UTIL_Lead.isSoho(recordTypeId)){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_PersonalData_Soho').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_ESP_Lead_New_Mandatory_ContactInforma'));
            } else {
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_PersonalData_Residential').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_ESP_Lead_New_Mandatory'));
            }
            // wrapper.fsDirection = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_Direction').getFields();
            wrapper.fsDocumentData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_DocumentInformation').getFields();
            // 29-11-2021 ALC changes for B2C/B2B/B2G to work - START
            System.debug('ALC userLEString: '+userLEString);
            if(userLEString == 'B2B' || userLEString == 'B2G'){
                wrapper.fsOpportunity = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_'+userLEString+'_New_Opportunity').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_'+userLEString+'_New_ContactInformation').getFields();
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_'+userLEString+'_New_PersonalData').getFields();
                wrapper.fsCampaign = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_CampaignInformation').getFields();
                wrapper.fsSource = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_Source').getFields();
            }else{
                wrapper.fsOpportunity = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_Opportunity').getFields();
                /*wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_ContactInformation').getFields();
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_PersonalData_Residential').getFields();*/
                //JJP - 20/12/2021 - Start
                wrapper.fsSource = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_Source').getFields();
                //JJP - 20/12/2021 - End

            }
            // 29-11-2021 ALC changes for B2C/B2B/B2G to work - END

            //wrapper.fsConsents = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_Consents').getFields();
            // wrapper.fsAddress = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_Address').getFields();
            //JJP - 20/12/2021 - Start
            //wrapper.fsSource = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_Source').getFields();
            //JJP - 20/12/2021 - End
        }
        else{
            if(XC_UTIL_Lead.isCondominium(recordTypeId)){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_PersonalData_Condominium').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_'+countryIso+'_'+userLEString+'_New_Mandatory_ContactInforma'));
            } else if(XC_UTIL_Lead.isSoho(recordTypeId) ){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_PersonalData_Soho').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_'+countryIso+'_'+userLEString+'_New_Mandatory_ContactInforma'));
            } else if(XC_UTIL_Lead.isGlobalB2B(recordTypeId) || XC_UTIL_Lead.isGlobalB2G(recordTypeId)){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_PersonalData').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_'+countryIso+'_'+userLEString+'_New_Mandatory_ContactInforma'));
                List<XC_CM_LegalEntity_Configuration__mdt> complexProduct = [SELECT  XC_Country__c, XC_ComplexProductActive__c, XC_Stream__c FROM  XC_CM_LegalEntity_Configuration__mdt WHERE XC_Country__c = : userLE.XC_Country__c AND XC_Stream__c =: userLEString AND XC_OrgId__c =: UserInfo.getOrganizationId() ];
                if((countryIso != 'CHL' && countryIso != 'COL') || (!complexProduct.isEmpty() && complexProduct[0].XC_ComplexProductActive__c)){
                    wrapper.fsCampaign = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_CampaignInformation').getFields();
                }
            } else if(XC_UTIL_Lead.isGlobalLead(recordTypeId) ){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_PersonalData').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_GLO_New_Mandatory_ContactInforma'));
                wrapper.fsCampaign = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_CampaignInformation').getFields();
                
            } 
            else{
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_PersonalData_Residential').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_'+countryIso+'_'+userLEString+'_Lead_New_Mandatory'));
            }
            if(!XC_UTIL_Lead.isGlobalLead(recordTypeId)){
                // wrapper.fsDirection = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_Direction').getFields();
                wrapper.fsDocumentData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_DocumentInformation').getFields();
                wrapper.fsOpportunity = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_Opportunity').getFields();
                //wrapper.fsConsents = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_Consents').getFields();
                // wrapper.fsAddress = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_Address').getFields();
                wrapper.fsSource = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_Source').getFields();
            }else{
                wrapper.fsDocumentData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_DocumentInformation').getFields();
                wrapper.fsOpportunity = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_Opportunity').getFields();
                wrapper.fsSource = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_Source').getFields();
            }


            //default Field - Mottaviano
            wrapper.defaultPhonePrefix= (userLE!=null && String.isNotBlank(userLE.XC_PhonePrefix__c)) ? userLE.XC_PhonePrefix__c : '';
            wrapper.defaultNationality = (userLE!=null && String.isNotBlank(userLE.XC_Nationality__c)) ? userLE.XC_Nationality__c : '';
            wrapper.defaultPrefLanguage= (userLE!=null && String.isNotBlank(userLE.XC_Preferredlanguageofcontact__c)) ? userLE.XC_Preferredlanguageofcontact__c : '';
        }
    }

    /**
    * @description Gets the mandatory fields
    * @return the mandatory fields
    */
    /*private static String getMandatoryFields(){
        String fieldSetMandatoryFields = '';
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            fieldSetMandatoryFields = 'XC_ESP_Lead_New_Mandatory';
        }  
        return fieldSetMandatoryFields;
    }*/

    /**
    * @description Gets the mandatory fields address
    * @return the mandatory fields address
    */
    /*private static String getMandatoryFieldsAddress(){
        String fieldSetMandatoryFields = '';
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            fieldSetMandatoryFields = 'XC_ESP_Lead_New_MandatoryAddress';
        }  
        return fieldSetMandatoryFields;
    }*/

    /** -------------------------------------------------     ONE ORG CONFIGURATION - END      ----------------------------------------------*/

    /** @description */
    /*private class RollBackWrapper {
        Boolean isRollBack = false;
        InsertResultWrapper resultWrapper;
    }*/

    /** @description The Class InsertResultWrapper */
    /*public class InsertResultWrapper{ 
        /** @description The record id * /
        @AuraEnabled
        public Id recordId {get; set;} 
        /** @description The success. * /
        @AuraEnabled
        public Boolean success {get; set;} 
        /** @description The error message. * /
        @AuraEnabled
        public String errorMessage {get; set;} 
        /** @description The field name. * /
        @AuraEnabled
        public String fieldName {get; set;} 
        /** @description The converted account id. * /
        @AuraEnabled
        public String convertedAccountId {get; set;}

        /**
        * @description InsertResultWrapper constructor for success
        * @param  recordId                 
        * /
        public InsertResultWrapper(Id recordId){
            this.recordId = recordId;
            this.success = true;
            this.errorMessage = '';
            this.fieldName = '';
            this.convertedAccountId = null;
        }

        /**
        * @description InsertResultWrapper constructor for error
        * @param  errorMessage 
        * @param  fieldName                 
        * /
        public InsertResultWrapper(String errorMessage, String fieldName){
            this.recordId = null;
            this.success = false;
            this.errorMessage = errorMessage;
            this.fieldName = fieldName;
            this.convertedAccountId = null;
        }
    }*/

    /** @description Wrapper with all input for the Lead creation **/
    /*public class LeadInputDataWrapper{
        public String recordTypeId;
        public Boolean assignLead;
        public Boolean thirdPartiesCheck;
        public String consentsLE;
    }*/

    /**
    * @description Check commercial visit
    * @param productCategory the product category
    * @return the string
    */
    /*@AuraEnabled
    public static String checkCommercialVisit(String productCategory) {
        String fieldSetMandatoryFields = getMandatoryFields(); 
        String fieldSetMandatoryFieldsAddress = getMandatoryFieldsAddress();
        List<String> mandatoryFieldNames = XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead', fieldSetMandatoryFields); 
        if(!String.isBlank(productCategory)){ 
            if(XC_LCC002_NewLead_U.hasCommercialVisit(productCategory)){
                mandatoryFieldNames.addAll(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead', fieldSetMandatoryFieldsAddress));
            }
        }  
        return JSON.serialize(mandatoryFieldNames);                                                               
    }*/

    /**
    * @description Check for RollBack
    * @param newLead - Lead
    * @param beforeInsertSavepoint - Savepoint  
    * @return RollBackWrapper
    */
    /*private static RollBackWrapper checkForInsertRollBack(Lead newLead, System.Savepoint beforeInsertSavepoint) {
        RollBackWrapper rollBackWrapper = new RollBackWrapper();
        XC_UTIL_Sobject.WrapperResult wrapResult = XC_UTIL_Sobject.insertRecord(newLead);
        if(!wrapResult.success){
            rollBackWrapper.isRollBack = true;
            rollBackWrapper.resultWrapper = doRollback(wrapResult, beforeInsertSavepoint); 
            return rollBackWrapper;
        }
        if(XC_UTIL_Lead.isResidential(newLead.recordTypeId)){ 
            XC_UTIL_Sobject.WrapperResult docDmlResult = XC_LCC002_NewLead_U.insertDocuments(newLead);
            if(!docDmlResult.success){
                rollBackWrapper.isRollBack = true;
                rollBackWrapper.resultWrapper = doRollback(docDmlResult, beforeInsertSavepoint); 
                return rollBackWrapper;
            }
        }
        return rollBackWrapper;
    }*/

    /**
    * @description Insert the Social Persona association and record
    * @param newLead the new lead
    * @param inputData  
    * @param beforeInsertSavepoint
    * @return the insert result wrapper
    */
    /*private static XC_LCC002_NewLead_W.InsertResultWrapper saveSocialPersonaAndConsents(Lead newLead, XC_LCC002_NewLead_W.LeadInputDataWrapper inputData, System.Savepoint beforeInsertSavepoint){
        XC_UTIL_Sobject.WrapperResult spDmlResult =  XC_LCC002_NewLead_U.associateSocialPersonaWithLead(newLead.Id, newLead.XC_SocialPersonaId__c);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@Social_Persona_DmlResult@@@' + spDmlResult);
        if (!spDmlResult.success){
            return doRollback(spDmlResult, beforeInsertSavepoint);
        }

        /*XC_UTIL_Sobject.WrapperResult indiDmlResult =  XC_LCC002_NewLead_U.saveConsentsOnIndividual(newLead.IndividualId, inputData.thirdPartiesCheck);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@Individual_DmlResult@@@' + indiDmlResult);
        if (!indiDmlResult.success){
            return doRollback(indiDmlResult, beforeInsertSavepoint);
        }* /

        XC_UTIL_Sobject.WrapperResult leDmlResult =  XC_LCC002_NewLead_U.insertLegalEntityConsents(newLead.IndividualId, inputData.consentsLE, newLead);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@leDmlResult@@@' + leDmlResult);
        if (!leDmlResult.success){
            return doRollback(leDmlResult, beforeInsertSavepoint);
        }

        XC_UTIL_Sobject.WrapperResult leDmlResult =  XC_LCC002_NewLead_U.insertLegalEntityConsents(newLead.IndividualId, inputData.consentsLE, newLead);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@leDmlResult@@@' + leDmlResult);
        if (!leDmlResult.success){
            return doRollback(leDmlResult, beforeInsertSavepoint);
        }

        return new XC_LCC002_NewLead_W.InsertResultWrapper(newLead.Id);
    }*/

    /**
    * @description populate InsertResultWrapper from WrapperResult
    * @param dmlResult the dml operation result
    * @param beforeInsertSavepoint
    * @return the insert result wrapper
    */
    /*private static XC_LCC002_NewLead_W.InsertResultWrapper doRollback(XC_UTIL_Sobject.WrapperResult dmlResult, System.Savepoint beforeInsertSavepoint){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@LEAD creation Rollback@@@');
        Database.rollback(beforeInsertSavepoint);
        return new XC_LCC002_NewLead_W.InsertResultWrapper(dmlResult.errorMessage, dmlResult.errorfieldName);
    }*/

}