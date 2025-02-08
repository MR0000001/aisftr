/**
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 26/03/2020
* @date Modification dd/mm/yyyy
* @description - Batch to update gii__p2add__c
*/

public class Giic_BA006_UpdateProductServiceType implements Database.batchable<Sobject>, Schedulable {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_BA006_UpdateProductServiceType');
     /**
      * @description query
      */
    public String query;
    
     
    
    public Giic_BA006_UpdateProductServiceType(){ 
        
        query='SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c WHERE gii__ProductReference__c != null';
      
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
    public void execute(Database.BatchableContext bc, List<gii__Product2Add__c> p2List){
        
        Giic_LCC021_UpdateProductReference.updateProdReference(p2List);
        
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
        Database.executebatch(new Giic_BA006_UpdateProductServiceType(), 200);  
    }  

}