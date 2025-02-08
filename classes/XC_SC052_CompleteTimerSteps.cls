/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 10/05/2021
* @description XC_SC052_CompleteTimerSteps – Batch to complete the timer steps when the unblocking date on the provisioning step record is reached.
*/
public without sharing class XC_SC052_CompleteTimerSteps implements Schedulable, Database.Batchable<sObject> {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC052_CompleteTimerSteps');
    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Database.executeBatch(new XC_SC052_CompleteTimerSteps(), 100);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Batch XC_SC052_CompleteTimerSteps in execution'); 
    }
    
     /**
     * @description Start method for batch
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In XC_SC052_CompleteTimerSteps');
        Date today = Date.today();
        String query = 'SELECT Id, XC_UnblockingDate__c, XC_Status__c FROM XC_Provisioning_Step__c';
        query += ' WHERE XC_UnblockingDate__c <=: today AND XC_Status__c = \'' + Label.XC_CL_Provisioning_Step_InProgress + '\' AND XC_TimerStep__c = true AND XC_UnblockingDate__c != null LIMIT 50000';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Query for scope --> ' + query);
        return Database.getQueryLocator(query);                                         
    }  
    
        /**
    * @description Execute method for batch
    * @param bc - Database.BatchableContext
    * @param scope - List<WorkOrder>
    */
    public void execute(Database.BatchableContext bc, List<XC_Provisioning_Step__c> scope) {
        for(XC_Provisioning_Step__c step : scope){
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
        }
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = XC_UTIL_Sobject.updateListRecords(scope, false);
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();
        for(XC_UTIL_Sobject.WrapperResult wr : wrapperResultList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC052_CompleteTimerSteps';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Complete timer steps batch';
                bel.XC_RecordId__c = wr.errorObjectId; 
                errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog);
    }
    
    /**
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Finish Batch SC052');
    }  
}