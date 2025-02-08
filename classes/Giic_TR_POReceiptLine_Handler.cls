/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 03/07/2019
* @date Modification 04/07/2019
* @description Giic_PurchaseOrderHandler – Handler for Giic_TR_POReceiptLine_Handler.
*/
public class Giic_TR_POReceiptLine_Handler implements XC_I_TriggerHandler {
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_POReceiptLine_Handler');
    
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to stop recursion of the same event method in the same transaction  
* @return Boolean true if recursion must be stopped
*/
    public Boolean stopRecursion() {   
         return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);  
         //return true;
    }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to set to true the stop recursion variable on the current trigger event  
*/
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
         XC_UTIL_Debug.debug(DEBUGACTIVE,'executedTrigger ----------');
    }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on before insert
* @param listNew - list of new values of records
*/
    public void onBeforeInsert(List<gii__TransferOrder__c> listNew){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'onBeforeInsert ----------');
    }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on before update
* @param mapOldS - map Id -> old value of record
* @param mapNewS - map Id -> new value of record
*/
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'onBeforeUpdate ----------');
    }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on before delete
* @param mapOld - map Id -> old value of record
*/
    public void onBeforeDelete(Map<Id, SObject> mapOld) { 
    List<Id> porId=new List<Id>();
         giic_POReceiptLineUtility.checkReasonOnPOR(mapOld.values());
         for(gii__PurchaseOrderReceiptLine__c objPORL : (list<gii__PurchaseOrderReceiptLine__c>)mapOld.values()){
             porId.add(objPORL.gii__PurchaseOrderReceipt__c);
         }
        if(porId.size()>0){ 
            Giic_IntegrationUtility.createPOReceiptStaging(porId); 
        }
        
        giic_POReceiptLineUtility.adjQuantityOnPI(mapOld.values());
    }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on after insert
* @param mapNewS - map Id -> new value of record
*/
    public void onAfterInsert(Map<Id, SObject> mapNewS) {  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Init onAfterInsert ----------');
        giic_POReceiptLineUtility.calcAvgPrice(mapNewS.values());
        giic_POReceiptLineUtility.clearBackOrderQtyOnPI(mapNewS.values());
        giic_POReceiptLineUtility.updateProductRequired(mapNewS.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE,'End onAfterInsert ----------'); 
      }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on after update
* @param mapOldS - map Id -> old value of record
* @param mapNewS - map Id -> new value of record
*/
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){  }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on after delete
* @param mapOld - map Id -> old value of record
*/
    public void onAfterDelete(Map<Id, SObject> mapOld){  } 
    
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on after undelete
* @param mapNew - map Id -> new value of record
*/
    public void onAfterUnDelete(Map<Id, SObject> mapNew) {  }
    
    
}