/**
 *@author Francesco Imperioli - fimperioli@deloitte.it
 *@Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com - 27/10/2020
 *@description XC_LCC171_LEConsentDescriptionDetail - Apex controller for LCP171 used to view detailed description for consents
 */

public without sharing class XC_LCC171_LEConsentDescriptionDetail {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC171_LEConsentDescriptionDetail');

    /**
      *@author Francesco Imperioli fimperioli@deloitte.it
      *@date creation 22-11-2019
      *@description Custom wrapper class for fieldset member
      **/
    public class FieldWrapper {
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public String fieldLabel {get;set;}
        @AuraEnabled public String helpText {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}
        @AuraEnabled public Boolean isHtmlFormatted {get;set;}
        @AuraEnabled public Boolean isIndividual {get;set;}
        @AuraEnabled public String urlConsens {get;set;}
    }

    /**
    * @author francesco imperioli - fimperioli@deloitte.it
    * @description Retrieves data about description and consent fields FOR LE CONSENT RECORD
    * @param leConsentId - String
    * @return List<FieldWrapper>
    */
    @AuraEnabled
    public static List<FieldWrapper> getConsentsDescriptionInfo(String leConsentId) {
        XC_LegalEntityConsent__c currentConsent = [
            SELECT Id, XC_ConsentDescription__c, XC_ProfilingConsent__c, XC_Individual__c, XC_Individual__r.XC_GiveDataToThirdParties__c 
            FROM XC_LegalEntityConsent__c 
            WHERE Id = :leConsentId 
            LIMIT 1
        ];
        String descriptionId = currentConsent.XC_ConsentDescription__c;
        List<XC_ConsentDescription__c> consentDescriptions = new List<XC_ConsentDescription__c>([
            SELECT Id, XC_ConsentVersion__c, XC_LegalEntity__c, XC_Country__c, XC_ConsentStatus__c, XC_DescriptionMarketing__c, XC_DescriptionProfiling__c, XC_DescriptionThirdParties__c, XC_DescriptionGiveDataToLE__c, XC_DescriptionLanguage__c, XC_ParentDescription__c, XC_PrivacyConsentUrl__c, XC_DescriptionNotCustomer__c, XC_DescriptionThirdProductsMarketing__c
            FROM XC_ConsentDescription__c 
            WHERE Id = :descriptionId AND XC_ParentDescription__c = NULL 
            LIMIT 1
        ]);
        Map<String, Object> mapConsentDescription = consentDescriptions[0].getPopulatedFieldsAsMap();

        // Getting fields that has to be shown from fieldsets
        List<FieldWrapper> fields = getFields('XC_FS_LEDescriptionFields', 'XC_LegalEntityConsent__c', mapConsentDescription);
        if(String.isBlank(descriptionId)){
            return fields;
        }        

        if(!consentDescriptions.isEmpty()) {
            Id currentUserId = userInfo.getUserId();
            String currentLanguageLabel = [SELECT LanguageLocaleKey FROM User WHERE Id = :currentUserId LIMIT 1][0].LanguageLocaleKey;
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'CURRENT USER LANGUAGE ' + currentLanguageLabel);
            XC_ConsentDescription__c descr = consentDescriptions[0];
            List<XC_CM_LeDescrFieldMapping__mdt> fieldMappings = [
                SELECT DeveloperName, XC_LEConsentField__c, XC_LEDescriptionField__c, XC_ConsentCategory__c, XC_IsIndividual__c 
                FROM XC_CM_LeDescrFieldMapping__mdt
            ];
            
            if(!fieldMappings.isEmpty()) {
                // Mapping fields:
                XC_ConsentDescription__c translationToUse = descr;
                if(currentLanguageLabel != translationToUse.XC_DescriptionLanguage__c) {
                    List<XC_ConsentDescription__c> consentDescriptionsTranslated = new List<XC_ConsentDescription__c>([
                        SELECT Id, XC_ConsentVersion__c, XC_LegalEntity__c, XC_Country__c, XC_ConsentStatus__c, XC_DescriptionMarketing__c, XC_DescriptionProfiling__c, XC_DescriptionThirdParties__c, XC_DescriptionGiveDataToLE__c, XC_DescriptionLanguage__c, XC_ParentDescription__c, XC_PrivacyConsentUrl__c, XC_DescriptionNotCustomer__c, XC_DescriptionThirdProductsMarketing__c
                        FROM XC_ConsentDescription__c 
                        WHERE XC_DescriptionLanguage__c = :currentLanguageLabel AND XC_ConsentVersion__c = :translationToUse.XC_ConsentVersion__c AND XC_LegalEntity__c = :translationToUse.XC_LegalEntity__c AND XC_Country__c = :translationToUse.XC_Country__c AND XC_ConsentStatus__c = :translationToUse.XC_ConsentStatus__c
                        LIMIT 1
                    ]);
                    if(!consentDescriptionsTranslated.isEmpty()) {
                        translationToUse = consentDescriptionsTranslated[0];
                    }
                }
                /*if(!descr.DescriptionTranslations__r.isEmpty()){
                    for(XC_ConsentDescription__c childDescr : descr.DescriptionTranslations__r){
                        if(childDescr.XC_DescriptionLanguage__c==currentLanguageLabel){
                            translationToUse = childDescr;
                        }
                    }
                }*/
                Map<String, XC_CM_LeDescrFieldMapping__mdt> fieldMappingValueMap = new Map<String, XC_CM_LeDescrFieldMapping__mdt>();
                for(XC_CM_LeDescrFieldMapping__mdt mapping : fieldMappings) {
                    fieldMappingValueMap.put(mapping.XC_LEConsentField__c,mapping);
                }
                for(FieldWrapper fw : fields) {
                    if(fieldMappingValueMap.containsKey(fw.fieldName)){
                        XC_CM_LeDescrFieldMapping__mdt singleMapping = fieldMappingValueMap.get(fw.fieldName);
                        //fw.helpText = fw.fieldLabel;
                        fw.fieldLabel = String.valueOf(translationToUse.get(singleMapping.XC_LEDescriptionField__c));
                        fw.helpText = singleMapping.XC_ConsentCategory__c;
                        fw.urlConsens = String.isNotBlank(descr.XC_PrivacyConsentUrl__c) ? descr.XC_PrivacyConsentUrl__c : null;
                    }
                }
            }
        }
        return fields;
    }

    /**
      *@author Salvatore Agrillo - salvatore.agrillo@nttdata.com
      *@date creation 28-10-2020
      *@description Method to get fields from fieldSet with check in Consent Description
      *@param fieldSetName - String
      *@param sObjectType - String
      *@param mapConsentDescription - Map<String, Object>
      *@return List<FieldWrapper> 
      **/
      @AuraEnabled
      public static List<FieldWrapper> getFields(String fieldSetName, String sObjectType, Map<String, Object> mapConsentDescription){
          return getFieldSetFields(fieldSetName, sObjectType, mapConsentDescription);
      }

    /**
      *@author Francesco Imperioli - fimperioli@deloitte.it
      *@date creation 22-11-2019
      *@description Method to get fields from fieldSet
      **/
    @AuraEnabled
    public static List<FieldWrapper> getFields(String fieldSetName, String sObjectType){
        return getFieldSetFields(fieldSetName, sObjectType, new Map<String, Object>());
    }

    /**
      *@author Francesco Imperioli fimperioli@deloitte.it
      *@date creation 21-11-2019
      *@mod 28-10-2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
      *@description Maps fieldset members to custom wrapper class
      **/
    private static List<FieldWrapper> getFieldSetFields(String fieldSetName, String sObjectName, Map<String, Object> mapConsentDescription){
        List<FieldWrapper> result = new List<FieldWrapper>();
        if(String.isNotBlank(fieldSetName) && String.isNotBlank(sObjectName)) {
            Schema.DescribeSObjectResult desResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
            Map<String,Schema.SObjectField> objFieldMap = desResult.fields.getMap();
            Schema.FieldSet fieldSetObj = desResult.FieldSets.getMap().get(fieldSetName);
            if(fieldSetObj!=null){
                for(Schema.FieldSetMember fsm : fieldSetObj.getFields()) {
                    // Check for optional consent (NotCustomer & ThirdProductsMarketing):
                    String fieldApi = String.valueOf(fsm.getFieldPath());
                    Map<String, String> mapFieldApiToCheck = new Map<String, String>{
                        'XC_NotCustomerConsent__c' => 'XC_DescriptionNotCustomer__c',
                        'XC_ThirdProductsMarketingConsent__c' => 'XC_DescriptionThirdProductsMarketing__c'
                    };
                    Boolean checkOptionalConsent = !mapFieldApiToCheck.keySet().contains(fieldApi) || (mapFieldApiToCheck.keySet().contains(fieldApi) && mapConsentDescription.containsKey(mapFieldApiToCheck.get(fieldApi)) && String.isNotBlank((String) mapConsentDescription.get(mapFieldApiToCheck.get(fieldApi))));
                    if(mapConsentDescription.keySet().isEmpty() || (!mapConsentDescription.keySet().isEmpty() && checkOptionalConsent)) {
                        // If true -> Consent to manage:
                        FieldWrapper fw = new FieldWrapper();
                        fw.fieldLabel = String.valueOf(fsm.getLabel());
                        fw.fieldName = fieldApi;
                        fw.isRequired = fsm.getRequired() || fsm.getDbRequired();
                        fw.helpText = objFieldMap.get(fieldApi).getDescribe().getInlineHelpText();
                        fw.isHtmlFormatted = objFieldMap.get(fieldApi).getDescribe().isHtmlFormatted() && objFieldMap.get(fieldApi).getDescribe().isCalculated(); 
                        result.add(fw);
                    }
                }
            }
        }
        return result;
    }

    /**
      *@author Francesco Imperioli - fimperioli@deloitte.it
      *@date 29-11-2019
      *@description Init the description field for the Individual Object
      **/
    @AuraEnabled
    public static String getConsentDescriptionInfoIndividual(String descriptionId){
        Map<String,Object> result= new Map<String,Object>();
        Id currentUserId = userInfo.getUserId();
        String currentLanguageLabel = [SELECT LanguageLocaleKey FROM User WHERE ID = :currentUserId LIMIT 1][0].LanguageLocaleKey;
        String currentUserLegalEntity = XC_UTIL_User.getLegalEntityFromUser();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ CURRENT LANGUAGE: ' + currentLanguageLabel);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ LEGAL ENTITY: ' + currentUserLegalEntity);        
        List<XC_CM_LeDescrFieldMapping__mdt> fieldMappings = [
            SELECT DeveloperName, XC_LEConsentField__c, XC_LEDescriptionField__c, XC_ConsentCategory__c, XC_IsIndividual__c 
            FROM XC_CM_LeDescrFieldMapping__mdt 
            WHERE XC_IsIndividual__c = true
        ];
        List<XC_ConsentDescription__c> consentDescriptions = [
            SELECT Id, XC_ConsentStatus__c,XC_Country__c,XC_ConsentVersion__c,XC_LegalEntity__c, XC_DescriptionGiveDataToLE__c, XC_DescriptionMarketing__c, XC_DescriptionProfiling__c, XC_DescriptionThirdParties__c, XC_DescriptionLanguage__c
            FROM XC_ConsentDescription__c 
            WHERE XC_LegalEntity__c = :currentUserLegalEntity AND XC_ParentDescription__c = NULL AND Id = :descriptionId  
            LIMIT 1
        ];
        
        if(consentDescriptions.isEmpty()) {
            return JSON.serialize(result);
        }
        XC_ConsentDescription__c descr = consentDescriptions[0];
        // Mapping fields:
        XC_ConsentDescription__c translationToUse = descr;
        if(currentLanguageLabel != translationToUse.XC_DescriptionLanguage__c) {
            List<XC_ConsentDescription__c> consentDescriptionsTranslated = new List<XC_ConsentDescription__c>([
                SELECT Id, XC_ConsentVersion__c, XC_LegalEntity__c, XC_Country__c, XC_ConsentStatus__c, XC_DescriptionMarketing__c, XC_DescriptionProfiling__c, XC_DescriptionThirdParties__c, XC_DescriptionGiveDataToLE__c, XC_DescriptionLanguage__c, XC_ParentDescription__c, XC_PrivacyConsentUrl__c, XC_DescriptionNotCustomer__c, XC_DescriptionThirdProductsMarketing__c
                FROM XC_ConsentDescription__c 
                WHERE XC_DescriptionLanguage__c = :currentLanguageLabel AND XC_ConsentVersion__c = :translationToUse.XC_ConsentVersion__c AND XC_LegalEntity__c = :translationToUse.XC_LegalEntity__c AND XC_Country__c = :translationToUse.XC_Country__c AND XC_ConsentStatus__c = :translationToUse.XC_ConsentStatus__c
                LIMIT 1
            ]);
            if(!consentDescriptionsTranslated.isEmpty()) {
                translationToUse = consentDescriptionsTranslated[0];
            }
        }
        /*if(!descr.DescriptionTranslations__r.isEmpty()){
            for(XC_ConsentDescription__c childDescr : descr.DescriptionTranslations__r){
                if(childDescr.XC_DescriptionLanguage__c==currentLanguageLabel){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, ':::TRANSLATIONS FOUND:::');
                    translationToUse = childDescr;
                }
            }
        }*/
        //'XC_GiveDataToThirdParties__c'
        for(XC_CM_LeDescrFieldMapping__mdt fieldMapping : fieldMappings){
            if(fieldMapping.XC_LEConsentField__c=='XC_GiveDataToThirdParties__c') {
                result.put('fieldName','XC_GiveDataToThirdParties__c');
                result.put('fieldLabel',translationToUse.get(fieldMapping.XC_LEDescriptionField__c));
                result.put('category', fieldMapping.XC_ConsentCategory__c);
            }
        }
        return JSON.serialize(result);
    }

}