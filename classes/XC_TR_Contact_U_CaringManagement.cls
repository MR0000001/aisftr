/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 18/01/2019
 * @date Modification 23/01/2019  Monica Cutillo - monica.cutillo@nttdata.com - Review for ESCEP-450-451 targets
 * @description XC_TR_Contact_U_CaringManagement – Class that manages case caring
 */

public without sharing class XC_TR_Contact_U_CaringManagement {

    /**
     * @description SearchCaseWrapper Class
     */
    public class SearchCaseWrapper {
        Boolean found = false;
        Case caso;
    }

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Contact_U_CaringManagement');
    
    /**
    *@name             checkOneOrgCountry
    *@description      method wich replaces "Casos Emergencias" node from  process bulder  "ATC Contacts Prcess" 
    *@param            contactList
    *@param            oldContactMap
    *@param            newContactMap
    *@author           VBV
    *@email            vbarquero@deloitte.es
    *@lastChange       Federico Amici - federico.amici@nttdata.com, [18/01/2019], Former @name: "allwaysAfter". Code review to fulfill X-Customer pattern
    *@otherLastChange  Monica Cutillo - monica.cutillo@nttdata.com, [23/01/2019], review for ESCEP-450-451 targets
    **/
    public static void manageCaseCreation(List<Contact> contactList, Map<ID, Contact> oldContactMap, Map<ID, Contact> newContactMap){
        List<String> listFieldsChanged = new List<String>{'XC_ChangeApproved__c', 'Phone', 'Name', 'MobilePhone', 'XC_HourToBeRecontacted__c',
                                                            'LastName', 'FirstName', 'XC_Nationality__c', 'XC_Preferredlanguageofcontact__c',
                                                            'Email'};
        List<Contact> listContactChanged = XC_UTIL_Sobject.getListChanged(listFieldsChanged, oldContactMap, newContactMap);
 
        if(listContactChanged.isEmpty()) {
            return;
        }
        //Retrive metadata records tu use. Add others in caseSettingNames when it needs.
        List<String> caseSettingNames = new List<String>{Label.XC_CL_PersonalInfoChangeWithoutAuth , Label.XC_CL_PersonalInfoChangeWithAuth};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        //Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA).getRecordTypeId();
        List<Case> existingCases = retriveExistingCasesFromContacts(XC_UTIL_Sobject.getIds(listContactChanged), caseSettingsMap.get(Label.XC_CL_PersonalInfoChangeWithAuth)); //, caseRecordTypeId
        
        List<Case> listCaseToUpsert = new List<Case>();        
        for(Contact newContact : listContactChanged){
            Contact oldContact = oldContactMap.get(newContact.Id);  

            if(XC_TR_Contact_U_CaringManagementCond.checkCond2(newContact, oldContact)) {
                
                /* NM LR - REVIEW CODE ESCEP-1994/1995/1997 */
                XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_PersonalInfoChangeWithoutAuth);
                Map<string,boolean> newMap=XC_TR_Contact_U_CaringManagementCond.checkCond5(newContact,oldContact);//NA
                Map<String, Object> parameters = new Map<String, Object>{'contactId' => newContact.Id,
                                                                        'existingCases' => existingCases,
                                                                        'settingCaseWithAuth' => (caseSettingsMap.get(Label.XC_CL_PersonalInfoChangeWithAuth)),
                                                                        'dataWithAuthChanges' => (newMap.get(newContact.id))
                                                                        };

                //if(!searchExistingCase(listCaseToUpsert, parameters)) {
                SearchCaseWrapper searchRes = searchAndGetExistingCase(listCaseToUpsert, parameters); /* ESCEP-2327 MC 30122019 */
               system.debug('searchRes.found'+' '+searchRes.found);
                if(!searchRes.found) {
                    Case caseContact = populateCaseFields(caseSettings, newContact, oldContact);
                    listCaseToUpsert.add(caseContact);
                } else {
                    searchRes.caso.CaseRemarks__c = populateRemarks(newContact, oldContact);
                }

                if(XC_TR_Contact_U_CaringManagementCond.checkCondZuora(newContact, oldContact)) {
                    callZuora(newContact.Id);
                }
                
                /* MCutillo - REVIEW CODE ESCEP-450/451 
                XC_CM_Case_Type_Setting__mdt caseSettings = null;
                if(XC_TR_Contact_U_CaringManagementCond.checkCond3(newContact,oldContact) ){

                        caseSettings = caseSettingsMap.get(Label.XC_CL_PersonalInfoChangeWithoutAuth);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ caseSettings='+caseSettings); 
                } else if (newContact.FirstName != oldContact.FirstName
                            || newContact.LastName != oldContact.LastName
                            || newContact.Email != oldContact.Email){
                        caseSettings = caseSettingsMap.get(Label.XC_CL_PersonalInfoChangeWithAuth);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ caseSettings='+caseSettings);
                }

                if(caseSettings != null){
                    caseContact = populateCaseFields(caseSettings, newContact, oldContact);
                } else {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName = '+Label.XC_CL_PersonalInfoChangeWithoutAuth+' and '+Label.XC_CL_PersonalInfoChangeWithAuth);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Case NOT created for Contact changes!');
                    return;
                }/* MCutillo - REVIEW CODE ESCEP-450/451 */

                /* ESCEP 450 fix - MCutillo 04/01/2049
                System.debug('??TEST-CASES'+ existingCases);
                searchExistingCase(caseContact, existingCases, caseSettingsMap.get(Label.XC_CL_PersonalInfoChangeWithAuth)); */
            }
        } 
        List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_Sobject.upsertListRecords(listCaseToUpsert);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Contact_U_CaringManagement.manageCaseCreation - upsert results='+results);
    }


    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param listCaseToUpsert the case List to upsert
     * @param parameters the parameters map
     * @description     Search if a Case exixts with equals Reason, Subcause__c and SubType and Contact not close or cancelled.
     *                  If it exists, it wull be closed.
     * @return result serach wrapper
     */
    private static SearchCaseWrapper searchAndGetExistingCase(List<Case> listCaseToUpsert, Map<String, Object> parameters) {
        SearchCaseWrapper resW = new SearchCaseWrapper();
        List<Case> existingCases = (List<Case>) parameters.get('existingCases');
        String contactId = (String) parameters.get('contactId');
        boolean dataWithAuthChanges=(boolean) parameters.get('dataWithAuthChanges');//NA
        XC_CM_Case_Type_Setting__mdt settingCaseWithAuth = (XC_CM_Case_Type_Setting__mdt) parameters.get('settingCaseWithAuth');

        for(Case caseObj: existingCases){
            if(dataWithAuthChanges && XC_TR_Contact_U_CaringManagementCond.checkCond4(contactId, caseObj, settingCaseWithAuth)) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ XC_TR_Contact_U_CaringManagement searchAndGetExistingCase - found existing case = ' + caseObj);
                caseObj.Status = settingCaseWithAuth.XC_Status__c;
                listCaseToUpsert.add(caseObj);
                resW.found = true;
                resW.caso = caseObj;
                return resW;
            }
        }

        return resW;
    }


    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param listCaseToUpsert the case List to upsert
     * @param parameters the parameters map
     * @description     Search if a Case exixts with equals Reason, Subcause__c and SubType and Contact not close or cancelled.
     *                  If it exists, it wull be closed.
     */
    public static Boolean searchExistingCase(List<Case> listCaseToUpsert, Map<String, Object> parameters) {

        List<Case> existingCases = (List<Case>) parameters.get('existingCases');
        String contactId = (String) parameters.get('contactId');
        XC_CM_Case_Type_Setting__mdt settingCaseWithAuth = (XC_CM_Case_Type_Setting__mdt) parameters.get('settingCaseWithAuth');

        for(Case caseObj: existingCases){
            if(XC_TR_Contact_U_CaringManagementCond.checkCond4(contactId, caseObj, settingCaseWithAuth)) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ XC_TR_Contact_U_CaringManagement searchExistingCase - found existing case = ' + caseObj);
                caseObj.Status = settingCaseWithAuth.XC_Status__c;
                listCaseToUpsert.add(caseObj);
                return true;
            }
        }

        return false;
    }


    /** 
    * @description Populate Case Fields
    * @param caseSettings
    * @param newContact
    * @param oldContact
    * @return Case
    */
    private static Case populateCaseFields(XC_CM_Case_Type_Setting__mdt caseSettings, Contact newContact, Contact oldContact){
        Case caseContact = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
        //Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA).getRecordTypeId();
        //caseContact.RecordTypeId = caseRecordTypeId;
        //caseContact.Reason = caseSettings.XC_Case_Reason__c;
        //caseContact.Subcause__c = caseSettings.XC_Sub_Cause__c;
        //caseContact.XC_Subtype__c = caseSettings.XC_Sub_Type__c;
        //caseContact.Priority = caseSettings.XC_Priority__c;
        //caseContact.Status = caseSettings.XC_Status__c;
        //caseContact.Origin = caseSettings.XC_Origin__c;
        if (newContact.AccountId!=null) {
            caseContact.AccountId =  newContact.AccountId;
        } 
        caseContact.ContactId =  newContact.Id; 
        
        String remarksContent = populateRemarks(newContact, oldContact);
        if(!String.isEmpty(remarksContent)){
            caseContact.CaseRemarks__c = remarksContent;
        }
        return caseContact;
    }


    /** 
    * @description Populate Remarks
    * @param newContact
    * @param oldContact
    * @return String
    */
    private static String populateRemarks(Contact newContact, Contact oldContact){
        String remarksContent = '';
        XC_AT_Utils.RemarkMessageWrapper remarkWrapper = new XC_AT_Utils.RemarkMessageWrapper();
        if(newContact.LastName != oldContact.LastName) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.Contact.fields.LastName.getDescribe();
            remarkWrapper.newValue = newContact.LastName;
            remarkWrapper.oldValue = oldContact.LastName;
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        if(newContact.FirstName != oldContact.FirstName) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.Contact.fields.FirstName.getDescribe();
            remarkWrapper.newValue = newContact.FirstName;
            remarkWrapper.oldValue = oldContact.FirstName;
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        if(newContact.Phone != oldContact.Phone) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.Contact.fields.Phone.getDescribe();
            remarkWrapper.newValue = newContact.Phone;
            remarkWrapper.oldValue = oldContact.Phone;
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        if(newContact.MobilePhone != oldContact.MobilePhone ) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.Contact.fields.MobilePhone.getDescribe();
            remarkWrapper.newValue = newContact.MobilePhone;
            remarkWrapper.oldValue = oldContact.MobilePhone;
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        if(newContact.XC_HourToBeRecontacted__c != oldContact.XC_HourToBeRecontacted__c ) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.Contact.fields.XC_HourToBeRecontacted__c.getDescribe();
            remarkWrapper.newValue = String.valueOf(newContact.XC_HourToBeRecontacted__c);
            remarkWrapper.oldValue = String.valueOf(oldContact.XC_HourToBeRecontacted__c);
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        if(newContact.Email != oldContact.Email ) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.Contact.fields.Email.getDescribe();
            remarkWrapper.newValue = newContact.Email;
            remarkWrapper.oldValue = oldContact.Email;
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        remarkWrapper.lastMessage = remarksContent;
        remarksContent = populateRemarksForCustomField(remarkWrapper, newContact, oldContact);
        return remarksContent;
    }


    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Populate Remarks for Custom Fields (For cyclomatic complexity)
    * @param remarkWrapper
    * @param newContact
    * @param oldContact
    * @return String
    */
    private static String populateRemarksForCustomField(XC_AT_Utils.RemarkMessageWrapper remarkWrapper, Contact newContact, Contact oldContact){
        String remarksContent = remarkWrapper.lastMessage;
        if(newContact.XC_Nationality__c != oldContact.XC_Nationality__c ) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.Contact.fields.XC_Nationality__c.getDescribe();
            remarkWrapper.newValue = newContact.XC_Nationality__c;
            remarkWrapper.oldValue = oldContact.XC_Nationality__c;
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        if(newContact.XC_Preferredlanguageofcontact__c != oldContact.XC_Preferredlanguageofcontact__c ) {
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.Contact.fields.XC_Preferredlanguageofcontact__c.getDescribe();
            remarkWrapper.newValue = newContact.XC_Preferredlanguageofcontact__c;
            remarkWrapper.oldValue = oldContact.XC_Preferredlanguageofcontact__c;
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        return remarksContent;
    }


    /**
     * @author      Monica Cutillo - monica.cutillo@nttdata.com
     * @param contactIds the contact id list
     * @param settingsWithAuth the settings with auth
     * @return the list
     * @description Retrive existing Case of type PersonalInfoChangeWithAuth
     */
    public static List<Case> retriveExistingCasesFromContacts(List<Id> contactIds, XC_CM_Case_Type_Setting__mdt settingsWithAuth){ //, Id caseRecordTypeId
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ START XC_TR_Contact_U_CaringManagement.retriveExistingCasesFromContacts');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'settingsWithAuth='+settingsWithAuth);
        System.debug('settingsWithAuth='+settingsWithAuth);
        List<Case> result = new List<Case>();
        if(settingsWithAuth!=null && !(contactIds.isEmpty())){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'contactIds='+contactIds);
            System.debug('contactIds='+contactIds);
            Map<id,Case> mapCase = new Map<id,Case>([  SELECT Id, RecordTypeId, Reason, Subcause__c, XC_Subtype__c, AccountId, ContactId
                            FROM Case 
                            WHERE Reason =: settingsWithAuth.XC_Case_Reason__c 
                            AND Subcause__c =: settingsWithAuth.XC_Sub_Cause__c 
                            //AND (XC_Subtype__c = null OR XC_Subtype__c =: settingsWithAuth.XC_Sub_Type__c)
                            AND XC_Subtype__c =: (settingsWithAuth.XC_Sub_Type__c != null) ? settingsWithAuth.XC_Sub_Type__c : null
                            //AND AccountId =: caseObj.AccountId 
                            AND ContactId IN: contactIds
                            AND Status !=: Label.XC_CL_Case_Status007
                            AND Status !=: Label.XC_CL_Case_Status008]);

        result = mapCase.values();
        }
        System.debug('???Result' + result);
       // XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ XC_TR_Contact_U_CaringManagement retriveExistingCasesFromContacts - result = ' + result);
        return result;
    }

    /**
     * @author          Monica Cutillo - monica.cutillo@nttdata.com
     * @param newCase the new case
     * @param existingCases the existing cases
     * @param settingsWithAuth the settings with auth
     * @description     Search if exixts a Case with equals RecType, Reason, Subcause__c and SubType and Contact
     * not close or cancelled. If exists, sets the Id on Case object in input
     */
    /*private static void searchExistingCase(Case newCase, List<Case> existingCases, XC_CM_Case_Type_Setting__mdt settingsWithAuth){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ START XC_TR_Contact_U_CaringManagement.searchExistingCase');
        if(newCase==null || existingCases==null || existingCases.isEmpty()){
            return;
        }
        for(Case caseObj: existingCases){
            if(XC_TR_Contact_U_CaringManagementCond.checkCond1(caseObj,newCase,settingsWithAuth) )
            {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ XC_TR_Contact_U_CaringManagement searchExistingCase - found existing case = ' + caseObj);
                newCase.Id = caseObj.Id;
            }
        }
    }*/


    /**
     * CallZuora.
     * 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param contactId the contactId
     * @description Call Zuora when Contact fields are changed
     */
    @future(callout=true)
    public static void callZuora(String contactId) {

        Map<Id, XC_BillingProfileLineItem__c> bpliMap =
            new Map<Id, XC_BillingProfileLineItem__c>([SELECT Id, XC_ZuoraId__c, XC_BillToContactId__c, XC_SoldToContactId__c, XC_BillToAddress__c, XC_BillingProfile__r.XC_Segment__c,
                                                        XC_SoldToAddress__c, XC_LegalEntity__c, XC_BillingProfile__r.NE__Account__c, XC_BillingProfile__r.NE__Account__r.Name,
                                                        XC_BillingProfile__r.NE__Account__r.RecordType.Name, XC_BillingProfile__r.NE__Account__r.XC_DocumentCountry__c,
                                                        XC_BillingProfile__r.NE__Account__r.IdentityNumber__c, XC_BillingProfile__r.NE__Account__r.IdentityType__c,
                                                        XC_BillingProfile__r.NE__Account__r.XC_NIE_expiration_date__c, XC_BillingProfile__r.NE__Account__r.XC_NIE_expedition_date__c
                                                        FROM XC_BillingProfileLineItem__c
                                                        WHERE (XC_ZuoraId__c != null AND (XC_BillToContactId__c = :contactId OR XC_SoldToContactId__c = :contactId))]);
        if(bpliMap.values().isEmpty()) {
            return;
        }

        String newAccountIdentityType = '';
        String newAccountIdentityNumber = '';
        String newAccountDocumentCountry = '';
        String newAccountDocumentReleaseDate = '';
        String newAccountDocumentExpirationDate = '';
        if(bpliMap.values()[0].XC_BillingProfile__r.NE__Account__r.RecordType.Name == 'Residential') {
            Map<Id, XC_PersonalDocument__c> docMap = new Map<Id, XC_PersonalDocument__c>([SELECT Id, XC_Country__c, XC_DocumentNumber__c, XC_DocumentType__c,
                                                                                            XC_ExpirationDate__c, XC_ReleaseDate__c
                                                                                            FROM XC_PersonalDocument__c
                                                                                            WHERE XC_Account__c =: bpliMap.values()[0].XC_BillingProfile__r.NE__Account__c
                                                                                            AND XC_MainDocument__c = true]);
            if(!docMap.values().isEmpty()) {
                newAccountIdentityType = docMap.values()[0].XC_DocumentType__c;
                newAccountIdentityNumber = docMap.values()[0].XC_DocumentNumber__c;
                newAccountDocumentCountry = docMap.values()[0].XC_Country__c;
                newAccountDocumentReleaseDate = String.valueOf(docMap.values()[0].XC_ReleaseDate__c);
                newAccountDocumentExpirationDate = String.valueOf(docMap.values()[0].XC_ExpirationDate__c);
            }
        } else {
            newAccountIdentityType = bpliMap.values()[0].XC_BillingProfile__r.NE__Account__r.IdentityType__c;
            newAccountIdentityNumber = bpliMap.values()[0].XC_BillingProfile__r.NE__Account__r.IdentityNumber__c;
            newAccountDocumentCountry = bpliMap.values()[0].XC_BillingProfile__r.NE__Account__r.XC_DocumentCountry__c;
            newAccountDocumentReleaseDate = String.valueOf(bpliMap.values()[0].XC_BillingProfile__r.NE__Account__r.XC_NIE_expedition_date__c);
            newAccountDocumentExpirationDate = String.valueOf(bpliMap.values()[0].XC_BillingProfile__r.NE__Account__r.XC_NIE_expiration_date__c);
        }

        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalInfoMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_LegalEntity__c, XC_Stream__c, XC_Country__c, XC_ValidDocuments__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_OrgId__c =: orgId]);
        Map<String, String> legalEntityDocuments = new Map<String, String>();
        for(XC_CM_LegalEntity_Configuration__mdt mdt : legalInfoMap.values()) {
            legalEntityDocuments.put(mdt.XC_LegalEntity__c+mdt.XC_Stream__c, mdt.XC_Country__c + '-' + mdt.XC_ValidDocuments__c);
        }

        Boolean check = true;
        List<ZuoraWebService.CreateZuoraAccountResponse> zuoraResponseList = new List<ZuoraWebService.CreateZuoraAccountResponse>();
        for(XC_BillingProfileLineItem__c bpli : bpliMap.values()) {
            
            String country = '';
            List<String> validDocuments = new List<String>();
            if(String.isNotBlank(legalEntityDocuments.get(bpli.XC_LegalEntity__c+bpli.XC_BillingProfile__r.XC_Segment__c))) {
                country = legalEntityDocuments.get(bpli.XC_LegalEntity__c+bpli.XC_BillingProfile__r.XC_Segment__c).split('-')[0];
                validDocuments.addAll((legalEntityDocuments.get(bpli.XC_LegalEntity__c+bpli.XC_BillingProfile__r.XC_Segment__c).split('-')[1]).split(';'));
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ country -> '+country);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ validDocuments -> '+validDocuments);

            Map<String, String> parametersMap = new Map<String, String>{'zuoraAccountId' => bpli.XC_ZuoraId__c,
                                                                        'billToId' => bpli.XC_BillToContactId__c,
                                                                        'soldToId' => bpli.XC_SoldToContactId__c,
                                                                        'billAddrId' => bpli.XC_BillToAddress__c,
                                                                        'soldAddrId' => bpli.XC_SoldToAddress__c,
                                                                        'newAccountName' => bpli.XC_BillingProfile__r.NE__Account__r.Name,
                                                                        'legalEntity' => bpli.XC_LegalEntity__c,
                                                                        'newAccountIdentityType' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType)) ? newAccountIdentityType : '',
                                                                        'newAccountIdentityNumber' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType)) ? newAccountIdentityNumber : '',
                                                                        'newAccountDocumentCountry' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType)) ? newAccountDocumentCountry : '',
                                                                        'newAccountDocumentReleaseDate' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType)) ? newAccountDocumentReleaseDate : '',
                                                                        'newAccountDocumentExpirationDate' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType)) ? newAccountDocumentExpirationDate : ''};

            //ZuoraWebService zws = new ZuoraWebService(XC_UTIL_Integration_U.getEntityName(bpli.XC_LegalEntity__c));
            ZuoraWebService zws = new ZuoraWebService(XC_UTIL_Integration_U.getEntityNameWithStream(bpli.XC_LegalEntity__c, bpli.XC_BillingProfile__r.XC_Segment__c));
            ZuoraWebService.CreateZuoraAccountResponse responseUpdateAccount = zws.updateZuoraAccount(parametersMap);
            if(responseUpdateAccount.success == 'false') {
                check = false;
            }
        }

        if(!check) {
            Contact c = new Contact(Id = contactId, XC_Dealignment_with_Zuora__c = true);
            XC_UTIL_Sobject.updateRecord(c);
        }
    }


    /**
     * ManageDisalignmentWithZuora.
     * 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param contactList
     * @param oldContactMap
     * @param newContactMap
     * @description Manage Disalignment With Zuora field and creare a case
     */
    public static void manageDisalignmentWithZuora(List<Contact> contactList, Map<ID, Contact> oldContactMap, Map<ID, Contact> newContactMap){
        List<String> listFieldsChanged = new List<String>{'XC_Dealignment_with_Zuora__c'};
        List<Contact> listContactChanged = XC_UTIL_Sobject.getListChanged(listFieldsChanged, oldContactMap, newContactMap);
 
        if(listContactChanged.isEmpty()) {
            return;
        }

        Map<String, XC_CM_Case_Type_Setting__mdt> caseTypeSettings = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{'XC_DisalignmentZuoraContact'});
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;

        List<Case> casesToInsert = new List<Case>();
        for(Contact contact : listContactChanged) {
            if(contact.XC_Dealignment_with_Zuora__c) {
                Case caseToInsert = XC_UTIL_Case.initCaseFromCaseSettings(caseTypeSettings.get('XC_DisalignmentZuoraContact'));
                caseToInsert.AccountId = contact.AccountId;
                caseToInsert.ContactId = contact.Id;
                caseToInsert.setOptions(dmlOpts);
                casesToInsert.add(caseToInsert);  
            }
        }

        XC_UTIL_Sobject.insertListRecords(casesToInsert);
    }

}