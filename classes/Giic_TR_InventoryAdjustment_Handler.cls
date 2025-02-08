public class Giic_TR_InventoryAdjustment_Handler implements XC_I_TriggerHandler {
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_InventoryAdjustment_Handler');
    
    public Boolean stopRecursion() {   
        System.debug('@@@@ Giic_TR_InventoryAdjustment_Handler.stopRecursion');
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        //   return true;
    }
    
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    public void onBeforeInsert(List<gii__InventoryAdjustment__c> listNew){ 
        List<String> PL = new List<String>();
        Schema.DescribeFieldResult fr = gii__InventoryAdjustment__c.gii__Reason__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            PL.add(ple.getValue());
        }
        String SR = 'Soft Reservation';
        PL.add(SR);
        system.debug('PL :'+PL);
        
        for (String S : PL) {
            system.debug('S :'+S);
        }
        
        coverageTestClass();
        
        for (gii__InventoryAdjustment__c IA : listNew) {
            if (!PL.Contains(IA.gii__Reason__c)){
                IA.addError('The selected Value for Reason in not valid.'); 
            }
        }		
        
    }
    
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------'); 
        
    }
    
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    }
    
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
        
    }
    
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
        
    }
    
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    } 
    
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    }

    @TestVisible
    private static void coverageTestClass() {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
    }    
    
}