/**
* @author FirstName : Parveen Kaur Parveen.Kaur@in.fujitsu.com
* @date Creation 03/07/2019
* @date Modification 04/07/2019
* @description Giic_PurchaseOrderHandler – Handler for giic_PurchaseOrderTrigger.
*/
public class Giic_TR_PurchaseOrder_Handler implements XC_I_TriggerHandler {
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_PurchaseOrder_Handler');
     
    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        System.debug('@@@@ Giic_TR_PurchaseOrder_Handler.stopRecursion');
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
     //   return true;
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
        giic_PurchaseOrderUtility.updateSupplierDiscount(listNew);
        giic_PurchaseOrderUtility.populateFieldForSharing(listNew);
        giic_PurchaseOrderUtility.setCorrectRecordTypeInInsert(listNew);
        giic_PurchaseOrderUtility.setTargetSystemIfApproved(listNew);
        giic_PurchaseOrderUtility.setWarehouseEmailAddress(listNew);
    }
    
    
    
    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
      
       XC_UTIL_Debug.debug(DEBUGACTIVE,'Trigger ----------'); 
        Map<Id, gii__PurchaseOrder__c > mapOld = (Map<Id, gii__PurchaseOrder__c >) mapOldS; 
        Map<Id, gii__PurchaseOrder__c > mapNew = (Map<Id, gii__PurchaseOrder__c >) mapNewS;
        List<gii__PurchaseOrder__c > listNew = mapNew.values();
        for(gii__PurchaseOrder__c objPO : listNew) { 
            if(objPO.gii__Status__c == 'Closed' && mapOld.get(objPO.Id).giic_Status__c != 'Cancelled' ){
                objPO.giic_Status__c = 'Closed';
            }
            if(objPO.gii__Status__c == 'Open' && mapOld.get(objPO.Id).giic_Status__c == 'Closed' && mapOld.get(objPO.Id).gii__Status__c == 'Closed'){
                objPO.giic_Status__c = 'Approved';
            }
        /*    if(objPO.giic_Status__c == 'Cancelled' && mapNew.get(objPO.Id).giic_IntegrationStatus__c != 'Integration Success' && mapNew.get(objPO.Id).giic_IntegrationStatus__c != 'Integration Failure'){
                objPO.giic_IntegrationStatus__c = System.Label.giic_TOIntegrationStatusReadyToIntegrate;
                objPO.giic_IntegrationOperation__c = System.Label.giic_CancellationRequest ;
                Set<String> values = new Set<String>();
                values.add(Label.giic_TargetSystemSAP);
                values.add('3PL');
                objPO.giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(null , values);
            }*/
        }
        giic_TR_PurchaseOrder_ManageUpdate.checkContractEndDate(listNew,mapOld,mapNew);
        giic_PurchaseOrderUtility.updateSupplierDiscount(listNew);
        giic_PurchaseOrderUtility.checkIfStatusChange(listNew,mapOld,mapNew);
        giic_PurchaseOrderUtility.setEnelUserName(listNew,mapOld,mapNew);
        giic_PurchaseOrderUtility.checkIfWarehouseChange(listNew, mapNew, mapOld);
        giic_PurchaseOrderUtility.checkIf4PLStatusChange(listNew, mapNew, mapOld);
        giic_PurchaseOrderUtility.checkIfWhChangeForEmail(listNew, mapNew, mapOld);
        giic_PurchaseOrderUtility.checkIfPickupDateChange(listNew, mapNew, mapOld);
		//NR2246	
		giic_PurchaseOrderUtility.SetOrderDeliveryDate(listNew, mapNew, mapOld);
		//NR2246
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
         
          Map<Id, gii__PurchaseOrder__c > mapNew = (Map<Id, gii__PurchaseOrder__c >) mapNewS;
          List<gii__PurchaseOrder__c > listNew = mapNew.values(); 
          giic_PurchaseOrderUtility.populateGloviaPriceBookId(mapNew);
        
         giic_PurchaseOrderUtility.rebaltinfoPO(listNew);//NR2338
         giic_PurchaseOrderUtility.qualityCheckPO(listNew); //NR2345
          
        
    }
    /**
     * @author Parveen Kaur Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
   public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
       Map<Id, gii__PurchaseOrder__c > mapOld = (Map<Id, gii__PurchaseOrder__c >) mapOldS; 
       Map<Id, gii__PurchaseOrder__c > mapNew = (Map<Id, gii__PurchaseOrder__c >) mapNewS;
       List<gii__PurchaseOrder__c > listNew = mapNew.values();
       system.debug('@@@@ listNew:' + ListNew);
       giic_TR_PurchaseOrder_ManageUpdate.createCaseFromPO(listNew,mapNew,mapOld);
       giic_PurchaseOrderUtility.checkIfWarehouseChange(listNew, mapNew, mapOld);
       giic_PurchaseOrderUtility.checkIfTotalOpenQtyChange(listNew,mapNew, mapOld);
       
	   giic_TR_PurchaseOrder_ManageUpdate.processAfterUpdate(mapOld , mapNew);
       Giic_TR_ManageOrderTracking.manageOrderTracking(listNew,mapOld , mapNew);

       //giic_TR_PurchaseOrder_ManageUpdate.customInteractionDeliveryTracking(listNew,mapNew,mapOld);
       
       //NR1923 send Update PO to Geodis also if some of fiels below are updated
       List<String> fieldList = new List<String>{'giic_NewDeliveryDate__c','giic_TrackingSubstate__c','giic_DeliveryTracking__c','giic_CarrierName__c','giic_NewPickupDate__c'};
       List<gii__PurchaseOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
       system.debug('@@@@ listChanged: ' + listChanged); 
       
       for(gii__PurchaseOrder__c po : listNew){ 
			  if(po.giic_IntegrationStatus__c == System.Label.giic_TOIntegrationStatusReadyToIntegrate 
              && po.giic_IntegrationOperation__c == System.Label.giic_IntegrationOperationCreate && mapOld.get(po.Id).giic_Status__c != 'Closed' &&
              po.gii__Approved__c == true && !System.isFuture() ){  
                  XC_REST_PurchaseOrder.callSendCreatePurchaseOrder(po.Id);
              } 
           
             if( po.giic_IntegrationStatus__c == System.Label.giic_TOIntegrationStatusReadyToIntegrate &&
              po.giic_IntegrationOperation__c == System.Label.giic_CancellationRequest && po.giic_Status__c== 'Cancelled' && mapOld.get(po.Id).giic_Status__c != 'Cancelled' &&
              !System.isFuture()){       
                  XC_REST_PurchaseOrder.callSendUpdatePurchaseOrder(po.Id); 
              }
           	 //NR1923
           	 if(!listChanged.isEmpty() && po.gii__Approved__c == true &&
              !System.isFuture() ){
                  system.debug('sto chiamando update verso 3PL');
           		XC_REST_PurchaseOrder.callSendUpdatePurchaseOrder3PL(po.Id);
       		 }
       }
			 
       giic_PurchaseOrderUtility.afterForSharing(listNew,mapNew,mapOld);  
       if(  !System.isFuture()){  
       		giic_TR_PurchaseOrder_ManageUpdate.checkIfNeedCustomerInteraction(listNew, mapOld);
       }
       
       giic_PurchaseOrderUtility.checkIfRequiredDateChange(listNew, mapNew, mapOld);
       giic_PurchaseOrderUtility.checkIfNewDeliveryDateChange(listNew, mapNew, mapOld);
      
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