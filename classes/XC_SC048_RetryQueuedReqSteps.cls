/**
* @description XC_SC048_RetryQueuedReqSteps - Batch to retry queued requests step
* @author Simone Trenta - strenta@deloitte.it
*/

public without sharing class XC_SC048_RetryQueuedReqSteps implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC048_RetryQueuedReqSteps');

	/**
     * @description execute method
     * @param sc - SchedulableContext 
    */
	public void execute(SchedulableContext sc) { 
		Id batchId = Database.executeBatch(new XC_SC048_RetryQueuedReqSteps(), 50);
	}     

	/**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch SC048');
		String query = 'SELECT Id, XC_Retried__c, XC_Status__c, XC_ErrorMessage__c, XC_QueuedRequest__c ' + 
        			   'FROM XC_QueuedRequestStep__c ' +
        			   'WHERE XC_Status__c = \'Completed KO\' and XC_Retried__c = false '+
                       'ORDER BY LastModifiedDate ASC '+
                       'LIMIT 50';
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'query ' +  Database.getQueryLocator(query));	
        return Database.getQueryLocator(query);
    }

	/** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<XC_QueuedRequestStep__c> scope) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Execute batch SC048');

        List<sObject> recToUpdate = new List<sObject>();

        List<String> reqIds = new List<String>();
        for(XC_QueuedRequestStep__c s:scope){
            reqIds.add(s.XC_QueuedRequest__c);
            s.XC_Retried__c = true;
            s.XC_ErrorMessage__c = '';
            recToUpdate.add(s);
        }

        List<XC_QueuedRequest__c> reqProcess =  XC_UTIL_Sobject.selectAllFields(reqIds, 'XC_QueuedRequest__c');

        for(XC_QueuedRequest__c q:reqProcess){
            q.XC_Status__c = 'In Progress';
            recToUpdate.add(q);
        }

        XC_UTIL_Sobject.updateListRecords(recToUpdate);
        XC_UTIL_QueuedRequestStep.setStepInProgressAndEmitEvent(scope);

    }

	/**
     * @description finish method
     * @param bc - BatchableContext 
    */
	public void finish(Database.batchablecontext bc) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch SC048'); 
    }

}