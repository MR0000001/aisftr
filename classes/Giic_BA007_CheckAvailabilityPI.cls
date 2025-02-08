/**
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 26/03/2020
* @date Modification dd/mm/yyyy
* @description - Batch to start check availability  
*/    

public class Giic_BA007_CheckAvailabilityPI implements Database.batchable<Sobject>, Schedulable {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_BA007_CheckAvailabilityPI');
     
   
    
     /**
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/03/2020
    * @description start method to do query 
    * @param bcDatabase.BatchableContext
    * @return Database.QueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String virtualValue = 'Virtual';
        String query='SELECT Id FROM gii__ProductInventory__c WHERE gii__Warehouse__r.giic_ParentWarehouse__c=null AND gii__Warehouse__r.giic_WarehouseType__c != \'' + String.escapeSingleQuotes(virtualValue)+ '\' ';
        return Database.getQueryLocator(query);
    } 
    /**
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/03/2020
    * @description execute method for logic 
    * @param bc Database.BatchableContext
    * @param whList warehouse list
    */
    public void execute(Database.BatchableContext bc, List<gii__ProductInventory__c> scope){
        
        giic_TR_CheckAvailability.checkAvailability(scope);
        
    } 
   
    
     /**
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/03/2020
    * @description finish method to do remaining logic
    * @param ctx SchedulableContext
    */
     
    public void execute(SchedulableContext ctx){
        Database.executebatch(new Giic_BA007_CheckAvailabilityPI(), 200);  
    }  
    
    
     /**
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/03/2020
    * @description finish method to do remaining logic
    * @param bc Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc){
       
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Finished');
    } 

}