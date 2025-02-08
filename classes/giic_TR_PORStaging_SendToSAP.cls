/**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 17/10/2019
* @description giic_TR_PORStaging_SendToSAP  
*/
public without sharing class giic_TR_PORStaging_SendToSAP {
    
     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_TR_PORStaging_SendToSAP');
    /**
    * @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
    * @date Creation 17/10/2019
    * @description method for sending a PurchaseOrderReceiptStaging to SAP Procurement System
    * @param lstPOReceiptChangeEvent list<gii__PurchaseOrderReceiptStaging__c>
    */	
      public static void sendToSAP(List<gii__PurchaseOrderReceiptStaging__c> lstPOReceiptStaging){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In giic_TR_PORStaging_SendToSAP.sendToSAP'); 
        for(gii__PurchaseOrderReceiptStaging__c porStaging : lstPOReceiptStaging) { 
                if(porStaging.giic_IntegrationStatus__c==System.Label.giic_TOIntegrationStatusReadyToIntegrate &&
                   porStaging.giic_IntegrationOperation__c==System.Label.giic_CancellationRequest &&
                   porStaging.giic_TargetSystem__c==System.Label.giic_TargetSystemSAP &&
                   porStaging.giic_MaterialDocument__c != null && porStaging.giic_YearDocument__c != null){
                      XC_REST_GoodReceipt.callSendUpdateGoodReceiptSAP(porStaging.Id);  
                   }
                
            }
     }
    
    public static void checkIfIntegrationStatusChange(List<gii__PurchaseOrderReceiptStaging__c> listNew,Map<Id, gii__PurchaseOrderReceiptStaging__c> mapOld,Map<Id, gii__PurchaseOrderReceiptStaging__c> mapNew){
        List<String> fieldList = new List<String>{'giic_IntegrationStatus__c','giic_IntegrationOperation__c','giic_TargetSystem__c'};
        List<gii__PurchaseOrderReceiptStaging__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        sendToSAP(listChanged);
        
        
    }
   
}