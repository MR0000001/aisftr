/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 30/08/2019
* @date Modification 04/07/2019
* @description Giic_TR_POReceipt_Handler for Giic_TR_POReceipt
*/
public class Giic_TR_POReceipt_Handler implements XC_I_TriggerHandler  {
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_POReceipt_Handler');
    
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to stop recursion of the same event method in the same transaction  
* @return Boolean true if recursion must be stopped
*/
    public Boolean stopRecursion() {   
          System.debug('Giic_TR_POReceipt_Handler.stopRecursion');
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
    public void onBeforeInsert(List<SObject> objSoList){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
        List<gii__PurchaseOrderReceipt__c> listNew = (List<gii__PurchaseOrderReceipt__c>)objSoList;
        giic_TR_ProductInventoryInInsertUTIL.setCorrectAccountMailOnPOR(listNew);
        giic_TR_ProductInventoryInInsertUTIL.setLEOnPurchaseOrderReceipt(listNew);
        Giic_TR_POReceipt_UTIL.checkIftoSetApprove(listNew);      
       
    }
    /**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @description Method to be executed on before update
* @param mapOldS - map Id -> old value of record
* @param mapNewS - map Id -> new value of record
*/
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
        Map<Id, gii__PurchaseOrderReceipt__c > mapOld = (Map<Id, gii__PurchaseOrderReceipt__c >) mapOldS;
        Map<Id, gii__PurchaseOrderReceipt__c > mapNew = (Map<Id, gii__PurchaseOrderReceipt__c >) mapNewS;
        List<gii__PurchaseOrderReceipt__c > listNew = mapNew.values(); 
       
        
        for(gii__PurchaseOrderReceipt__c poReceipt : listNew){
            if(poReceipt.giic_IntegrationStatus__c == null){
                poReceipt.giic_IntegrationStatus__c = System.Label.giic_TOIntegrationStatusReadyToIntegrate;
                poReceipt.giic_IntegrationOperation__c = System.Label.giic_IntegrationOperationCreate;
                poReceipt.giic_TargetSystem__c = System.Label.giic_TargetSystemSAP;  
            } 
        } 

        Giic_TR_POReceipt_UTIL.preventUpateQualityFields(listNew, mapOld, mapNew);

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
         XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------');
         Map<Id, gii__PurchaseOrderReceipt__c > mapNew = (Map<Id, gii__PurchaseOrderReceipt__c >) mapNewS;
         List<gii__PurchaseOrderReceipt__c > listNew = mapNew.values();
		 Set<Id> porIds = XC_UTIL_Sobject.getSetIds(listNew);
          Giic_TR_POReceipt_UTIL.sendPoReceiptForApproval(listNew);
         Giic_TR_POReceipt_UTIL.rebaltOnWo(porIds);
        for(gii__PurchaseOrderReceipt__c poReceipt : listNew){
            if(poReceipt.giic_DeliveryDate__c != null &&
               poReceipt.giic_DeliveryDocumentID__c != null){
               	XC_REST_GoodReceipt.callSendCreateGoodReceipt3PL(poReceipt.Id);
            }
            /* FIX INC000091382636 */
            /*Boolean sendGoodReceiptSAP = false;
            sendGoodReceiptSAP = Giic_TR_POReceipt_UTIL.checkSendGoodReceiptSAP(poReceipt);
            if(poReceipt.giic_DeliveryDate__c != null &&
               poReceipt.giic_DeliveryDocumentID__c != null 
               && sendGoodReceiptSAP){
                XC_REST_GoodReceipt.callSendCreateGoodReceiptSAP(poReceipt.Id);
            }*/
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
        Map<Id, gii__PurchaseOrderReceipt__c > mapOld = (Map<Id, gii__PurchaseOrderReceipt__c >) mapOldS; 
        Map<Id, gii__PurchaseOrderReceipt__c > mapNew = (Map<Id, gii__PurchaseOrderReceipt__c >) mapNewS;
        List<gii__PurchaseOrderReceipt__c > listNew = mapNew.values();
        Giic_TR_POReceipt_UTIL.sendPoReceiptForApprovalInUpdate(listNew,mapOld,mapNew);
        for(gii__PurchaseOrderReceipt__c poReceipt : listNew){
            if( poReceipt.giic_IntegrationStatus__c==System.Label.giic_TOIntegrationStatusReadyToIntegrate &&
               poReceipt.giic_IntegrationOperation__c==System.Label.giic_IntegrationOperationCreate &&
               poReceipt.giic_TargetSystem__c==System.Label.giic_TargetSystemSAP &&
               poReceipt.giic_DeliveryDate__c != null &&
               poReceipt.giic_DeliveryDocumentID__c != null && 
               poReceipt.giic_Status__c =='Approved' ){  
                  XC_REST_GoodReceipt.callSendCreateGoodReceiptSAP(poReceipt.Id); 
              }
            /*if(poReceipt.giic_IntegrationStatus__c==System.Label.giic_TOIntegrationStatusReadyToIntegrate &&
               poReceipt.giic_IntegrationOperation__c==System.Label.giic_IntegrationOperationCreate &&
               poReceipt.giic_DeliveryDate__c != null &&
               poReceipt.giic_DeliveryDocumentID__c != null && 
               poReceipt.giic_Status__c =='Approved'){
               	XC_REST_GoodReceipt.callSendCreateGoodReceipt3PL(poReceipt.Id);
            }*/
        }
        Giic_TR_POReceipt_UTIL.checkIfDeliveryChange(listNew,mapOld,mapNew);
        
         
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