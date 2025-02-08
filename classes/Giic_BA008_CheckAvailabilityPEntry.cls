/**
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 26/03/2020
* @date Modification dd/mm/yyyy
* @description - Batch to start check availability  
*/

public class Giic_BA008_CheckAvailabilityPEntry implements Database.batchable<Sobject>, Schedulable {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_BA008_CheckAvailabilityPEntry');
     /**
      * @description query
      */
    public String query;
   
    
    
    public Giic_BA008_CheckAvailabilityPEntry(){ 
         query='SELECT Id,giic_Default__c FROM gii__PriceBookEntry__c';
    } 
     /**
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/03/2020
    * @description start method to do query 
    * @param bcDatabase.BatchableContext
    * @return Database.QueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    } 
    /**
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/03/2020
    * @description execute method for logic 
    * @param bc Database.BatchableContext
    * @param whList warehouse list
    */
    public void execute(Database.BatchableContext bc, List<gii__PriceBookEntry__c> pEnList){
        
         giic_TR_CheckAvailabilityForSupplierProd.checkAvailabilityForSupplierProduct(pEnList); 
        
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
    
     /**
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/03/2020
    * @description finish method to do remaining logic
    * @param ctx SchedulableContext
    */
     
    public void execute(SchedulableContext ctx){
        Database.executebatch(new Giic_BA008_CheckAvailabilityPEntry(), 200);  
    }  

}