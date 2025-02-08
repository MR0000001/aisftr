/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 01/02/2019
* @date Modification dd/mm/yyyy
* @description  – public class with invocable method. It is invoked by a Flow to cancel the provisioing on the original order connected to the asset.
*/ 

public without sharing class XC_IN006_CancelPreviousProvisioning {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN006_CancelPreviousProvisioning');
    /** 
    * @description InputWrapper the input wrapper.
    */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }

    private class UtilWrapper{
        List<String> configurationDeprovisioningIds = new List<String>();
        String subtype;
    }
    /** 
     * @description Cancel previous provisioning. 
     * @param inputWrapperList the input wrapper list.
     */
    @InvocableMethod
    public static void cancelPreviousProvisioning(List<InputWrapper> inputWrapperList) {
        Map<Id, NE__OrderItem__c> orderItemsInSameBundleMap = new Map<Id, NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItemsInSameBundle = new List<NE__OrderItem__c>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In XC_IN006_CancelPreviousProvisioning');
        if(!inputWrapperList.isEmpty()){
            UtilWrapper utilWr = getConfigurationDeprovisioningIds(inputWrapperList);
            List<String> configurationDeprovisioningIds = utilWr.configurationDeprovisioningIds;
            String subtype = utilWr.subtype;
            List<String> configurationItemProvisioningIds = getConfigurationItemProvisioningIds(configurationDeprovisioningIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'configurationDeprovisioningIds -->'+ configurationDeprovisioningIds);

            List<Id> orderItemsToSuspendIds = new List<Id>();
            orderItemsToSuspendIds.addAll(configurationItemProvisioningIds); 
            //BUNDLE
            if(!configurationItemProvisioningIds.isEmpty() 
                && Schema.sObjectType.NE__OrderItem__c.isAccessible()
                && Schema.sObjectType.WorkOrder.isAccessible()
            ){
                orderItemsInSameBundleMap = new Map<Id,NE__OrderItem__c>([
                        SELECT Id, NE__OrderId__c,
                        (SELECT Id FROM Work_Orders__r WHERE XC_Check_Final_Status__c =: false)
                        FROM NE__OrderItem__c
                        WHERE (NE__Bundle_Configuration__c IN: configurationItemProvisioningIds 
                        OR Id IN: configurationItemProvisioningIds)
                        AND NE__OrderId__r.NE__Type__c =: Label.XC_CL_Configuration_TypeInOrder
                ]);  
            }
            orderItemsInSameBundle = orderItemsInSameBundleMap.values();
            orderItemsToSuspendIds.addAll(XC_UTIL_Sobject.getIds(orderItemsInSameBundle));  
            
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@##@ configurationItemProvisioningIds-->' + configurationItemProvisioningIds); 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@##@ orderItemsToSuspendIds-->' + orderItemsToSuspendIds);

            List<XC_UTIL_Sobject.WrapperResult> listDMLResult = suspendOrderItems(orderItemsInSameBundle); 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN006 - dmlResultList ---->' + listDMLResult);
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c(Id=inputWrapperList[0].stepId);
            if(!XC_UTIL_Sobject.checkDMLResults(listDMLResult)){  
                stepToUpdate.XC_ErrorMessage__c=listDMLResult[0].errorMessage;
                XC_UTIL_Sobject.updateRecord(stepToUpdate);
                return;
            }
            List<XC_UTIL_Sobject.WrapperResult> listDMLResultOrder = updateOrder(orderItemsInSameBundle,subtype); 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN006 - dmlResultList ---->' + listDMLResultOrder);
            if(!XC_UTIL_Sobject.checkDMLResults(listDMLResultOrder)){
                stepToUpdate.XC_ErrorMessage__c=listDMLResultOrder[0].errorMessage;
                XC_UTIL_Sobject.updateRecord(stepToUpdate);
                return;
            }
            // Removed for Too many queueable jobs error
            //System.enqueueJob(new ManageDMLQueuable (orderItemsInSameBundle));  
            
            List <XC_UTIL_Sobject.WrapperResult> listDMLServiceAppointment =  cancelServiceAppointments(orderItemsInSameBundle);
            if(!XC_UTIL_Sobject.checkDMLResults(listDMLServiceAppointment)){
                stepToUpdate.XC_ErrorMessage__c=listDMLServiceAppointment[0].errorMessage;
                XC_UTIL_Sobject.updateRecord(stepToUpdate);
                return;
            } else {
                stepToUpdate.XC_Status__c=Label.XC_CL_Completed_Ok;
                XC_UTIL_Sobject.updateRecord(stepToUpdate);
            }                           
        }     
    }

    /**
    * Gets the configuration deprovisioning ids.
    * @description Gets the configuration deprovisioning ids.
    * @param inputWrapperList the input wrapper list
    * @return the configuration deprovisioning ids
    **/
    public static UtilWrapper getConfigurationDeprovisioningIds(List<InputWrapper> inputWrapperList){
        UtilWrapper utilWr = new UtilWrapper();
        List<String> configurationDeprovisioningIds = new List<String>(); 
        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        }
        
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>([
            SELECT ID, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c, 
            XC_Configuration_Item__r.NE__Bundle_Configuration__c, XC_ConfigurationId__c
            FROM XC_Provisioning_Step__c 
            WHERE Id IN: listStepIds
        ]);             
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_ConfigurationId__c)){
                configurationDeprovisioningIds.add(step.XC_ConfigurationId__c);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listStepIds -->' + listStepIds);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'configurationDeprovisioningIds -->' + configurationDeprovisioningIds); 
        
        utilWr.configurationDeprovisioningIds = configurationDeprovisioningIds;
        utilWr.subtype = listSteps[0].XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c;
        return utilWr; 
    }

    /**
     * Gets the configuration item provisioning ids.
     * @description the method do getConfigurationItemProvisioningIds
     * @param configurationDeprovisioningIds the configuration deprovisioning ids
     * @return the configuration item provisioning ids
     */
    public static List<String> getConfigurationItemProvisioningIds(List<String> configurationDeprovisioningIds){
        List<Asset> listAsset = new List<Asset>();
        List<String> configurationItemProvisioningIds = new List<String>();
        if(!configurationDeprovisioningIds.isEmpty() && Schema.sObjectType.Asset.isAccessible()){
            listAsset = [SELECT Id, XC_Original_Creation_OrderItem__c  //  XC_Configuration_Item__c
                                    FROM Asset 
                                    WHERE NE__Order_Config__c IN: configurationDeprovisioningIds];
        }
        configurationItemProvisioningIds = XC_UTIL_Sobject.getListFieldValues(listAsset, 'XC_Original_Creation_OrderItem__c');

        return configurationItemProvisioningIds;
    }


    /**
     * @description Cancel service appointments.
     * @param orderItemsToSuspend the order items to suspend
     * @return the list
     */
    public static List<XC_UTIL_Sobject.WrapperResult>  cancelServiceAppointments(List<NE__OrderItem__c> orderItemsToSuspend){
        List<WorkOrder> woToCancel = new List<WorkOrder>();
        for(NE__OrderItem__c oi : orderItemsToSuspend){
            woToCancel.addAll(oi.Work_Orders__r);
        }
        List<WorkOrder> woFatherList = getWOFathers(orderItemsToSuspend);
        if(!woFatherList.isEmpty()){
            woToCancel.addAll(woFatherList);
        } 
        Set<Id> woToCancelIds = XC_UTIL_Sobject.getSetIds(woToCancel);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@##@ woToCancelIds -->' +woToCancelIds );
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@##@ orderitemsMap.get(oiId).Work_Orders__r -->' +woToCancel );
        
        List<ServiceAppointment> listSAToCancel = new List<ServiceAppointment>();
        List<WorkOrder> listWOToCancel = new List<WorkOrder>();
        List<WorkOrder> listWOToUpdate = new List<WorkOrder>();
        if(Schema.sObjectType.ServiceAppointment.isAccessible()){
            listSAToCancel = [
                SELECT Id, Status,XC_Reason_Cannot_Complete__c, ParentRecordId
                FROM ServiceAppointment 
                WHERE ParentRecordId IN: woToCancelIds AND XC_Check_Final_Status__c = false
            ];
            List<String> woIdWithSAList = new List<String>();
            for(ServiceAppointment serviceApp : listSAToCancel){
                woIdWithSAList.add(serviceApp.ParentRecordId);
            }
            List<Id> listWOIdWithoutSA = new List<Id>();
            for(Id woId : woToCancelIds){
                if(!woIdWithSAList.contains(woId)){
                    listWOIdWithoutSA.add(woId);
                } 
            }
            for(Id woId : woToCancelIds){ //listWOIdWithoutSA
                WorkOrder wo = new WorkOrder(Id = woId);
                wo.XC_ToBeManuallyDigitalized__c = true;
                wo.XC_Digitized__c = true;
                listWOToUpdate.add(wo);
            }
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateListRecords(listWOtoUpdate);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);

            for(ServiceAppointment sa : listSAToCancel){
                sa.XC_IgnoreReschedulingLock__c = true;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@##@ Check sa status--->'+ sa.Status); 
                if(sa.Status == Label.XC_CL_ServiceAppointment_None || sa.Status == Label.XC_CL_ServiceAppointment_Scheduled || sa.Status == Label.XC_CL_ServiceAppointment_OnHold){
                    sa.Status = Label.XC_CL_ServiceAppointment_Canceled;
                    sa.XC_ForceWOCancellation__c = true;
                } else {
                    sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
                    sa.XC_Reason_Cannot_Complete__c = Label.XC_CL_ServiceAppointment_CannotCompleteReason_Disconnection;
                }
            }   
            for(Id woIdWithoutSAToCancel : listWOIdWithoutSA){ //listWOIdWithoutSA
                WorkOrder woWithoutSAToCancel = new WorkOrder(Id = woIdWithoutSAToCancel);
                woWithoutSAToCancel.Status = Label.XC_CL_WorkOrder_Canceled;
                listWOToCancel.add(woWithoutSAToCancel);
            }
        }

        //XC_UTIL_Sobject.updateListRecords(listWOToCancel);
        System.enqueueJob(new ManageDMLQueuable (listWOToCancel));  
        List <XC_UTIL_Sobject.WrapperResult> listDMLServiceAppointment = XC_UTIL_Sobject.updateListRecords(listSAToCancel);
        return listDMLServiceAppointment;
    }
    
    private static List<WorkOrder> getWOFathers(List<NE__OrderItem__c> orderItemsToSuspend) {
        List<String> orderIdList = new List<String>();
        for(NE__OrderItem__c orderItem: orderItemsToSuspend){
            orderIdList.add(orderItem.NE__OrderId__c);
        }
        List<WorkOrder> woToVerifyList = new List<WorkOrder>([SELECT Id 
                                                            FROM WorkOrder 
                                                            WHERE XC_Configuration__c IN: orderIdList AND XC_Check_Final_Status__c =: false]);
        return woToVerifyList;
    }

    /**
     * Suspend order items.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param orderItemsToSuspend the order items to suspend
     * @return the list
     * @description Given a list of Order Item update the NE__Status__c in disconnected
     */
    public static List<XC_UTIL_Sobject.WrapperResult> suspendOrderItems(List<NE__OrderItem__c> orderItemsToSuspend){
        for(NE__OrderItem__c oi : orderItemsToSuspend){
            oi.NE__Status__c = Label.XC_CL_Configuration_Item_Disconnected;          
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@##@ Conf Item Updated --->' + orderItemsToSuspend);
        return XC_UTIL_Sobject.updateListRecords(orderItemsToSuspend);
    }

    /**
     * Update order.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param orderItemsList the order items list
     * @return the list
     * @description Given a list of Order Item update two fields on the father Order related to the partial cancellation process
     */
    public static List<XC_UTIL_Sobject.WrapperResult>  updateOrder(List<NE__OrderItem__c> orderItemsList, String subtype){
        Set<NE__Order__c> orderSet = new Set<NE__Order__c>();
        for(NE__OrderItem__c orderItem: orderItemsList){
            NE__Order__c order = new NE__Order__c(Id = orderItem.NE__OrderId__c);
            order.XC_Status__c = Label.XC_CL_Configuration_OrderCancelled;
            order.XC_Cancellation_Date__c = Date.today();
            if(subtype == Label.XC_CL_OrdersubTypeValue_Rethinking){
                order.XC_Type_of_cancellation__c = Label.XC_CL_Configuration_CancellationType_Total;
                order.XC_Reason_of_cancellation__c = Label.XC_CL_Configuration_UserRethinking;
            } else {
                order.XC_Type_of_cancellation__c = Label.XC_CL_Configuration_CancellationType_Partial;
                order.XC_Reason_of_cancellation__c = Label.XC_CL_Configuration_ProductUnavailability;                
            }
            orderSet.add(order);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@##@ order updated -->' + orderSet);    
        List<NE__Order__c> orderList = new List<NE__Order__c>(orderSet);
        return XC_UTIL_Sobject.updateListRecords(orderList);
    }


    /**
    * @description 
    **/
    public class ManageDMLQueuable implements Queueable{
        List <WorkOrder> woToUpdate;

        /**
        * @description
        * @param woToUpdate - List <WorkOrder>
        **/
        public ManageDMLQueuable(List <WorkOrder> woToUpdate){
            this.woToUpdate = woToUpdate;
        }
        
        /**
        * @description 
        * @author Del Prete Domenico | 28/10/2019 
        * @param context 
        **/
        public void execute(QueueableContext context) {
            XC_UTIL_Sobject.updateListRecords(woToUpdate);
        }
    }
}