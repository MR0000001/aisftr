/**
* @author FirstName : Parveen Kaur 
* @date Creation 22/07/2019
* @date Modification dd/mm/yyyy
* @description - Batch to calculate the warehouse value for all the warehouses.
*/

public class Giic_BA004_UpdateTOAfterMerge implements Database.batchable<Sobject>{
     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_BA001_UpdateTOAfterMerge');
    /**
      * @description query
      */
    public String query;
    /**
      * @description listofTOforUpdate
      */
    public Set<Id> listofTOforUpdate;
   
 /**
    * @author Name :  Parveen Kaur 
    * @date 22/07/2019
    * @description Constructor for  Giic_BA004_UpdateTOAfterMerge
    * @param listofTOforUpdate Set<Id> 
    */
    public Giic_BA004_UpdateTOAfterMerge(Set<Id> listofTOforUpdate){ 
        this.listofTOforUpdate = new Set<Id>();
        this.listofTOforUpdate = listofTOforUpdate;
         query='SELECT Id,gii__Account__c,giic_Approved__c,giic_IntegrationStatus__c,giic_IntegrationOperation__c,giic_TargetSystem__c,giic_WarehouseLimitExceeded__c,giic_status__c,gii__TransferToWarehouse__r.gii__Account__c, gii__OrderDate__c,gii__FromWarehouse__c,gii__TransferToWarehouse__c from gii__TransferOrder__c WHERE Id IN: listofTOforUpdate';
       //query='SELECT Id,gii__Account__c,giic_Approved__c,giic_status__c,gii__TransferToWarehouse__r.gii__Account__c, gii__OrderDate__c,gii__FromWarehouse__c,gii__TransferToWarehouse__c from gii__TransferOrder__c WHERE giic_status__c=\''+System.Label.giic_TOOpenStatus+'\' AND giic_Approved__c=True AND gii__OrderDate__c='+(Datetime.newInstance(today.year(), today.month(), today.day()).format('yyyy-MM-dd'));
} 
    /**
* @author Name : Parveen Kaur
* @date  09/08/2019
* @description This a start method : retrieve the record based on query .
* @param bc Database.BatchableContext 
* @return Database.QueryLocator
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
    public void execute(Database.BatchableContext bc, List<gii__TransferOrder__c> listTO){
        giic_TransferOrderUtility.updateIntegrationStatus(listTO);
    } 
/**
* @author Name : Parveen Kaur - Parveen.Kaur@fujitsu.com
* @date  09/08/2019
* @description This a Finish method : This method ise for run the last process, its execute once in all process
* @param bc Database.BatchableContext
*/
    public void finish(Database.BatchableContext bc){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Finish:');
    } 
    
    
}