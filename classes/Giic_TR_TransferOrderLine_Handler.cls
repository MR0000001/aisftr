/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 03/07/2019
* @date Modification 04/07/2019
* @description Giic_TransferOrderLineHandler – Handler for Giic_TR_TransferOrderLine_Handler.
*/
public class Giic_TR_TransferOrderLine_Handler implements XC_I_TriggerHandler {
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_TransferOrderLine_Handler');
    
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
    public void onBeforeInsert(List<gii__TransferOrderLine__c> listNew){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
         Giic_TransferOrderLineUtility.preventTOLineInsert(listNew);
         Giic_TransferOrderLineUtility.SetPartnerGRGI(listNew);
    }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on before update
* @param mapOldS - map Id -> old value of record
* @param mapNewS - map Id -> new value of record
*/
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
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
        User u = [SELECT Id , XC_EnabledToSkip__c FROM User WHERE Id = :UserInfo.getUserId() ];
        if(!u.XC_EnabledToSkip__c){
            List<gii__TransferOrderLine__c > tolListNew = giic_TransferOrderLineUtility.getTolWithToNotMerged(mapNews.values());
            if(tolListNew.size() > 0){
                giic_TransferOrderUtility.checkLimitsForOrderFromTrigger(tolListNew,true,null);
                Giic_TransferOrderLineUtility.reserveQuantitiesForTOL(tolListNew, false);
                Giic_TransferOrderLineUtility.addQtyToWOPI(tolListNew);
            }
        }
    }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on after update
* @param mapOldS - map Id -> old value of record
* @param mapNewS - map Id -> new value of record
*/
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
        Map<Id, gii__TransferOrderLine__c > mapOld = (Map<Id, gii__TransferOrderLine__c >) mapOldS; 
        Map<Id, gii__TransferOrderLine__c > mapNew = (Map<Id, gii__TransferOrderLine__c >) mapNewS;
        List<gii__TransferOrderLine__c > listNew = mapNew.values();
        Giic_TR_ManageOrderTracking.rebaltOrderTrackOnTO(listNew,mapOld,mapNew);
        giic_TransferOrderUtility.checkLimitsForOrderFromTrigger(mapNewS.values(),false,mapOldS);
        Giic_TransferOrderLineUtility.checkIfQuantityChange(mapNewS.values(), mapNew, mapOld);
        Giic_TransferOrderLineUtility.checkIfWhChange(listNew,mapOld,mapNew);
    }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on after delete
* @param mapOld - map Id -> old value of record
*/
    public void onAfterDelete(Map<Id, SObject> mapOlds){ 
         XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
         Map<Id, gii__TransferOrderLine__c > mapOld = (Map<Id, gii__TransferOrderLine__c >) mapOldS;
         List<gii__TransferOrderLine__c > listOld = mapOld.values();
        giic_TransferOrderLineUtility.reserveQuantitiesForTOL(mapOlds.values(), mapOld);  
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