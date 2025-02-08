/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 11/02/2020
* @date Modification dd/mm/yyyy
* @description XC_TR_ZuoraInvoiceItem_Handler – Handler for XC_TR_ZuoraInvoiceItem Trigger
*/
public without sharing class XC_TR_ZuoraInvoiceItem_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ZuoraInvoiceItem_Handler');
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        // return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        return false;	// NM LR - 17.05.2020 - Zuora updates two times
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
    public void onBeforeInsert(List<Zuora__InvoiceItem__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__InvoiceItem__c on ' + Trigger.operationType);
        XC_TR_ZuoraInvItem_U_FillSubscriptionNum.onBeforeInsert(listNew);
    }
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__InvoiceItem__c on ' + Trigger.operationType);
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        List<Zuora__InvoiceItem__c> listNew = mapNewS.values();
        Map<Id, Zuora__InvoiceItem__c> mapOld = (Map<Id, Zuora__InvoiceItem__c>) mapOldS; 
        Map<Id, Zuora__InvoiceItem__c> mapNew = (Map<Id, Zuora__InvoiceItem__c>) mapNews;
        XC_TR_ZuoraInvItem_U_FillSubscriptionNum.onBeforeUpdate(mapOld, mapNew);
    } 
    		
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__InvoiceItem__c on ' + Trigger.operationType);       
    }
    		
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__InvoiceItem__c on ' + Trigger.operationType);
        List<Zuora__InvoiceItem__c> listNew = mapNewS.values();
        XC_TR_ZuoraInvItem_U_FillSubscriptionNum.updateRelatedRecordsOnInsert(listNew);
        XC_TR_ZuoraInvItem_U_PPM_FinancialBen.createRecordFinancialBenefit(listNew);
        XC_TR_ZuoraInvItem_U_FillInvoiceNum.fillInvoiceNumberDateOnOI(listNew);
    } 
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__InvoiceItem__c on ' + Trigger.operationType); 
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapNews =' + mapNews); 
        List<Zuora__InvoiceItem__c> listNew = mapNewS.values();
        Map<Id, Zuora__InvoiceItem__c> mapOld = (Map<Id, Zuora__InvoiceItem__c>) mapOldS; 
        Map<Id, Zuora__InvoiceItem__c> mapNew = (Map<Id, Zuora__InvoiceItem__c>) mapNews;
        XC_TR_ZuoraInvItem_U_FillInvoiceNum.fillInvoiceNumberDateOnOIOnUpdate(mapOld, mapNew);  
        XC_TR_ZuoraInvItem_U_FillSubscriptionNum.updateRelatedRecordsOnUpdate(mapOld, mapNew);
    }
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__InvoiceItem__c on ' + Trigger.operationType);                     
    } 

    /**	
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to be executed on after undelete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapOld) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__InvoiceItem__c on ' + Trigger.operationType);          
    }    
}