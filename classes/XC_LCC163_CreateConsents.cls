/**
* @author dpalamides - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 14/10/2019
* @date Mod 28/09/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC163_CreateConsents - Apex Class for component LCP163
*/

public without sharing class XC_LCC163_CreateConsents {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC163_CreateConsents');

    /**
    * @author dpalamides
    * @date 14/10/2019
    * @description GetLegalEntitiesResponse Wrapper
    */
    public class GetLegalEntitiesResponse {
        public String developerName;
        public String label;
        public String legalEntity;
        public String country;
        public String companyCode;
        public String consentVersion;
        public String thirdPartyLabel;
        public String profilingLabel;
        public String marketingLabel;
        public String descriptionThirdParties;
        public String descriptionProfiling;
        public String descriptionMarketing;
        public String descriptionGiveData;
        public String marketingValue;
        public String profilingValue;
        public String thirdPartyValue;
        public String legalEntityConsentId;
        public Id consentDescriptionLookup;
        public Boolean isExisting;
        public Boolean confirmationByTheCustomer;
        public Boolean isPrimary;
        public String privacyConsentUrl;

        public String notCustomerLabel;
        public String descriptionNotCustomer;
        public String notCustomerValue;
        public String thPartiesMarketingLabel;
        public String descriptionThPartiesMarketing;
        public String thPartiesMarketingValue;
        public Boolean isExistingNotCustomer = false;
        public Boolean isExistingThPartiesMarketing = false;

        public XC_UTIL_GDPR.CreateConsentsWrapper consentsData = new XC_UTIL_GDPR.CreateConsentsWrapper();
    }

    /**
    * @author Palamides Damiano
    * @date Creation 14/10/2019
    * @date Mod 28/09/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to get consents to show
    * @param recordId - String
    * @param objectType - String
    * @param sObjectData - String
    * @return String (Serialized legal entities)
    */
    @AuraEnabled
    public static String getLegalEntities(String recordId, String objectType, String sObjectData) {
        User currUser = XC_LCC163_CreateConsents_U.getCurrUSer();
        Boolean isAccount = recordId != null && XC_UTIL_Sobject.getObjectType(recordId) == 'Account';
        List<GetLegalEntitiesResponse> response = new List<GetLegalEntitiesResponse>();
        Lead theLead = XC_LCC163_CreateConsents_U.getLead(recordId, objectType, sObjectData);
        Account theAccount = XC_LCC163_CreateConsents_U.getAccount(recordId, objectType, sObjectData);
        Contact theContact = XC_LCC163_CreateConsents_U.getPrimaryContact(recordId, objectType, sObjectData);
        Individual theIndividual = XC_LCC163_CreateConsents_U.getContactIndividual(theContact);
        String recordTypeId;
        if(String.isNotBlank(recordId)){
            Id recID = recordId;
            String objTypeName = recID.getSObjectType().getDescribe().getName();
            recordTypeId = XC_UTIL_Sobject.getFieldValue(objTypeName, 'RecordTypeId', recordId);
        }
        else{ //if(String.isNotBlank(sObjectData)){
            Map<String, Object> sObjectDataMap = (Map<String, Object>) JSON.deserializeUntyped(sObjectData);
            recordTypeId = sObjectDataMap.get('RecordTypeId') != null ? String.valueOf(sObjectDataMap.get('RecordTypeId')) : '';
        }
        //Map<String, Object> sObjectDataMap = (Map<String, Object>) JSON.deserializeUntyped(sObjectData);
        //String recordTypeId = sObjectDataMap.get('RecordTypeId') != null? String.valueOf(sObjectDataMap.get('RecordTypeId')) : '';
        List<XC_CM_CountryLegalEntityAssociation__mdt> legalEntities = XC_LCC163_CreateConsents_U.getLegalEntityConfigurations(currUser, recordTypeId );
        Map<String, XC_ConsentDescription__c> consentDescriptionsMap = XC_UTIL_GDPR_D.getConsentDescriptionsByLegalEntity(XC_UTIL_Sobject.getListFieldValues(legalEntities,'XC_LegalEntity__c'));
        Map<String, XC_ConsentDescription__c> consentDescriptionsVersionMap = getConsentDescriptionsByCurrentUser(XC_UTIL_Sobject.getListFieldValues(legalEntities,'XC_LegalEntity__c'));
        Map<Id, Map<String, XC_LegalEntityConsent__c>> existingLE = XC_UTIL_GDPR_D.getExistingLegalEntitiesConsents(theIndividual != null ? new List<Individual>{
                theIndividual
        } : new List<Individual>());

        Boolean confirmationValue = false;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'consentDescriptionsMap: '+consentDescriptionsMap);
        for (XC_CM_CountryLegalEntityAssociation__mdt le : legalEntities) {
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'le: '+le);
            Boolean isExistingBoolean = existingLE != null && theContact != null
                    && existingLE.get(theContact.IndividualId) != null
                    && existingLE.get(theContact.IndividualId).get(le.XC_LegalEntity__c) != null;
            Boolean skipLE = isAccount && currUser!=null && currUser.XC_LegalEntity__c!=null && currUser.XC_LegalEntity__c!=le.XC_LegalEntity__c && legalEntities.size()>1 && !isExistingBoolean;
            String mainLE = XC_UTIL_User.getLegalEntityFromUser();
            if (skipLE) {
               continue;
            }
            XC_ConsentDescription__c consDescr = consentDescriptionsMap.get(le.XC_Country__c + '§' + le.XC_LegalEntity__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'consDescr: '+consDescr);
            GetLegalEntitiesResponse currResp = new GetLegalEntitiesResponse();
            currResp.developerName = le.DeveloperName;
            currResp.label = le.label;
            currResp.legalEntity = le.XC_LegalEntity__c;
            currResp.country = le.XC_Country__c;
            //currResp.companyCode = le.XC_CompanyCode__c;
            currResp.consentVersion = consDescr.XC_ConsentVersion__c;
            currResp.thirdPartyLabel = Label.XC_CL_Consents_ThirdParty;
            currResp.profilingLabel = Label.XC_CL_Consents_Profiling;
            currResp.marketingLabel = Label.XC_CL_Consents_Marketing;
            currResp.descriptionThirdParties = consDescr.XC_DescriptionThirdParties__c;
            currResp.descriptionProfiling = consDescr.XC_DescriptionProfiling__c;
            currResp.descriptionMarketing = consDescr.XC_DescriptionMarketing__c;
            currResp.descriptionGiveData = consDescr.XC_DescriptionGiveDataToLE__c;
            currResp.consentDescriptionLookup = consDescr.Id;
            currResp.privacyConsentUrl = consDescr.XC_PrivacyConsentUrl__c;

            
            if(String.isNotBlank(consDescr.XC_DescriptionNotCustomer__c)) {
                currResp.notCustomerLabel = Label.XC_CL_NotCustomerConsens;
                currResp.descriptionNotCustomer = consDescr.XC_DescriptionNotCustomer__c;
                currResp.isExistingNotCustomer = true;
            }
            if(String.isNotBlank(consDescr.XC_DescriptionThirdProductsMarketing__c)) {
                currResp.thPartiesMarketingLabel = Label.XC_CL_ThirdProductsMarketing;
                currResp.descriptionThPartiesMarketing = consDescr.XC_DescriptionThirdProductsMarketing__c;
                currResp.isExistingThPartiesMarketing = true;
            }            

            //&& existingLE.get(theContact.IndividualId).get(le.XC_LegalEntity__c).XC_ProfilingConsent__c == 'Yes'
            //&& existingLE.get(theContact.IndividualId).get(le.XC_LegalEntity__c).XC_MarketingConsent__c == 'Yes';
            if (isExistingBoolean){
                confirmationValue = theAccount.XC_ConfirmationByCustomer__c;
                String consentVersion = XC_LCC163_CreateConsents_U.getExistingConsentVersion(theIndividual, currResp.consentVersion);//theIndividual.XC_ThirdPartyConsentVersion__c;
                //XC_ConsentDescription__c existingConsDescr = consentDescriptionsVersionMap.get(le.XC_Country__c + '§' + le.XC_LegalEntity__c + '§' + consentVersion);
                XC_ConsentDescription__c existingConsDescr = consentDescriptionsVersionMap.get(existingLE.get(theContact.IndividualId).get(le.XC_LegalEntity__c).XC_ConsentDescription__c);
                if(existingConsDescr != null){
                    currResp.descriptionThirdParties = existingConsDescr.XC_DescriptionThirdParties__c;
                    currResp.descriptionProfiling = existingConsDescr.XC_DescriptionProfiling__c;
                    currResp.descriptionMarketing = existingConsDescr.XC_DescriptionMarketing__c;
                    currResp.descriptionNotCustomer = existingConsDescr.XC_DescriptionNotCustomer__c;
                    currResp.descriptionThPartiesMarketing = existingConsDescr.XC_DescriptionThirdProductsMarketing__c;
                    currResp.descriptionGiveData = existingConsDescr.XC_DescriptionGiveDataToLE__c;
                    currResp.consentVersion = existingConsDescr.XC_ConsentVersion__c;//consentVersion;
                    currResp.consentDescriptionLookup = existingConsDescr.Id;
                }
                currResp.marketingValue = existingLE.get(theContact.IndividualId).get(le.XC_LegalEntity__c).XC_MarketingConsent__c;
                currResp.notCustomerValue = existingLE.get(theContact.IndividualId).get(le.XC_LegalEntity__c).XC_NotCustomerConsent__c;
                currResp.thPartiesMarketingValue = existingLE.get(theContact.IndividualId).get(le.XC_LegalEntity__c).XC_ThirdProductsMarketingConsent__c;
                currResp.profilingValue = existingLE.get(theContact.IndividualId).get(le.XC_LegalEntity__c).XC_ProfilingConsent__c;
                currResp.thirdPartyValue = theIndividual.XC_GiveDataToThirdParties__c;
                currResp.isExisting = currResp.marketingValue == 'Yes' && currResp.profilingValue == 'Yes';
                currResp.legalEntityConsentId = existingLE.get(theContact.IndividualId).get(le.XC_LegalEntity__c).Id;
            } else {
                currResp.notCustomerValue = null;
                currResp.thPartiesMarketingValue = null;
                currResp.marketingValue = null;
                currResp.profilingValue = null;
                currResp.thirdPartyValue = theIndividual != null ? theIndividual.XC_GiveDataToThirdParties__c : null;
                currResp.isExisting = false;
            }

            currResp.consentsData.personalInfo.theContactAccount = theAccount;
            currResp.consentsData.personalInfo.theContact = theContact;
            currResp.consentsData.personalInfo.theLead = theLead;
            currResp.consentsData.personalInfo.theContactIndividual = theIndividual;
            currResp.consentsData.personalInfo.currentLE = le.XC_LegalEntity__c;
            currResp.consentsData.personalInfo.countryLE = le.XC_Country__c;

            currResp.isPrimary = currResp.legalEntity == mainLE;
            response.add(currResp);
        }

        for(GetLegalEntitiesResponse currResp : response){
            currResp.confirmationByTheCustomer = confirmationValue;
        }

        return JSON.serialize(response);
    }

    /**
    * @author Monica Cutillo
    * @date Creation 31/03/2020
    * @description createLegalEntities with result wrapper output
    * @param data String  serialized GetLegalEntitiesResponse
    * @return dml result wrapper list
    */
    public static List<XC_UTIL_Sobject.WrapperResult> createLegalEntitiesWithResults(String data) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '§DP' + data);
        //GetLegalEntitiesResponse dataObj = (GetLegalEntitiesResponse) JSON.deserialize(data, GetLegalEntitiesResponse.Class);
        List<Object> dataObjList = (List<Object>) JSON.deserializeUntyped(data);
        List<XC_UTIL_GDPR.CreateConsentsWrapper> consDataList = new List<XC_UTIL_GDPR.CreateConsentsWrapper>();
        for(Object getLE : dataObjList){
            GetLegalEntitiesResponse getLEConsents = (GetLegalEntitiesResponse) JSON.deserialize(JSON.serialize(getLE), GetLegalEntitiesResponse.Class);
            dataMapping(getLEConsents);
            consDataList.add(getLEConsents.consentsData);
        }
        //dataMapping(dataObj);
        //return XC_UTIL_GDPR.createConsentsResults(new List<XC_UTIL_GDPR.CreateConsentsWrapper>{
        //        dataObj.consentsData
        //});
        return XC_UTIL_GDPR.createConsentsResults(consDataList);
    }

    /**
    * @author Palamides Damiano
    * @date Creation 15/10/2019
    * @description createLegalEntities
    * @param data String  serialized GetLegalEntitiesResponse
    * @return String message
    */
    @AuraEnabled
    public static String createLegalEntities(String data) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '§DP' + data);
        GetLegalEntitiesResponse dataObj = (GetLegalEntitiesResponse) JSON.deserialize(data, GetLegalEntitiesResponse.Class);
        dataMapping(dataObj);
        return XC_UTIL_GDPR.createConsents(new List<XC_UTIL_GDPR.CreateConsentsWrapper>{
                dataObj.consentsData
        });
    }

    /**
    * @author Palamides Damiano
    * @date Creation 15/10/2019
    * @description internal dataMapping
    * @param data String  serialized GetLegalEntitiesResponse
    */
    private static void dataMapping(GetLegalEntitiesResponse dataObj){
        mapThirdPartyFields(dataObj);
        mapProfilingFields(dataObj);
        mapMarketingFields(dataObj);
        if(dataObj.isExistingNotCustomer) {
            mapNotCustomerFields(dataObj);
        }
        if(dataObj.isExistingThPartiesMarketing) {
            mapThPartiesMarketing(dataObj);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '§DP--' + dataObj.consentsData);
        dataObj.consentsData.personalInfo.confirmationByTheCustomer = dataObj.confirmationByTheCustomer;
    }

    /**
    * @author Palamides Damiano
    * @date Creation 15/10/2019
    * @description getLegalEntitiesOptions
    * @param recordId String
    * @param objectType String
    * @param sObjectData String
    * @return String message serialized list of LEs
    */
    @AuraEnabled
    public static String getLegalEntitiesOptions(String recordId, String objectType, String sObjectData) {
        Lead theLead = XC_LCC163_CreateConsents_U.getLead(recordId, objectType, sObjectData);
        Account theAccount = XC_LCC163_CreateConsents_U.getAccount(recordId, objectType, sObjectData);
        User u = XC_LCC163_CreateConsents_U.getCurrUser();
        String recordTypeName;
        if(String.isNotBlank(recordId)){
            Id recID = recordId;
            String objTypeName = recID.getSObjectType().getDescribe().getName();
            recordTypeName = XC_UTIL_Sobject.getFieldValue(objTypeName, 'RecordTypeId', recordId);
            //recordTypeName = Schema.getGlobalDescribe().get(objTypeName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        }else{
            Map<String, Object> sObjectDataMap = (Map<String, Object>) JSON.deserializeUntyped(sObjectData);
            recordTypeName = sObjectDataMap.get('RecordTypeId') != null? String.valueOf(sObjectDataMap.get('RecordTypeId')) : '';
        }
        //Map<String, Object> sObjectDataMap = (Map<String, Object>) JSON.deserializeUntyped(sObjectData);
        //String recordTypeName = sObjectDataMap.get('RecordTypeId') != null? String.valueOf(sObjectDataMap.get('RecordTypeId')) : '';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ sObjectData ' + sObjectData);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ recordTypeName ' + recordTypeName);
        String country = theLead!=null? theLead.Country__c : theAccount!=null? theAccount.XC_Country__c : null;
        List<XC_CM_CountryLegalEntityAssociation__mdt> metadataList = XC_LCC163_CreateConsents_U.getLegalEntityConfigurations(u, recordTypeName);
        List<String> ret = XC_UTIL_Sobject.getListFieldValues(metadataList,'XC_LegalEntity__c');
        return JSON.serialize(ret);
    }

    private static GetLegalEntitiesResponse mapThirdPartyFields(GetLegalEntitiesResponse dataObj) {
        dataObj.consentsData.thirdPartiesConsent.consentValue = dataObj.thirdPartyValue;
        dataObj.consentsData.thirdPartiesConsent.consentVersion = dataObj.consentsData.thirdPartiesConsent.consentVersion == null ? dataObj.consentVersion : dataObj.consentsData.thirdPartiesConsent.consentVersion;
        dataObj.consentsData.thirdPartiesConsent.leCollectedConsent = dataObj.legalEntity;
        dataObj.consentsData.thirdPartiesConsent.collectionDate = dataObj.consentsData.thirdPartiesConsent.ConsentCompanyDate == null ? Date.today() : dataObj.consentsData.thirdPartiesConsent.ConsentCompanyDate;
        dataObj.consentsData.thirdPartiesConsent.collectionChannel = 'Internal User';
        dataObj.consentsData.thirdPartiesConsent.consentDescriptionLookup = dataObj.consentDescriptionLookup;
        dataObj.consentsData.thirdPartiesConsent.collectionUser = UserInfo.getUserId();
        return dataObj;
    }

    private static GetLegalEntitiesResponse mapProfilingFields(GetLegalEntitiesResponse dataObj) {
        dataObj.consentsData.profilingConsent.consentValue = dataObj.profilingValue;
        dataObj.consentsData.profilingConsent.consentVersion = dataObj.consentsData.profilingConsent.consentVersion == null ? dataObj.consentVersion : dataObj.consentsData.profilingConsent.consentVersion;
        dataObj.consentsData.profilingConsent.leCollectedConsent = dataObj.legalEntity;
        dataObj.consentsData.profilingConsent.collectionDate = dataObj.consentsData.profilingConsent.ConsentMarketingDate == null ? Date.today() : dataObj.consentsData.profilingConsent.ConsentMarketingDate;
        dataObj.consentsData.profilingConsent.collectionChannel = 'Internal User';
        dataObj.consentsData.profilingConsent.consentDescriptionLookup = dataObj.consentDescriptionLookup;
        dataObj.consentsData.profilingConsent.collectionUser = UserInfo.getUserId();
        return dataObj;
    }

    private static GetLegalEntitiesResponse mapMarketingFields(GetLegalEntitiesResponse dataObj) {
        dataObj.consentsData.marketingConsent.consentValue = dataObj.marketingValue;
        dataObj.consentsData.marketingConsent.consentVersion = dataObj.consentsData.marketingConsent.consentVersion == null ? dataObj.consentVersion : dataObj.consentsData.marketingConsent.consentVersion;
        dataObj.consentsData.marketingConsent.leCollectedConsent = dataObj.legalEntity;
        dataObj.consentsData.marketingConsent.collectionDate = dataObj.consentsData.marketingConsent.ConsentProfilingDate == null ? Date.today() : dataObj.consentsData.marketingConsent.ConsentProfilingDate;
        dataObj.consentsData.marketingConsent.collectionChannel = 'Internal User';
        dataObj.consentsData.marketingConsent.consentDescriptionLookup = dataObj.consentDescriptionLookup;
        dataObj.consentsData.marketingConsent.collectionUser = UserInfo.getUserId();
        return dataObj;
    }

    private static GetLegalEntitiesResponse mapNotCustomerFields(GetLegalEntitiesResponse dataObj) {
        dataObj.consentsData.notCustomerConsent.consentValue = dataObj.notCustomerValue;
        dataObj.consentsData.notCustomerConsent.consentVersion = dataObj.consentsData.notCustomerConsent.consentVersion == null ? dataObj.consentVersion : dataObj.consentsData.notCustomerConsent.consentVersion;
        dataObj.consentsData.notCustomerConsent.leCollectedConsent = dataObj.legalEntity;
        dataObj.consentsData.notCustomerConsent.collectionDate = dataObj.consentsData.notCustomerConsent.ConsentProfilingDate == null ? Date.today() : dataObj.consentsData.notCustomerConsent.ConsentProfilingDate;
        dataObj.consentsData.notCustomerConsent.collectionChannel = 'Internal User';
        dataObj.consentsData.notCustomerConsent.consentDescriptionLookup = dataObj.consentDescriptionLookup;
        dataObj.consentsData.notCustomerConsent.collectionUser = UserInfo.getUserId();
        return dataObj;
    }

    private static GetLegalEntitiesResponse mapThPartiesMarketing(GetLegalEntitiesResponse dataObj) {
        dataObj.consentsData.thPartiesMarketingConsent.consentValue = dataObj.thPartiesMarketingValue;
        dataObj.consentsData.thPartiesMarketingConsent.consentVersion = dataObj.consentsData.thPartiesMarketingConsent.consentVersion == null ? dataObj.consentVersion : dataObj.consentsData.thPartiesMarketingConsent.consentVersion;
        dataObj.consentsData.thPartiesMarketingConsent.leCollectedConsent = dataObj.legalEntity;
        dataObj.consentsData.thPartiesMarketingConsent.collectionDate = dataObj.consentsData.thPartiesMarketingConsent.ConsentProfilingDate == null ? Date.today() : dataObj.consentsData.thPartiesMarketingConsent.ConsentProfilingDate;
        dataObj.consentsData.thPartiesMarketingConsent.collectionChannel = 'Internal User';
        dataObj.consentsData.thPartiesMarketingConsent.consentDescriptionLookup = dataObj.consentDescriptionLookup;
        dataObj.consentsData.thPartiesMarketingConsent.collectionUser = UserInfo.getUserId();
        return dataObj;
    }

    /*private static boolean checkAccessibility(){
        return  Schema.sObjectType.Account.isAccessible() &&
                Schema.sObjectType.Contact.isAccessible() &&
                Schema.sObjectType.Individual.isAccessible();
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 19/05/2021
    * @description Method to retriev consens by country/legal entity/language
    * @param leList - List<String>
    * @return Map<String, XC_ConsentDescription__c> - key:Country§LegalEntity/values:Consent Description
    */
    private static Map<String, XC_ConsentDescription__c> getConsentDescriptionsByCurrentUser(List<String> leList) {
        leList.addAll(XC_UTIL_User.getLegalEntitiesFromUser());
        String currentLanguageLabel = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0].LanguageLocaleKey;
        List<XC_CM_CountryLegalEntityAssociation__mdt> retList4Group = new List<XC_CM_CountryLegalEntityAssociation__mdt>([
            SELECT Id, DeveloperName, Label, XC_LegalEntity__c, XC_Country__c, XC_LegalEntityGroup__c
            FROM XC_CM_CountryLegalEntityAssociation__mdt
            WHERE XC_LegalEntity__c IN :leList
        ]);
        List<XC_CM_CountryLegalEntityAssociation__mdt> leListAll = new List<XC_CM_CountryLegalEntityAssociation__mdt>([
            SELECT Id, DeveloperName, Label, XC_LegalEntity__c, XC_Country__c, XC_LegalEntityGroup__c
            FROM XC_CM_CountryLegalEntityAssociation__mdt
            WHERE XC_LegalEntityGroup__c IN :XC_UTIL_Sobject.getListFieldValues(retList4Group,'XC_LegalEntityGroup__c')
        ]);
        List<XC_ConsentDescription__c> allDescr = new List<XC_ConsentDescription__c>([
            SELECT Id, XC_ConsentVersion__c, XC_DescriptionGiveDataToLE__c, XC_LegalEntity__c, XC_Country__c, XC_ConsentStatus__c, XC_DescriptionNotCustomer__c, XC_DescriptionThirdProductsMarketing__c, XC_DescriptionMarketing__c, XC_DescriptionProfiling__c, XC_DescriptionThirdParties__c
            FROM XC_ConsentDescription__c
            WHERE XC_DescriptionLanguage__c = :currentLanguageLabel AND XC_ParentDescription__c = null AND XC_LegalEntity__c in :XC_UTIL_Sobject.getListFieldValues(leListAll,'XC_LegalEntity__c')
        ]);       
        Map<String, XC_ConsentDescription__c> mapResult = new Map<String, XC_ConsentDescription__c>();
        for(XC_ConsentDescription__c descr : allDescr) {
            mapResult.put(descr.Id,descr);
        }
        return mapResult;
    }

}