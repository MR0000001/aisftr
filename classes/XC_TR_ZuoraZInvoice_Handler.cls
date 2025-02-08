/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 11/10/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ZuoraZInvoice_Handler – Handler for XC_TR_ZuoraZInvoice Trigger
*/
public without sharing class XC_TR_ZuoraZInvoice_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ZuoraZInvoice_Handler');
    
    /**
     * @author Valeria Martino - valeria.martino@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */	
    public Boolean stopRecursion() {   
        //return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        return false;	// NM LR - 17.05.2020 - Zuora updates two times
    }
   
    /**
     * @author Valeria Martino - valeria.martino@nttdata.com 
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Valeria Martino - valeria.martino@nttdata.com
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<Zuora__ZInvoice__c> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__ZInvoice__c on ' + Trigger.operationType);
        }
    }
    
    /**
     * @author Valeria Martino - valeria.martino@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__ZInvoice__c on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            List<Zuora__ZInvoice__c> listNew = mapNewS.values();
            Map<Id, Zuora__ZInvoice__c> mapOld = (Map<Id, Zuora__ZInvoice__c>) mapOldS; 
            Map<Id, Zuora__ZInvoice__c> mapNew = (Map<Id, Zuora__ZInvoice__c>) mapNews;
        }
    } 
    
    /**
     * @author Valeria Martino - valeria.martino@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__ZInvoice__c on ' + Trigger.operationType);
        }        
    }
    
    /**
     * @author Valeria Martino - valeria.martino@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__ZInvoice__c on ' + Trigger.operationType);
            List<Zuora__ZInvoice__c> listNew = mapNewS.values();
            XC_TR_ZuoraZInvoice_U_FillInvoiceNum.fillInvoiceNumberDateOnOIOnInsert(listNew);
            XC_TR_ZuoraZInvoice_U_FillConfigItem.PopulateInvoiceConfigItemLookup(listNew); // cr 730 vdb
        //}
      } 
    
    /**
     * @author Valeria Martino - valeria.martino@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__ZInvoice__c on ' + Trigger.operationType); 
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapNews =' + mapNews); 
            List<Zuora__ZInvoice__c> listNew = mapNewS.values();
            Map<Id, Zuora__ZInvoice__c> mapOld = (Map<Id, Zuora__ZInvoice__c>) mapOldS; 
            Map<Id, Zuora__ZInvoice__c> mapNew = (Map<Id, Zuora__ZInvoice__c>) mapNews;
            XC_TR_ZuoraZInvoice_U_CompleteStep.afterUpdateStatus(listNew, mapOld, mapNew);
            XC_TR_ZuoraZInvoice_U_FillInvoiceNum.fillInvoiceNumberDateOnOI(listNew, mapOld, mapNew);
            XC_TR_ZuoraZInvoice_U_FillConfigItem.fillInvoiceConfigItemLookup(mapOld,mapNew);//CR730 26/07/2022
        //}
    }
    
    /**
     * @author Valeria Martino - valeria.martino@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__ZInvoice__c on ' + Trigger.operationType);            
        }           
    } 

    /**
     * @author Valeria Martino - valeria.martino@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapOld) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on Zuora__ZInvoice__c on ' + Trigger.operationType); 
        }           
    }    
}