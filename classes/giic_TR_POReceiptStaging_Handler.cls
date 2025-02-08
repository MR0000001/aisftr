/**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 07/11/2019 
* @description Giic_TR_POReceipt Trigger on PO Receipt
*/
public class giic_TR_POReceiptStaging_Handler implements XC_I_TriggerHandler  {
	 public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_TR_POReceiptStaging_Handler');
     
    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
       // return false; //TEMP MR
    }
    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<gii__PurchaseOrder__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    }
    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
       XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
        
    }
    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
         XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    }
    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
          XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
          giic_TR_PORStaging_SendToSAP.sendToSAP(mapNewS.values());
    }
    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
   public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
     XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
     Map<Id, gii__PurchaseOrderReceiptStaging__c> mapNew = (map<Id,gii__PurchaseOrderReceiptStaging__c>)mapNewS;
     Map<Id, gii__PurchaseOrderReceiptStaging__c> mapOld = (map<Id,gii__PurchaseOrderReceiptStaging__c>)mapOldS;
     List<gii__PurchaseOrderReceiptStaging__c> listNew = mapNew.values();
     giic_TR_PORStaging_SendToSAP.checkIfIntegrationStatusChange(listNew,mapOld,mapNew);
       
    }
 
    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
       XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    } 

    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
         XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    }
}