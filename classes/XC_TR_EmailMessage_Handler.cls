/**
 * The Class XC_TR_EmailMessage_Handler.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 15/07/2019
 * @date Modification : dd/mm/yyyy
 * @description       : XC_TR_EmailMessage_Handler - Handler for EmailMessage Trigger
 */ 


public without sharing class XC_TR_EmailMessage_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_EmailMessage_Handler');
    
    /**
     * StopRecursion.
     *
     * @return Boolean true if recursion must be stopped
     * @description Method to stop recursion of the same event method in the same transaction  
     */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    /**
     * ExecutedTrigger.
     *
     * @description Method to set to true the stop recursion variable on the current trigger event  
     */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }

    /**
     * On before insert.
     *
     * @param listNew the list new
     * @param mapNew the map new
     * @description Method to be executed on before insert
     */
    public static void onBeforeInsert(List<EmailMessage> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }
    }

    /**
     * On before update.
     *
     * @param mapOldS the map old
     * @param mapNewS the map new
     * @description Method to be executed on before update
     */
    public static void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }
    }

    /**
     * On before delete.
     *
     * @param mapOld the map old
     * @description Method to be executed on before delete
     */
    public static void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }
    }

    
    /**
     * On after insert.
     *
     * @param mapNewS the map new
     * @description Method to be executed on after insert
     */
    public static void onAfterInsert(Map<Id, SObject> mapNewS) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            XC_TR_EmailMessage_U_ManageParentCase.updateEmail2CaseField(mapNewS.values());
        }
        XC_TR_EmailMessage_U_ManageParentCase.updateGeolocalizationCountryCaseField(mapNewS.values());
    }

    /**
     * On after update.
     *
     * @param mapOldS the map old
     * @param mapNewS the map new
     * @description Method to be executed on after ypdate
     */
    public static void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }
    }
    

    /**
     * On after delete.
     *
     * @param mapOld the map old
     * @description Method to be executed on after delete
     */
    public static void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }
    }    


    /**
     * On after undelete.
     *
     * @param mapNew -> new value of record
     * @description Method to be executed on after undelete
     */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }           
    }    
    
}