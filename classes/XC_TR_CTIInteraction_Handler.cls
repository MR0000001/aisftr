/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 18/12/2020
* @date Modification 
* @description XC_TR_CTIInteraction
*/

public without sharing class XC_TR_CTIInteraction_Handler implements XC_I_TriggerHandler {
    
   	public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_CTIInteraction_Handler');

     /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<XC_CTI_Interaction__c> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on XC_CTI_Interaction__c on ' + Trigger.operationType);
        }
    }
    
     /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
		//JJP 28-10-2021 - ENELX
		//NR1752 - Extend_Post_CallCenter_Survey - El pais debe de ser global
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on XC_CTI_Interaction__c on ' + Trigger.operationType);
            List<XC_CTI_Interaction__c> listNew = mapNewS.values();
            Map<Id, XC_CTI_Interaction__c> mapOld = (Map<Id, XC_CTI_Interaction__c>) mapOldS; 
            Map<Id, XC_CTI_Interaction__c> mapNew = (Map<Id, XC_CTI_Interaction__c>) mapNews;
            
            XC_TR_CTIInteraction_U_CreateCI.createCIonClosure(listNew, mapOld, mapNew);
        //}
    } 
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
              XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on XC_CTI_Interaction__c on ' + Trigger.operationType);
        }        
    }
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on XC_CTI_Interaction__c on ' + Trigger.operationType);
        }
      } 
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on XC_CTI_Interaction__c on ' + Trigger.operationType);
        }
    }
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on XC_CTI_Interaction__c on ' + Trigger.operationType);          
        }           
    } 

    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on after undelete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapOld) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on XC_CTI_Interaction__c on ' + Trigger.operationType);
        }           
    }    
    
}