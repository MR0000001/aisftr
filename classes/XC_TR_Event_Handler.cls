/**
* @author Andrea Di Cicco
* @date Creation 11/06/2020
* @date Modification dd/mm/yyyy
* @description XC_TR_Event_Handler – Handler for Event Trigger
*/
public without sharing class XC_TR_Event_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Event_Handler');
    
    /**
     * @author Andrea Di Cicco
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    /**
     * @author Andrea Di Cicco 
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Andrea Di Cicco
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<Event> listNew){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Event on ' + Trigger.operationType);
            XC_TR_Event_SetLeadStatus.setLeadInAppointmentScheduled(listNew); 
    }
    
    /**
     * @author Andrea Di Cicco
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Event on ' + Trigger.operationType);
        
    } 
    
    /**
     * @author Andrea Di Cicco
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Event on ' + Trigger.operationType);
           
    }
    
    /**
     * @author Andrea Di Cicco
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Event on ' + Trigger.operationType);
      } 
    
    /**
     * @author Andrea Di Cicco
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
       
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Event on ' + Trigger.operationType);  
		mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
		List<Event> listNew = mapNewS.values();
        Map<Id, Event> mapOld = (Map<Id, Event>) mapOldS; 
        Map<Id, Event> mapNew = (Map<Id, Event>) mapNews;
        XC_TR_Event_SetLeadStatus.setLeadInPendingScheduling(listNew); 
    }
    
    /**
     * @author Andrea Di Cicco
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Event on ' + Trigger.operationType);                 
    } 

    /**
     * @author Andrea Di Cicco
     * @description Method to be executed on after undelete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapOld) { 
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Event on ' + Trigger.operationType); 
    }    
}