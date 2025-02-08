/**  
 * @author Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 14/12/2020
 * @description Class to manage Quality Check related operation
 */
public without sharing class XC_TR_Case_U_QualityCheck {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_QualityCheck');
    
    public static void updateWorkOrder(Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        List<Case> caseList = XC_UTIL_SObject.getListChanged(new List<String>{'XC_UpdateNonCompliancePenalty__c'}, mapOld, mapNew);
        List<WorkOrder> listToUpdate = new List<WorkOrder>();
        for(Case c : caseList){
            if(!String.isBlank(c.XC_NonComplianceWorkOrder__c)){ 
                listToUpdate.add(new WorkOrder(Id = c.XC_NonComplianceWorkOrder__c, XC_NonCompliancePenalty__c = true));
            }
        }
        XC_UTIL_Sobject.updateListRecords(listToUpdate);
    } 
}