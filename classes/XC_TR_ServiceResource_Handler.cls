/**
* @author Federica Tavera - federica.tavera@nttdata.com
* @date Creation 13/09/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_ServiceResource_Handler – Handler for XC_TR_ServiceResource Trigger
*/

public without sharing class XC_TR_ServiceResource_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceResource_Handler');
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {
        if(mapTriggerStopped.containsKey(Trigger.operationType) && mapTriggerStopped.get(Trigger.operationType)){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'TR-> Trigger event ' + Trigger.operationType + ' recursion stopped');
            return true;
        }
        return false;
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<ServiceResource> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        XC_TR_ServiceResource_U_FillContactInfo.fillContactInfoMethod(listNew); 
        // XC_TR_ServiceResource_U_FillContactInfo.populateFields(listNew); SS 23-07-2020 Now the logic is in XC_TR_ServiceResource_U_FillContactInfo.fillContactInfoMethod
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
            List<ServiceResource> listNew = mapNewS.values();
            Map<Id, ServiceResource> mapOld = (Map<Id, ServiceResource>) mapOldS; 
            Map<Id, ServiceResource> mapNew = (Map<Id, ServiceResource>) mapNews; 
            XC_TR_ServiceResource_U_WorkingForEndesa.checkResourceWorkingForEndesa(listNew, mapOld, mapNew);
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
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        List<ServiceResource> listNew = mapNewS.values();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Before enter in classes in After Insert');
        XC_TR_ServiceResource_U_UserTerritory.checkAccountOnResources(listNew);

      } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Before enter in classes in After Update');
        XC_TR_ServiceResource_U_PopulateSRC.populateServiceResourceCoverage(mapOldS, mapNewS);

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