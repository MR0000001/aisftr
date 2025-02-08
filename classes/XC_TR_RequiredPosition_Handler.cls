/**
* @author Matteo Monteforte
* @date 23/02/2022
* @description classes.XC_TR_RequiredPosition_Handler
*/

public without sharing class XC_TR_RequiredPosition_Handler implements XC_I_TriggerHandler{
	
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_RequiredPosition_Handler');
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    
     /**
     * @author Matteo Monteforte - mmonteforte@deloitte.it
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    /**
     * @author Matteo Monteforte - mmonteforte@deloitte.it
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Matteo Monteforte - mmonteforte@deloitte.it 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<ProductRequired> listNew){
        
    }

    /**
     * @author Matteo Monteforte - mmonteforte@deloitte.it
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        
    }

    /**
     * @author Matteo Monteforte - mmonteforte@deloitte.it 
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld){
        
    }

    /**
     * @author Matteo Monteforte - mmonteforte@deloitte.it 
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew){
        
        XC_TR_ProductRequired_U_WOLIPName.updateProdIdOnWoli((Map<Id,XC_RequiredPosition__c>) mapNew, 'RequiredPosition');
    
    }
    /**
     * @author Matteo Monteforte - mmonteforte@deloitte.it 
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        
    }

    /**
     *  @author Matteo Monteforte - mmonteforte@deloitte.it 
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){
        
    }

    /**
      @author Matteo Monteforte - mmonteforte@deloitte.it 
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew){
       
    }
}