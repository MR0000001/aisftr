/**
* @author Salvatore Scarpato -  salvatore.scarpato@nttdata.com
* @date Creation 01/02/2021
* @date Modification dd/mm/yyyy
* @description  – XC_TR_Case_U_SetQualityCheckStatus class related to the HSEQ Process.
*/ 

public without sharing class XC_TR_Case_U_SetQualityCheckStatus {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_SetQualityCheckStatus');
    
      /**
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
      * @param mapOld Map<Id, Case> from trigger
      * @param mapNew Map<Id, Case> from trigger
      * @return the list
      * @description Given a list of case from case handler, set the status of the related quality check record to Validated (NR0857)
      */
      public static void setQCStatusToValidated(Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
            List<String> fieldList = new List<String>{'XC_UpdateNonCompliancePenalty__c','XC_NoNonDifformity__c'};
            List<Case> caseChangedList = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
            List<String> qualityCheckIdList = new List<String>();
            List<XC_B2BG_QualityCheck__c> qualityChecksToUpdateList = new List<XC_B2BG_QualityCheck__c>();
            for(Case newCase : caseChangedList){
                Case oldCase = mapOld.get(newCase.Id); 
                if( (oldCase.XC_UpdateNonCompliancePenalty__c != newCase.XC_UpdateNonCompliancePenalty__c && newCase.XC_UpdateNonCompliancePenalty__c) || (oldCase.XC_NoNonDifformity__c != newCase.XC_NoNonDifformity__c && newCase.XC_NoNonDifformity__c)){
                    qualityCheckIdList.add(newCase.XC_CheckList__c);
                }
            }
            for(String qualityCheckId : qualityCheckIdList){
                XC_B2BG_QualityCheck__c qualityCheck = new XC_B2BG_QualityCheck__c(Id = qualityCheckId);
                qualityCheck.XC_Status__c = Label.XC_CL_QualityCheckStatus_Validated;
                qualityChecksToUpdateList.add(qualityCheck);
            } 
            XC_UTIL_Sobject.updateListRecords(qualityChecksToUpdateList); 
      }
      
      
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com - Marco Rosa - marco.rosa@nttdata.com
    * @date 11/02/2021
    * @description Method to complete a milestone under a case 
    * @param listCase
    * @param milestoneName
    * @param completionDate
    */ 
    public static void completeMilestoneQualityCheck(Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        List<String> fieldList = new List<String>{'XC_NonComplianceFound__c','XC_NoNonDifformity__c'};
        List<Case> caseChangedList = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!caseChangedList.isEmpty()){
            XC_UTIL_Entitlement.completeMilestone(caseChangedList, 'XC_ITA_QualityCheckSendMail', System.now());
        } 
    }
}