/**
* @author Milko Fatiga
* @date Creation 04/05/2022
* @date Modification 
* @description Giic_TR_FormCase_Handler - Handler for Form Case Trigger
*/ 

public without sharing class Giic_TR_FormCase_Handler implements XC_I_TriggerHandler {
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    public static Boolean bypassAfterInsert = true;
    public static Boolean bypassBeforeInsert = true;
    
    /**
     * @author Milko Fatiga 
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    /**
     * @author Milko Fatiga 
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Milko Fatiga
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<XC_FormCase__c> listNew){

    }
    
    /**
     * @author Milko Fatiga
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        Map<Id, XC_FormCase__c > mapOld = (Map<Id, XC_FormCase__c >) mapOldS; 
        Map<Id, XC_FormCase__c > mapNew = (Map<Id, XC_FormCase__c >) mapNewS;
        List<XC_FormCase__c > listNew = mapNewS.values();
        Giic_UTIL_FormCase.checkIfRMALineChange(listNew,mapOld,mapNew);
    } 
    
    /**
     * @author Milko Fatiga
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
                
    }
    
    /**
     * @author Milko Fatiga
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
             
               
      } 
    
    /**
     * @author Milko Fatiga
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        Map<Id, XC_FormCase__c > mapOld = (Map<Id, XC_FormCase__c >) mapOldS; 
        Map<Id, XC_FormCase__c > mapNew = (Map<Id, XC_FormCase__c >) mapNewS;
        List<XC_FormCase__c > listNew = mapNewS.values();
        Giic_UTIL_FormCase.checkIfStatusChange(listNew,mapOld,mapNew);    
    }

    /**
     * @author Milko Fatiga
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
               
    } 

    /**
     * @author Milko Fatiga
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
               
    } 
}