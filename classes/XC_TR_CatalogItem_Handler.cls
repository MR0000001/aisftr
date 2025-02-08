/**
* @author Nicola Mariniello nmariniello@deloitte.it
* @date Creation 12/07/2021
* @date Modification
* @description XC_TR_CatalogItem_Handler – Handler for XC_TR_CatalogItem Trigger
*/  


public without sharing class XC_TR_CatalogItem_Handler implements XC_I_TriggerHandler {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_CatalogItem_Handler');
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */ 
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */ 
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    } 
    

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<NE__Catalog_Item__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> XC_TR_CatalogItem_Handler.onBeforeInsert'); 
        XC_TR_CatalogItem_U_CheckWBEFields.checkFields(listNew);
    }
    

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
        Map<Id, NE__Catalog_Item__c> mapOld = (Map<Id, NE__Catalog_Item__c>) mapOldS; 
        Map<Id, NE__Catalog_Item__c> mapNew = (Map<Id, NE__Catalog_Item__c>) mapNewS;
        List<NE__Catalog_Item__c> listNew = mapNew.values();
        XC_TR_CatalogItem_U_CheckWBEFields.changeFieldsUpdate(listNew, mapOld, mapNew);
    } 
    

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description Method to be executed on before delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        Map<Id, NE__Catalog_Item__c> mapOld = (Map<Id, NE__Catalog_Item__c>) mapOldS; 
  
    }
    

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        List<NE__Catalog_Item__c> listNew = mapNew.values();

    } 
    

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
        Map<Id, NE__Catalog_Item__c> mapOld = (Map<Id, NE__Catalog_Item__c>) mapOldS; 
        Map<Id, NE__Catalog_Item__c> mapNew = (Map<Id, NE__Catalog_Item__c>) mapNewS;      
        List<NE__Catalog_Item__c> listNew = mapNew.values();

    }
    

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description Method to be executed on after delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOldS){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    } 


    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew ){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    }

}