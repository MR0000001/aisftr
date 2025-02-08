/**
 * @description       : 
 * @author            : Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @group             : 
 * @last modified on  : 09-06-2021
 * @last modified by  : Eleni Tsiolaki - etsiolaki@deloitte.gr
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   05-05-2021   Eleni Tsiolaki - etsiolaki@deloitte.gr   Initial Version
**/
public with sharing class XC_LCC253_DelegatedSignatureButton {

    /**
     * @description Document Wrapper
     */
    public class XC_FieldSetInput {
        public String prefix;
        public String name;
        public String relatedObject;
        public String segment;
    }
    
    /**
    * @description Initializing the whole component about accountId ,secondaryContacts ,primaryContactsDocument, 
                                                          personalDocumentFieldSet,personalPrimaryDocumentFieldSet
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param orderId String 
    * @return XC_UTIL_ResultWrapper
    **/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper initializeComponent(String orderId) {
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();

        Map<String,Object> resultData = new Map<String,Object>();
        Id idObj = Id.valueOf(orderId);
        Map<Id,NE__Order__c> orderInfoMap = XC_LCC253_DelegatedSignatureButton_D.retrieveInfoFromOrder(new Set<Id>{idObj});
        result.success = true;
        
        String accountId = orderInfoMap.get(idObj).NE__AccountId__c;
        String contactFromOpportunity = orderInfoMap.get(idObj).NE__OptyId__r.XC_Contact__c;
        resultData.put('accountId', accountId); 
        resultData.put('contactFromOpportunity', contactFromOpportunity);

        List<Map<String,String>> secondaryContacts = XC_LCC253_DelegatedSignatureButton_D.retrieveSecondaryContacts(accountId);
        List<Map<String,String>> primaryContactsDocument = XC_LCC253_DelegatedSignatureButton_D.retrievePrimaryContactsDocument(accountId);

        resultData.put('secondaryContacts', secondaryContacts); 
        resultData.put('primaryContactsDocument', primaryContactsDocument);

        //Taking The Field Set for XC_PersonalDocument__c 
        XC_FieldSetInput fsDocInput = new XC_FieldSetInput();
        fsDocInput.prefix = 'XC_ITA_';
        fsDocInput.name = 'PersonalDocument';
        fsDocInput.relatedObject = 'XC_PersonalDocument__c';

        List<XC_UTIL_FieldSet.FieldWrapper> personalDocumentFieldSet = retrieveFieldsFromFieldSet(fsDocInput);
        if(!personalDocumentFieldSet.isEmpty()){
            resultData.put('personalDocumentFieldSet', personalDocumentFieldSet);
            
            List<String> fieldNames = new List<String>();
            for(XC_UTIL_FieldSet.FieldWrapper f : personalDocumentFieldSet) {
                fieldNames.add(f.fieldName);
            }
            resultData.put('personalDocumentFieldNames', fieldNames);
        }

        XC_FieldSetInput a = new XC_FieldSetInput();
        a.prefix = 'XC_ITA_';
        a.name = 'PersonalDocument';
        a.relatedObject = 'XC_PersonalDocument__c';

        List<XC_UTIL_FieldSet.FieldWrapper> personalPrimaryDocumentFieldSet = retrieveFieldsFromFieldSet(a);
        if(!personalPrimaryDocumentFieldSet.isEmpty()){
            resultData.put('personalPrimaryDocumentFieldSet', personalPrimaryDocumentFieldSet);
            List<String> fieldNames = new List<String>();
            for(XC_UTIL_FieldSet.FieldWrapper f : personalPrimaryDocumentFieldSet) {
                fieldNames.add(f.fieldName);
            }
            resultData.put('personalPrimaryDocumentFieldNames', fieldNames);
        }

        result.objectInfo = JSON.serialize(resultData);
        return result;
    }
   
    /**
    * @description Getting the Secondary contact doccuments from retrieveSecondaryContactDocument in spesific data structure
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param secondaryContactId String 
    * @return XC_UTIL_ResultWrapper 
    **/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getSecondaryContactDocument(String secondaryContactId) {
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        Map<String,Object> resultData = new Map<String,Object>();
        
        List<Map<String,String>> secondaryContactDocuments = XC_LCC253_DelegatedSignatureButton_D.retrieveSecondaryContactDocument(secondaryContactId);
        resultData.put('secondaryContactDocuments', secondaryContactDocuments); 
        result.objectInfo = JSON.serialize(resultData);
        return result;
    }


    /*
     * @description retrieveFieldsFromFieldSet
     * ────────────────────────────────────────────────────────────────────────────────────────────────────
     * @param fsInput
     * @return List<XC_UTIL_FieldSet.FieldWrapper>, empty if the fieldset there isn't
     */
    private static List<XC_UTIL_FieldSet.FieldWrapper> retrieveFieldsFromFieldSet(XC_FieldSetInput fsInput) {
        XC_CM_CountryLegalEntityAssociation__mdt userLE = XC_UTIL_User.getLegalEntityMetadataFromUser();
        String countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
        String userLEStream = fsInput.segment;
        String fieldSetKey = fsInput.prefix + fsInput.name; 
        System.debug('retrieveFieldsFromFieldSet' + fieldSetKey);
        List<XC_UTIL_FieldSet.FieldWrapper> fieldFromFieldSet = XC_UTIL_FieldSet.getFieldSetFields(fieldSetKey, fsInput.relatedObject);
        System.debug('retrieveFieldsFromFieldSet' + fieldFromFieldSet);
        return fieldFromFieldSet;
    }

    /**
    * @description updateOrder
    * @param paramsMap input Map<String,Object>
    * @return XC_UTIL_Sobject.WrapperResult 
    **/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updateOrder(Map<String,Object> paramsMap){
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        Id idObj = String.valueOf(paramsMap.get('recordId'));
        String secondaryContact = String.valueOf(paramsMap.get('secondaryContact'));
        String relationshipType = String.valueOf(paramsMap.get('relationshipType'));
        String primaryContactDocumentId = String.valueOf(paramsMap.get('primaryContactDocumentId'));
        String secondaryContactDocumentId = String.valueOf(paramsMap.get('secondaryContactDocumentId'));

        Map<Id,NE__Order__c> orderMap = XC_LCC253_DelegatedSignatureButton_D.retrieveInfoFromOrder(new Set<Id>{idObj});
        NE__Order__c orderToBeUpdated = orderMap.get(idObj);
        orderToBeUpdated.XC_DelegatedContact__c = secondaryContact;
        orderToBeUpdated.XC_SecondaryContactRelationshipType__c = relationshipType;
        orderToBeUpdated.XC_DelegatedSignature__c = true;
        orderToBeUpdated.XC_DelegatedPersonalDocument__c = secondaryContactDocumentId;
        orderToBeUpdated.XC_ContactPersonalDocument__c = primaryContactDocumentId;
        
        List<XC_UTIL_Sobject.WrapperResult> updateResult = XC_UTIL_DML.updateRecords(new List<Sobject>{orderToBeUpdated});
        if(!updateResult[0].success) {
            result.success = false;
            result.resultMessage = updateResult[0].errorMessage;
        }
        result.success = true;
        return result;   
    }

}