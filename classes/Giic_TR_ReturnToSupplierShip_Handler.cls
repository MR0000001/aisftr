/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 16/10/2019
* @date 
* @description Giic_TR_ReturnToSupplierShip_Handler – Handler for giic_TR_Product2 Trigger
*/  
 
public without sharing class Giic_TR_ReturnToSupplierShip_Handler implements XC_I_TriggerHandler {
    
    public static Boolean stopTrigger = false;
    public static Boolean stopTriggerBI = false;
    public static Boolean stopTriggerAI = false;
    public static Boolean stopTriggerBU = false;
    public static Boolean stopTriggerAU = false;
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */ 
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
      // return true;
    }
      /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */ 
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    } 
    
    public void commitPendingWork() {
        System.debug('Giic_TR_ReturnToSupplierShip_Handler: commit pending work');
        executedTrigger();
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<gii__ReturntoSupplierLineShipment__c > listNew){
        System.debug('-> Giic_TR_ReturnToSupplierShip_Handler.onBeforeInsert');
  		Giic_TR_ReturnToSupplierShip_UTIL.checkValidSerialNumber(listNew);      
		
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        System.debug('Trigger on ' + Trigger.operationType);
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
        Map<Id, gii__ReturntoSupplierLineShipment__c > mapOld = (Map<Id, gii__ReturntoSupplierLineShipment__c >) mapOldS; 
        Map<Id, gii__ReturntoSupplierLineShipment__c > mapNew = (Map<Id, gii__ReturntoSupplierLineShipment__c >) mapNewS;
        List<gii__ReturntoSupplierLineShipment__c> listNew = mapNew.values();
       
    } 
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
         System.debug( 'Trigger on ' + Trigger.operationType); 
        Map<Id, gii__ReturntoSupplierLineShipment__c > mapOld = (Map<Id, gii__ReturntoSupplierLineShipment__c >) mapOldS; 
      
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        System.debug( 'Trigger on ' + Trigger.operationType);
        List<gii__ReturntoSupplierLineShipment__c > listNew = mapNew.values();
        
    } 
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        System.debug('Trigger on ' + Trigger.operationType); 
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
      
	}
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOldS){ 
        System.debug( 'Trigger on ' + Trigger.operationType);            
    } 

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com  
     * @description Method to be executed on after undelete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapOld){ 
         System.debug( 'Trigger on ' + Trigger.operationType);            
    }     
    
}