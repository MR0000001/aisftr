/**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 17/10/2019
* @description Giic_TR_SalesOrder_Handler –  Event Trigger to close Delivery WO
*/
public without sharing class Giic_TR_SalesOrder_Handler implements XC_I_TriggerHandler {
public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_SalesOrder_Handler');
    
    /**
     * @author  Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
      	return false;
        //return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
     
    }
    
    /**
     * @author  Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author  Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */ 
    public void onBeforeInsert(List<gii__SalesOrder__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        Giic_TR_SalesOrder_UTIL.setLEOnSO(listNew);
        
    }
    
    /**
     * @author  Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);    

        
    } 
    
    /**
     * @author  Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
                
    }
    
    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
       
      } 
    
    /**
     * @author  Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record 
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
            System.debug('@@@# Giic_TR_SalesOrder_Handler.onAfterUpdate');
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
          //  mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            List<gii__SalesOrder__c> listNew = mapNewS.values(); 
            giic_TR_SalesOrder_CloseWO.closedWorkOrder(listNew);
            Map<Id, gii__SalesOrder__c> mapOld = (Map<Id, gii__SalesOrder__c>) mapOldS; 
            Map<Id, gii__SalesOrder__c> mapNew = (Map<Id, gii__SalesOrder__c>) mapNewS; 
            Giic_TR_SalesOrder_UTIL.checkIfNeedCustomerInteraction(listNew, mapOld);
            Giic_TR_SalesOrder_UTIL.customInteractionDeliveryTracking(listNew, mapOld, mapNew);
         
     
    }
    
    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
      
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
                 
    } 

    /**
     * @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapOld - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapOld) { 
       
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
                 
    }    
}