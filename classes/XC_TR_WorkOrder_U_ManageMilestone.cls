/**
 * @author Roberta Cossiga - rcossiga@deloitte.it
 * @date Creation 02/04/2020
 * @date Modification dd/mm/yyyy
 * @description XC_TR_WorkOrder_U_ManageMilestone - Class to manage Work order Milestone completion
 */
public without sharing class XC_TR_WorkOrder_U_ManageMilestone {
    
    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @param listNew - List<WorkOrder>
     * @param mapOld - Map<Id,WorkOrder>
     * @param mapNew - Map<Id,WorkOrder>
     * @description Method to update WorkOrder Milestone
     */
    public static void updateCompletedMilestone(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String>{'Status', 'XC_StatusReason__c'};
        List<String> fieldListSched = new List<String>{'XC_ScheduledStart__c'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        List<WorkOrder> listChangedSched = XC_UTIL_SObject.getListChanged(fieldListSched, mapOld, mapNew);
        List<EntityMilestone> milestoneToUpdate = new List<EntityMilestone>();
        if(!listChanged.isEmpty()){
            milestoneToUpdate = checkMilestoneCompletion(listChanged);
        }
        if(!listChangedSched.isEmpty()){
        	milestoneToUpdate.addAll(checkMilestoneRestart(listChangedSched));
        }
        XC_UTIL_Sobject.updateListRecords(milestoneToUpdate);
    }
    
     /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @param listNew - List<WorkOrder>
     * @description Method to update WorkOrder Milestone to Complete
     */
    private static List<EntityMilestone> checkMilestoneCompletion(List<WorkOrder> listNew){
        List<Id> workOrderIds = XC_UTIL_Sobject.getIds(listNew);
        List<EntityMilestone> milestoneListToUpdate = new List<EntityMilestone>();
        Map<Id,WorkOrder> milestoneMap = retrieveWOMilestone(workOrderIds, false);
        for (WorkOrder wo : listNew){
            if((wo.XC_WorkTypeCategory__c != 'Repair' && wo.Status == Label.XC_CL_WorkOrder_InProgress) ||
              (wo.XC_WorkTypeCategory__c == 'Repair' && wo.XC_StatusReason__c == Label.XC_CL_StatusReason_ConfirmedByTechnician)){     
                if(milestoneMap.get(wo.Id).EntityMilestones.isEmpty()){
                    return milestoneListToUpdate;
                }
                for(EntityMilestone mil : milestoneMap.get(wo.Id).EntityMilestones){
                    if(!mil.IsViolated) {
                        mil.completionDate = System.now();
                        milestoneListToUpdate.add(mil);
                    }
                }
              }
        }
        return milestoneListToUpdate;
    }
    
    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @param listNew - List<WorkOrder>
     * @description Method to update WorkOrder Milestone to Complete
     */
    private static List<EntityMilestone> checkMilestoneRestart(List<WorkOrder> listNew){
        List<EntityMilestone> milestoneListToUpdate = new List<EntityMilestone>();
        List<Id> workOrderIds = XC_UTIL_Sobject.getIds(listNew);    
        Map<Id,WorkOrder> milestoneMap = retrieveWOMilestone(workOrderIds,  false);
        for(WorkOrder wo : listNew){
            if(milestoneMap.get(wo.Id).EntityMilestones.isEmpty()){
            	return milestoneListToUpdate;
            }
            for(EntityMilestone mil : milestoneMap.get(wo.Id).EntityMilestones){
                mil.Startdate = wo.XC_ScheduledStart__c;
                milestoneListToUpdate.add(mil);
            }
        }
        return milestoneListToUpdate;
    }
    
    
	/**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @param listNew - List<WorkOrder>
     * @description Method to update WorkOrder Milestone to Complete
     */
    private static Map<Id, WorkOrder> retrieveWOMilestone(List<Id> workOrderIds,  Boolean completion){
       return new Map<Id, WorkOrder>([SELECT Id,
           								  (SELECT Id, isCompleted, isViolated, StartDate
                                           FROM EntityMilestones
                                           WHERE isCompleted =: completion
                                           AND (SlaProcess.Name =: 'XC_UrgentWorkOrder'OR SlaProcess.Name =: 'XC_WorkOrderInOneHour'))
                                      FROM WorkOrder
                                      WHERE Id IN: workOrderIds]);
    }    

}