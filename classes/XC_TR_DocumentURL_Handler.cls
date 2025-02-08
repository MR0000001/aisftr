/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 26/06/2020
* @description XC_TR_DocumentURL_Handler
* @description Handler for DocumentURL
*/ 

public without sharing class XC_TR_DocumentURL_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_DocumentURL_Handler');
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped 
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }    
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }   
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param mapNewS - list of new values of records
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS){
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        List<XC_DocumentURL__c> listNew = mapNewS.values();   
        XC_TR_DocumentURL_GenerateCI.checkDocTypeAndGenerateCI(listNew);
    }   
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<SObject> listNew){ 
        
    	XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);          
    }    
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param mapOldS - list of old values of records
     * @param mapNewS - list of new values of records
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
            
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);          
    }    
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param mapOldS - list of old values of records
     * @param mapNewS - list of new values of records
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        List<XC_DocumentURL__c> listNew = mapNewS.values();        
     }   
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param mapOld
    */
    public void onAfterDelete(Map<Id, SObject> mapOld) {
        
    	XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);        
    }
        
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param mapNew -> new value of record
    */
    public void onAfterUndelete(Map<Id, SObject> mapNew) {
        
    	XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);              
    }
       
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param mapOld
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
                
    	XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    }   
}