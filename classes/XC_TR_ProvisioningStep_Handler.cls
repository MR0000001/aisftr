/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 20/11/2018
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_ProvisioningStep_Handler – Handler for XC_TR_ProvisioningStep Trigger
*/

public without sharing class XC_TR_ProvisioningStep_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ProvisioningStep_Handler');
    
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
    public void onBeforeInsert(List<XC_Provisioning_Step__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before update
     * @param mapOld - map Id -> old value of record
     * @param mapNew - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);   
        XC_TR_ProvisioningStep_U_StartProcess.onBeforeUpdate(mapOldS, mapNewS); //20211201_DD_ERR_03 
    } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew) { 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
      } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after update
     * @param mapOld - map Id -> old value of record
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            Map<Id, XC_Provisioning_Step__c> mapOld = (Map<Id, XC_Provisioning_Step__c>) mapOldS; 
            Map<Id, XC_Provisioning_Step__c> mapNew = (Map<Id, XC_Provisioning_Step__c>) mapNewS; 
            //Map<Id,Sobject> mapNewFiltered = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNew, mapEventRecordsToBeReProcessed);  
            /* START LOGIC */ 
            XC_TR_ProvisioningStep_U_PopulateFields.populateMasterOfSubscription(mapOld, mapNew); 
            XC_TR_ProvisioningStep_U_StartProcess.onAfterUpdate(mapOldS, mapNewS);
            // XC_TR_ProvisioningStep_U_StepFinalStatus.onAfterUpdate(mapOldS, mapNewS); DEPRECATED- When the step goes in Completed KO, the cancellation logic is skipped - SS 20/01/2021
            XC_UTIL_CustomerInteractionGeneration_UU.generateOrdersPickupNoStockEnelX(mapOld, mapNew);
            XC_TR_ProvisioningStep_CustomInteraction.customerInteractionEndOfProv( mapNew,  mapOld);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);          
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    }    
}