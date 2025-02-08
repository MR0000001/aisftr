/**
 * @author Nicola Mariniello - nmariniello@deloitte.it
 * @date Creation 03/05/2020
 * @date Modification dd/mm/yyyy
 * @description XC_TR_TechnicalSheet_Handler – Handler for XC_TR_TechnicalSheet Trigger
 */

public without sharing class XC_TR_TechnicalSheet_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_TechnicalSheet_Handler');
    
    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {  
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }

    
    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */ 
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    

    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */ 
    public void onBeforeInsert(List<XC_TechnicalSheet__c > listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            XC_TR_TechnicalSheet_U_FillFields.fillFields(listNew);
        }
    }
    

    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);    
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            List<XC_TechnicalSheet__c > listNew = mapNewS.values();
            Map<Id, XC_TechnicalSheet__c > mapOld = (Map<Id, XC_TechnicalSheet__c>) mapOldS; 
            Map<Id, XC_TechnicalSheet__c > mapNew = (Map<Id, XC_TechnicalSheet__c>) mapNews; 
        }
    } 
    

    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }        
    }
    

    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            List<XC_TechnicalSheet__c> listNew = mapNewS.values();
        }
    } 
    

    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record 
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            List<XC_TechnicalSheet__c> listNew = mapNewS.values();
            Map<Id, XC_TechnicalSheet__c> mapOld = (Map<Id, XC_TechnicalSheet__c>) mapOldS;
            Map<Id, XC_TechnicalSheet__c> mapNew = (Map<Id, XC_TechnicalSheet__c>) mapNews; 
        }
    }
    

    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
        }           
    } 


    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description Method to be executed on after undelete
     * @param mapOld - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapOld) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }           
    }    

}