/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 27-04-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_TR_ContractService_Handler implements XC_I_TriggerHandler{
    
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ContractService_Handler');

    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed); 
    }
    
    public void executedTrigger(){ 
       
    }
    
    /**
    * @description Method to be executed on before insert
    * @author pedro.danielalmeida@nttdata.com | 27-04-2022 
    * @param listNew - new values of records
    **/
    public void onBeforeInsert(List<XC_ContractItem__c> listNew){
        XC_TR_ContractService_U_CheckDuplicates.checkInsertContractService(listNew);
    }
    
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        
    } 
    
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
       
    }
    
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
          
    } 
    
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
        
    }

    public void onAfterDelete(Map<Id, SObject> mapOld){ 
         
    } 

    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        
    }    
}