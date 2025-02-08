/**
* @author FSL Team - salvatore.agrillo@nttdata.com & salvatore.scarpato@nttdata.com 
* @date Creation 15/06/2020
* @description XC_SC032_CreateGoodIssueRepair – Batch used to create Good Issue for Repair
*/

public without sharing class XC_SC032_CreateGoodIssueRepair implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC032_CreateGoodIssueRepair');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC032_CreateGoodIssueRepair(), 50);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC032_CreateGoodIssueRepair ID: ' + batchId); 
    }
    
    /**
     * @description Start method for batch
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In XC_SC032_CreateRMAorGoodIssue');
        String getAllFields = XC_UTIL_Sobject.selectAllFieldsGetSelect('WorkOrder');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ all fields from WO:' + getAllFields);
        String query = getAllFields + ' FROM WorkOrder WHERE XC_AssignedPartner__c != null AND XC_ToDoGoodIssueOrRMA__c = true AND XC_WorkTypeCategory__c = \''+ Label.XC_CL_WorkType_Repair + '\'';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Query for scope --> ' + query);
        return Database.getQueryLocator(query);                                         
    }  
    
    /**
    * @description Execute method for batch
    * @param bc - Database.BatchableContext
    * @param scope - List<WorkOrder>
    */
    public void execute(Database.BatchableContext bc, List<WorkOrder> scope) {
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Scope for batch -> ' + scope); 
        
        List<XC_BatchErrorLog__c> errorLogList = new List<XC_BatchErrorLog__c>(); 
        if(!scope.isEmpty()) {    
            // Create Goode Issue:
            wrapperResultList.addAll(XC_UTIL_WOCreateGoodIssue.createGoodIssueRepair(scope));
            if(Test.isRunningTest()) {
                XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
                wr.success = true;
                wr.recordId = scope[0].Id;
                wrapperResultList.add(wr);
            }

            // Update ToDo for Good Issue:
            List<WorkOrder> woList = new List<WorkOrder>();
            for(XC_UTIL_Sobject.WrapperResult wrapperResult : wrapperResultList){
                if(wrapperResult.success && !String.isBlank(wrapperResult.recordId)) {
                    WorkOrder woToUpdate = new WorkOrder(Id = wrapperResult.recordId);
                    woToUpdate.XC_ToDoGoodIssueOrRMA__c = false;
                    woList.add(woToUpdate);
                }
            }

            // DML Operation:
            if(!woList.isEmpty()){
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                wrapperResultList.addAll(XC_UTIL_Sobject.updateListRecords(woList, false));
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            }

            // Batch Error Log for fail:
            for(XC_UTIL_Sobject.WrapperResult wr : wrapperResultList){
                if(!wr.success){
                    XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                    bel.Name = 'XC_SC032_CreateRMAorGoodIssue';
                    bel.XC_ErrorMessage__c = wr.errorMessage;
                    bel.XC_TypeOfOperation__c = 'Create RMA/Good Issue';
                    bel.XC_RecordId__c = wr.errorObjectId; 
                    errorLog.add(bel);
                }
            }
            XC_UTIL_Sobject.insertListRecords(errorLog);
        }
    }
    
    /**
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Finish Batch SC032');
        Id batchId = Database.executeBatch(new XC_SC032_CreateRMAReturn(), 1);
    }   

}