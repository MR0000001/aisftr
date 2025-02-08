/**
* @author Sara Miozza - sara.miozza@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 12/04/2019
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_ZuoraCustomerAccount_Handler – Handler for XC_TR_ZuoraCustomerAccount Trigger
*/  
 
public without sharing class XC_TR_ZuoraCustomerAccount_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ZuoraCustomerAccount_Handler');
    

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
     */
    public Boolean stopRecursion() {   
        //return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed); 
        return false;   // NM LR - 18.02.2020 - Zuora updates customer account two times
    }
    

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to set to true the stop recursion variable on the current trigger event  
     */ 
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
     */
    public void onBeforeInsert(List<Zuora__CustomerAccount__c> listNew) {
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            XC_TR_ZuoraCustAccount_U_CreateBillProf.createLineItemLookup(listNew); 
        //}
    }
    

    /**
     * @author Sara Miozza - sara.miozza@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
     */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS) {
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
            List<Zuora__CustomerAccount__c> listNew = mapNewS.values(); 
            XC_TR_ZuoraCustAccount_U_CreateBillProf.createLineItemLookup(listNew); 
        //}
    } 
    

    /**
     * @author Sara Miozza - sara.miozza@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
     */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }        
    }
    

    /**
     * @author Sara Miozza - sara.miozza@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
     */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            List<Zuora__CustomerAccount__c> listNew = mapNewS.values(); 
            System.debug('@@@List New'+listNew);
            XC_TR_ZuoraCustAccount_U_CreateBillProf.billingProfileCreation(listNew); 
        //}
    } 
    

    /**
     * @author Sara Miozza - sara.miozza@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
     */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS) {
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed); 
            List<Zuora__CustomerAccount__c> listNew = mapNewS.values();
            Map<Id, Zuora__CustomerAccount__c> mapOld = (Map<Id, Zuora__CustomerAccount__c>) mapOldS; 
            Map<Id, Zuora__CustomerAccount__c> mapNew = (Map<Id, Zuora__CustomerAccount__c>) mapNews; 
            XC_TR_ZuoraCustAccount_U_CreateBillProf.updateBillingProfile(listNew, mapOld, mapNew);
            XC_TR_ZuoraCustAccount_U_CreateBillProf.manageBadPayer(listNew, mapOld, mapNew);
        //}           
    } 
    
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
     */
    public void onAfterDelete(Map<Id, SObject> mapOld) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
        }           
    } 


    /**
     * @author Sara Miozza - sara.miozza@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
     */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }           
    }    
}