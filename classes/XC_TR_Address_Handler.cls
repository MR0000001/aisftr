/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/03/2019
* @date Modification 08/04/2019 Marco Rosa - marco.rosa@nttdata.com
* @description XC_TR_Address_Handler – Handler for XC_TR_Address Trigger
*/ 

public without sharing class XC_TR_Address_Handler implements XC_I_TriggerHandler {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Address_Handler');
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
      
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records 
    */

    public void onBeforeInsert(List<XC_Address__c> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            XC_TR_Address_U_PopulateFields.populateNameAddress(listNew);
            XC_TR_Address_U_PopulateFields.populateStreetTypeText(listNew);
            XC_TR_Address_U_PopulateFields.populateMacthKeyField(listNew);
            XC_TR_Address_U_PopulateFields.populateAccountAndLeadFields(listNew);
        }
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */

    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
            Map<Id, XC_Address__c> mapOld = (Map<Id, XC_Address__c>) mapOldS; 
            Map<Id, XC_Address__c> mapNew = (Map<Id, XC_Address__c>) mapNewS;
            List<XC_Address__c> listNew = mapNew.values();
            XC_TR_Address_U_PopulateFields.populateNameAddressOnUpdate(listNew, mapOld, mapNew);
            XC_TR_Address_U_PopulateFields.populateStreetTypeText(listNew, mapOld, mapNew);
            XC_TR_Address_U_PopulateFields.populateMacthKeyField(listNew, mapOld, mapNew);
            XC_TR_Address_U_PopulateFields.populateAccountAndLeadFieldsOnUpdate(listNew, mapOld, mapNew);
        }
    } 
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    
    public void onBeforeDelete(Map<Id, SObject> mapOld){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }            
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */

    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            List<XC_Address__c> listNew = mapNew.values();
            XC_TR_Address_U_PopulateFields.updateAddressOnLead(listNew);
        }         
    } 
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */

    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
        }
        //[Start Denise Avolio denise.avolio@accenture.com 18-03-2022 R2 CR756]
        Map<Id, XC_Address__c> mapOld = (Map<Id, XC_Address__c>) mapOldS; 
        Map<Id, XC_Address__c> mapNew = (Map<Id, XC_Address__c>) mapNewS;      
        List<XC_Address__c> listNew = mapNew.values();
        XC_TR_Address_SetProvinceOnAsset.setProvinceOnAsset(listNew, mapOld, mapNew); 
        //[END Denise Avolio denise.avolio@accenture.com 18-03-2022 R2 CR756]        
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }                  
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    
    public void onAfterUnDelete(Map<Id, SObject> mapNew){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }            
    }    
}