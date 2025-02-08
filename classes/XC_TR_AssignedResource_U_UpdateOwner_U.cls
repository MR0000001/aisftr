/**
* @author Marco Rosa - marco.rosa@nttdata.com 
* @date Creation 18/04/2019
* @date Modification 30/09/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description UTIL Class for XC_TR_AssignedResource_U_UpdateOwner
*/ 

public class XC_TR_AssignedResource_U_UpdateOwner_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_AssignedResource_U_UpdateOwner'); 
    
    
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @description Update data for Maintenance Work Orders
    * @param mapServiceAppointment
    * @param saId
    * @param saToUpdate 
    */
    public static void updateServiceAppointmentMaintenance(Map<Id, ServiceAppointment> mapServiceAppointment, Id saId, ServiceAppointment saToUpdate){      
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start  XC_TR_AssignedResource_U_UpdateOwner');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner.updateServiceAppointmentMaintenance');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner.updateServiceAppointmentMaintenance');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner.updateServiceAppointmentMaintenance');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner.updateServiceAppointmentMaintenance');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner.updateServiceAppointmentMaintenance');
        if(mapServiceAppointment.get(saId).XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
            if(
                mapServiceAppointment.get(saId).Status == Label.XC_CL_ServiceAppointment_Scheduled 
                && mapServiceAppointment.get(saId).EarliestStartTime >= (Date.Today().addMonths(6))
            ) {
                saToUpdate.Status = Label.XC_CL_ServiceAppointment_OnHold; 
            } else if(
                mapServiceAppointment.get(saId).Status == Label.XC_CL_ServiceAppointment_OnHold 
                && (
                    mapServiceAppointment.get(saId).EarliestStartTime <= System.now() 
                    || System.now().isSameDay(mapServiceAppointment.get(saId).EarliestStartTime)
                    )
            ) { 
                saToUpdate.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            }
        }
    }
    
    /**  
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @param mapAssignedResources the map assigned resources
    * @return the map service appointment service resource
    * @description Returns a map ServiceAppointmentId -> ServiceResourceId
    */ 
    public static Map<Id, Id> getMapServiceAppointmentServiceResource(Map<Id, AssignedResource> mapAssignedResources){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner.mapAssignedResources');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner.mapAssignedResources');
        Map<Id,Id> mapServiceAppointmentServiceResource = new Map<Id,Id>();
        for (Id arId : mapAssignedResources.keySet()){
       		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ENTER FOR mapAssignedResources');
			XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ENTER FOR mapAssignedResources');
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ENTER FOR mapAssignedResources');
            AssignedResource ar = mapAssignedResources.get(arId);
            mapServiceAppointmentServiceResource.put(ar.ServiceAppointmentId, ar.ServiceResource.Id);     
        }
        return mapServiceAppointmentServiceResource;
    }
    
    /**  
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @param mapAssignedResources the map assigned resources
    * @return the map service appointment service resource with accountid
    * @description Returns a map ServiceAppointmentId -> ServiceResource.AccountId
    */ 
    public static Map<Id, Id> getMapServiceAppointmentServiceResourceAccount(Map<Id, AssignedResource> mapAssignedResources){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner.getMapServiceAppointmentServiceResourceAccount');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start getMapServiceAppointmentServiceResourceAccount');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start getMapServiceAppointmentServiceResourceAccount');
        Map<Id,Id> mapServiceAppointmentServiceResourceAccount = new Map<Id,Id>();
        for (Id arId : mapAssignedResources.keySet()){
            AssignedResource ar = mapAssignedResources.get(arId);
            mapServiceAppointmentServiceResourceAccount.put(ar.ServiceAppointmentId, ar.ServiceResource.XC_Account__c);
        }
        return mapServiceAppointmentServiceResourceAccount;
    }
    
    /** 
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @param mapAssignedResources the map assigned resources
    * @return the map work order service appointment
    * @description Returns a map Work Order -> Service Appointment
    */
    public static Map<Id,Id> getMapWorkOrderServiceAppointment(Map<Id, AssignedResource> mapAssignedResources){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner.getMapWorkOrderServiceAppointment');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start getMapWorkOrderServiceAppointment');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start getMapWorkOrderServiceAppointment');
        Map<Id,Id> mapWorkOrderServiceAppointmentId = new Map<Id,Id>(); 
        for (Id arId : mapAssignedResources.keySet()){ 
            AssignedResource ar = mapAssignedResources.get(arId);
            mapWorkOrderServiceAppointmentId.put(ar.ServiceAppointment.parentRecordId, ar.ServiceAppointmentId);     
        }
        return mapWorkOrderServiceAppointmentId;
    } 

    /** 
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @param mapAssignedResources the map assigned resources
    * @return the map service appointment work order
    * @description Returns a map Service Appointment -> WorkOrder
    */
    public static Map<Id,Id> getMapServiceAppointmentWorkOrder(Map<Id, AssignedResource> mapAssignedResources){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner.getMapServiceAppointmentWorkOrder');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start getMapServiceAppointmentWorkOrder');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start getMapServiceAppointmentWorkOrder');
        Map<Id,Id> mapServiceAppointmentWorkOrderId = new Map<Id,Id>(); 
        for (Id arId : mapAssignedResources.keySet()){ 
            AssignedResource ar = mapAssignedResources.get(arId);
            mapServiceAppointmentWorkOrderId.put(ar.ServiceAppointmentId, ar.ServiceAppointment.parentRecordId);     
        }
        return mapServiceAppointmentWorkOrderId;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @param wrapper containing 
    *                          listWorkOrder the list work order
    *                          mapWorkOrderServiceAppointmentId -> the map work order service appointment id
    *                          mapServiceAppointmentServiceResource the map service appointment service resource
    *                          mapServiceAppointment the map service appointment
    * @description This method fills fields XC_InstallationAssignedResource__c and XC_MaintenanceAssignedResource__c on Asset. US ESCEP-551 ESCEP-833
    */
    public static void updateAsset(XC_TR_AssignedResource_U_UpdateOwner_W.UpdateRecordWrapper wrapper){  
        List<WorkOrder> listWorkOrder = wrapper.listWorkOrder; 
        Map<Id,Id> mapWorkOrderServiceAppointmentId = wrapper.mapWorkOrderServiceAppointmentId; 
        Map<Id,Id> mapServiceAppointmentServiceResource = wrapper.mapServiceAppointmentServiceResource; 
        Map<Id, ServiceAppointment> mapServiceAppointment = wrapper.mapServiceAppointment;
        
        List<Asset> listAssetToUpdate = new List<Asset>();
        for(WorkOrder wo : listWorkOrder){ 
            if(!mapWorkOrderServiceAppointmentId.containsKey(wo.Id)){
                continue;
            }
            Id saId = mapWorkOrderServiceAppointmentId.get(wo.Id); 
            if(!mapServiceAppointmentServiceResource.containsKey(saId)){
                continue;
            }
            Date appointmentDateTime = mapServiceAppointment.get(saId).SchedStartTime.Date();
            Id serviceResourceId = mapServiceAppointmentServiceResource.get(saId);
            if(wo.AssetId!=null){
                listAssetToUpdate.add(populateFieldsOnAsset(wo,appointmentDateTime,serviceResourceId)); 
            } else {
                for(WorkOrder woChild : wo.ChildWorkOrders){
                    listAssetToUpdate.add(populateFieldsOnAsset(woChild,appointmentDateTime,serviceResourceId)); 
                }
            }
        }
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(listAssetToUpdate);
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 08-24-2021 
    * @param wo 
    * @param mapServiceAppointmentServiceResource 
    * @param mapServiceAppointment 
    * @return Asset 
    **/
    private static Asset populateFieldsOnAsset(WorkOrder wo, Date appointmentDateTime, Id serviceResourceId){
        Asset asset = new Asset();
        asset.Id = wo.AssetId;
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ XC_WorkTypeCategory__c-->' +wo.XC_WorkTypeCategory__c );   
        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation 
                || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Installation){
            asset.XC_InstallationAssignedResource__c = serviceResourceId;
        } else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
            asset.XC_MaintenanceAssignedResource__c = serviceResourceId;
            asset.XC_LastMaintenanceDate__c = appointmentDateTime;
        } else if(XC_UTIL_WorkType.isRepair( wo.XC_WorkTypeCategory__c )){
            asset.XC_RepairAssignedResource__c = serviceResourceId;
            asset.XC_LastRepairDate__c = appointmentDateTime;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ asset-->' +asset ); 
        return asset;
    }  

    /** 
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @param updateWOwrapper the update W owrapper
    * @date Modification 04/03/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description This method fills gives ownership of the WorkOrder to the assigned Service Resource.
    */ 
    public static void updateWorkOrder(XC_TR_AssignedResource_U_UpdateOwner_W.UpdateRecordWrapper updateWOwrapper){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start updateWOwrapper');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start updateWOwrapper');
        List<WorkOrder> listWorkOrderToUpdate = new List<WorkOrder>();  
        List<WorkOrder> listWorkOrderForGlovia = new List<WorkOrder>();
        for(WorkOrder wo : updateWOwrapper.listWorkOrder){ 
            Boolean toUpdate = false;
            Id saId = null;
            if(updateWOwrapper.mapWorkOrderServiceAppointmentId.containsKey(wo.Id)){
        		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ in IF');
        		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ in IF');
                saId = updateWOwrapper.mapWorkOrderServiceAppointmentId.get(wo.Id);

                if(updateWOwrapper.mapServiceAppointment.containsKey(saId)) {
                    ServiceAppointment sa = updateWOwrapper.mapServiceAppointment.get(saId);
                    wo.XC_EarliestStartPermitted__c = sa.EarliestStartTime;
                    wo.XC_IgnoreReschedulingLock__c = false;
                    /*if(!sa.XC_AssignToPartner__c) {
                        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_Assignedtothetechnician;
                    } else {
                        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_Pendingassigntechnician;
                    }*/
                    toUpdate = true;
                }
                if(updateWOwrapper.mapServiceAppointmentServiceTerritoryId.containsKey(saId)){
                    wo.ServiceTerritoryId = updateWOwrapper.mapServiceAppointmentServiceTerritoryId.get(saId);
                    toUpdate = true;
                }
                if(updateWOwrapper.mapServiceAppointmentServiceResource.containsKey(saId)){
                    wo.XC_AssignedResource__c = updateWOwrapper.mapServiceAppointmentServiceResource.get(saId);
                    wo.XC_AssignedPartner__c = updateWOwrapper.mapServiceAppointmentServiceResourceAccount.get(saId);
                    toUpdate = true;
                }  
            } 
            if(toUpdate) {
               // wo.XC_StatusReason__c = Label.XC_CL_StatusReason_Assignedtothetechnician;
                if(updateWOwrapper.mapServiceAppointmentTerritory.containsKey(saId)) {
                    wo.ServiceTerritoryId = updateWOwrapper.mapServiceAppointmentTerritory.get(saId);
                }
                listWorkOrderToUpdate.add(wo);
            }
            for(WorkOrder woChild : wo.ChildWorkOrders) {
                woChild.XC_AssignedPartner__c = wo.XC_AssignedPartner__c;                   
                woChild.XC_AssignedResource__c = wo.XC_AssignedResource__c;
                woChild.ServiceTerritoryId = wo.ServiceTerritoryId;
                woChild.Status = wo.Status;
                if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Substitution){
                    woChild.XC_SerialNumber__c = wo.XC_SerialNumber__c;
                    /* REWORK FOR GLOVIA
                    if(woChild.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) {
                        listWorkOrderForGlovia.add(woChild);
                    }*/
                }
                listWorkOrderToUpdate.add(woChild);
            }
        } 
        XC_UTIL_Sobject.updateListRecords(listWorkOrderToUpdate);
    } 
    
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @param mapServiceAppointment the map service appointment
    * @description Method to check that the status of the WorkOrder is completed and set to Completed OK the corresponding step status
    */   
    public static void updateSteps(Map<Id, ServiceAppointment> mapServiceAppointment, Map<Id,WorkOrder> mapWorkOrder, Map<Id,Id> mapServiceAppointmentWorkOrderId){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start XC_TR_AssignedResource_U_UpdateOwner.mapServiceAppointmentWorkOrderId');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start mapServiceAppointmentWorkOrderId');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start mapServiceAppointmentWorkOrderId');
        List<XC_Provisioning_Step__c> listStep = new List<XC_Provisioning_Step__c>();
        List<ServiceAppointment> listServiceAppointment = new List<ServiceAppointment>();
        listServiceAppointment.addAll(mapServiceAppointment.values()); 
        for(Id saId : mapServiceAppointment.keySet()){  
            ServiceAppointment sa = mapServiceAppointment.get(saId);
            if(mapWorkOrder.containsKey(mapServiceAppointmentWorkOrderId.get(saId)) && mapWorkOrder.get(mapServiceAppointmentWorkOrderId.get(saId)).XC_Provisioning_Step__r.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningTechnicalBookAppointment_Flow){
                XC_Provisioning_Step__c ps = new XC_Provisioning_Step__c(Id = mapWorkOrder.get(mapServiceAppointmentWorkOrderId.get(saId)).XC_Provisioning_Step__c);
                ps.XC_Status__c = Label.XC_CL_Completed_OK;
                listStep.add(ps);
            } 
        }  
        List<String> listOfConfigurationId = new List<String>();
        for(WorkOrder wo : mapWorkOrder.values()){
            if (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && wo.XC_isTree__c == true){
                listOfConfigurationId.add(wo.XC_Configuration__c);
            }
        }
        List<String> listConfigurationItemIds = XC_UTIL_Sobject.getListFieldValues(listServiceAppointment, 'XC_Configuration_Item__c');
        List<XC_Provisioning_Step__c> listOfStep = XC_TR_AssignedResource_U_UpdateOwner_D.retrieveStep(listConfigurationItemIds, listOfConfigurationId);

        for(XC_Provisioning_Step__c step : listOfStep){
            step.XC_Status__c = Label.XC_CL_Completed_OK;
            listStep.add(step);
        }
        List<NE__OrderItem__c> listOfOiToUpdate = new List<NE__OrderItem__c>();
        if(!listOfConfigurationId.isEmpty()){
            for(XC_Provisioning_Step__c step : listOfStep){
                if(!String.isBlank(step.XC_Configuration_Item__r.XC_LegalEntityFormula__c) && (step.XC_Configuration_Item__r.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || step.XC_Configuration_Item__r.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia)){
                    NE__OrderItem__c oi = new NE__OrderItem__c(Id = step.XC_Configuration_Item__c);
                    oi.XC_DeliveryStatus__c = Label.XC_CL_OrderItem_DelStatus_InProgress;
                    listOfOiToUpdate.add(oi);
                }
            }
        }else{
            for(ServiceAppointment sa : listServiceAppointment){
                if(!String.isBlank(sa.XC_LegalEntity__c) && (sa.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || sa.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia) && 
                    mapWorkOrder.get(mapServiceAppointmentWorkOrderId.get(sa.Id)).XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation){
                    NE__OrderItem__c oi = new NE__OrderItem__c(Id = sa.XC_Configuration_Item__c);
                    oi.XC_DeliveryStatus__c = Label.XC_CL_OrderItem_DelStatus_InProgress;
                    listOfOiToUpdate.add(oi);
                }
            }
        }
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(listOfOiToUpdate);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
       /* List<String> listConfigurationItemIds = XC_UTIL_Sobject.getListFieldValues(listServiceAppointment, 'XC_Configuration_Item__c'); 
        Map<id,NE__OrderItem__c> mapConfigurationItems = XC_TR_AssignedResource_U_UpdateOwner_D.retrieveMapConfigurationItems(listConfigurationItemIds);   
        
        for(Id saId : mapServiceAppointment.keySet()){  
            ServiceAppointment sa = mapServiceAppointment.get(saId);
            if(mapConfigurationItems.containsKey(sa.XC_Configuration_Item__c)){ 
                NE__OrderItem__c oi = mapConfigurationItems.get(sa.XC_Configuration_Item__c);
                List<XC_Provisioning_Step__c> psList = oi.Provisioning_Steps__r;
                for(XC_Provisioning_Step__c ps : psList){
                    if(listFlowAPINameBookAppointment.contains(ps.XC_Flow_API_Name__c)){ 
                       ps.XC_Status__c = Label.XC_CL_Completed_OK;
                       listStep.add(ps);
                    } 
                } 
            } 
        }*/
        XC_UTIL_Sobject.updateListRecords(listStep);
    }  

    /** @description Class to manage GroupMember (Queuable) */
   	/* public class SendPushNotification implements Queueable, Database.AllowsCallouts {
        
        Map<Id,Id> mapWorkOrderServiceAppointmentId = new Map<Id,Id>(); 
        Map<Id,Id> mapServiceAppointmentServiceResource = new Map<Id,Id>(); 
        List<WorkOrder> listUrgentRepairWO = new List<WorkOrder>();
        /**
         * @description Instantiates a new sendPushNotification
         * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
         * @date 23/09/2019
         * @param mapWorkOrderServiceAppointmentId - Map<Id,Id>
         * @param mapServiceAppointmentServiceResource - Map<Id,Id>
         * @param listUrgentRepairWO List<WorkOrder> 
         */
    /*

        //RICORDA DI CONTROLLARE LA LISTA DI WO DEVONO ESSERE TRUE E LA LISTA POPOLATA
        public SendPushNotification(Map<Id,Id> mapWorkOrderServiceAppointmentId, Map<Id,Id> mapServiceAppointmentServiceResource, List<WorkOrder> listUrgentRepairWO) {
            this.mapWorkOrderServiceAppointmentId = mapWorkOrderServiceAppointmentId;
            this.mapServiceAppointmentServiceResource = mapServiceAppointmentServiceResource;
            this.listUrgentRepairWO = listUrgentRepairWO;
        }
        
        /**
        * @description Execute Queuable
        * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
        * @date 23/09/2019
        * @param context - QueueableContext 
        */
        /* public void execute(QueueableContext context) {
            WorkOrder wo = this.listUrgentRepairWO[0];
            if(this.mapWorkOrderServiceAppointmentId.containsKey(wo.Id)){
                Id saId = this.mapWorkOrderServiceAppointmentId.get(wo.Id);
                if(this.mapServiceAppointmentServiceResource.containsKey(saId)) {
                    XC_REST_UrgentWONotification.callout(wo.WorkOrderNumber, this.mapServiceAppointmentServiceResource.get(saId), true);
                }
            }
        }
    }*/

}