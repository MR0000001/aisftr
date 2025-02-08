/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 10/12/2019
* @description XC_TR_ActionPlanTemplate_Handler - Handler for Action Template Trigger
*/ 
public with sharing class XC_TR_ActionPlanTemplate_Handler implements XC_I_TriggerHandler {
  public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ActionPlanTemplate_Handler');
 
     /**
     * @author Nicola Arrigo - narrigo@deloitte.it
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
 public Boolean stopRecursion() {
    return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
 }
   /**
     * @author Nicola Arrigo - narrigo@deloitte.it
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    public void onBeforeInsert(List<SObject> listNew){
     system.debug('Start Before Insert');
    }
    
 /**
     * @author Nicola Arrigo - narrigo@deloitte.it
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
  public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
      system.debug('Start Before Update');
     /* Map <id,ActionPlanTemplate__c> oldMapApt = (Map <id,ActionPlanTemplate__c>) mapOldS; 
      Map <id,ActionPlanTemplate__c> newMapApt = (Map <id,ActionPlanTemplate__c>) mapNews;
      XC_TR_ActionPlanTemp_U_CheckDuplicates.checkDuplicatesBeforeUpdate(newMapApt,oldMapApt);*/ 
  }
  /**
     * @author Nicola Arrigo - narrigo@deloitte.it  
     * @description Interface Method for before delete
     * @param mapOld - map Id -> old value of record
    */

    public void onBeforeDelete(Map<Id, SObject> mapOld){
     system.debug('Start Before Delete');
    }
    /**
     * @author Nicola Arrigo - narrigo@deloitte.it  
     * @description Interface Method for after insert
     * @param mapNew - map Id -> new value of record
    */

    public void onAfterInsert(Map<Id, SObject> mapNew){
     system.debug('Start After Insert');
    }
    /**
     * @author Nicola Arrigo - narrigo@deloitte.it  
     * @description Interface Method for after update
     * @param mapOld - map Id -> old value of record* 
     * @param mapNew - map Id -> new value of record
    */
    
   public  void onAfterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew){
     system.debug('Start After Update');
    }
    /**
     * @author Nicola Arrigo - narrigo@deloitte.it  
     * @description Interface Method for after delete
     * @param mapOld - map Id -> old value of record
    */    
    
    public void onAfterDelete(Map<Id, SObject> mapOld){
     system.debug('Start After Delete');
    }
    
    /**
     * @author Nicola Arrigo - narrigo@deloitte.it  
     * @description Interface Method for after undelete
     * @param mapOld - map Id -> old value of record
    */

    public void onAfterUndelete(Map<Id, SObject> mapOld){
      system.debug('Start After Undelete');
    }
	

}