/**
* @author Dario Tramontin - dtramontin@deloitte.it 
* @date Creation 23/10/2019
* @date Modification dd/mm/yyyy
* @description
**/

public without sharing class XC_TR_Opportunity_U_SetParentCaseStatus {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Opportunity_U_SetParentCaseStatus');

    public static void setParentCaseStatusInPending(List<Opportunity> oppList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Opportunity_U_SetParentCaseStatus - setParentCaseStatusInPending');
        List<Case> caseToUpdate = new List<Case>();
        List<String> oppIds = new List<String>(); 
		for (Opportunity opp : oppList){
			oppIds.add(opp.Id);
		}
        Map<Id,Opportunity> mapCase = new Map<Id,Opportunity>([SELECT Id,XC_CaseId__c, XC_CaseId__r.Status FROM Opportunity WHERE Id IN : oppIds]);
        
        for(Opportunity opp : oppList){
            if ( opp.XC_CaseId__c != null && mapCase.get(opp.Id).XC_CaseId__r.Status == Label.XC_CL_Case_InProgress ){ 
                Case c = new Case(Id=opp.XC_CaseId__c);
                c.Status = Label.XC_CL_Case_Pending;
                caseToUpdate.add(c);
                System.debug('update case Pending');
            }
        }
        XC_UTIL_Sobject.updateListRecords(caseToUpdate);  
    }
 
    public static void manageCasePendingOpp(List<Opportunity> listNew,Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        XC_UTIL_Case.manageCasePendingOpp(listNew,mapOld,mapNew);
    }
}