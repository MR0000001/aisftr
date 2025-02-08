/**
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       08/11/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         XC_TR_NbaNbo_Handler –  Handler for NbaNbo Trigger
 */
 
public without sharing class XC_TR_NbaNbo_Handler implements XC_I_TriggerHandler {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_NbaNbo_Handler');
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    
    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped 
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    
    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    
    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<XC_NbaNbo__c> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
           
                for(XC_NbaNbo__c nbanbo : listNew){
                    if(!String.isBlank(nbanbo.XC_Reason__c) && !String.isBlank(nbanbo.XC_Subcause__c)){
                        nbanbo.RecordTypeId = Schema.SObjectType.XC_NbaNbo__c.getRecordTypeInfosByDeveloperName().get('XC_GLO_NB_Case').getRecordTypeId();
                    }else{
                        nbanbo.RecordTypeId = Schema.SObjectType.XC_NbaNbo__c.getRecordTypeInfosByDeveloperName().get('XC_GLO_NB_Opportunity').getRecordTypeId();
                    }
                }
               
        }
    }
    
    
    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            List<XC_NbaNbo__c> listNew = mapNewS.values();
               for(XC_NbaNbo__c nbanbo : listNew){
                if(!String.isBlank(nbanbo.XC_Reason__c) && !String.isBlank(nbanbo.XC_Subcause__c)){
                    nbanbo.RecordTypeId = Schema.SObjectType.XC_NbaNbo__c.getRecordTypeInfosByDeveloperName().get('XC_GLO_NB_Case').getRecordTypeId();
                }else{
                    nbanbo.RecordTypeId = Schema.SObjectType.XC_NbaNbo__c.getRecordTypeInfosByDeveloperName().get('XC_GLO_NB_Opportunity').getRecordTypeId();
                }
            }
        }
    } 
    
    
    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to be executed on before delete
     * @param mapOlds 
    */
    public void onBeforeDelete(Map<Id, SObject> mapOlds) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            Map<Id, XC_NbaNbo__c> mapOld = (Map<Id, XC_NbaNbo__c>) mapOldS;  
            
        }        
    }
    
    
    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to be executed on after insert
     * @param mapNewS 
     */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
          if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
                List<XC_NbaNbo__c> listNew = mapNewS.values();
                            
               
           }
            
      } 
    
    
    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            List<XC_NbaNbo__c> listNew = mapNewS.values();
            Map<Id, XC_NbaNbo__c> mapOld = (Map<Id, XC_NbaNbo__c>) mapOldS; 
            Map<Id, XC_NbaNbo__c> mapNew = (Map<Id, XC_NbaNbo__c>) mapNews; 
        }
    }
    
    
    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
        }           
    } 


    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }           
    }    
	


}