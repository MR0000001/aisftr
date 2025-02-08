/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
* @date Creation 31/07/2019
* @date Modification 31/07/2019  Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
* @description XC_TR_BillingProfile_Handler – Trigger Handler on BillingProfile
*/ 

public without sharing class XC_TR_BillingProfile_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_BillingProfile_Handler');
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        //return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        return false;
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com  
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<NE__Billing_Profile__c> listNew){
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            XC_TR_BillingProfile_U_fillFields.populateAccountId(listNew);
        //}
    } 
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
            List<NE__Billing_Profile__c> listNew = mapNewS.values();
            Map<Id, NE__Billing_Profile__c> mapOld = (Map<Id, NE__Billing_Profile__c>) mapOldS; 
            Map<Id, NE__Billing_Profile__c> mapNew = (Map<Id, NE__Billing_Profile__c>) mapNews;   
            XC_TR_BillingProfile_U_StartCongaWF.populateCongaField(listNew, mapOld, mapNew);
        //}
    }  
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        //if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            Map<Id, NE__Billing_Profile__c> mapNew = (Map<Id, NE__Billing_Profile__c>)mapNewS;
            List<NE__Billing_Profile__c> listNew = mapNew.values();
            XC_TR_BillingProfile_ManageSEPA.createSepaMandate(listNew);
            //XC_TR_BillingProfile_U_StartCongaWF.onInsert(listNew);
        //}
      } 
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        List<NE__Billing_Profile__c> listNew = mapNewS.values();
        Map<Id, NE__Billing_Profile__c> mapOld = (Map<Id, NE__Billing_Profile__c>) mapOldS; 
        Map<Id, NE__Billing_Profile__c> mapNew = (Map<Id, NE__Billing_Profile__c>) mapNews;

        XC_TR_BillingProfile_U_UpdateOnChild.manageStatusUpdate(listNew, mapOld, mapNew);


        XC_TR_BillingProfile_U_DisconnectAsset.onStatusUpdate(mapOld, mapNew);
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    } 

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to be executed on after undelete
     * @param mapNew- map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    }    
}