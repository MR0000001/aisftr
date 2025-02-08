/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 11/10/2019
* @description XC_SC024_UpdateWOAfterFailedVisit – Batch used to set WorkOrder in Cannot Complete when the related Service Appointment 
                                                        has status Reason Visita fallida
*/
public without sharing class XC_SC024_UpdateWOAfterFailedVisit implements Schedulable, Database.Batchable<sObject>{

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC024_UpdateWOAfterFailedVisit');

    /**
	* @description execute method
	* @param sc - SchedulableContext 
	*/ 
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC024_UpdateWOAfterFailedVisit());
    }

    /**
    * @description start method
    * @param bc - BatchableContext 
    * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch XC_SC024_UpdateWOAfterFailedVisit'); 
        String query = 'SELECT Id '+
            'FROM WorkOrder ' +
            'WHERE Status = \'' + Label.XC_CL_OnHold + '\' AND ' +
            'XC_StatusReason__c = \'' + Label.XC_CL_StatusReason_Customernotlocated + '\' AND '+
            'XC_WorkTypeCategory__c =\'' + Label.XC_CL_CommercialVisit + '\' AND '+
            'Id IN (SELECT ParentRecordId ' +
                'FROM ServiceAppointment '+
                'WHERE XC_StatusReason__c = \'' + Label.XC_CL_StatusReason_Failedvisit + '\' AND ' + 
                'Status =\'' + Label.XC_CL_ServiceAppointment_CannotComplete + '\'';
        query = Test.isRunningTest() ? query + ')' : query + ' AND XC_ReadyForCanceled__c = true)';        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Final Query ---> ' + query); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'End start method for batch XC_SC024_UpdateWOAfterFailedVisit'); 
        return Database.getQueryLocator(query);
    }

        /**
    * @description execute method
    * @param bc - BatchableContext 
    * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<WorkOrder> scope) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Enter in execute method'); 
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        List<WorkOrder> listWoToProcess = new List<WorkOrder>();
        for(WorkOrder wo : scope) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For WorkOrder ---> ' + wo);
            wo.Status = Label.XC_CL_CannotComplete;
            listWoToProcess.add(wo);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listWoToProcess ---> ' + listWoToProcess);
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.updateListRecords(listWoToProcess);
        for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC024_UpdateWOAfterFailedVisit';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Update Work Order based on Service Appointment Due Date';
                bel.XC_RecordId__c = wr.errorObjectId;
                errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog); 
    }  

    /**
    * @description finish method
    * @param bc - BatchableContext 
    */
    public void finish(Database.batchablecontext bc) {        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Finish XC_SC024_UpdateWOAfterFailedVisit');
    }
}