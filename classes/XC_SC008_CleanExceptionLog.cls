/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 26/02/2019
* @date Modification dd/mm/yyyy
* @description XC_SC008_CleanExceptionLog – Batch used to automatically delete records in XC_ExceptionLog__c
*/

public class XC_SC008_CleanExceptionLog implements Schedulable, Database.Batchable<sObject> {
    
    public Integer recordsProcessed = 0;
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC008_CleanExceptionLog');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC008_CleanExceptionLog());
    }

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start batch XC_SC008_CleanExceptionLog');
        return Database.getQueryLocator('SELECT Id FROM XC_ExceptionLog__c WHERE CreatedDate = LAST_WEEK');
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<XC_ExceptionLog__c> scope){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Execute batch XC_SC008_CleanExceptionLog');
        recordsProcessed = scope.size();
        delete scope;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Deleted: scope ---> ' + scope);
    }    

    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Records deleted from XC_ExceptionLog__c ---> ' + recordsProcessed);
    }    

}