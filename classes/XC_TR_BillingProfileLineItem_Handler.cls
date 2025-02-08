/**
* @author Sara Miozza - sara.miozza@nttdata.com 
* @date Creation 29/04/2019
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_BillingProfileLineItem_Handler – Handler for XC_TR_BillingProfileLineItem Trigger
*/ 

public without sharing class XC_TR_BillingProfileLineItem_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_BillingProfileLineItem_Handler');
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com  
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        //return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        return false;   // NM LR - 03.06.2020 - Zuora updates customer account two times
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */ 
    
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<XC_BillingProfileLineItem__c> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            XC_TR_BillingProfileLineItem_U_Address.updateAdressFields(listNew);
            XC_TR_BillProfLineItem_U_FillFields.fillFieldsOnInsert(listNew);
        }
    }
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com 
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            List<XC_BillingProfileLineItem__c> listNew =  mapNewS.values();
            XC_TR_BillingProfileLineItem_U_Address.updateAdressFields(listNew);
        }
    } 
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com 
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }        
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to be executed on after insert
     * @param mapNewS
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            List<XC_BillingProfileLineItem__c> listNew =  mapNewS.values();
            XC_TR_BillingProfileLineItem_U_Sepa.rebaltLegalEntity(listNew);
        }
    }  
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com 
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
            Map<Id, XC_BillingProfileLineItem__c> mapOld = (Map<Id, XC_BillingProfileLineItem__c>) mapOldS;
            Map<Id, XC_BillingProfileLineItem__c> mapNew = (Map<Id, XC_BillingProfileLineItem__c>) mapNews;
            XC_TR_BillProfLineItem_U_CompleteStep.afterBpliUpdate(mapOld, mapNew);
            XC_TR_BillingProfileLineItem_U_Address.changeBillingAddressOnZuora(mapOld, mapNew);
            XC_TR_BillProfLineItem_U_FillFields.changeInfosOnZuora(mapOld, mapNew);
            XC_TR_BillingProfileLineItem_U_UpdateOI.onUpdate(mapOld, mapNew);
            
            XC_TR_Account_UpdateZuoraAccount.updateBillingAccount(mapOld, mapNew);

            XC_TR_BillProfLineItem_U_FillFields.updateInvoiceDeliveryPrefOnBp(mapOld, mapNew);
        }
    } 
    
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com 
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
        }           
    } 

    /**
     * @author Sara Miozza - sara.miozza@nttdata.com 
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }           
    }    
}