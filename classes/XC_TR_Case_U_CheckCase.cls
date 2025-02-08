/**
* @description XC_TR_Case_U_CheckCase 
*/

public without sharing class XC_TR_Case_U_CheckCase {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_CheckCase');

    /**
     * @description Assing SLA
     * @param caseList the case list
     */
    public static void assingSLA(List<Case> caseList) {
        //DeAv CR760 START
        Set<String> faultTypeList = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        for(Case newCase : caseList) {
            faultTypeList.add(newCase.XC_FaultType__c);
            accountIds.add(newCase.AccountId);
        }
        List<Entitlement> entList = [SELECT Id, Name, AccountId, SlaProcessId, SlaProcess.Name FROM Entitlement WHERE Name IN :faultTypeList OR AccountId IN :accountIds];
        System.debug('@@@ entList.size(): ' + entList.size());
        List<Entitlement> entListFinal = new List<Entitlement>();
        for(Case newCase : caseList) {
            for(Entitlement et : entList){
                if(newCase.XC_FaultType__c==et.name && newCase.AccountId == et.AccountId){
                    entListFinal.add(et);
                }
            }
        }
        System.debug('@@@ entListFinal.size(): ' + entListFinal.size());
        System.debug('@@@ entListFinal: ' + entListFinal);
        //DeAv CR760 END

        Map<String, Entitlement> slaMap = XC_AT_Utils.getSLAEntitlement('Case');
        system.debug('XC_TR_Case_U_CheckCAse assingSLA slaMap'+slaMap);

        Map<String, XC_CM_Case_ESPAttentionTypes__mdt> attentionTypeMap = XC_UTIL_Case_U.retriveCaseESPAttentionTypesFromCases(caseList);
        String mtdKey;
        XC_CM_Case_ESPAttentionTypes__mdt attentionTypes;
        system.debug('XC_TR_Case_U_CheckCAse assingSLA attentionTypes'+attentionTypeMap);

        for(Case newCase : caseList) {
            if(newCase.Reason == null || newCase.Subcause__c == null) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ assingSLA failed for null data > Reason=' + newCase.Reason + ', Subcause=' + newCase.Subcause__c);  
                return;
            }
            mtdKey = newCase.Reason + '_' + newCase.Subcause__c;

            if(newCase.XC_Subtype__c != null) {
                mtdKey = mtdKey + '_' + newCase.XC_Subtype__c;
			 
												  
																  
            }
            
            //MT
             if(newCase.XC_LegalEntity__c != null) {
                mtdKey = mtdKey + '_' + newCase.XC_LegalEntity__c;									  
																  
            }
			
			 if(newCase.XC_Segment__c != null){
              mtdKey = mtdKey + '_' + newCase.XC_Segment__c;	  
            }
            //MT
            system.debug('XC_TR_Case_U_CheckCAse assingSLA attentionTypes'+mtdKey);
            attentionTypes = attentionTypeMap.get(mtdKey);
            system.debug('XC_TR_Case_U_CheckCAse assingSLA attentionTypes'+attentionTypes);

            if(attentionTypes == null && newCase.XC_Subtype__c != null) {
                mtdKey = newCase.Reason + '_' + newCase.Subcause__c;
                attentionTypes = attentionTypeMap.get(mtdKey);
            }
            if(attentionTypes == null) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ SLA - No Match on XC_CM_Case_ESPAttentionTypes__mdt for Case=' + newCase);
                continue;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ SLA - attentionTypes=' + attentionTypes);
            if(attentionTypes.XC_SLAProcess__c != null && (!attentionTypes.XC_AccountSLA__c || (newCase.XC_BusinessLine__c!='eCity' && attentionTypes.XC_AccountSLA__c))){//DeAv add && condition CR760 - vdb CR760 Fix for eMobility
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ SLA - XC_CM_Case_ESPAttentionTypes__mdt XC_SLAProcess__c=' + attentionTypes.XC_SLAProcess__c); 
                populateEntitlement(newCase, slaMap, attentionTypes);
            }
            //DeAv CR760 START
            else if(attentionTypes.XC_SLAProcess__c != null && attentionTypes.XC_AccountSLA__c && newCase.XC_BusinessLine__c=='eCity'){ //vdb CR760 Fix for eMobility
                System.debug('@@@ Sono nella casistica CR760'); 
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ SLA - XC_CM_Case_ESPAttentionTypes__mdt XC_SLAProcess__c=' + attentionTypes.XC_SLAProcess__c);
                populateEntitlementDefault(newCase, slaMap, entListFinal, attentionTypes);
            }
            //DeAv CR760 END
            else{          
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ assingSLA - XC_SLAProcess__c sin info en la custom setting encontrada');
            }  
        }
    }

    private static void populateEntitlement(Case newCase, Map<String, Entitlement> slaMap, XC_CM_Case_ESPAttentionTypes__mdt attentionTypes){
        if(!slaMap.isEmpty()) { 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'SLAEntitlement map found'); 
            Entitlement et = slaMap.get(attentionTypes.XC_SLAProcess__c);
            if(et != null ){
                newCase.EntitlementId = et.Id;
            } else{
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ assingSLA - no se encuentra Entitlement en el mapa ');  
            }
        } else{
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ assingSLA - caso sin Cuenta sociada ');  
        } 
    }
    //DeAv CR760 START
    private static void populateEntitlementDefault(Case newCase, Map<String, Entitlement> slaMap, List<Entitlement> entListFinal, XC_CM_Case_ESPAttentionTypes__mdt attentionTypes){
 
        System.debug('@@ATTENTIONTYPE populateEntitlementDefault '+attentionTypes.XC_SLAProcess__c);
        System.debug('@@@ newCase populateEntitlementDefault ' + newCase);
        Boolean check = false;
        for(Entitlement et : entListFinal){
            if(et.AccountId == newcase.accountId && et.name == newCase.XC_FaultType__c){
                check = true;
                newCase.EntitlementId = et.Id;
                break;                    
            }
        }
        System.debug('@@@ Case and check: ' + check + ' ' + newCase);
        if(!check){
            populateEntitlement(newCase, slaMap, attentionTypes);
        }
    }
    //DeAv CR760 END

    /**
     * @author Federico Amici - federico.amici@nttdata.com, Monica Cutillo - monica.cutillo@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     * @description checkCaseAndAssignSLA()
     */
    public static void checkCaseAndAssignSLA(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
        List<String> fieldList = new List<String> {
            'Status',
            'Reason',
            'XC_Subtype__c',
            'Subcause__c'
        };
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew); 
        if(!listChanged.isEmpty()) {
            checkCaseAndAssignSLA(listChanged);
        } 
    } 

    private static void checkCaseAndAssignSLA(List<Case> listChanged){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ checkCaseAndAssignSLA list  '); 
        /*
        List<Id> listCaseId = XC_UTIL_Sobject.getIds(listChanged);
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_ESP_Case).getRecordTypeId();        
        
        Map<Id, Case> mapCase = new Map<Id, Case>(
            [SELECT Id, Status, 
                (SELECT Id, CaseId, Status FROM WorkOrders),
                (SELECT Id, WhatId, Status FROM Tasks), //,RelatedCase__c
                (SELECT Id, ParentId, Status, AssetId  FROM Cases WHERE RecordTypeId =: recordTypeId)
            FROM Case
            WHERE Id IN :listCaseId]);                    
        if(!mapCase.isEmpty()){
            XC_TR_Case_U_CheckCaseUtil.isRelatedObjectOpen(listChanged, mapCase); 
            assingSLA(listChanged);
        } 
        */
        List<Case> listCaseSLA= new List<Case>();
        Set<Id> listCaseId = new Set<Id>(XC_UTIL_Sobject.getIds(listChanged) );
        Set<Id> caseCheck = new Set<Id>();
        for(Case c: listChanged){
            if(c.Status != null && (c.Status.equals(Label.XC_CL_Case_Status007) /*|| c.Status.equals(Label.XC_CL_Case_Status008)*/) ){
                caseCheck.add(c.Id);
            }
        }
        Map<Id,XC_UTIL_Case_U.UpdateCaseWrapper> mapWrapper= XC_UTIL_Case_U_Check.isParentCasePending(caseCheck);
        for(Case c : listChanged ){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Status :'+ c.Status);
																																	  
            if(mapWrapper!=null && mapWrapper.get(c.Id) !=null && mapWrapper.get(c.Id).parentCaseArePending ){
                c.addError(Label.XC_CL_Trigger_Error_IsRelatedObjectOpen );
                continue;
            }else{
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'added case to assign SLA'); 
                listCaseSLA.add(c);
            }
        }   
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'check on status and assignSlA');  
        assingSLA(listCaseSLA);    
				 
    } 

    /**
     * Checks if is related object open.
     *
     * @author         VBV
     * @param caseList the case list
     * @param listChildCase the list child case
     * @param listWorkOrder the list work order
     * @param listTask the list task 
     * @name          isRelatedObjectOpen
     * @description   vb - Cada vez que vayamos a CERRAR UN CASO (es decir pasar al estado ‘ESTA007’), se debe mirar en el trigger que ese Caso tenga CERRADOS O CANCELADOS los siguientes objetos relacionados:
     *                             o   Casos Hijo -> Estado cerrado (ESTA007), Estado cancelado (ESTA008)
     *                             o   Work Orders -> Estado completado (Completed), Estado no completado (Cannot Complete), Estado cancelado (Canceled)
     *                             o   Tasks -> Estado cerrado (Completed), Estado cancelado (Rejected)
     *                         Si el caso que queremos cerrar tiene algo de esto en un estado distinto de cerrado/completado, debe saltar un mensaje de error indicando que el caso tiene actividades relacionadas aún abiertas 
     * @email          vbarquero@deloitte.es
     * @lastChange     vbarquero , this method will be executed by Trigger
     */
    /*private static void isRelatedObjectOpen(List<Case> caseList, List<Case> listChildCase, List<WorkOrder> listWorkOrder, List<Task> listTask) {
        for(Case newCase : caseList) {
            if(newCase.Status != null && (newCase.Status.equals(XC_AT_Constants.TRIGGER_STATUS_ESTA007) ||
                newCase.Status.equals(XC_AT_Constants.TRIGGER_STATUS_ESTA008))) {
                    if(isRelatedObjectOpenForCase(newCase, listChildCase, listWorkOrder, listTask)) {
                        newCase.addError(Label.XC_CL_Trigger_Error_IsRelatedObjectOpen);
                    }
            }
        }
    }

    /**
    @name           isRelatedObjectOpen
    @description    method wich returs true if we cant close the case
    @return         -
    @author           VBV
    @email            vbarquero@deloitte.es
    @param caso
    @param caseList
    @param wiList
    @param taskList
    */
    /*public static Boolean isRelatedObjectOpenForCase(Case caso, List<Case> caseList, List<WorkOrder>  wiList, List<Task> taskList){
        if(caso==null || caso.Id==null || caseList == null){
            return false;
        }
        for (Case c : caseList) {
            if(c.ParentId!=null && c.ParentId.equals(caso.Id) && c.Status!=null && !c.Status.equals(Label.XC_CL_Case_Status007) && !c.Status.equals(Label.XC_CL_Case_Status008)){
                return true;
            }
        } 
        isRelatedObjectOpenHelper(caso,wiList,taskList);
        return false;
    }

    @TestVisible
    private static Boolean isRelatedObjectOpenHelper(Case caso, List<WorkOrder> wiList, List<Task> taskList){
        if(wiList!=null) { 
            for (WorkOrder w : wiList) { 
                if(w.CaseId!=null && w.CaseId.equals(caso.Id) && w.Status!=null  && !w.Status.equals(Label.XC_CL_WorkOrder_Canceled) && !w.Status.equals(Label.XC_CL_WorkOrder_Completed) && !w.Status.equals(Label.XC_CL_WorkOrder_CannotComplete)) {
                    return true; 
                }
            } 
        } 
        isRelatedObjectOpenHelper2(caso,wiList,taskList); 
        return true;
    }

    @TestVisible
    private static Boolean isRelatedObjectOpenHelper2(Case caso,List<WorkOrder>  wiList, List<Task> taskList){
        if(taskList!=null){
            for (Task t : taskList){
                if(t.WhatId!=null  && t.WhatId.equals(caso.Id)&& t.Status!=null && !t.Status.equals(Label.XC_CL_Task_Completed) && !t.Status.equals(Label.XC_CL_Task_Cancelled) && !t.Status.equals(Label.XC_CL_Task_Rejected)){
                    return true;
                } 
                if(t.RelatedCase__c!=null && t.RelatedCase__c.equals(caso.Id) && t.Status!=null && !t.Status.equals(Label.XC_CL_Task_Completed)&& !t.Status.equals(Label.XC_CL_Task_Canceled) && !t.Status.equals(Label.XC_CL_Task_Rejected)) {
                    return true; 
                }
            }
        }
        return true;
    }*/

/**
    @name           assingSLA
    @description    vb - SLA funtionality
    return         -
    @author           VBV
    @email            vbarquero@deloitte.es
    @lastChange       Federico Amici, [21/01/2019],     deleted Trigger.isInsert line - method is executed only by an insert trigger
                                                        moved from the XC_TR_Case_U_Care_SLAs class
    @lastlastChange [01/03/2019] Monica Cutillo - monica.cutillo@nttdata.com - add metadata and remove dependency with asset to assign SLA
    **/
    /*/*
    private static void assingSLA(List<Case> caseList, Set<Id> assetIds) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ CALL XC_TR_Case_U_Care_SLAs.assingSLA');
        //vb Map SAL contains as key AssetId en as value the catalog category Name
        //Map<Id, String> catalogCategoryNamesMap = new Map<Id, String>();
        Map<String, Entitlement> slaMap = new  Map<String, Entitlement>();

        //catalogCategoryNamesMap = XC_AT_Utils.getCatalogCategoryNamesMap(assetIds);
        //vb Entitlement List
        slaMap = XC_AT_Utils.getSLAEntitlement();

        Map<String, XC_CM_Case_ESPAttentionTypes__mdt> attentionTypeMap = XC_UTIL_Case_U.retriveCaseESPAttentionTypesFromCases(caseList);
        String mtdKey;
        XC_CM_Case_ESPAttentionTypes__mdt attentionTypes;
        for(Case newCase : caseList){

            if (newCase.Reason==null || newCase.Subcause__c==null){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ assingSLA failed for null data > Reason='+newCase.Reason+' , Subcause='+newCase.Subcause__c);  
                return;
            }
            mtdKey = newCase.Reason + '_' + newCase.Subcause__c;
            if(newCase.XC_Subtype__c != null){
                mtdKey = mtdKey + '_' + newCase.XC_Subtype__c;
            }
            attentionTypes = attentionTypeMap.get(mtdKey);
            if(attentionTypes==null && newCase.XC_Subtype__c != null){
                mtdKey = newCase.Reason + '_' + newCase.Subcause__c;
                attentionTypes = attentionTypeMap.get(mtdKey);
            }
            if(attentionTypes==null){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ SLA - No Match on XC_CM_Case_ESPAttentionTypes__mdt for Case='+newCase);
                continue;
            }

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ SLA - attentionTypes=' + attentionTypes);
            if(attentionTypes.XC_SLAProcess__c!=null) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ SLA - XC_CM_Case_ESPAttentionTypes__mdt XC_SLAProcess__c=' + attentionTypes.XC_SLAProcess__c); 
                if(!slaMap.isEmpty()){
                    //vb SlaProcess --> MilestoneType
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'SLAEntitlement map found'); 
                    Entitlement et = slaMap.get(attentionTypes.XC_SLAProcess__c);
                    if(et!=null ){
                        newCase.EntitlementId = et.Id;
                    }else XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ assingSLA - no se encuentra Entitlement en el mapa ');  
                }else XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ assingSLA - caso sin Cuenta sociada ');  
            }else XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ assingSLA - XC_SLAProcess__c sin info en la custom setting encontrada');  
        }
    }
    */ /**/

/**
     * @author Sara Miozza - sara.miozza@nttdata.com & Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com
     * @param listNew case list
     * @description fillRecordType
     */
    public static void fillRecordType(List<Case> listNew) {
        
        String recordTypeId;
        List<String> reasonList = XC_UTIL_Sobject.getListFieldValues(listNew, 'Reason'); 
        List<String> legalEntityList = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_LegalEntity__c'); 
        List<String> streamList = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Segment__c'); 
        System.debug('@@@@ Entrato in fillRecordType con ' +reasonList);
        
        Map<Id, XC_CM_CaseReasonRtMapping__mdt> caseReasonMap = new Map<Id, XC_CM_CaseReasonRtMapping__mdt>
                                                                ([SELECT Id, XC_CaseReason__c, XC_CaseRecordType__c, XC_LegalEntity__c, XC_Stream__c 
                                                                FROM XC_CM_CaseReasonRtMapping__mdt
                                                                WHERE XC_CaseReason__c IN : reasonList AND XC_LegalEntity__c IN: legalEntityList AND XC_Stream__c IN: streamList]);
        String defRTName;
        Map<String,String> defaultRT = XC_UTIL_Case.getDefaultCaseRecordTypeByMetadata(new Set<String>(legalEntityList), new Set<String>(streamList));
        for(Case c : listNew){
            for(XC_CM_CaseReasonRtMapping__mdt cr : caseReasonMap.values()){
                if(c.Origin == Label.XC_CL_EmailToCaseOrigin && String.isNotBlank(c.RecordTypeId)){
                    continue;
                }
                if(c.Reason == cr.XC_CaseReason__c && c.XC_LegalEntity__c == cr.XC_LegalEntity__c && c.XC_Segment__c == cr.XC_Stream__c){
                    c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(cr.XC_CaseRecordType__c).getRecordTypeId();
                    System.debug('@@@ RecordTypeId ' +c.RecordTypeId);
                }
                if(c.RecordTypeId == null){		//20200113 [MC] fix email2case B2B, set RT
                    //defRTName = XC_UTIL_Case.getDefaultCaseRecordType(c.XC_LegalEntity__c);
                    if(defaultRT.get(c.XC_LegalEntity__c + c.XC_Segment__c) != null){
                        defRTName = defaultRT.get(c.XC_LegalEntity__c + c.XC_Segment__c);
                    }else{
                        defRTName = defaultRT.get('master_default');
                    }
                    c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(defRTName).getRecordTypeId();
                }
            }
            if(String.isBlank(c.RecordTypeId)){
                c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(defaultRT.get('master_default')).getRecordTypeId();
            }
        }
        
    }

    /**
     * @author Dario Tramontin - dtramontin@deloitte.it
     * @lastChange 20191205 Monica Cutillo - mcutillo@deloitte.it [ESCEP-2292]
     * @param listNew case list
     * @description avoid UnsubIstEqpBadSale and UnsubContrSerBadSale Case creation if doesn't exixist the appropriate ComplaintBadSale
     */
    /*public static void checkExistAppropriateCase(List<Case> listNew){
        //List<Id> accountList = new List<Id>();
        List<Id> assetList = new List<Id>();
        //List<Id> contactList = new List<Id>();
        List<Case> unsBSCases = new List<Case>();

        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_ComplaintBadSale_CaseSettings,Label.XC_CL_UnsubIstEqpBadSale_CaseSettings,Label.XC_CL_UnsubContrSerBadSale_CaseSettings});
        if(caseSettingsMap.get(Label.XC_CL_ComplaintBadSale_CaseSettings)==null || caseSettingsMap.get(Label.XC_CL_UnsubIstEqpBadSale_CaseSettings)==null
           || caseSettingsMap.get(Label.XC_CL_UnsubContrSerBadSale_CaseSettings)==null){ //caseSettingsMap.isEmpty() || 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on Case_Type_Setting__mdt for '+
                Label.XC_CL_ComplaintBadSale_CaseSettings+' or '+Label.XC_CL_UnsubIstEqpBadSale_CaseSettings+' or '+Label.XC_CL_UnsubContrSerBadSale_CaseSettings);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ checkExistAppropriateCase NOT processed!');
            return;
        }
        for(Case c: listNew){
            //if(c.Reason.equals(Label.XC_CL_CaseReason_XCMOT010) && c.SubCause__c.equals(Label.XC_CL_SubCause_BadSaleValue) ){
            if( XC_UTIL_Case.matchSettings(c, caseSettingsMap.get(Label.XC_CL_UnsubIstEqpBadSale_CaseSettings)) || 
                XC_UTIL_Case.matchSettings(c, caseSettingsMap.get(Label.XC_CL_UnsubContrSerBadSale_CaseSettings)) ){
                //accountList.add(c.AccountId);
                if(c.AssetId != null){
                    assetList.add(c.AssetId);
                    unsBSCases.add(c);
                }
                //contactList.add(c.ContactId);
            }
        }
        XC_CM_Case_Type_Setting__mdt complaintCaseSett = caseSettingsMap.get(Label.XC_CL_ComplaintBadSale_CaseSettings);
        //if(accountlist!= null && assetList!=null && contactList!=null){
        if(!unsBSCases.isEmpty()){
            //List<Case> caseL = [SELECT Id FROM Case WHERE AccountId IN :accountlist AND AssetId IN :assetList AND ContactId IN :contactList AND Status = :Label.XC_CL_Case_Status007 AND Reason = :Label.XC_CL_CaseReason_ComplaintValue AND SubCause__c= :Label.XC_CL_SubCause_BadSaleValue AND XC_Result__c = :Label.XC_CL_Case_Result001 ];
            Map<Id,Case> complCaseData = new Map<Id,Case>(
                [SELECT Id, AssetId, XC_Subtype__c
                   FROM Case 
                  WHERE AssetId IN :assetList 
                    //AND AccountId IN :accountlist
                    //AND ContactId IN :contactList 
                    AND Status =: Label.XC_CL_Case_Status007 
                    AND Reason =: complaintCaseSett.XC_Case_Reason__c //Label.XC_CL_CaseReason_ComplaintValue 
                    AND SubCause__c=: complaintCaseSett.XC_Sub_Cause__c //Label.XC_CL_SubCause_BadSaleValue 
                    //AND XC_Subtype__c =: complaintCaseSett.XC_Sub_Type__c // Fix MC_AV 04/01/2020
                    AND XC_Result__c =: Label.XC_CL_Case_Result001 ]);
            
            //I take all asset ids with complaint case
            Set<Id> assetWithComplaitIds = new Set<Id>();
            for(Case complCase : complCaseData.values()){
                if(String.isBlank(complaintCaseSett.XC_Sub_Type__c) || complaintCaseSett.XC_Sub_Type__c == complCase.XC_Subtype__c){
                	assetWithComplaitIds.add(complCase.AssetId);
                }
            }
            for(Case c: unsBSCases){
                //if(!caseL.contains(c)){
                //if don't exixts for the asset the Complain closed procedant Case >> Error
                if(!assetWithComplaitIds.contains(c.AssetId)){
                    c.addError(Label.XC_CL_CantCreateComplaintBadSaleCaseMess); //(Label.XC_CL_Case_AlreadyExist);
                }
            }
        }
    }*/
    /**
	 * @author Calogero Perconti - cperconti@deloitte.it
	 * @param listNew the list new
	 * @param mapOld the map old
     * @param mapNew the map new
     * @description check Case Permitting Status if document SF_RESULT_DOC is present in case Completed OK or Completed KO
    */
    public static void checkPermittingStatus(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ START checkPermittingStatus');
        List<String> fieldList = new List<String>{'XC_Permitting_Status__c'};
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);

        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_PermittingManagement});
        XC_CM_Case_Type_Setting__mdt caseTypeSetting = new XC_CM_Case_Type_Setting__mdt();
        caseTypeSetting = mapCaseSetting.get(Label.XC_CL_PermittingManagement);
        Map<Id, Case> idToCase = new Map <Id, Case> ();
        for(Case c : listChanged) {
            if((c.XC_Permitting_Status__c == Label.XC_CL_Completed_Ok || c.XC_Permitting_Status__c == Label.XC_CL_Step_CompletedKO) && (c.Reason == caseTypeSetting.XC_Case_Reason__c && c.Subcause__c ==caseTypeSetting.XC_Sub_Cause__c && c.XC_Subtype__c ==caseTypeSetting.XC_Sub_Type__c)) {
                idToCase.put(c.id, c);
            }  
        }
        if(idToCase.isEmpty()) 
		{
            System.debug('idToCase is empty');
            return;
        }
        String SF_RESULT_DOC = Label.XC_CL_DocumentType_Category_SF_RESULT_DOC;
        List<XC_DocumentType__c> cDocuments = [SELECT ID, CASE__c, Category__c 
                                               FROM XC_DocumentType__c
                                               WHERE CASE__c IN :idToCase.keySet()
                                               AND Category__c = :SF_RESULT_DOC];
        if(cDocuments.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'Not found SF_RESULT_DOC');
            listChanged.get(0).addError(Label.XC_CL_Case_PermittingClosure);
            return;
        }    
        
        Map<Id, String> casesToDocCategory = new Map<Id, String>();
        for(XC_DocumentType__c doc : cDocuments){
            
            casesToDocCategory.put(doc.CASE__c, doc.Category__c);
        }
        
        for(Id ci : casesToDocCategory.keySet()){
            String caseDocuments = casesToDocCategory.get(ci);
            if (caseDocuments.contains(Label.XC_CL_DocumentType_Category_SF_RESULT_DOC)){
                idToCase.get(ci).XC_Result__c = (idToCase.get(ci).XC_Permitting_Status__c == Label.XC_CL_Completed_Ok) ? Label.XC_CL_CaseResolutionRS003 : Label.XC_CL_CaseResult_RS004;
                idToCase.get(ci).XC_Resolution__c=Label.XC_CL_Case_Resolution_R001;
                idToCase.get(ci).CaseRemarks__c=(idToCase.get(ci).XC_Permitting_Status__c == Label.XC_CL_Completed_Ok) ? Label.XC_CL_Case_Close_PermittingStatus_OK : Label.XC_CL_Case_Close_PermittingStatus_KO;
                if(idToCase.get(ci).XC_ProvisioningStep__c != null){
                    relaunchStep(idToCase.get(ci).XC_ProvisioningStep__c);
                }
                else{
                    System.debug('XC_ProvisioningStep__c is null');
                }
            }
            
        }
        
    }
    @future(callout=true)
    public static void relaunchStep(Id stepId) {
        List<XC_Provisioning_Step__c> listSteps = XC_UTIL_Sobject.selectAllFields(stepId);
        XC_UTIL_ProvisioningStep.executeSteps(listSteps);
    }
}