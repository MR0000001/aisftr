/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 03/07/2019
* @date Modification 04/07/2019
* @description Giic_TransferOrderLineHandler – Handler for Giic_TR_PurchaseOrderLine_Handler.
*/
public class Giic_TR_PurchaseOrderLine_Handler implements XC_I_TriggerHandler {
	public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_PurchaseOrderLine_Handler');
     
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
    	return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed); 
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<gii__PurchaseOrderLine__c> listNew){
        giic_PurchaseOrderUtility.preventPOLineInsert(listNew);
        giic_PurchaseOrderUtility.updatePOLWithDiscountOnInsert(listNew);
        giic_PurchaseOrderUtility.preventMoreTransCost(listNew);
        giic_PurchaseOrderUtility.checkMinQuantity(listNew);
        giic_PurchaseOrderUtility.SetPartnerGRGI(listNew);
        giic_PurchaseOrderUtility.rebaltinfoPOLine(listNew);//NR2338
        
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com  
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        Map<Id, gii__PurchaseOrderLine__c > mapOld = (Map<Id, gii__PurchaseOrderLine__c >) mapOldS; 
        Map<Id, gii__PurchaseOrderLine__c > mapNew = (Map<Id, gii__PurchaseOrderLine__c >) mapNewS;
        List<gii__PurchaseOrderLine__c > listNew = mapNew.values();
         giic_PurchaseOrderUtility.updatePOLWithDiscountOnUpdate(listNew,mapOld,mapNew);
         giic_PurchaseOrderUtility.preventPOLineInUpdate(listNew,mapOld,mapNew);
         giic_PurchaseOrderUtility.preventMoreTransCostInUpdt(listNew);
         giic_PurchaseOrderUtility.checkMinQuantity(listNew);
         
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
           XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        List<gii__PurchaseOrderLine__c > listNew = mapNewS.values();
        if(!system.isBatch()){ 
            Giic_PurchaseOrderUtility.checkLimitsForOrderFromTrigger(mapNewS.values(),true,null); 
        }
        Giic_TR_ManageOrderTracking.updateAlertFlagOnPO(listNew);
     
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
        Map<Id, gii__PurchaseOrderLine__c > mapOld = (Map<Id, gii__PurchaseOrderLine__c >) mapOldS; 
        Map<Id, gii__PurchaseOrderLine__c > mapNew = (Map<Id, gii__PurchaseOrderLine__c >) mapNewS;
        List<gii__PurchaseOrderLine__c > listNew = mapNew.values();
        Giic_TR_ManageOrderTracking.rebaltOrderTrackOnPo(listNew,mapOld,mapNew);
        Giic_TR_ManageOrderTracking.checkIfAmountChange(listNew,mapOld,mapNew);
        if (Trigger.isAfter && Trigger.isUpdate){
            if(!system.isBatch()){
                Giic_PurchaseOrderUtility.checkLimitsForOrderFromTrigger(mapNewS.values(),false,mapOldS);
            }
        }
    }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on after delete
* @param mapOld - map Id -> old value of record
*/
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
         XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');     
    } 
    
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on after undelete
* @param mapNew - map Id -> new value of record
*/
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
           XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    }
 

}