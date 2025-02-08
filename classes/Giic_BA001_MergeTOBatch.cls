/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@fujitsu.com
* @date Creation 09/08/2019
* @date Modification dd/mm/yyyy
* @description Giic_BA001_MergeTOBatch – Batch to merge Transfer Order 
*/
public class Giic_BA001_MergeTOBatch implements Database.batchable<Sobject>,Schedulable,Database.Stateful {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_BA001_MergeTOBatch');
    public String query;
    public List<gii__TransferOrder__c> listofTOforUpdate= new List<gii__TransferOrder__c>();
        
/**
* @author Name : Parveen Kaur - Parveen.Kaur@fujitsu.com
* @date 09/08/2019
* @description This is a constructor use to create dynamic query.
*/
    public Giic_BA001_MergeTOBatch(){    
        
        query = 'SELECT Id,gii__Account__c,giic_WarehouseLimitExceeded__c, giic_status__c,gii__TransferToWarehouse__r.gii__Account__c, gii__OrderDate__c,gii__FromWarehouse__c,gii__TransferToWarehouse__c from gii__TransferOrder__c WHERE giic_status__c=\''+System.Label.giic_TODraftStatus+'\' ';
        XC_UTIL_Debug.debug(DEBUGACTIVE,'query'+query);  
        
    } 
    /**
    * @author Name : Parveen Kaur - Parveen.Kaur@fujitsu.com
    * @date  09/08/2019
    * @description This a start method : retrieve the record based on query .    
    * @param  bc Database.BatchableContext
    * @return Database.QueryLocator  records to the execute method
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
       XC_UTIL_Debug.debug(DEBUGACTIVE,'query:::'+query);
        return Database.getQueryLocator(query);
    } 
    /**
    * @author Name : Parveen Kaur - Parveen.Kaur@fujitsu.com
    * @date  09/08/2019
    * @description This a execute method : This method used for process on records which are comming from start method.
    * @param bc Database.BatchableContext 
    * @param listTO List<gii__TransferOrder__c> 
    */
    public void execute(Database.BatchableContext bc, List<gii__TransferOrder__c> toList){
     
        listofTOforUpdate = giic_TransferOrderUtility.processMergeForTO(toList);
    } 
    
    /**
    * @author Name : Parveen Kaur - Parveen.Kaur@fujitsu.com
    * @date  09/08/2019
    * @description This a Finish method : This method ise for run the last process, its execute once in all process
    * @param bc Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc){
        
        Giic_BA010_ShareTO3PL bcn2 = new Giic_BA010_ShareTO3PL();
        ID batchprocessid2 = Database.executeBatch(bcn2,100);
        
        Giic_BA009_ShareTOPartner bcn1 = new Giic_BA009_ShareTOPartner() ;
        ID batchprocessid1 = Database.executeBatch(bcn1,100);
        
        
    } 
    
/**
* @author Name : Parveen Kaur - Parveen.Kaur@fujitsu.com
* @date  09/08/2019
* @description This a Finish method : This method ise for run the last process, its execute once in all process
* @param ctx SchedulableContext
*/
    public void execute(SchedulableContext ctx){
        Database.executebatch(new Giic_BA001_MergeTOBatch(), 10);  
    } 
    
    
}