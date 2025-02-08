/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 28/08/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Case_D – DAO class for XC_UTIL_Case
*/ 
public without sharing class XC_UTIL_Case_D {
	
    /**
    * @description getCaseReasonRtMappingValues
    * @param listNew List<Case>
    * @return XC_CM_CaseReasonRtMapping__mdt result rows
    **/
    public static List<XC_CM_CaseReasonRtMapping__mdt> getCaseReasonRtMappingValues(List<Case> listNew){
        List<String> reasonList = XC_UTIL_Sobject.getListFieldValues(listNew, 'Reason');
        Set<String> reasonSet  = new Set<String>(reasonList);
        List<String> legalEntityList = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_LegalEntity__c');
        Set<String> legalEntitySet  = new Set<String>(legalEntityList);
        List<String> streamList = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Segment__c');
        Set<String> streamSet  = new Set<String>(streamList);
        Map<Id,XC_CM_CaseReasonRtMapping__mdt> rtByReason = new Map<Id,XC_CM_CaseReasonRtMapping__mdt> (
            [SELECT id, XC_CaseReason__c, XC_CaseRecordType__c, XC_LegalEntity__c, XC_RecordTypeFamily__c
               FROM XC_CM_CaseReasonRtMapping__mdt 
              WHERE XC_CaseReason__c IN: reasonSet 
                AND XC_LegalEntity__c IN:legalEntitySet AND XC_Stream__c IN :streamSet]
        ); 
        
        return rtByReason.values();
    }

    /**
     * @description retrive record from XC_CM_Case_Type_Setting__mdt by a Case List in input
     * @param caseList - List<Case>
     * @return Map<String, XC_CM_Case_Type_Setting__mdt> with associations depending on caseReason, subcause and subType
     */
    public static Map<Id, XC_CM_Case_Type_Setting__mdt> retriveCaseTypeSettingMtdFromCases(List<Case> caseList){
        Map<Id, XC_CM_Case_Type_Setting__mdt> result = new Map<Id, XC_CM_Case_Type_Setting__mdt>();
        Set<String> caseReasonValueSet = new Set<String>();
        Set<String> subCauseValueSet = new Set<String>();
        Set<String> subTypeValueSet = new Set<String>();
        
        for(Case caseObj: caseList){
            caseReasonValueSet.add(caseObj.Reason);
            subCauseValueSet.add(caseObj.Subcause__c);
            subTypeValueSet.add(caseObj.XC_Subtype__c);
        }
        
        Map<Id, XC_CM_Case_Type_Setting__mdt> mtData = new Map<Id, XC_CM_Case_Type_Setting__mdt>([
            SELECT Id, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_Priority__c, 
                   XC_Origin__c, XC_Status__c, XC_Resolution__c, XC_Result__c, XC_CaseRemarks__c, XC_CaseRemarksEnelXItalia__c
            FROM XC_CM_Case_Type_Setting__mdt
            WHERE XC_Case_Reason__c IN: caseReasonValueSet
              AND XC_Sub_Cause__c IN: subCauseValueSet
              AND XC_Sub_Type__c IN: subTypeValueSet
        ]);
        
        for(Case caso : caseList){
            for(XC_CM_Case_Type_Setting__mdt mtd : mtData.values()){
                if(caso.Reason == mtd.XC_Case_Reason__c && caso.Subcause__c == mtd.XC_Sub_Cause__c && caso.XC_Subtype__c == mtd.XC_Sub_Type__c){
                    result.put(caso.Id,mtd);
                    break;
                }
            }
        }
        return result;
    }

    /**
     * @description retrieveCaseTypeData
     * @param casesId - List<Case Id>
     * @return Map<Id,Case> results
     */
    public static Map<Id,Case> retrieveCaseTypeData(List<String> casesId){
        return new Map<Id,Case>([
            SELECT Id, Reason, Subcause__c, XC_Subtype__c, XC_LegalEntity__c
              FROM Case
             WHERE Id IN: casesId
        ]);
    }


    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date Creation 25/11/2020
     * @date Modification dd/MM/yyyy
     * @description filterCasesByCaseTypeSettings
     * @param cases list of case to check
     * @param typeSettingsName
     * @return Cases of typeSettingsName type
     */
    public static List<Case> filterCasesByCaseTypeSettings(List<Case> cases, String typeSettingsName){
        List<Case> result = new List<Case>();
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{typeSettingsName});
        if(caseSettingsMap.isEmpty() || caseSettingsMap.get(typeSettingsName)==null){
            System.debug('@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+typeSettingsName);
            return result;
        }
        for(Case caso: cases){
            if(XC_UTIL_Case.matchSettings(caso, caseSettingsMap.get(typeSettingsName))){
                result.add(caso);
            }
        }
        return result;
    }

}