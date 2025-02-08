/**
 * The Class XC_TR_PersonalDoc_U_CaringManagement.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 09/10/2019
 * @date Modification : 
 * @description       : Class that manages case caring
 **/
 
public without sharing class XC_TR_PersonalDoc_U_CaringManagement {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_PersonalDocument_Handler');

    /** 
     * ManageCaseCreation.
     *
     * @description Method to manage the case creation.
     * @param listNew - List<XC_PersonalDocument__c>
     * @param mapOld - Map<Id,XC_PersonalDocument__c> 
     * @param mapNew - Map<Id,XC_PersonalDocument__c> 
     */
    public static void manageCaseCreation(List<XC_PersonalDocument__c> listNew, Map<Id, XC_PersonalDocument__c> mapOld, Map<Id, XC_PersonalDocument__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_Country__c', 'XC_DocumentNumber__c', 'XC_DocumentType__c', 'XC_ExpirationDate__c', 'XC_ReleaseDate__c'};
        List<XC_PersonalDocument__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }

        List<String> caseSettingNames = new List<String>{Label.XC_CL_PersonalInfoChangeWithoutAuth , Label.XC_CL_PersonalInfoChangeWithAuth};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        //Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA).getRecordTypeId();
        List<Id> contactIds = XC_UTIL_Sobject.getListFieldValues(listChanged, 'XC_Contact__c');
        List<Case> existingCases = XC_TR_Contact_U_CaringManagement.retriveExistingCasesFromContacts(contactIds, caseSettingsMap.get(Label.XC_CL_PersonalInfoChangeWithAuth)); //, caseRecordTypeId

        List<Case> listCaseToUpsert = new List<Case>();        
        for(XC_PersonalDocument__c newdoc : listChanged){
            if(newDoc.XC_MainDocument__c) {

                XC_PersonalDocument__c oldDoc = mapOld.get(newdoc.Id);
                XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_PersonalInfoChangeWithoutAuth);
                    
                Map<String, Object> parameters = new Map<String, Object>{'contactId' => newdoc.XC_Contact__c,
                                                                        'existingCases' => existingCases,
                                                                        'settingCaseWithAuth' => (caseSettingsMap.get(Label.XC_CL_PersonalInfoChangeWithAuth))
                                                                        };

                if(!XC_TR_Contact_U_CaringManagement.searchExistingCase(listCaseToUpsert, parameters)) {
                    Case caseContact = populateCaseFields(caseSettings, newdoc, oldDoc);
                    listCaseToUpsert.add(caseContact);
                }

                XC_TR_Contact_U_CaringManagement.callZuora(newdoc.XC_Contact__c);
            }
        }

        List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_Sobject.upsertListRecords(listCaseToUpsert);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_PersonalDoc_U_CaringManagement.manageCaseCreation - upsert results='+results);
    }


    /** 
    * @description Populate Case Fields
    * @param caseSettings
    * @param newContact
    * @param oldContact
    * @return Case
    */
    private static Case populateCaseFields(XC_CM_Case_Type_Setting__mdt caseSettings, XC_PersonalDocument__c newdoc, XC_PersonalDocument__c oldDoc){
        Case newCase = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
        //Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA).getRecordTypeId();
        //newCase.RecordTypeId = caseRecordTypeId;
        //newCase.Reason = caseSettings.XC_Case_Reason__c;
        //newCase.Subcause__c = caseSettings.XC_Sub_Cause__c;
        //newCase.Origin = caseSettings.XC_Origin__c;
        //newCase.XC_Subtype__c = caseSettings.XC_Sub_Type__c;
        //newCase.Priority = caseSettings.XC_Priority__c;
        //newCase.Status = caseSettings.XC_Status__c;
        newCase.AccountId = newdoc.XC_Account__c;
        newCase.ContactId = newdoc.XC_Contact__c;
        
        String remarksContent = populateRemarks(newDoc, oldDoc);
        if(!String.isEmpty(remarksContent)){
            newCase.CaseRemarks__c = remarksContent;
        }
        return newCase;
    }


    /** 
    * @description Populate Remarks
    * @param newdoc the new document
    * @param oldDoc the old document
    * @return String
    */
    private static String populateRemarks(XC_PersonalDocument__c newdoc, XC_PersonalDocument__c oldDoc){
        String remarksContent = '';
        XC_AT_Utils.RemarkMessageWrapper remarkWrapper = new XC_AT_Utils.RemarkMessageWrapper();
        if(newdoc.XC_Country__c != oldDoc.XC_Country__c) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.XC_PersonalDocument__c.fields.XC_Country__c.getDescribe();
            remarkWrapper.newValue = newdoc.XC_Country__c;
            remarkWrapper.oldValue = oldDoc.XC_Country__c;
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        if(newdoc.XC_DocumentNumber__c != oldDoc.XC_DocumentNumber__c) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.XC_PersonalDocument__c.fields.XC_DocumentNumber__c.getDescribe();
            remarkWrapper.newValue = newdoc.XC_DocumentNumber__c;
            remarkWrapper.oldValue = oldDoc.XC_DocumentNumber__c;
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        if(newdoc.XC_DocumentType__c != oldDoc.XC_DocumentType__c) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.XC_PersonalDocument__c.fields.XC_DocumentType__c.getDescribe();
            remarkWrapper.newValue = newdoc.XC_DocumentType__c;
            remarkWrapper.oldValue = oldDoc.XC_DocumentType__c;
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        if(newdoc.XC_ExpirationDate__c != oldDoc.XC_ExpirationDate__c ) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.XC_PersonalDocument__c.fields.XC_ExpirationDate__c.getDescribe();
            remarkWrapper.newValue = String.valueOf(newdoc.XC_ExpirationDate__c);
            remarkWrapper.oldValue = String.valueOf(oldDoc.XC_ExpirationDate__c);
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        if(newdoc.XC_ReleaseDate__c != oldDoc.XC_ReleaseDate__c ) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.XC_PersonalDocument__c.fields.XC_ReleaseDate__c.getDescribe();
            remarkWrapper.newValue = String.valueOf(newdoc.XC_ReleaseDate__c);
            remarkWrapper.oldValue = String.valueOf(oldDoc.XC_ReleaseDate__c);
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }

        return remarksContent;
    }



}