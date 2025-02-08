/**
 * The Class XC_TR_Case_U_DefaultSettings.
 *
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 28/02/2019
 * @date Modification 21/06/2019 skip crate notification for eMobility
 * @description XC_TR_Case_U_DefaultSettings – Class that applay default settings on cases after creation
 */
public without sharing class XC_TR_Case_U_DefaultSettings {

    /** @description The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_DefaultSettings');
    
    /**
     * @description Apply default settings.
     * @param listNew the list new
     */
    public static void applyDefaultSettings(List<Case> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ XC_TR_Case_U_DefaultSettings.applyDefaultSettings');
        
        // Set Case Origin from User
        Map<Id,User> userMap  = new Map<Id,User>([SELECT id, Origin__c FROM USER WHERE id = :Userinfo.getUserId()]);
        User user =  userMap.values();
        if(user == null || user.Origin__c == null) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ applyDefaultSettings - user or user origin NULL');
        } else {
            for(Case caseObj : listNew) {
                if(caseObj.Origin == null){
                    caseObj.Origin = user.Origin__c;
                }
                
            }
        } 

        for(Case caseObj : listNew) {
            //Set Communication Date
            if(caseObj.XC_Channel_Attribute__c!='CA003'){
                caseObj.XC_Communication_Date__c = Date.today();
            }
            //Set AssetRelation
            if(caseObj.AssetId != null){
                caseObj.AssetRelation__c = caseObj.AssetId;
            }
        }
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param listNew the list new
     * @description update the AssetRelation on Case when the lookup value changes
     */
    public static void updateAssetRelation(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'AssetId'}, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        for(Case caso : listChanged){
            caso.AssetRelation__c = caso.AssetId;
        }
    }

    /**
     * Send notification for case creation.
     *
     * @author Monica Cutillo - mcutillo@deloitte.it  & Chiara Turco - cturco@deloitte.it
     * @param listNew the list new
     * @date 20/03/2019
     * @description Insert CustomerIntegrations for the Case creations
     */
    public static void sendNotificationForCaseCreation(List<Case> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ XC_TR_Case_U_DefaultSettings.sendNotificationForCaseCreation');
        List<Case> casesToNotify1 = filterCaseToNotify(listNew);
        List<Case> casesToNotify = new List<Case>();
        for(Case ca : casesToNotify1){
            Set<String> legalEntityToExclude = new Set<String>{'EnelXItalia', 'EnelXMobility', 'YouSaveSpA', 'ESCoComuniSrl', 'Cogenio', 'EnelXMSP', 'EnelSole'};
            Boolean checkITAB2B = !((ca.XC_Segment__c == 'B2B' || ca.XC_Segment__c == 'B2G') && (legalEntityToExclude.contains(ca.XC_LegalEntity__c)));
            if(checkITAB2B && (ca.Origin == 'CAN001' || ca.Origin == Label.XC_CL_Case_Origin_AppEmobility || (ca.Origin == 'CAN004' && (ca.XC_LegalEntity__c == 'EnelXMSP' || ca.XC_LegalEntity__c == 'EnelXMobilityHolding')))){  // Send notification only if the Origin is 'CAN001' or 'CAN008' (Origin sent from the emobility app)
               casesToNotify.add(ca);
            }
        }
        
        if(casesToNotify.isEmpty()){
            return;
        }

        Set<Id> contactIds = XC_UTIL_Sobject.getSetIdsOnField(casesToNotify, 'ContactId');
        Map<Id,Contact> contacts = retriveContactsNotificationInfo(contactIds);
        List<Map<String,Object>> notifies = new List<Map<String,Object>>();

        for(Case newCase : casesToNotify){
            notifies.add(createValueMap(newCase, contacts.get(newCase.ContactId)));
        }
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromCases(notifies);

        return;
    }
    /**
     * @author Sara Miozza sara.miozza@nttdata.com & Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com
     * @param listNew the list new
     * @date 24/07/2019
     * @modifyDate 18/10/2019 Monica Cutillo - monica.cutillo@nttdata.com
     * @description set case record type
     */
    /*public static void setCaseRecordType(List<Case> listNew){
        Map<String,String> reasonRecordTypeMap = XC_UTIL_Case.getCaseRecordType(listNew);
        for(Case cs : listNew){
            cs.RecordTypeId = reasonRecordTypeMap.get(cs.Reason);
        }
        String defRTName = '';
        for(Case cs : listNew){
            if(cs.RecordTypeId == null){
                defRTName = XC_UTIL_Case.getDefaultCaseRecordType(cs.XC_LegalEntity__c);
                //cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(defRTName).getRecordTypeId();
                //cs.RecordTypeId = defRTName;
            }
        } 
    }*/

    /**
     * @description filterCaseToNotify > excluds closed, canceled, eMobility_SuspendZuoraDunning and eMobility_DisconnectZuoraDunning cases
     * @param newCases cases list new
     * @return filtered cases
     */
    private static List<Case> filterCaseToNotify(List<Case> newCases){
        List<Case> casesNotClosed = filterNotOpenCase(newCases);
        if(casesNotClosed.isEmpty()){
            return casesNotClosed;
        }
        
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_eMobility_DisconnectZuoraDunning, Label.XC_CL_eMobility_SuspendZuoraDunning});
        if(caseSettingsMap.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+Label.XC_CL_eMobility_DisconnectZuoraDunning+' and '+Label.XC_CL_eMobility_SuspendZuoraDunning);
            return casesNotClosed;
        }
        if(caseSettingsMap.get(Label.XC_CL_eMobility_DisconnectZuoraDunning)==null ){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+Label.XC_CL_eMobility_DisconnectZuoraDunning);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Case check to not create Customer Interaction for eMobility >>> NOT APPLY for it!');
        }
        else if(caseSettingsMap.get(Label.XC_CL_eMobility_SuspendZuoraDunning)==null ){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+Label.XC_CL_eMobility_SuspendZuoraDunning);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Case check to not create Customer Interaction for eMobility >>> NOT APPLY for it!');
        }

        return filterCaseBySettings(casesNotClosed, caseSettingsMap);
        
        /*List<Case> casesToNotify = new List<Case>();
        for(Case caso : casesNotClosed){
            if(caseSettingsMap.get(Label.XC_CL_eMobility_DisconnectZuoraDunning) != null && XC_UTIL_Case.matchSettings(caso, caseSettingsMap.get(Label.XC_CL_eMobility_DisconnectZuoraDunning))){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ eMobility NOT Notyfy for Case eMobility_DisconnectZuoraDunning - '+caso.Id);
                continue;
            }
            if(caseSettingsMap.get(Label.XC_CL_eMobility_SuspendZuoraDunning) != null && XC_UTIL_Case.matchSettings(caso, caseSettingsMap.get(Label.XC_CL_eMobility_SuspendZuoraDunning))){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ eMobility NOT Notyfy for Case eMobility_SuspendZuoraDunning - '+caso.Id);
                continue;
            }
            casesToNotify.add(caso);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ filterCaseToNotify result = '+casesToNotify);
        return casesToNotify;*/
    }

    /**
     * @description filterCaseBySettings
     * @param cases cases list new
     * @param caseSettingsMap metadata case settings
     * @return filtered cases
     */
    private static List<Case> filterCaseBySettings(List<Case> cases, Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap){
        List<Case> casesToNotify = new List<Case>();
        for(Case caso : cases){
            if(caseSettingsMap.get(Label.XC_CL_eMobility_DisconnectZuoraDunning) != null && XC_UTIL_Case.matchSettings(caso, caseSettingsMap.get(Label.XC_CL_eMobility_DisconnectZuoraDunning))){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ eMobility NOT Notyfy for Case eMobility_DisconnectZuoraDunning - '+caso.Id);
                continue;
            }
            if(caseSettingsMap.get(Label.XC_CL_eMobility_SuspendZuoraDunning) != null && XC_UTIL_Case.matchSettings(caso, caseSettingsMap.get(Label.XC_CL_eMobility_SuspendZuoraDunning))){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ eMobility NOT Notyfy for Case eMobility_SuspendZuoraDunning - '+caso.Id);
                continue;
            }
            casesToNotify.add(caso);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ filterCaseToNotify result = '+casesToNotify);
        return casesToNotify;
    }

    /**
     * @description filterCaseToNotify > excluds closed, canceled
     * @param newCases cases list new
     * @return filtered cases
     */
    private static List<Case> filterNotOpenCase(List<Case> newCases){
        //send notification only for Cases not Closed or Canceled
        //Id recordTypeId = CaseDAO.newInstance().getActiveRecordtypeIdByDeveloperName(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA);
        List<Case> casesNotClosed = new List<Case>();
        for(Case newCase : newCases){
            if( //newCase.RecordTypeId == recordTypeId && 
               !(newCase.Status.equals(Label.XC_CL_Case_Status007)) && !(newCase.Status.equals(Label.XC_CL_Case_Status008)) && !(Label.XC_EMobility.equals(newCase.XC_OriginChannel__c))){
                casesNotClosed.add(newCase);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ filterNotOpenCase result = '+casesNotClosed);
        return casesNotClosed;
    }

    /**
     * Creates the value map.
     *
     * @author Monica Cutillo - monica.cutillo@nttdata.com  & Chiara Turco - cturco@deloitte.it
     * @param caseObj the case obj
     * @param contact the contact
     * @return the map
     * @date 20/03/2019
     * @description Prepare the map for CustomerIntegration creation
     */
    private static Map<String,Object> createValueMap(Case caseObj, Contact contact){
        Map<String,Object> data = new Map<String,Object>();
        data.put('customerType', (caseObj.Origin == 'CAN001') ? 'Case_Created' : 'Case_Created_Email');
        data.put('sent', false); //XC_Sent__c
        data.put('skipComunication', false);
        data.put('caseId', caseObj.Id);
        data.put('legalEntity',caseObj.XC_LegalEntity__c  );
        if(contact != null){
            data.put('contactId', contact.Id);
            data.put('fullName', contact.Name);
            data.put('email', contact.Email);
            data.put('preferredlanguage', contact.XC_Preferredlanguageofcontact__c); /*ESCEP-1826 MCutillo 10/05/2019*/
            if(caseObj.AccountId != null){
                data.put('accountId', caseObj.AccountId);
            }
            
        }else{
            data.put('email', caseObj.XC_SuppliedEmail__c);
        }
        return data;
    }

    /**
     * Retrive contacts notification info.
     *
     * @author Monica Cutillo - monica.cutillo@nttdata.com & Chiara Turco - cturco@deloitte.it
     * @param contactIds the contact ids
     * @return the map
     * @date 20/03/2019
     * @description Retrive Contact info from the Ids in input and return a map with Id and Contact Obj populated
     */
    private static Map<Id,Contact> retriveContactsNotificationInfo(Set<Id> contactIds){
        return new Map<Id, Contact>([SELECT Id, Name, Email, AccountId, XC_Preferredlanguageofcontact__c FROM Contact WHERE Id IN: contactIds]);
    }

    /**
     * @author Dario Tramontin dtramontin@deloitte.it 
     * @param  listNew
     * @date 07/11/2019
     * @description set default case record type by legal entity
     */
    public static void setFieldEmail2Case(List<Case> listNew) {
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_Email2Case});
        XC_CM_Case_Type_Setting__mdt caseMDT = new XC_CM_Case_Type_Setting__mdt();
        caseMDT = mapCaseSetting.get(Label.XC_CL_Email2Case);
        List<Schema.PicklistEntry> picklistOrigin = Schema.Case.Origin.getDescribe().getPicklistValues();
        String labelOrigin;
        for(Schema.PicklistEntry pe : picklistOrigin){
            if(pe.getValue() == 'CAN004'){
                labelOrigin = pe.getLabel();
                break;
            }
            
        }
        for(Case c: listNew){
            if(c.Origin== labelOrigin){
                c.Origin = Label.XC_CL_EmailToCaseOrigin;
            }
            if(c.Origin==Label.XC_CL_EmailToCaseOrigin && String.isBlank(c.Reason) && String.isBlank(c.SubCause__c) ){
                c.Reason = caseMDT.XC_Case_Reason__c;
                c.Subcause__c = caseMDT.XC_Sub_Cause__c;
            }
        }
    }

    public static void setParentWithChildren(List<Case> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'setParentWithChildren=' + listNew );
        List<String> listIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'ParentId');
       // List<Case> listCases = [SELECT id, Status,ParentId FROM Case WHERE Id IN: listIds AND ParentId != null];
        List<Case> listParent = new List<Case>();
        for( String parentId : listIds){
            Case caseParent = new Case( Id=parentId);
            if(!listParent.contains(caseParent)){
                caseParent.XC_WithCaseChildren__c = true; 
                listParent.add(caseParent);
            }
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'caseParentToUpdate=' + listParent);
        XC_TR_Case_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Case_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        List<XC_UTIL_Sobject.WrapperResult> dmlResult = XC_UTIL_Sobject.updateListRecords(listParent);
        XC_TR_Case_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_Case_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'dmlResult=' + dmlResult);
    }
    /**
     * @author Luigi Porcelli luporcelli@deloitte.it
     * @param  listNew - List of new cases
     * @date 16/02/2022
     * @description set case creator profile by user profile name at creation time.
     */
    public static void setCaseCreatorProfile(List<Case> newCases) {
        String profileName = [SELECT NAME FROM PROFILE WHERE ID = :UserInfo.getProfileId()].Name;
        for(Case c : newCases){
            c.XC_CreatorProfile__c = profileName;
        }
    }
}