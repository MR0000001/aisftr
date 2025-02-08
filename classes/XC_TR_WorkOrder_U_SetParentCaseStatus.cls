/**
 * @description The Class XC_TR_WorkOrder_U_SetParentCaseStatus.
 */
public without sharing class XC_TR_WorkOrder_U_SetParentCaseStatus {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_Handler');
    
    /**
     * @description Sets the parent case status in progress.
     * @param woList the new parent case status in progress
     */
    /*public static void setParentCaseStatusInProgress(List<WorkOrder> woList) {
        List<Case> caseParentdIsInProgress = new List<Case>();
        for(WorkOrder wo : woList){
            if (wo.Status.equals(XC_AT_Constants.TRIGGER_TASK_STATUS_NEW) && wo.CaseId!=null  ){ 
                Case c = new Case(id=wo.CaseId);
                c.Status = Label.XC_CL_Case_InProgress;
                caseParentdIsInProgress.add(c);
            }
            
        }
        XC_UTIL_Sobject.updateListRecords(caseParentdIsInProgress);  
    }
    

    /**
     * @description Sets the parent case status in status pending.
     * @param woList 
     */
    public static void setParentCaseStatusInPending(List<WorkOrder> woList) {
        
        Set<Id> caseIds = new Set<Id>();
        for(WorkOrder wo : woList){
            if(!String.isBlank(wo.CaseId)&&
			    wo.XC_Segment__c=='B2C'){
                caseIds.add(wo.CaseId);
            }
        }

        if(!caseIds.isEmpty()){
            Map<Id, Case> mapCases = new Map<Id,Case>([SELECT Id, Status FROM Case WHERE Id IN: caseIds]);
            List<Case> caseParentdIsInPending = new List<Case>();
            for(WorkOrder wo : woList){
                if (wo.CaseId != null && mapCases.containsKey(wo.CaseId) && mapCases.get(wo.CaseId).Status == Label.XC_CL_Case_InProgress){ 
                    Case c = new Case(id=wo.CaseId);
                    c.Status = XC_AT_Constants.TRIGGER_STATUS_ESTA002;
                    caseParentdIsInPending.add(c);
                }
                
            }
            if(!caseParentdIsInPending.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(caseParentdIsInPending);  
            }   
        }
        
    }


    /**
     * @description Parent case status set and remove pending.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void parentCaseStatusSetAndRemovePending(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String>{'Status','OwnerId'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){ 
            return;
        }

        List<Id> caseIds = XC_UTIL_Sobject.getListFieldValues(listChanged, 'CaseId'); 
        if(caseIds.isEmpty()){
            return;
        } 

        //PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA   
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new SetAndRemovePendingAsync(listChanged, caseIds));
        }else{
            SetAndRemovePending(listChanged, caseIds);
        }        
    }

    /**
    * @description INNER QUEABLE CLASS
    * @author PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA 
    * @return Boolean
    */
    public class SetAndRemovePendingAsync implements Queueable{
        List<WorkOrder> listChanged;
        List<Id> caseIds;
        public SetAndRemovePendingAsync(List<WorkOrder> listChanged, List<Id> caseIds){
            this.listChanged = listChanged;
            this.caseIds = caseIds;
        }

        public void execute(QueueableContext context) {
            SetAndRemovePending(this.listChanged, this.caseIds);
        }
    }
    
    /**
     * @description set and remove pending.
     * @param listChanged the list changed
     * @param caseIds the case ids
     */
    public static void SetAndRemovePending(List<WorkOrder> listChanged, List<Id> caseIds){

        List<Case> caseParentdIsInProgress = new List<Case>();
        Map<Id, Case> mapCases = new Map<Id,Case>([
            SELECT Id, Status,OwnerId 
            FROM Case 
            WHERE Id IN: caseIds
        ]);

        for(WorkOrder wo : listChanged){
            if (wo.CaseId !=null && mapCases.containsKey(wo.CaseId) &&  wo.XC_Segment__c=='B2C'){
                Case c = mapCases.get(wo.CaseId);
                //List<Case> c = [SELECT id, Status,OwnerId FROM Case WHERE Id=: wo.CaseId];
                caseParentdIsInProgress = populateCaseParentInProgress(wo, c);
            }
        }		
        XC_UTIL_Sobject.updateListRecords(caseParentdIsInProgress);  
    }

    /**
     * @description Populate List of parent Case in Progress
     * @param wo
     * @param c
     * @return List<Case>
     */ 
    private static List<Case> populateCaseParentInProgress (WorkOrder wo, Case c){
        List<Case> caseParentdIsInProgress = new List<Case>();
        /*if(wo.Status!=null && wo.OwnerId!=c.OwnerId && (wo.Status.equals(Label.XC_CL_WorkOrder_Canceled) || wo.Status.equals(Label.XC_CL_WorkOrder_Completed) )   ){
            c.status = populateCaseStatus(c);
            caseParentdIsInProgress.add(c);
        }else if(wo.Status!=null && wo.OwnerId!=c.OwnerId && (!wo.Status.equals(Label.XC_CL_WorkOrder_Canceled) && !wo.Status.equals(Label.XC_CL_WorkOrder_Completed) )   ){
            c.status = populateCaseStatus(c);
            caseParentdIsInProgress.add(c);                    
        }*/
        if(wo.Status!=null && wo.OwnerId!=c.OwnerId){
            c.status = populateCaseStatus(c);
            caseParentdIsInProgress.add(c);
        }
        return caseParentdIsInProgress;
    }

    /**
     * @description Parent case status set and remove pending.
     * @param c
     * @return String
     */
    private static String populateCaseStatus(Case c){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_WorkOrder_U_SetParentCaseStatus CALL populateCaseStatus - init parent c.Status='+c.Status);
        if(c.Status.equals(XC_AT_Constants.TRIGGER_STATUS_ESTA002)){
            c.Status = Label.XC_CL_Case_InProgress;
        }
        else if(c.Status.equals(Label.XC_CL_Case_InProgress)){
            c.Status = XC_AT_Constants.TRIGGER_STATUS_ESTA002;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'return parent c.Status='+c.Status);
        return c.Status;
    }
}