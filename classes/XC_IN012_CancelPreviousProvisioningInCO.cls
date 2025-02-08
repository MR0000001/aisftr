/**
 * @author: Riccardo Cossu - riccardo.cossu@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date: 07 - 03 - 2019
 * @description  – public class with invocable method. It is invoked by a Flow of the change the provisioing  to cancel on the original order connected to the asset. 
 **/

public without sharing class XC_IN012_CancelPreviousProvisioningInCO {

    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN012_CancelPreviousProvisioningInCO');

    /**
     * @description Input Wrapper
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }
    
    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @param inputWrapperList the list coming from flow
     * @description class to the the logic of cancelPreviousProvisioning
     */
    @InvocableMethod
    public static void cancelPreviousProvisioning(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In XC_IN012_CancelPreviousProvisioningInCO');
        
        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
           
            List<NE__OrderItem__c> orderItemsInSameBundle = new List<NE__OrderItem__c>();
            List<String> configurationDeprovisioningIds = getConfigurationDeprovisioningIds(inputWrapperList);
            List<String> configurationItemProvisioningIds = getConfigurationItemProvisioningIds(configurationDeprovisioningIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'configurationDeprovisioningIds -->'+ configurationDeprovisioningIds);

            List<Id> orderItemsToSuspendIds = new List<Id>();

            //WITH OK GAS/LUZ AND OK GAZ/LUZ
            if(!configurationItemProvisioningIds.isEmpty() && Schema.sObjectType.NE__OrderItem__c.isAccessible()){
                Map<Id,NE__OrderItem__c> orderItemsInSameBundleMap= new Map<Id,NE__OrderItem__c> ([
                    SELECT Id,NE__OrderId__c,
                    (SELECT Id, Status, XC_WorkTypeCategory__c FROM Work_Orders__r)
                    FROM NE__OrderItem__c
                    WHERE (NE__Parent_Order_Item__c IN: configurationItemProvisioningIds 
                    OR Id IN: configurationItemProvisioningIds)
                    AND NE__OrderId__r.NE__Type__c =: Label.XC_CL_Configuration_TypeInOrder
                ]);  

                orderItemsInSameBundle = orderItemsInSameBundleMap.values();
            } 

            
            if(orderItemsInSameBundle.isEmpty()){
                updateStepsStatus(inputWrapperList, Label.XC_CL_Step_Skipped, '');
                return;
            }

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@!!@@ orderItemsInSameBundle  -->' + orderItemsInSameBundle);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@!!@@ configurationItemProvisioningIds  --->' + configurationItemProvisioningIds);
            orderItemsToSuspendIds.addAll(XC_UTIL_Sobject.getIds(orderItemsInSameBundle));  

            List<XC_UTIL_Sobject.WrapperResult> listDMLResult = suspendOrderItems(orderItemsInSameBundle); 
            if(!XC_UTIL_Sobject.checkDMLResults(listDMLResult)){
                updateStepsStatus(inputWrapperList, Label.XC_CL_Step_CompletedKO, Label.XC_CL_ProvisioningStep_OrderItemDisconnectionError);
                return;
            }

            listDMLResult = updateOrder(orderItemsInSameBundle);
            if(!XC_UTIL_Sobject.checkDMLResults(listDMLResult)){
                updateStepsStatus(inputWrapperList, Label.XC_CL_Step_CompletedKO, Label.XC_CL_ProvisioningStep_OrderCancellationError);
                return;
            }

            listDMLResult = cancelServiceAppointments(orderItemsInSameBundle); 
            if(!XC_UTIL_Sobject.checkDMLResults(listDMLResult)){
                updateStepsStatus(inputWrapperList, Label.XC_CL_Step_CompletedKO, Label.XC_CL_ProvisioningStep_ServiceAppCancellationError);
                return;
            }        

            updateStepsStatus(inputWrapperList, Label.XC_CL_Completed_Ok, '');
            return;
                                        
        }     

        updateStepsStatus(inputWrapperList, Label.XC_CL_Step_CompletedKO, '');
        return;
    }


    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description method to return list of configurationDeprovisioningIds     
     * @param inputWrapperList the list coming from flow
     * @return the configuration deprovisioning ids
     */
    public static List<String> getConfigurationDeprovisioningIds(List<InputWrapper> inputWrapperList){
        List<String> configurationDeprovisioningIds = new List<String>();
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>(); 
        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        }
        if(Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            listSteps = [
                SELECT ID, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, 
                XC_Configuration_Item__r.NE__Bundle_Configuration__c, XC_ConfigurationId__c
                FROM XC_Provisioning_Step__c 
                WHERE Id IN: listStepIds
            ];    
        }          
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_ConfigurationId__c)) {
                configurationDeprovisioningIds.add(step.XC_ConfigurationId__c);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listStepIds -->' + listStepIds);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'configurationDeprovisioningIds -->' + configurationDeprovisioningIds); 
        return configurationDeprovisioningIds;
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description method to return list of configurationItemProvisioningIds
     * @param configurationDeprovisioningIds the configuration deprovisioning ids
     * @return configurationItemProvisioningIds the configuration item provisioning ids
     */
    public static List<String> getConfigurationItemProvisioningIds(List<String> configurationDeprovisioningIds){
        List<String> configurationItemProvisioningIds = new List<String>();
        if(!Schema.sObjectType.Asset.isAccessible()){
            return configurationItemProvisioningIds;
        }
        List<Asset> listAsset = [SELECT Id, XC_Original_Creation_OrderItem__c
                                FROM Asset 
                                WHERE NE__Order_Config__c IN: configurationDeprovisioningIds];
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@# listAsset -->' + listAsset);                         
        for(Asset asset : listAsset){
            if(asset.XC_Original_Creation_OrderItem__c != null){
                configurationItemProvisioningIds.add(asset.XC_Original_Creation_OrderItem__c);
            }
        }
        return configurationItemProvisioningIds;
    }


    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description method to return list of configurationItemProvisioningIds
     * @param orderItemsToSuspend the order items to suspend
     * @return the list
     */
    public static List<XC_UTIL_Sobject.WrapperResult> cancelServiceAppointments(List<NE__OrderItem__c> orderItemsToSuspend){
        
        List<WorkOrder> woToCancel = new List<WorkOrder>();
        if(!Schema.sObjectType.ServiceAppointment.isAccessible()){
            return new List<XC_UTIL_Sobject.WrapperResult>();
        }
        for(NE__OrderItem__c oi : orderItemsToSuspend){
            woToCancel.addAll(oi.Work_Orders__r);
        }
        List<WorkOrder> listWorkOrderToUpdate = new List<WorkOrder>();
        for(WorkOrder wo : woToCancel) {
            if(wo.Status == Label.XC_CL_WorkOrder_Assigned && wo.XC_WorkTypeCategory__c  == Label.XC_CL_WorkType_PlannedMaintenance){
                wo.Status = Label.XC_CL_OnHold;
                listWorkOrderToUpdate.add(wo);
            }
        }
        XC_UTIL_Sobject.updateListRecords(listWorkOrderToUpdate);


        List<Id> woToCancelIds = XC_UTIL_Sobject.getIds(woToCancel);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@##@ woToCancelIds -->' +woToCancelIds );
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@##@ orderitemsMap.get(oiId).Work_Orders__r -->' +woToCancel );

        List<ServiceAppointment> listSAToCancel = [
            SELECT Id, Status,XC_Reason_Cannot_Complete__c
            FROM ServiceAppointment 
            WHERE ParentRecordId =: woToCancelIds AND XC_Check_Final_Status__c = false
        ];
        for(ServiceAppointment sa : listSAToCancel){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@##@ Check sa status--->'+ sa.Status);
            sa.XC_IgnoreReschedulingLock__c = true;
            if(sa.Status == Label.XC_CL_ServiceAppointment_None){
                sa.Status = Label.XC_CL_ServiceAppointment_Canceled;
            } else {
                sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
                sa.XC_Reason_Cannot_Complete__c = Label.XC_CL_ServiceAppointment_CannotCompleteReason_Disconnection;
            }
        }   
        return XC_UTIL_Sobject.updateListRecords(listSAToCancel);
    }
    
    /**
     * Suspend order items.
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
    public static List<XC_UTIL_Sobject.WrapperResult> updateOrder(List<NE__OrderItem__c> orderItemsList){
        Set<NE__Order__c> orderSet = new Set<NE__Order__c>();
        NE__Order__c order = new NE__Order__c(Id = orderItemsList[0].NE__OrderId__c);
        order.XC_Type_of_cancellation__c = Label.XC_CL_Configuration_CancellationType_Partial;
        order.XC_Reason_of_cancellation__c = Label.XC_CL_Configuration_ProductUnavailability;        
        /*for(NE__OrderItem__c orderItem: orderItemsList){
            NE__Order__c order = new NE__Order__c(Id = orderItem.NE__OrderId__c);
            order.XC_Type_of_cancellation__c = Label.XC_CL_Configuration_CancellationType_Partial;
            order.XC_Reason_of_cancellation__c = Label.XC_CL_Configuration_ProductUnavailability;
            orderSet.add(order);
        }
           
        */
        orderSet.add(order);
        List<NE__Order__c> orderList = new List<NE__Order__c>(orderSet);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@##@ order updated -->' + orderList); 
        return XC_UTIL_Sobject.updateListRecords(orderList);
    }


    /**
     * @description method to set provisioning step status   
     * @param inputWrapperList the list coming from flow
     * @param status the status to set on the step 
     * @param errorMessage the error message to set on the step
    */
    public static void updateStepsStatus(List<InputWrapper> inputWrapperList, String status, String errorMessage){
        
        List<XC_Provisioning_Step__c> stepToUpdate = new List<XC_Provisioning_Step__c>();

        for(InputWrapper inputWr : inputWrapperList){ 
            XC_Provisioning_Step__c step = new XC_Provisioning_Step__c (Id = inputWr.stepId, XC_Status__c = status);
            if(!String.isBlank(errorMessage)){
                step.XC_ErrorMessage__c = errorMessage;
            }        
            stepToUpdate.add(step);
        }
        XC_UTIL_Sobject.updateListRecords(stepToUpdate);

    }

}