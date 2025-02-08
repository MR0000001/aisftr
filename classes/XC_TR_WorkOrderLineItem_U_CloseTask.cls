/**
 * The Class XC_TR_WorkOrderLineItem_Handler.
 *
 * @author Nicola Arrigo - narrigo@deloitte.com
 * @date Creation 13/07/2020
 * @date Modification dd/mm/yyyy 
 * @description XC_TR_WorkOrderLineItem_U_CloseProjectTask – Handler for XC_TR_WorkOrderLineItem Trigger
 */ 
public without sharing class XC_TR_WorkOrderLineItem_U_CloseTask {
    public static void closeProjectTask ( Map<Id,WorkOrderLineItem> mapOldS, Map<Id,WorkOrderLineItem> mapNewS){
        Id recordTypePEId =Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_PE_WOLI').getRecordTypeId();
        Id recordTypeMRId =Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_MR_WOLI').getRecordTypeId();
        List<id> ProjectTasksIds=new List<id>();
        List<WorkOrderLineItem> listNew = mapNewS.values();
        for(WorkOrderLineItem woli:listNew){ 
            if(mapOldS.get(woli.id).Status!=woli.Status &&
               (woli.RecordTypeId==recordTypePEId || woli.RecordTypeId==recordTypeMRId) &&
               woli.Status=='Completed' && 
               woli.XC_Project_Task__c!=null  
               ){
                ProjectTasksIds.add(woli.XC_Project_Task__c);
                system.debug('id task'+' '+woli.XC_Project_Task__c);
            }
        }
        if(ProjectTasksIds.size()>0){
        List<project_cloud__project_task__c> projectTasksList=retrievePT(ProjectTasksIds);
        updatePT(projectTasksList);
        }

    }
   public static List<project_cloud__project_task__c> retrievePT(List<id> ProjectTasksIds){
    system.debug('enter method');  
    List<project_cloud__project_task__c> projectTasksList=[select id,XC_TaskStatus__c, XC_TaskType__c,project_cloud__Completed_Date__c 
                                                              from project_cloud__Project_Task__c 
                                                             where id IN:ProjectTasksIds AND 
                                                                   (XC_TaskType__c='Partner Engagement' OR XC_TaskType__c='Material Supply') ];
       return  projectTasksList;                                                           
   }
   public static void updatePT(List<project_cloud__project_task__c> projectTasksList){
    system.debug('enter method updatePT');   
    for(project_cloud__project_task__c p:projectTasksList){
           p.XC_TaskStatus__c='Closed';
           p.project_cloud__Completed_Date__c=system.today();
       }
       update projectTasksList;
   }
}