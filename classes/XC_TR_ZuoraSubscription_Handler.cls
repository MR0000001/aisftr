/**
 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation 02/10/2019
 * @date Modification
 * @description XC_TR_ZuoraSubscription_Handler – Handler for XC_TR_ZuoraSubscription Trigger
 */
 
public without sharing class XC_TR_ZuoraSubscription_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ZuoraSubscription_Handler');
    

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
     */
    public Boolean stopRecursion() {   
        //return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        return false;	// NM LR - 09.04.2020 - Zuora updates subscription two times
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
    public void onBeforeInsert(List<Zuora__Subscription__c> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            
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
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);   
        }
    } 
    

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
     */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }        
    }
    

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
     */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            List<Zuora__Subscription__c> listNew = mapNewS.values(); 
            System.debug('@@@List New'+listNew);
            //XC_TR_ZuoraSubscription_U_ManageZquote.updateZquotes(listNew);
            //XC_TR_ZuoraSubscription_U_ManageZquote.updateSubscriptionFieldInsert(listNew); //GDB
            //20211119_DD_SO_14 - start
            XC_TR_ZuoraSubscription_U_ManageZquote.updateZquotesAssetsOnInsert(listNew, listNew);    
            //XC_TR_ZuoraSubscription_U_ManageZquote.updateZquotesAssetsOnInsert(listNew);    // NM - LR 08.04.2020
            //XC_TR_ZuoraSubscription_U_ManageZquote.retriveAndUpdateSubscriptionFieldonAsset(listNew); //GDB 
            //20211119_DD_SO_14 - end
        //}
    } 
    
    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed); 
            Map<Id, Zuora__Subscription__c> mapOld = (Map<Id, Zuora__Subscription__c>) mapOldS; 
            Map<Id, Zuora__Subscription__c> mapNew = (Map<Id, Zuora__Subscription__c>) mapNews; 
            List<Zuora__Subscription__c> listNew = mapNewS.values(); 
            //XC_TR_ZuoraSubscription_U_ManageZquote.updateSubscriptionFieldInsert(listNew); //GDB
            XC_TR_ZuoraSubscription_U_ManageZquote.updateZquotesAssetsOnUpdate(mapOld, mapNew);   // NM - LR 08.04.2020
            //XC_TR_ZuoraSubscription_U_ManageZquote.retriveAndUpdateSubscriptionFieldonAsset(listNew); //GDB //20211119_DD_SO_14
        //}           
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