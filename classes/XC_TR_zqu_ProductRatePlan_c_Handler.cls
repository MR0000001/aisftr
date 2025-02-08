/**
* @author Antonio D'Onofrio - andonofrio@deloitte.it
* @date Creation 20/04/2020
* @description zqu_ProductRatePlan_c – Handler for XC_TR_zqu_ProductRatePlan_c
*/ 

public without sharing class XC_TR_zqu_ProductRatePlan_c_Handler implements XC_I_TriggerHandler {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_zqu_ProductRatePlan_c_Handler');
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
    

    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Antonio D'Onofrio - andonofrio@deloitte.it 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records 
    */

    public void onBeforeInsert(List<zqu__ProductRatePlan__c> listNew){
        
        if(XC_TR_zqu_ProductRatePlan_c_U.skipTrigger(listNew) == true){
            
            System.debug('Trigger skipped');
            
        }else{
            
            System.debug('Trigger starting. ProductRatePlan Migration.');
            
            XC_TR_zqu_ProductRatePlan_c_U.manageFields(listNew);
            
        }

    }
    


    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
	
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        
    } 
    

    
    public void onBeforeDelete(Map<Id, SObject> mapOld){
    
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        
    }


    public void onAfterInsert(Map<Id, SObject> mapNew){ 
    
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        
    } 
    


    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
    
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        
    }
    

    
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
    
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    
    } 

    
    public void onAfterUnDelete(Map<Id, SObject> mapNew){ 
        
    	XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
                    
    }  
}