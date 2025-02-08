/**
* @description XC_SC049_DeleteQueuedRequest - Batch to delete qr
* @author Simone Trenta - strenta@deloitte.it
*/

public without sharing class XC_SC049_DeleteQueuedRequest implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC049_DeleteQueuedRequest');

	/**
     * @description execute method
     * @param sc - SchedulableContext 
    */
	public void execute(SchedulableContext sc) { 
		Id batchId = Database.executeBatch(new XC_SC049_DeleteQueuedRequest());
	}     

	/**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch SC049');

		String query = 'SELECT Id, XC_Status__c, XC_ValidationStatus__c, LastModifiedDate ' + 
        			   'FROM XC_QueuedRequest__c '+
        			   'WHERE'+setFilter();

		XC_UTIL_Debug.debug(DEBUGACTIVE, 'query ' +  Database.getQueryLocator(query));	

        system.debug(query);

        return Database.getQueryLocator(query);
    }

	/** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<XC_QueuedRequest__c> scope) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Execute batch SC049');

		XC_UTIL_Sobject.deleteListRecords(scope);
    }

	/**
     * @description finish method
     * @param bc - BatchableContext 
    */
	public void finish(Database.batchablecontext bc) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch SC049'); 
    }


    private String setFilter(){
        String condition = '';

        Map<Id,XC_CM_QRDeleteBatchSetting__mdt> temp = new Map<Id,XC_CM_QRDeleteBatchSetting__mdt>([
            SELECT XC_OlderThanDays__c, XC_QueuedRequestStatus__c, XC_Validation__c FROM XC_CM_QRDeleteBatchSetting__mdt
        ]);

        if(temp.values().isEmpty()){
            return ' id = null';
        }

        Decimal days = temp.values()[0].XC_OlderThanDays__c;
        List<String> reqStatus = String.isBlank(temp.values()[0].XC_QueuedRequestStatus__c) ? new List<String>() : temp.values()[0].XC_QueuedRequestStatus__c.split(';'); //nel metadato posso fare diversi valori separati da ';'
        List<String> validation = String.isBlank(temp.values()[0].XC_Validation__c) ? new List<String>() : temp.values()[0].XC_Validation__c.split(';'); //
       
        if(days==null || (reqStatus.isEmpty()&&validation.isEmpty())){
            return ' id = null';
        }

        condition += ' LastModifiedDate < LAST_N_DAYS:'+(Integer)days;

        if(!reqStatus.isEmpty()){
            condition += ' AND ( XC_Status__c = \''+reqStatus[0].trim()+'\'';
            reqStatus.remove(0);
            for(String s:reqStatus){ //metto in OR i vari valori per lo stesso campo , se sono piu di uno 
                condition += ' OR XC_Status__c = \''+s.trim()+'\'';
            }
            condition += ')';
        }

        if(!validation.isEmpty()){
            condition += ' AND ( XC_ValidationStatus__c = \''+validation[0].trim()+'\'';
            validation.remove(0);
            for(String s:validation){ //
                condition += ' OR XC_ValidationStatus__c = \''+s.trim()+'\'';
            }
            condition += ')';
        }

        return condition;
    }

}