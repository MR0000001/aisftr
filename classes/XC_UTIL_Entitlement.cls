/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com - Marco Rosa - marco.rosa@nttdata.com
* @date 11/02/2021
* @description XC_UTIL_Entitlement - Util class for Entitlements and Milestones
*/ 

public without sharing class XC_UTIL_Entitlement {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Entitlement');

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com - Marco Rosa - marco.rosa@nttdata.com
    * @date 11/02/2021
    * @description Method to complete a milestone under a case 
    * @param listCase
    * @param milestoneName
    * @param completionDate
    */ 
    public static void completeMilestone(List<Case> listCase, String milestoneName, DateTime completionDate) {
        List<CaseMilestone> cmsToUpdate = [
            Select Id, completionDate
            FROM CaseMilestone
            WHERE caseId in :listCase
            AND milestoneType.Name =: milestoneName 
            AND completionDate = null
        ]; 
        for (CaseMilestone cm : cmsToUpdate){
            cm.completionDate = completionDate;
        } 
        XC_UTIL_Sobject.updateListRecords(cmsToUpdate);
    }
}