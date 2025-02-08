/**
* @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 07/08/2019
* @date Modification ..
* @description XC_TR_VoucherUtilization_Handler – Handler for XC_TR_VoucherUtilization Trigger
*/  
 
public without sharing class XC_TR_VoucherUtilization_Handler implements XC_I_TriggerHandler {

    private final static Boolean DEBUGACTIVE = true;
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    
    /**
     * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it  
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */ 
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    } 
    
    /**
     * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it 
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */ 
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    } 
    
    /**
     * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<XC_VoucherUtilization__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> XC_TR_VoucherUtilization_Handler.onBeforeInsert'); 
    }
    
    /**
     * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it  
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        Map<Id, XC_VoucherUtilization__c> mapOld = (Map<Id, XC_VoucherUtilization__c>) mapOldS; 
        Map<Id, XC_VoucherUtilization__c> mapNew = (Map<Id, XC_VoucherUtilization__c>) mapNewS;
        List<XC_VoucherUtilization__c> listNew = mapNew.values();      
    } 
    
    /**
     * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it  
     * @description Method to be executed on before delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
   
    }
    
    /**
     * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it  
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        List<XC_VoucherUtilization__c> listNew = mapNew.values();    
        //XC_TR_VoucherUtilization_U_changeStatus.changeVoucherStatus(listNew);
    } 
    
    /**
     * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it 
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        Map<Id, XC_VoucherUtilization__c> mapOld = (Map<Id, XC_VoucherUtilization__c>) mapOldS; 
        Map<Id, XC_VoucherUtilization__c> mapNew = (Map<Id, XC_VoucherUtilization__c>) mapNewS;
        List<XC_VoucherUtilization__c> listNew = mapNew.values();  
    }
    
    /**
     * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it  
     * @description Method to be executed on after delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOldS){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    } 

    /**
     * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it  
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew ){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    }     

}