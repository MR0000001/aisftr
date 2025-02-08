/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 11/12/2020
* @description XC_TR_QualityCheck_Handler – Handler for XC_TR_QualityCheck Trigger
*/  

public without sharing class XC_TR_QualityCheck_Handler implements XC_I_TriggerHandler {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_QualityCheck_Handler');
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    
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
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<XC_B2BG_QualityCheck__c> listNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> XC_TR_QualityCheck_Handler.onBeforeInsert');
        XC_TR_QualityCheck_U_CheckFields.fillFields(listNew); 
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
        Map<Id, XC_B2BG_QualityCheck__c> mapOld = (Map<Id, XC_B2BG_QualityCheck__c>) mapOldS; 
        Map<Id, XC_B2BG_QualityCheck__c> mapNew = (Map<Id, XC_B2BG_QualityCheck__c>) mapNewS;
        List<XC_B2BG_QualityCheck__c> listNew = mapNew.values();    
    } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to be executed on before delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        Map<Id, XC_B2BG_QualityCheck__c> mapOld = (Map<Id, XC_B2BG_QualityCheck__c>) mapOldS;  
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        List<XC_B2BG_QualityCheck__c> listNew = mapNew.values();
        XC_TR_QualityCheck_U_CheckFields.checkAnswers(listNew);  
    } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
        Map<Id, XC_B2BG_QualityCheck__c> mapOld = (Map<Id, XC_B2BG_QualityCheck__c>) mapOldS; 
        Map<Id, XC_B2BG_QualityCheck__c> mapNew = (Map<Id, XC_B2BG_QualityCheck__c>) mapNewS;      
        List<XC_B2BG_QualityCheck__c> listNew = mapNew.values();
        XC_TR_QualityCheck_U_CheckFields.checkAnswersOnUpdate(mapOld, mapNew); 
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to be executed on after delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOldS){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        List<XC_B2BG_QualityCheck__c> listOld = mapOldS.values();
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew ){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);        
    }     

}