/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 22/07/2019
* @date Modification dd/mm/yyyy
* @description - Batch to calculate the warehouse value for all the warehouses.
*/
  
public class Giic_BA005_WarehouseValueCalcBatch implements Database.batchable<Sobject>,Schedulable {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_BA005_WarehouseValueCalcBatch');
     /**
      * @description query
      */
    public String query;         
    /**
      * @description listofWHforUpdate
      */
    public Set<Id> listofWHforUpdate;
    
    
    public Giic_BA005_WarehouseValueCalcBatch(){ 
        
        query='SELECT Id,giic_WarehouseValue__c,giic_StorageCapacity__c,CurrencyISOCode FROM gii__Warehouse__c';
      
    } 
     /**
    * @author Name : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date 22/07/2019
    * @description start method to do query 
    * @param bcDatabase.BatchableContext
    * @return Database.QueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator(query);
    } 
    /**
    * @author Name : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date 22/07/2019
    * @description execute method for logic 
    * @param bc Database.BatchableContext
    * @param whList warehouse list
    */
    public void execute(Database.BatchableContext bc, List<gii__Warehouse__c> whList){
        giic_WarehouseUtility.calculateValueForWH(whList);
    } 
    /**
    * @author Name : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date 22/07/2019
    * @description finish method to do remaining logic
    * @param bc Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Finished');
    } 
     /**
    * @author Name : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date 22/07/2019
    * @description finish method to do remaining logic
    * @param ctx SchedulableContext
    */
     
    public void execute(SchedulableContext ctx){
        Database.executebatch(new Giic_BA005_WarehouseValueCalcBatch(), 200);  
    }  

}