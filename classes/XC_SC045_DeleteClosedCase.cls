/**
* @description XC_SC045_DeleteClosedCase - Batch to delete case
* @author Simone Trenta - strenta@deloitte.it
*/

public without sharing class XC_SC045_DeleteClosedCase implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC045_DeleteClosedCase');

	/**
     * @description execute method
     * @param sc - SchedulableContext 
    */
	public void execute(SchedulableContext sc) { 
		Id batchId = Database.executeBatch(new XC_SC045_DeleteClosedCase());
	}     

	/**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch SC045');
		String query = 'SELECT Id, ClosedDate ' + 
        			   'FROM Case ' +
        			   'WHERE ClosedDate = LAST_N_WEEKS:1 and (Status = \'Closed\' OR Status = \'ESTA007\') and Reason = \'XCMOT009\' and SubCause__c = \'ATCL160\' order by ClosedDate';
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'query ' +  Database.getQueryLocator(query));	
        return Database.getQueryLocator(query);
    }

	/** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<Case> scope) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Execute batch SC045');

		XC_UTIL_Sobject.deleteListRecords(scope);
    }

	/**
     * @description finish method
     * @param bc - BatchableContext 
    */
	public void finish(Database.batchablecontext bc) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch SC045'); 
    }

}