/**
* @author FirstName : Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @date Creation 03/07/2019
* @date Modification 04/07/2019
* @description Giic_TR_Receipt_Handler – Handler for Giic_TR_Receipt.
*/
public class Giic_TR_Receipt_Handler implements XC_I_TriggerHandler {
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_Receipt_Handler');
    
    /**O
* @author Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @description Method to stop recursion of the same event method in the same transaction  
* @return Boolean true if recursion must be stopped
*/
    public Boolean stopRecursion() {   
         XC_UTIL_Debug.debug(DEBUGACTIVE,'****mapTriggerStopped****'+mapTriggerStopped + '***Trigger.operationType****'+Trigger.operationType);
          XC_UTIL_Debug.debug(DEBUGACTIVE,'****mapEventRecordsToBeReProcessed****'+mapEventRecordsToBeReProcessed );
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        //return false; //TEMP MR
    }
    /**
* @author Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @description Method to set to true the stop recursion variable on the current trigger event  
*/
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    /**
* @author Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @description Method to be executed on before insert
* @param listNew - list of new values of records
*/
    public void onBeforeInsert(List<gii__Receipt__c> listNew){
          XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
            for(gii__Receipt__c receipt : listNew){
                if(receipt.giic_IntegrationStatus__c == null && receipt.gii__TransferOrder__c != null){
                    receipt.giic_IntegrationStatus__c=System.Label.giic_TOIntegrationStatusReadyToIntegrate;
                    receipt.giic_IntegrationOperation__c=System.Label.giic_IntegrationOperationCreate;
                }
            }
    }
    /**
* @author Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @description Method to be executed on before update
* @param mapOldS - map Id -> old value of record
* @param mapNewS - map Id -> new value of record
*/
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    }
    /**
* @author Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @description Method to be executed on before delete
* @param mapOld - map Id -> old value of record
*/
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
          XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    }
    /**
* @author Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @description Method to be executed on after insert
* @param mapNewS - map Id -> new value of record
*/
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
      User u = [SELECT Id , XC_EnabledToSkip__c FROM User WHERE Id = :UserInfo.getUserId() ];
      if(!u.XC_EnabledToSkip__c){
      	Giic_ReceiptUtility.changeQtyToWOPI(mapNewS.values());
          
      	if(Giic_TransferOrderIntegrationUtility.isExecuteClearBackOrder){
        	Giic_ReceiptUtility.clearBackOrderQtyOnPI(mapNewS.values());
      	} 
          
      }
      Map<Id, gii__Receipt__c > mapNew = (Map<Id, gii__Receipt__c >) mapNewS;
      List<gii__Receipt__c > listNew = mapNew.values();
        for(gii__Receipt__c receipt : listNew){
            if(receipt.giic_IntegrationStatus__c==System.Label.giic_TOIntegrationStatusReadyToIntegrate &&
            receipt.giic_IntegrationOperation__c==System.Label.giic_IntegrationOperationCreate){
                XC_REST_GoodReceipt.callSendCreateTOGoodReceipt3PL(receipt.id);
            }
        }
        
        /*List<Id> porId=new List<Id>();
        for(gii__Receipt__c objRQ : (list<gii__Receipt__c>)mapNewS.values()){
            porId.add(objRQ.Id);
        }
        if(porId.size()>0){
            Giic_IntegrationUtility.setReceiptStatusReadytoIntegrate(porId);
        }*/
        
    }
    /**
* @author Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @description Method to be executed on after update
* @param mapOldS - map Id -> old value of record
* @param mapNewS - map Id -> new value of record
*/
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
           XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
        
      }
    /**
* @author Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @description Method to be executed on after delete
* @param mapOld - map Id -> old value of record
*/
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
          XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    } 
    
    /**
* @author Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @description Method to be executed on after undelete
* @param mapNew - map Id -> new value of record
*/
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
          XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
    }
    
    
}