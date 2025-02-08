/**
* @author Marco Rosa - marco.rosa@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 19/09/2018
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_AssignedResource_Handler – Handler for XC_TR_AssignedResource Trigger
*/

public without sharing class XC_TR_AssignedResource_Handler implements XC_I_TriggerHandler {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_AssignedResource_Handler');
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    
    public void executedTrigger(){ 
        //mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<AssignedResource> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);        

        }
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);    
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);      
        }
    } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }        
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after insertù
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            List<AssignedResource> listNew = mapNew.values();
            XC_TR_AssignedResource_U_UpdateOwner.updateFieldsAfterAssignment(listNew);
            //[DDP] Rework Glovia XC_TR_AssignedResource_U_Glovia.createSalesOrder(listNew);
        }
    } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
            List<AssignedResource> listNew = mapNewS.values();
            Map<Id, AssignedResource> mapOld = (Map<Id, AssignedResource>) mapOldS; 
            Map<Id, AssignedResource> mapNew = (Map<Id, AssignedResource>) mapNewS; 
            XC_TR_AssignedResource_U_UpdateOwner.updateFieldsOnUpdate(listNew, mapOld, mapNew);             
        }
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
        }           
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }           
    }    
}