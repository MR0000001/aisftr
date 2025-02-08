/**
 * The Class XC_TR_Case_U_ClosureManagement.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 03/07/2019
 * @date Modification : 06/08/2019 Dario Tramontin - dtramontin@deloitte.it 
 * @description       : Class to manage Case closure
 **/ 

public without sharing class XC_TR_Case_U_ClosureManagement {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_ClosureManagement');


    /**
    * CloseCaseForFieldsFilled.
    * 
    * @param listNew the list new
    * @param  the mapmapOld old
    * @param mapNew the map new
    * @description Close Case when XC_Resolution__c, XC_Result__c and CaseRemarks__c fields are filled
    */
    public static void closeCaseForFieldsFilled(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_Case_U_ClosureManagement.closeCaseForFieldsFilled');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew -> ' + listNew);
        List<String> fieldList = new List<String>{'XC_Resolution__c', 'XC_Result__c', 'CaseRemarks__c'};
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '#listChanged -> ' + listChanged);
        for(Case c : listChanged) {
			if(String.isNotBlank(c.XC_Resolution__c) && String.isNotBlank(c.XC_Result__c) && String.isNotBlank(c.CaseRemarks__c) && c.Status != XC_AT_Constants.TRIGGER_STATUS_ESTA008) {
				c.Status = XC_AT_Constants.TRIGGER_STATUS_ESTA007;
			}
		}
    }


    /**
    * populateRequiredCaseClosureFields.
    * 
    * @param listNew the list new
    * @param mapOld the map old
    * @param mapNew the map new
    * @description populate required case closure fields when a case is closed automatically
    */
    public static void populateRequiredCaseClosureFields(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_Case_U_ClosureManagement.populateRequiredCaseClosureFields');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew -> ' + listNew);
        List<String> fieldList = new List<String>{'Status'}; 
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        
        if(!listChanged.isEmpty()) {
            List<Case> caseList= new List<Case>();
            Set<String> reasonSet = new Set<String>();
            Set<String> subcauseSet = new Set<String>();
            for( Case c : listChanged){
                if(!String.isBlank(c.Type) && c.Type.equals(Label.XC_CL_ComplianceVerification)){
                    return ;
                }
                //if these fields are not blank, it's meaning that there is an cancellation by button and it's no necessary to set these fields
                if( !String.isBlank(c.XC_Resolution__c) && !String.isBlank(c.XC_Result__c) && !String.isBlank(c.CaseRemarks__c)  ){
                    continue;
                }

                if( c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA007 || c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA008  ){
                    reasonSet.add(c.Reason);
                    subcauseSet.add(c.SubCause__c);
                    caseList.add(c);
                }
            }
            //if these two list are empty there is an update on a status different by cancel or closed so you must exit without error
            if( !reasonSet.isEmpty() && !subcauseSet.isEmpty() ){
                Map<Id, XC_CM_CaseClosureDependencies__mdt> fieldsMap = new Map<Id, XC_CM_CaseClosureDependencies__mdt>(
                    [SELECT XC_Resolution__c, XC_Result__c, XC_CaseRemarks__c, XC_CaseRemarksEnelXItalia__c, XC_ClousureType__c, XC_ReasonCode__c,XC_SubCause__c,XC_Type_Intermediary__c,
                            XC_CaseRemarksCogenio__c,XC_CaseRemarksEnelSole__c,XC_CaseRemarksEnelXMobility__c,	XC_CaseRemarksEnelXMSP__c,XC_CaseRemarksESCoComuniSrl__c,XC_CaseRemarksYouSaveSpA__c
                    FROM XC_CM_CaseClosureDependencies__mdt 
                    WHERE XC_ReasonCode__c IN :reasonSet AND XC_SubCause__c IN :subcauseSet ]);

                if( !fieldsMap.isEmpty()  ){
                    pupulateCaseFields(fieldsMap,caseList);
                }else{
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Not found CustomMetadata to fill fields for ReasonCode e SubCause');
                    
                    listChanged[0].addError(Label.XC_CL_Case_AutomaticClosure);
                    return;
                }
            }
        }
    }


    /**
    * pupulateCaseFields.
    * 
    * @param fieldsMap map of Custom metadata
    * @param caseList the list of case to Update
    * @description populate required case closure fields 
    */
    public static void pupulateCaseFields(Map<Id, XC_CM_CaseClosureDependencies__mdt> fieldsMap, List<Case> caseList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_Case_U_ClosureManagement.pupulateCaseFields');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#caseList -> ' + caseList);
        Map<String,String> mapCaseFamily= XC_UTIL_Case.getCaseRecordTypeFamily(caseList);

        Map<String, XC_CM_CaseClosureDependencies__mdt> mapValues = new Map<String,XC_CM_CaseClosureDependencies__mdt>();
        for(XC_CM_CaseClosureDependencies__mdt depMdt : fieldsMap.values() ){
            String val= depMdt.XC_SubCause__c + depMdt.XC_ReasonCode__c + depMdt.XC_ClousureType__c + depMdt.XC_Type_Intermediary__c;
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Created key for map: '+ val);
            mapValues.put( val, depMdt );
        }
        for( Case c : caseList){
            String status;
            //do translation from code to String according to field of CustomMetadata
            if(c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA007){
                status = 'Closing';
            }else if( c.Status== XC_AT_Constants.TRIGGER_STATUS_ESTA008){
                status =  'Cancelling';
            }
            if(Label.XC_CL_Case_FamilyComplaintRT.equals(mapCaseFamily.get(c.Reason))  ){
                status = null;
            }
            String k= c.SubCause__c + c.Reason + status + c.XC_Type_Intermediary__c; 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Created key to find: '+ k);
            if( mapValues.containsKey(k) ){ 
                c.XC_Resolution__c = mapValues.get(k).XC_Resolution__c;
                c.XC_Result__c = mapValues.get(k).XC_Result__c;
                c.CaseRemarks__c = (String.isNotBlank(c.CaseRemarks__c)) ? c.CaseRemarks__c : XC_UTIL_Case_U.getCaseRemarksClosureByLegalEntity(mapValues.get(k), c.XC_LegalEntity__c);
                //c.CaseRemarks__c = (String.isNotBlank(c.CaseRemarks__c)) ? c.CaseRemarks__c : mapValues.get(k).XC_CaseRemarks__c;  /* ESCEP-2327 MC 30122019 */
            }else{ 
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Not found value and set the status of case: '+ c.Id + 'to Open');
                c.Status = Label.XC_CL_Case_Open; //ESTA001
            }
        }
    }

    
    /**
     * populateRequiredClosedCaseClosureFields.
     * 
     * @param listNew the list of case created
     * @description populate required case closure fields when a case is created closed
    */
    public static void populateRequiredClosedCaseClosureFields(List<Case> listNew){
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_Case_U_ClosureManagement.populateRequiredClosedCaseClosureFields');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew -> ' + listNew);

        List<Case> caseListToProcess = new List<Case>();
        for(Case c : listNew) {
            if(c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA007) {
                caseListToProcess.add(c);  
            }
        }

        if(!caseListToProcess.isEmpty()) {
            System.debug('there is an element with status closed');
            Set<String> reasonSet = new Set<String>();
            Set<String> subcauseSet = new Set<String>();
            Set<String> subtypeSet = new Set<String>();
            for( Case c : caseListToProcess){
                reasonSet.add(c.Reason);
                subcauseSet.add(c.SubCause__c);
                subtypeSet.add(c.XC_Subtype__c);
            }

            Map<Id,XC_CM_Case_Type_Setting__mdt> fieldsMap= new  Map<Id,XC_CM_Case_Type_Setting__mdt>(
                [SELECT XC_Resolution__c, XC_Result__c, XC_CaseRemarks__c, XC_CaseRemarksEnelXItalia__c, XC_Sub_Type__c,XC_Sub_Cause__c,XC_Case_Reason__c
                FROM XC_CM_Case_Type_Setting__mdt
                WHERE XC_Case_Reason__c IN :reasonSet AND XC_Sub_Cause__c IN :subcauseSet AND XC_Sub_Type__c IN :subtypeSet]);
            
            if( !fieldsMap.isEmpty()  ){
                pupulateClosedCaseFields(fieldsMap,caseListToProcess);
            }else{
                XC_UTIL_Debug.debug(DEBUGACTIVE,'Not found CustomMetadata to fill fields' );
                caseListToProcess[0].addError(Label.XC_CL_Case_AutomaticClosure);
                return;
            }
        }
    }
    /**
     * pupulateClosedCaseFields.
     * 
     * @param fieldsMap map of Custom metadata
     * @param caseList the list of case
     * @description populate required case closure fields when a case is created closed
    */
    private static void pupulateClosedCaseFields(Map<Id, XC_CM_Case_Type_Setting__mdt> fieldsMap, List<Case> caseList){
        Map<String, XC_CM_Case_Type_Setting__mdt> mapValues = new Map<String,XC_CM_Case_Type_Setting__mdt>();
                
        for(XC_CM_Case_Type_Setting__mdt depMdt : fieldsMap.values() ){
            String val= depMdt.XC_Sub_Cause__c + depMdt.XC_Case_Reason__c + depMdt.XC_Sub_Type__c;
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Created key for map: '+ val);
            mapValues.put( val, depMdt );
        }

        for( Case c : caseList){
            String k= c.SubCause__c+c.Reason+ c.XC_Subtype__c; 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Created key to find: '+ k);
            if( String.isBlank(c.XC_Resolution__c) || String.isBlank(c.XC_Result__c) || String.isBlank(c.CaseRemarks__c) ){  
                if( mapValues.containsKey(k) ){
                    c.XC_Resolution__c = (String.isNotBlank(c.XC_Resolution__c) ) ? c.XC_Resolution__c : mapValues.get(k).XC_Resolution__c;
                    c.XC_Result__c = (String.isNotBlank(c.XC_Result__c) ) ? c.XC_Result__c : mapValues.get(k).XC_Result__c;
                    c.CaseRemarks__c = (String.isNotBlank(c.CaseRemarks__c)) ? c.CaseRemarks__c : XC_UTIL_Case_U.getCaseRemarksByLegalEntity(mapValues.get(k), c.XC_LegalEntity__c);
                    //c.CaseRemarks__c = (String.isNotBlank(c.CaseRemarks__c)) ? c.CaseRemarks__c : mapValues.get(k).XC_CaseRemarks__c;
                    continue;
                }else{
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Not found valure');
                    c.addError(Label.XC_CL_Case_AutomaticClosure);
                    return;
                }
            }
        }
    }

    public static void updateIsStopped(List<Case> listCase){
        for( Case c: listCase){
            if(c.Status==XC_AT_Constants.TRIGGER_STATUS_ESTA007 || c.Status==XC_AT_Constants.TRIGGER_STATUS_ESTA008){
                c.IsStopped=true;
            }
        }
    }

        /**
    * closeAdministrativeStep.
    * 
    * @param listNew the list new
    * @param mapOld the map old
    * @param mapNew the map new
    * @description closeAdministrativeStep
    */
    public static void closeAdministrativeStep(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
        List<String> fieldList = new List<String>{'Status'}; 
        List<Case> caseToConsider = new List<Case>();
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            for(Case c : listChanged){
                if(( c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA007 || c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA008)
                  && !String.isEmpty(c.XC_ProvisioningStep__c)){
                      caseToConsider.add(c);
                }
            }
        } 
        List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();
        for(Case c : caseToConsider){
            XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(Id = c.XC_ProvisioningStep__c);
            if(c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA007){
                step.XC_Status__c = Label.XC_CL_Completed_Ok;
            }else if (c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA008) {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO; 
            }  
            stepsToUpdate.add(step); 
        }   
        XC_UTIL_Sobject.updateListRecords(stepsToUpdate);
    }
    
  	/**
    * sendCI.
    * 
    * @author Simone Trenta - strenta@deloitte.it
    * @param listNew the list new
    * @param mapOld the map old
    * @param mapNew the map new
    * @description send notificaation
    */
    public static void sendCI(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
        List<String> fieldList = new List<String>{'Status'}; 
        List<Case> caseToConsider = new List<Case>(); 
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            for(Case c : listChanged){

                if((c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA007) && c.Reason == 'XCMOT007' && (c.SubCause__c == 'ATCL028'|| ( c.SubCause__c == 'ATCL140' && c.XC_Result__c == 'RS003')) ){

                    caseToConsider.add(c);
                } 
            }
        } 

        Map<Id,String> caseURL = new Map<Id,String>();
        Map<Id,XC_DocumentURL__c> docs = new Map<Id,XC_DocumentURL__c>([SELECT id, XC_Url__c, XC_Case__c FROM XC_DocumentURL__c WHERE XC_Case__c in: caseToConsider]);
        for(XC_DocumentURL__c d:docs.values()){
            if(caseURL.get(d.XC_Case__c)!=null){

                caseURL.put(d.XC_Case__c, caseURL.get(d.XC_Case__c)+','+d.XC_Url__c); //

            } else {
                caseURL.put(d.XC_Case__c, d.XC_Url__c);
            }
        }

        Map<Id,Case> caseData = new Map<Id,Case>([SELECT id, AccountId, Contact.Name, ContactId, XC_LegalEntity__c, XC_Segment__c, Contact.Email, SubCause__c FROM Case WHERE id in: caseToConsider]);

        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        for(Case c : caseData.values()){

            String url = caseURL.get(c.id);
            String type;
            if (c.SubCause__c == 'ATCL028') {
                type = 'Case_Incentive';
            } else if (c.SubCause__c == 'ATCL140') {
                type = 'Case_Credit_Assignment';
            }

            interactions.add(XC_UTIL_CustomerInteractionGeneration_UU.populateCustIntForCaseITA(c, type, url));
        }  
    
        List<XC_UTIL_Sobject.WrapperResult> wr = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromCases(interactions);
    }

    /**
    * checkLegalization
    * 
    * @author Luigi Porcelli - luporcelli@deloitte.it
    * @param listNew the list new
    * @param mapOld the map old
    * @param mapNew the map new
    * @description Runs all the necessary checks for the Legalization Completed field to be true.
    */
    public static void checkLegalization(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
        List<String> fieldList = new List<String>{'XC_Legalization_Completed__c'}; 
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);

        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_PermittingManagement});
        XC_CM_Case_Type_Setting__mdt caseSettings = new XC_CM_Case_Type_Setting__mdt();
        caseSettings = mapCaseSetting.get(Label.XC_CL_PermittingManagement);
        Map<Id, Case> idToCaseMap = new Map<Id, Case>();
        if(!listChanged.isEmpty()) {
            for(Case c : listChanged){
                if(c.XC_Legalization_Completed__c){
                    idToCaseMap.put(c.id, c);
                }
            }

            String SF_ELECTRIC_CERT = Label.XC_CL_DocumentType_Category_SF_ELECTRIC_CERT;
            String SF_RESULT_DOC = Label.XC_CL_DocumentType_Category_SF_RESULT_DOC;
            List <XC_DocumentType__c> casesDocuments = [SELECT ID, CASE__c, Category__c 
                                                        FROM XC_DocumentType__c 
                                                        WHERE CASE__c IN :idToCaseMap.keySet()
                                                        AND (Category__c = :SF_ELECTRIC_CERT OR Category__c = :SF_RESULT_DOC)];
            Map<Id, Set<String>> casesToDocCategory = new Map<Id, Set<String>>();
            for(XC_DocumentType__c doc : casesDocuments){
                if(casesToDocCategory.containsKey(doc.CASE__c)){
                    Set<String> categories = casesToDocCategory.get(doc.Case__c);
                    categories.add(doc.Category__c);
                    casesToDocCategory.put(doc.CASE__c, categories);
                } else {
                    casesToDocCategory.put(doc.CASE__c, new Set<String>{doc.Category__c});
                }
            }
            Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([SELECT ID, Status FROM WorkOrder WHERE Caseid IN :idToCaseMap.keySet()]);
            for(Id ci : idToCaseMap.keySet()){
                Set<String> caseDocuments = casesToDocCategory.get(ci);
                Case caseToCheck = idToCaseMap.get(ci);
                if(caseDocuments == null || (!caseDocuments.contains(Label.XC_CL_DocumentType_Category_SF_ELECTRIC_CERT) || !caseDocuments.contains(Label.XC_CL_DocumentType_Category_SF_RESULT_DOC)) || 
                caseToCheck.Status !=  Label.XC_CL_Case_Status007 || caseToCheck.Reason != caseSettings.XC_Case_Reason__c 
                || caseToCheck.XC_Subtype__c != caseSettings.XC_Sub_type__c || caseToCheck.Subcause__c != caseSettings.XC_Sub_cause__c
                || !(caseToCheck.XC_WorkOrder__c == null  || woMap.get(caseToCheck.XC_WorkOrder__c).status == Label.XC_CL_WorkOrder_Completed)){
                    idToCaseMap.get(ci).XC_Legalization_Completed__c = False;
                    idToCaseMap.get(ci).addError(Label.XC_CL_Case_CheckedLegalizationError);
                }
            }
        }
    }
}