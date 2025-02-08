/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 22/11/2019
* @date Modification 
* @description Handler for XC_Document_to_sign__c Trigger
*/ 

public without sharing class XC_TR_DocumentToSign_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_DocumentToSign_Handler');
    
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
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            List<XC_Document_to_sign__c> listNew = mapNewS.values();
            XC_TR_DocumentToSign_U_Notifications.createCustomerInteractionRemoteSign(listNew);
        }
    }
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<SObject> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }
    }
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param mapOldS - list of old values of records
     * @param mapNewS - list of new values of records
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        }
    }
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param mapOldS - list of old values of records
     * @param mapNewS - list of new values of records
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            Map<Id, XC_Document_to_sign__c> mapOld = (Map<Id, XC_Document_to_sign__c>) mapOldS; 
            Map<Id, XC_Document_to_sign__c> mapNew = (Map<Id, XC_Document_to_sign__c>) mapNewS;      
            List<XC_Document_to_sign__c> listNew = mapNew.values();
            XC_TR_DocumentToSign_U_Notifications.createCustomerInteractionDocSigned(listNew, mapOld, mapNew);
        }
    }
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param mapOld
    */
    public void onAfterDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }
        
    }
        
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param mapNew -> new value of record
    */
    public void onAfterUndelete(Map<Id, SObject> mapNew) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }
        
    }
    
    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param mapOld
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }
        
    }
    

}