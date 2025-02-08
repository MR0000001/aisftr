/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 04/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderHandler – Handler for giic_TransferOrderTrigger.
*/
public without sharing class Giic_TR_TransferOrder_Handler implements XC_I_TriggerHandler  {
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_TransferOrder_Handler');
     
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
    public void onBeforeInsert(List<gii__TransferOrder__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger ----------');
        Giic_TransferOrderUtility.setLEOnTO(listNew);
        Giic_TR_TransferOrder_UTIL.setEmailFiled(listNew);
        Giic_TransferOrderUtility.setCorrectRecordTypeInInsert(listNew);
        Giic_TransferOrderUtility.rebaltFromWhFieldsOnTO(listNew);
        for(gii__TransferOrder__c to: listNew){           
            if(to.giic_Approved__c == true  ){
                to.giic_IntegrationStatus__c=System.Label.giic_TOIntegrationStatusReadyToIntegrate;
                to.giic_TargetSystem__c=System.Label.giic_TargetSystem3PL;
                to.giic_IntegrationOperation__c=System.Label.giic_IntegrationOperationCreate ;
            }
        }
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
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger Before Update----------');
        map<Id,gii__TransferOrder__c> mapOld = (map<Id,gii__TransferOrder__c>)mapOldS;
        map<Id,gii__TransferOrder__c> mapNew = (map<Id,gii__TransferOrder__c>)mapNewS;
        List<gii__TransferOrder__c > listNew = mapNew.values();
        for(gii__TransferOrder__c objTO: (list<gii__TransferOrder__c>)mapNewS.values()){
            if(objTO.gii__Status__c == Label.giic_PartiallyShipped || objTO.gii__Status__c == Label.giic_StatusShipped || objTO.gii__Status__c == Label.giic_TOPartiallyReceivedStatus || objTO.gii__Status__c == Label.giic_Received){
				objTO.giic_status__c = objTO.gii__Status__c; 
            }
           /* if(objTO.giic_Approved__c && objTO.giic_IntegrationStatus__c != System.Label.giic_IntegrationStatusSuccess
              && objTO.giic_IntegrationStatus__c != System.Label.giic_IntegrationStatusFailure){ 
                objTO.giic_IntegrationStatus__c= System.Label.giic_TOIntegrationStatusReadyToIntegrate;
                objTO.giic_TargetSystem__c= System.Label.giic_TargetSystem3PL;
                objTO.giic_IntegrationOperation__c=System.Label.giic_IntegrationOperationCreate ;
            }     */
        }
        giic_TransferOrderUtility.checkIfStatusChange(listNew,mapOld,mapNew); 
        giic_TransferOrderUtility.upgradeAddressWarehouse(listNew,mapOld,mapNew);
        Giic_TransferOrderUtility.checkIfFromWHChange(listNew,mapOld,mapNew);


    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger ----------');
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        /*if(!system.isBatch()){
        giic_TransferOrderUtility.checkLimitsForOrder(mapNewS.values());
        }*/
        List<gii__TransferOrder__c > listNew = mapNewS.values();
        giic_UTIL_TransferOrderSharing.startToShare(listNew);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger ----------');
        Giic_TR_TransferOrder_UTIL.setGoodsNotAvailable(listNew);
        
    }
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
   public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
        List<Id> toIdList=new List<Id>();
		List<Id> toIdList2=new List<Id>();
		List<Id> restTOIdList=new List<Id>();
		for(gii__TransferOrder__c to: (list<gii__TransferOrder__c>)mapNewS.values()){
            if(to.giic_NewDeliveryDate__c != null && to.giic_NewDeliveryDate__c!=((gii__TransferOrder__c)mapOldS.get(to.Id)).giic_NewDeliveryDate__c){
                toIdList.add(to.Id);  
            }  
        	if(to.giic_IntegrationStatus__c==System.Label.giic_TOIntegrationStatusReadyToIntegrate
              && to.giic_TargetSystem__c==System.Label.giic_TargetSystem3PL
              && to.giic_IntegrationOperation__c==System.Label.giic_IntegrationOperationCreate 
              && to.giic_Approved__c == true  ){  
                  restTOIdList.add(to.Id); 
             }
            if(to.giic_Status__c == 'Cancelled'/* || to.giic_Status__c == 'Merged'*/){
                toIdList2.add(to.Id);  
            } 
            
        }
       
        if(toIdList.size()>0){
            giic_TransferOrderUtility.createCaseFromTO(toIdList); 
            giic_TransferOrderUtility.checkIfNeedCustomerInteraction(toIdList); 
        }
        if(toIdList2.size()>0){
            Giic_TransferOrderUtility.reserveQuantitiesAfterToDel(toIdList2);
            Giic_TransferOrderLineUtility.cancelQtyToWOPI(toIdList2);           
        }
        if(restTOIdList.size()>0){ 
            XC_REST_TransferOrder.callSendCreateTransferOrder3PL(restTOIdList);
        } 
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
        Map<Id, gii__TransferOrder__c > mapOld = (Map<Id, gii__TransferOrder__c >) mapOldS; 
        Map<Id, gii__TransferOrder__c > mapNew = (Map<Id, gii__TransferOrder__c >) mapNewS;      
        List<gii__TransferOrder__c > listNew = mapNew.values();
        Giic_TransferOrderUtility.checkIfWHFromChange(listNew,mapOld,mapNew);
      	Giic_TR_ManageOrderTracking.fillFieldsOrderTracking(listNew,mapOld,mapNew);
        giic_UTIL_TransferOrderSharing.startToShareInUpdate(listNew,mapOld,mapNew);
        giic_TransferOrderUtility.closeSalesOrder(listNew,mapOld,mapNew);
       
    }

   
    /**
     * @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOlds){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger ----------');
        Map<Id, gii__TransferOrder__c > mapOld = (Map<Id, gii__TransferOrder__c >) mapOldS;
        List<id> toIdList = new List<id>();
        for(gii__TransferOrder__c to: mapOld.values()){
            toIdList.add(to.id);
        }
        Giic_TransferOrderUtility.ReserveQuantitiesAfterToDel(toIdList);
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger ----------');
    }
}