/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 04/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderHandler – Handler for giic_TransferOrderTrigger.
*/
public class Giic_TR_ReceiptQueue_Handler implements XC_I_TriggerHandler  {
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_ReceiptQueue_Handler');
     
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Giic_TR_ReceiptQueue_Handler --------- stopRecursion ----------');
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'receiptQueue_Handler --------- start ----------');
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<gii__ReceiptQueue__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'receiptQueue_Handler Before Insert ----------');
        Giic_IntegrationUtility.setLEFromTO(listNew);
    }
    
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
     * @modified: Anil Giri  - Anil.giri@fujitsu.com
     * @Modified Date: 11/09/2019
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'receiptQueue_Handler Before Update----------');
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'receiptQueue_Handler onBeforeDelete----------');
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
       XC_UTIL_Debug.debug(DEBUGACTIVE, 'receiptQueue_Handler onAfterInsert ----------'); 
       List<gii__ReceiptQueue__c > listNew = mapNewS.values();
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
   public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
   		 XC_UTIL_Debug.debug(DEBUGACTIVE, 'receiptQueue_Handler onAfterUpdate ----------');    
   }

   
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'receiptQueue_Handler ----------');
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'receiptQueue_Handler ----------');
    }
}