/**
* @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone massimiliano.avallone@nttdata.com
* @date Creation 10/09/2019
* @description XC_TR_ZipCodeWorkType_Handler - Handler for XC_TR_ZipCodeWorkType
*/

public without sharing class XC_TR_ZipCodeWorkType_Handler implements XC_I_TriggerHandler{
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ZipCodeWorkType');
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();

    /**
     * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone massimiliano.avallone@nttdata.com 
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */     
    public Boolean stopRecursion(){   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    /**
     * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone massimiliano.avallone@nttdata.com  
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
 
    /**
     * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone massimiliano.avallone@nttdata.com  
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<XC_ZipCodeWorkType__c> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            XC_TR_ZipCodeWorkType_U_FillFields.populateExternalId(listNew);
        }
    }
    
    /**
     * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone massimiliano.avallone@nttdata.com 
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
      public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    } 
    
    /**
     * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone massimiliano.avallone@nttdata.com  
     * @description Method to be executed on before delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
   
    }
    
    /**
     * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone massimiliano.avallone@nttdata.com  
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    } 
    
    /**
     * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone massimiliano.avallone@nttdata.com 
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    }
    
    /**
     * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone massimiliano.avallone@nttdata.com 
     * @description Method to be executed on after delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOldS){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    } 

    /**
     * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone massimiliano.avallone@nttdata.com 
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew ){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    }  
	

}