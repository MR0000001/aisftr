/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 02/11/2020
* @date Modification dd/mm/yyyy
* @description  – XC_TR_BillingProfileLineItem_U_UpdateOI  - Update the Order Item when the bpli is activated 
*/ 
public without sharing class XC_TR_BillingProfileLineItem_U_UpdateOI {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_BillingProfileLineItem_U_UpdateOI'); 
    
    /**
    * @description  method to start on bpli on update
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 02/11/2020
    * @param orderItemList List<XC_BillingProfileLineItem__c> 
    */
    public static void onUpdate(Map<Id, XC_BillingProfileLineItem__c> mapOld, Map<Id, XC_BillingProfileLineItem__c> mapNew){
        List<String> fieldList = new List<String>{'XC_Status__c'};
        List<XC_BillingProfileLineItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew); 
        if(listChanged.isEmpty()){
            return;
        }
        chechBPLIStatus(listChanged);
    }
    
    /**
    * @description  method to check that the bpli is not Draft anymore
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 02/11/2020
    * @param orderItemList List<XC_BillingProfileLineItem__c> 
    */
    private static void chechBPLIStatus(List<XC_BillingProfileLineItem__c> listChanged) { 
        List<String> billingProfileLineIdItemList = new List<String>();
        for(XC_BillingProfileLineItem__c bpli :listChanged){
            if(bpli.XC_Status__c != Label.XC_CL_BillingProfileStatus_Draft && bpli.XC_Status__c != Label.XC_CL_BillingProfileStatus_Refused ){
                billingProfileLineIdItemList.add(bpli.id);
            }
        }
        if(billingProfileLineIdItemList.isEmpty()){
            return;
        }
        List<NE__OrderItem__c> oiList = getOrderItemId(billingProfileLineIdItemList);
        startCongaProcess(oiList);
        startProvisioning(oiList);
    }

    /**
    * @description  method to start the Conga Document Creation by updating the field XC_StartCongaProcess__c on NE__OrderItem__c
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 03/12/2020
    * @param orderItemList List<XC_BillingProfileLineItem__c> 
    */
    private static void startCongaProcess(List<NE__OrderItem__c> oiList){
        List<NE__OrderItem__c> oiListToUpdateWithEvent = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oi : oiList){
            if(!oi.XC_StartCongaProcess__c){
                oiListToUpdateWithEvent.add(oi);
            }
        }
        insertEventForConga(oiListToUpdateWithEvent);
    }

        /**
    * @description  method to start the provisioning when a CC BPLI is not Draft anymore
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 03/12/2020
    * @param orderItemList List<XC_BillingProfileLineItem__c> 
    */
    private static void startProvisioning(List<NE__OrderItem__c> oiList){
        Set<String> orderIdSet = new Set<String>();
        for(NE__OrderItem__c oi : oiList){
            orderIdSet.add(oi.NE__OrderId__c);
        }
        if(orderIdSet.size() == 1){
            String orderId =  new List<String>(orderIdSet)[0] ;
            startProvisioningOnSingleOrder(orderId);
        } else if(orderIdSet.size() > 1) {
            List<String> orderIdList = new List<String>();
            String orderId =  new List<String>(orderIdSet)[0] ;
            startProvisioningOnSingleOrder(orderId);
            for(String orId : orderIdSet ){
                if(orId != orderId){
                    orderIdList.add(orId);
                }	                
            }
            insertEventForProvisioning(orderIdList);
        }
    }
    
    /**
    * @description  method to retrieve order item id related to the billing profile line item
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 02/11/2020
    * @param orderItemList List<XC_BillingProfileLineItem__c> 
    */
    private static List<NE__OrderItem__c> getOrderItemId(List<String> billingProfileLineIdItemList){
        List<String> listStatusForError = new List<String>{
            Label.XC_CL_Configuration_OrderInProvisioning,
                Label.XC_CL_Configuration_Closed,
                Label.XC_CL_Configuration_OrderCancelled
                };
                    Id recTypeOrderId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_Order).getRecordTypeId();
        List<NE__OrderItem__c> oiList = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c, XC_StartCongaProcess__c
                                                                    FROM NE__OrderItem__c
                                                                    WHERE XC_BillingProfileLineItem__c IN : billingProfileLineIdItemList
                                                                    AND  NE__OrderId__r.RecordTypeId =: recTypeOrderId
                                                                    AND NE__OrderId__r.XC_Status__c NOT IN: listStatusForError]);
        //AND NE__OrderId__r.XC_SignedByExternal__c != 'Web']);
        return oiList;
    }
    
    /**
    * @author Salvatore Scarpato
    * @description Given a list of order items launchs a Platform Event to perform an update
    * @param stepIdList
    **/
    private static void insertEventForConga(List<NE__OrderItem__c> oiList) {
        List<String> operationsRecordIds = new List<String>();
        if(!oiList.isEmpty()){
            for(NE__OrderItem__c orderItem : oiList){
                String operationOrderItem = 'launchConga#-#' + orderItem.Id;
                operationsRecordIds.add(operationOrderItem);
            }
            String orderIdToExecute = operationsRecordIds[0];
            operationsRecordIds.remove(0);
            String operationsRecordStringIds = String.join(operationsRecordIds, ';;');
            if(!String.isBlank(orderIdToExecute)){ 
                XC_UtilEvent__e event = new XC_UtilEvent__e();
                event.XC_OperationRecordId__c = orderIdToExecute;
                event.XC_OperationRecordIdList__c = operationsRecordStringIds;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'event->' + event);
                XC_UTIL_PlatformEvent.publishListEvent(event);
            }
        }
    }
    
    /**
    * @author Salvatore Scarpato
    * @description Given a list of record Ids launchs a Platform Event with the concatenation of record Ids
    * @param stepIdList
    **/
    private static void insertEventForProvisioning(List<String> orderIdList){
        List<String> operationsRecordIds = new List<String>();
        if(!orderIdList.isEmpty()){
            for(String orderId : orderIdList){
                String operationOrderId = 'launchProvisioning#-#' + orderId;
                operationsRecordIds.add(operationOrderId);
            }
            String orderIdToExecute = operationsRecordIds[0];
            operationsRecordIds.remove(0);
            String operationsRecordStringIds = String.join(operationsRecordIds, ';;');
            if(!String.isBlank(orderIdToExecute)){ 
                XC_UtilEvent__e event = new XC_UtilEvent__e();
                event.XC_OperationRecordId__c = orderIdToExecute;
                event.XC_OperationRecordIdList__c = operationsRecordStringIds;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'event->' + event);
                XC_UTIL_PlatformEvent.publishListEvent(event);
            }
        }
    }
    
    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09-29-2021 
    * @param orderId 
    **/
    private static void startProvisioningOnSingleOrder(String orderId){
        XC_UTIL_ResultWrapper resultWrapper = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(orderId);
        if(resultWrapper.success && resultWrapper.executeNextStep && !Test.isRunningTest()) {
            XC_UTIL_ResultWrapper resultWrapperChangeInProv = new XC_UTIL_ResultWrapper();
            XC_LCC099_NextStepOrderToProvisioning.manageChangeInProvisioning(orderId, resultWrapperChangeInProv);
            if(resultWrapperChangeInProv.success && resultWrapperChangeInProv.executeNextStep && !Test.isRunningTest()) {
                System.enqueueJob(new XC_UTIL_NextStepOrderToProvisioning.ThirdNextStepQueue(orderId)); 
            }
        }
    }
}