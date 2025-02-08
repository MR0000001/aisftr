/**
* @description XC_SC048_RetryQueuedReqSteps - Batch to retry queued requests step
* @author Simone Trenta - strenta@deloitte.it
*/

public without sharing class XC_SC055_UnblockQRStepWaiting implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC055_UnblockQRStepWaiting');

	/**
     * @description execute method
     * @param sc - SchedulableContext 
    */
	public void execute(SchedulableContext sc) { 
		Id batchId = Database.executeBatch(new XC_SC055_UnblockQRStepWaiting(), 50);
	}     

	/**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch SC055');
        Datetime now = datetime.now();
		String query = 'SELECT Id, XC_Status__c ' + 
        			   'FROM XC_QueuedRequestStep__c ' +
        			   'WHERE XC_Status__c = \'In Progress\' and XC_StepLabel__c = \'Wait For External\' and XC_DateTimeToUnblock__c <=: now '+
                       'ORDER BY LastModifiedDate ASC '+
                       'LIMIT 1000';
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'query ' +  Database.getQueryLocator(query));	
        return Database.getQueryLocator(query);
    }

	/** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<XC_QueuedRequestStep__c> scope) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Execute batch SC055');

        List<sObject> recToUpdate = new List<sObject>();

        List<String> reqIds = new List<String>();
        for(XC_QueuedRequestStep__c s:scope){
            s.XC_Status__c = 'Completed OK';
            recToUpdate.add(s);
        }


        XC_UTIL_Sobject.updateListRecords(recToUpdate);

    }

	/**
     * @description finish method
     * @param bc - BatchableContext 
    */
	public void finish(Database.batchablecontext bc) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch SC055'); 
    }

}