/**
* @author FSL Team - salvatore.agrillo@nttdata.com & salvatore.scarpato@nttdata.com 
* @date Creation 15/06/2020
* @description XC_SC032_CreateGoodIssueDelivInstal – Batch used to create Good Issue for Repair
*/

public without sharing class XC_SC032_CreateGoodIssueDelivInstal implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC032_CreateGoodIssueDelivInstal');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 

        Database.executeBatch(new XC_SC032_CreateGoodIssueDelivInstal(), 1);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Batch XC_SC032_CreateGoodIssueDelivInstal in execution'); 

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
        String query = getAllFields + ' FROM WorkOrder WHERE XC_AssignedPartner__c != null AND XC_ToDoGoodIssueOrRMA__c = true AND XC_WorkTypeCategory__c = \''+ Label.XC_CL_WorkType_DeliveryInstallation + '\'';
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
            // Query Sales Order:
            Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>([
                SELECT Id,
                    (SELECT Id, giic_status__c 
                    FROM Sales_Orders__r
                    WHERE giic_Status__c = 'Open')
                FROM WorkOrder
                WHERE Id IN :scope
            ]);
            List<WorkOrder> listWoForGlovia = new List<WorkOrder>();
            for(WorkOrder wo : scope) {
                if(mapWorkOrder.containsKey(wo.Id) && !mapWorkOrder.get(wo.Id).Sales_Orders__r.isEmpty()) {
                    listWoForGlovia.add(wo);
                } 
            }

            // Create Goode Issue From Sales Order:
            wrapperResultList.addAll(XC_UTIL_WOCreateGoodIssue.createGoodIssueFromSalesOrder(listWoForGlovia));
            if(Test.isRunningTest()) {
                XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
                wr.success = true;
                wr.recordId = !listWoForGlovia.isEmpty() ? listWoForGlovia[0].Id : null;
                wrapperResultList.add(wr);
            }

            // Update ToDo for Good Issue:
            Map<Id, WorkOrder> mapWorkOrderUpdated = new Map<Id, WorkOrder>([
                SELECT Id,
                    (SELECT Id, giic_status__c 
                    FROM Sales_Orders__r
                    WHERE giic_Status__c = 'Open')
                FROM WorkOrder
                WHERE Id IN :scope
            ]);
            List<WorkOrder> listWoToUpdateFlag = new List<WorkOrder>();
            for(WorkOrder wo : scope) {
                if(mapWorkOrderUpdated.containsKey(wo.Id) && mapWorkOrderUpdated.get(wo.Id).Sales_Orders__r.isEmpty()) {
                    wo.XC_ToDoGoodIssueOrRMA__c = false;
                    listWoToUpdateFlag.add(wo);
                } 
            }

            /*List<WorkOrder> woList = new List<WorkOrder>();
            for(XC_UTIL_Sobject.WrapperResult wrapperResult : wrapperResultList){
                if(wrapperResult.success && !String.isBlank(wrapperResult.recordId)) {
                    WorkOrder woToUpdate = new WorkOrder(Id = wrapperResult.recordId);
                    woToUpdate.XC_ToDoGoodIssueOrRMA__c = false;
                    woList.add(woToUpdate);
                }
            }*/

            // DML Operation:
            if(!listWoToUpdateFlag.isEmpty()){
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                wrapperResultList.addAll(XC_UTIL_Sobject.updateListRecords(listWoToUpdateFlag, false));
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

        Database.executeBatch(new XC_SC032_CreateGoodIssueRepair(), 1);

    }   

}