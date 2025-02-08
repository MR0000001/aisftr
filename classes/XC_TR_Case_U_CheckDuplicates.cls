/**
 * The Class XC_TR_Case_U_CheckDuplicates.
 *
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @date Creation dd/mm/yyyy
 * @date 11/02/2019 Monica Cutillo - monica.cutillo@nttdata.com
 * @date 21/03/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_TR_Case_U_Care_CheckDuplicates – Evaluate the duplication checks for Case creation
 */

public without sharing class XC_TR_Case_U_CheckDuplicates {    

    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_CheckDuplicates');

    /**
     * @description Check duplicates.
     *
     * @param listNew the list new
     */
    public static void checkDuplicates(List<Case> listNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ START checkDuplicates');
        List<Case> listCasesToCheck = new List<Case>();
        Map<String,String> mapCaseFamily= XC_UTIL_Case.getCaseRecordTypeFamily(listNew);
        for(Case newCase : listNew) {
            // Check to skip Case Duplication
            if(newCase.XC_IsCloned__c || newCase.Origin == Label.XC_CL_EmailToCaseOrigin || ((Label.XC_CL_Case_FamilyComplaintRT).equals(mapCaseFamily.get(newCase.Reason)) && !String.isBlank(newCase.XC_ClaimType__c)) ) {
                continue;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Skip CheckDuplicates Case in Insert');
            listCasesToCheck.add(newCase);     
        }

        if(listCasesToCheck.isEmpty()) {
            return;
        }

        List<String> listContactId   = XC_UTIL_Sobject.getListFieldValues(listCasesToCheck, 'ContactId');
        List<String> listReason      = XC_UTIL_Sobject.getListFieldValues(listCasesToCheck, 'Reason');
        List<String> listSubcause    = XC_UTIL_Sobject.getListFieldValues(listCasesToCheck, 'Subcause__c');
        List<String> listSubtype     = XC_UTIL_Sobject.getListFieldValuesWithNullValue(listCasesToCheck, 'XC_Subtype__c');
        List<String> listParentId    = XC_UTIL_Sobject.getListFieldValuesWithNullValue(listCasesToCheck, 'ParentId');
        List<String> listWorkOrder   = XC_UTIL_Sobject.getListFieldValuesWithNullValue(listCasesToCheck, 'XC_WorkOrder__c');
        List<String> listOpportunity = XC_UTIL_Sobject.getListFieldValuesWithNullValue(listCasesToCheck, 'XC_Opportunity__c');
        List<String> listOrder       = XC_UTIL_Sobject.getListFieldValuesWithNullValue(listCasesToCheck, 'XC_Order__c');
        List<String> listOrderItem   = XC_UTIL_Sobject.getListFieldValuesWithNullValue(listCasesToCheck, 'XC_OrderItem__c');
        List<String> listAsset   = XC_UTIL_Sobject.getListFieldValuesWithNullValue(listCasesToCheck, 'AssetId');
        List<String> listTypeIntermediary = XC_UTIL_Sobject.getListFieldValuesWithNullValue(listCasesToCheck, 'XC_Type_Intermediary__c'); /* ESCEP-2049 MC 20190829 */
        List<string> listAssetTechnical=XC_UTIL_Sobject.getListFieldValuesWithNullValue(listCasesToCheck, 'XC_TechnicalAsset__c'); /*NA 21092020 List Technicl Asset*/

        Map<Id,Case> listExistingCasesMap = new Map<Id,Case>([
            SELECT Id,Status, RecordTypeId, ContactId, ParentId, CaseNumber, Subcause__c, XC_Subtype__c, Reason, Priority,
            XC_WorkOrder__c, XC_Opportunity__c, XC_Order__c, XC_OrderItem__c, AssetId, XC_Type_Intermediary__c,XC_TechnicalAsset__c
            FROM Case 
            WHERE Status !=: Label.XC_CL_Case_Status008
                AND ContactId IN :listContactId
                AND Reason IN :listReason
                AND Subcause__c IN :listSubcause
                AND XC_Subtype__c IN :listSubtype
                AND ParentId IN :listParentId
                AND XC_WorkOrder__c IN :listWorkOrder
                AND XC_Opportunity__c IN :listOpportunity
                AND XC_Order__c IN :listOrder
                AND XC_OrderItem__c IN :listOrderItem
                AND AssetId IN: listAsset
                AND XC_TechnicalAsset__c IN:listAssetTechnical
                AND XC_Type_Intermediary__c IN :listTypeIntermediary
                /*AND (XC_Subtype__c IN :listSubtype OR XC_Subtype__c = null)
                AND (ParentId IN :listParentId OR ParentId = null)
                AND (XC_WorkOrder__c IN :listWorkOrder OR XC_WorkOrder__c = null)
                AND (XC_Opportunity__c IN :listOpportunity OR XC_Opportunity__c = null)
                AND (XC_Order__c IN :listOrder OR XC_Order__c = null)
                AND (XC_OrderItem__c IN :listOrderItem OR XC_OrderItem__c = null)*/
            ]);

        Map<String,String> caseRtFamily = XC_UTIL_Case.getCaseRecordTypeFamily(listCasesToCheck);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ caseRtFamily='+caseRtFamily);
        for(Case caseToCheck : listCasesToCheck) {
            for(Case existingCase : listExistingCasesMap.values()) {
                if( caseToCheck.Id != null && existingCase.Id == caseToCheck.Id ){
                    continue;
                } 
                if( utilMethodToCheckPartA(caseToCheck, existingCase) && utilMethodToCheckPartB(caseToCheck, existingCase)
                    && checkComplaintCase(caseToCheck, existingCase, caseRtFamily.get(caseToCheck.Reason)) ) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ Case duplicate: ' + existingCase.Id + ')');
                        
                    if( Label.XC_CL_Case_FamilyComplaintRT == caseRtFamily.get(caseToCheck.Reason) &&
                        existingCase.Status.equals(Label.XC_CL_Case_Status007)){
                        caseToCheck.addError(Label.XC_CL_Trigger_Error_CaseIsClosedReasonSubcause1 + ' ' + 
                                            existingCase.CaseNumber + '. ' + 
                                            Label.XC_CL_Trigger_Error_CaseIsClosedReasonSubcause2);
                    }else if( !existingCase.Status.equals(Label.XC_CL_Case_Status007)){
                        caseToCheck.addError(Label.XC_CL_Trigger_Error_CaseIsOpenReasonSubcause1 + ' ' + 
                                            existingCase.CaseNumber + '. ' + 
                                            Label.XC_CL_Trigger_Error_CaseIsOpenReasonSubcause2);
                    }
                    break;
                }
            }
        }
    }

    /**
     * @description Check duplicates.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkDuplicates(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
        List<String> fieldList = new List<String> {
            'Reason',
            'Subcause__c',
            'XC_Subtype__c',
            'ParentId',
            'XC_WorkOrder__c',
            'XC_Opportunity__c',
            'XC_Order__c',
            'XC_OrderItem__c',
            'AssetId',
            'XC_TechnicalAsset__c',
            'XC_Type_Intermediary__c' /* ESCEP-2049 MC 20190829 */
        };
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew); 
        if(!listChanged.isEmpty()) {
            checkDuplicates(listChanged);
        } 
    } 


    /**
     * @description Method to avoid the cyclomatic complexity issue in checkDuplicates method.
     * @param caseToCheck
     * @param existingCase
     * @return check
     */
    private static Boolean utilMethodToCheckPartA(Case caseToCheck, Case existingCase){
        Boolean check = false;
        if(caseToCheck.ContactId      == existingCase.ContactId         &&
        caseToCheck.Reason            == existingCase.Reason            &&
        caseToCheck.Subcause__c       == existingCase.Subcause__c       &&
        caseToCheck.XC_Subtype__c     == existingCase.XC_Subtype__c     &&
        caseToCheck.ParentId          == existingCase.ParentId ) {
            check = true;
        }
        return check;
    } 
    /**
     * @description Method to avoid the cyclomatic complexity issue in checkDuplicates method.
     * @param caseToCheck
     * @param existingCase
     * @return check 
     */
    private static Boolean utilMethodToCheckPartB(Case caseToCheck, Case existingCase){
        Boolean check = false;
        if(caseToCheck.XC_WorkOrder__c   == existingCase.XC_WorkOrder__c   &&
           caseToCheck.XC_Opportunity__c == existingCase.XC_Opportunity__c &&
           caseToCheck.XC_Order__c       == existingCase.XC_Order__c       &&
           caseToCheck.XC_OrderItem__c   == existingCase.XC_OrderItem__c   &&
           caseToCheck.AssetId           == existingCase.AssetId           &&
           caseToCheck.XC_TechnicalAsset__c == existingCase.XC_TechnicalAsset__c){
            check = true;
        }
        return check;
    }

    /**
     * @description ESCEP-2049 MC 20190829
     * @param caseToCheck
     * @param existingCase
     * @param caseRtFamily
     * @return check 
     */
    private static Boolean checkComplaintCase(Case caseToCheck, Case existingCase, String caseRtFamily){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkComplaintCase - caseRtFamily ='+caseRtFamily);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'caseToCheck.XC_Type_Intermediary__c ='+caseToCheck.XC_Type_Intermediary__c);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'existingCase.XC_Type_Intermediary__c ='+existingCase.XC_Type_Intermediary__c);
        Boolean check = false;
        if(Label.XC_CL_Case_FamilyComplaintRT != caseRtFamily){
            check = true;
        }
        else if(caseToCheck.XC_Type_Intermediary__c == existingCase.XC_Type_Intermediary__c){
            check = true;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ checkComplaintCase result='+check);
        return check;
    }
}