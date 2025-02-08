/**
* @author Giovanni Schioppa & Fabrizio Antonioli 
* @date Creation 22/10/2018
* @date Modification 
* @description XC_SC004_AutoDeleteIntegrationLog - Batch to delete XC_Integration_Log__c records with CreatedDate > 1 month
*/ 

public class XC_SC004_AutoDeleteIntegrationLog implements Schedulable, Database.Batchable<sObject> {

	private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC004_AutoDeleteIntegrationLog');

	/**
     * @description execute method
     * @param sc - SchedulableContext 
    */
	public void execute(SchedulableContext sc) {	   
		Id batchId = Database.executeBatch(new XC_SC004_AutoDeleteIntegrationLog(),200);
	}
	
	/**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
	public Database.QueryLocator start(Database.BatchableContext bc) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch XC_SC004_AutoDeleteIntegrationLog');
		String query = 'SELECT Id, Name, CreatedDate '+
						' FROM XC_Integration_Log__c ' + 
						' WHERE ' + 
						' XC_To_Be_Deleted__c = TRUE' ;		
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Query ---> ' + query);			
		return Database.getQueryLocator(query);
	}

	/** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
	public void execute(Database.BatchableContext bc, List<XC_Integration_Log__c> scope){
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Execute method for batch XC_SC004_AutoDeleteIntegrationLog');
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ scope ---> ' + scope);
    	List<XC_UTIL_Sobject.WrapperResult> wr = XC_UTIL_Sobject.deleteListRecords(scope);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wr ---> ' + wr);
	}

	/**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC004_AutoDeleteIntegrationLog ID');
	}

}