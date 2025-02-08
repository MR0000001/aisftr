/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
* @date Creation 11/07/2019
* @description XC_TR_LeadAssignmentMaster_Handler – Handler for XC_TR_LeadAssignmentMaster
*/
public without sharing class XC_TR_LeadAssignmentMaster_Handler implements XC_I_TriggerHandler{
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_LeadAssignmentMaster_Handler');
  
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to stop recursion of the same event method in the same transaction  
    * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
     
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com  
    * @description Methods to be executed on before insert
    * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<XC_LeadAssignmentMaster__c> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            XC_TR_LeadAssignmentMaster_U_AddErrors.onBeforeInsert(listNew);
        } 
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com  
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        Map<Id, XC_LeadAssignmentMaster__c> mapOld = (Map<Id, XC_LeadAssignmentMaster__c>) mapOldS; 
        Map<Id, XC_LeadAssignmentMaster__c> mapNew = (Map<Id, XC_LeadAssignmentMaster__c>) mapNewS;
        XC_TR_LeadAssignmentMaster_U_AddErrors.onBeforeUpdate(mapOld, mapNew);
    }
 
        /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description Method to be executed on before delete
     * @param mapOldS - map Id -> old value of record
    */
    
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        Map<Id, XC_LeadAssignmentMaster__c> mapOld = (Map<Id, XC_LeadAssignmentMaster__c>) mapOldS; 
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com   
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        List<XC_LeadAssignmentMaster__c> listNew = mapNew.values();
    } 

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    
    public void onAfterUnDelete(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    }


     
}