/**
* @author Marco Rosa - marco.rosa@nttdata.com 
* @date Creation 19/09/2018
* @date Modification 12/08/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_AssignedResource_U_UpdateOwner – Util class to change owner of Service Appointment and reletad Objects
*/ 

public without sharing class XC_TR_AssignedResource_U_UpdateOwner { 

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_AssignedResource_U_UpdateOwner');

    /** 
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     * @description Methods to update fields for Service Appointment and related Objects after assignment
     */  
    public static void updateFieldsOnUpdate(List<AssignedResource> listNew, Map<Id,AssignedResource> mapOld, Map<Id,AssignedResource> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@#@ Enter in XC_TR_AssignedResource_U_UpdateOwner'); 
        List<String> fieldList = new List<String>{'ServiceResourceId'};
        List<AssignedResource> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            updateFieldsAfterAssignment(listChanged);
        }
    } 

    /**
     * @description Update fields after assignment.
     * @param listNew the list new 
     */
    public static void updateFieldsAfterAssignment(List<AssignedResource> listNew){ 
        List<Id> listIds = XC_UTIL_Sobject.getIds(listNew); 
        Map<Id, AssignedResource> mapAssignedResources = XC_TR_AssignedResource_U_UpdateOwner_D.getMapAssignedResources(listIds); 
        Map<Id,Id> mapWorkOrderServiceAppointmentId = XC_TR_AssignedResource_U_UpdateOwner_U.getMapWorkOrderServiceAppointment(mapAssignedResources);         
        Map<Id,Id> mapServiceAppointmentWorkOrderId = XC_TR_AssignedResource_U_UpdateOwner_U.getMapServiceAppointmentWorkOrder(mapAssignedResources);
        Map<Id,WorkOrder> mapWorkOrder = XC_TR_AssignedResource_U_UpdateOwner_D.retrieveListWorkOrder(mapWorkOrderServiceAppointmentId);
        XC_UTIL_WorkType.WorkOrderWrapper wrapper = XC_UTIL_WorkType.splitWorkOrders(mapWorkOrder.values()); 
        Map<Id,Id> mapServiceAppointmentServiceResource = XC_TR_AssignedResource_U_UpdateOwner_U.getMapServiceAppointmentServiceResource(mapAssignedResources);  
        Map<Id,Id> mapServiceAppointmentServiceResourceAccount = XC_TR_AssignedResource_U_UpdateOwner_U.getMapServiceAppointmentServiceResourceAccount(mapAssignedResources);  
        Map<Id, ServiceAppointment> mapServiceAppointment = getMapServiceAppointment(mapAssignedResources);

        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@mapAssignedResources-->' +mapAssignedResources); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@mapServiceAppointment-->' +mapServiceAppointment);  
        Map<Id,Id> mapServiceAppointmentOwner = getMapServiceAppointmentResourceUser(mapAssignedResources); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@wrapper-->' +wrapper);  

        XC_TR_AssignedResource_U_UpdateOwner_W.UpdateRecordWrapper commercialVisitWrapper = new XC_TR_AssignedResource_U_UpdateOwner_W.UpdateRecordWrapper();
        commercialVisitWrapper.listWorkOrder = wrapper.listWorkOrderCommercialVisit; 
        commercialVisitWrapper.mapServiceAppointmentOwner = mapServiceAppointmentOwner; 
        commercialVisitWrapper.mapWorkOrderServiceAppointmentId = mapWorkOrderServiceAppointmentId; 
        commercialVisitWrapper.mapServiceAppointmentServiceResource = mapServiceAppointmentServiceResource;  
        commercialVisitWrapper.mapServiceAppointmentServiceResourceAccount = mapServiceAppointmentServiceResourceAccount;  
        updateCommercialVisitRelatedObjects(commercialVisitWrapper);
        
       /* if(!wrapper.listWorkOrderRepair.isEmpty()){
            List<WorkOrder> listWorkOrderRepair = new List<WorkOrder>();
            for(WorkOrder currentWO: wrapper.listWorkOrderRepair){
                if(currentWO.XC_Urgent_Repair__c){
                    listWorkOrderRepair.add(currentWO);
                }
            }
            if(!listWorkOrderRepair.isEmpty()){
                XC_TR_AssignedResource_U_UpdateOwner_U.SendPushNotification sendPushNotification = new XC_TR_AssignedResource_U_UpdateOwner_U.SendPushNotification(mapWorkOrderServiceAppointmentId, mapServiceAppointmentServiceResource, listWorkOrderRepair);
                System.enqueueJob(sendPushNotification);
            }
        }
        */


        if(!wrapper.listWorkOrderDeliveryInstallation.isEmpty() || !wrapper.listWorkOrderMaintenance.isEmpty() || !wrapper.listWorkOrderRepair.isEmpty()){
            List<WorkOrder> listWorkOrderToManage = new List<WorkOrder>();
            listWorkOrderToManage.addAll(wrapper.listWorkOrderDeliveryInstallation);
            listWorkOrderToManage.addAll(wrapper.listWorkOrderMaintenance);
            listWorkOrderToManage.addAll(wrapper.listWorkOrderRepair); 
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@wrapper.listWorkOrderRepair-->' +wrapper.listWorkOrderRepair); 
            XC_TR_AssignedResource_U_UpdateOwner_W.UpdateRecordWrapper wrapperAsset = new XC_TR_AssignedResource_U_UpdateOwner_W.UpdateRecordWrapper();
            wrapperAsset.listWorkOrder = listWorkOrderToManage; 
            wrapperAsset.mapWorkOrderServiceAppointmentId = mapWorkOrderServiceAppointmentId; 
            wrapperAsset.mapServiceAppointmentServiceResource = mapServiceAppointmentServiceResource; 
            wrapperAsset.mapServiceAppointmentServiceResourceAccount = mapServiceAppointmentServiceResourceAccount; 
            wrapperAsset.mapServiceAppointment = mapServiceAppointment;
            XC_TR_AssignedResource_U_UpdateOwner_U.updateAsset(wrapperAsset);
        } 
 
        XC_TR_AssignedResource_U_UpdateOwner_U.updateSteps(mapServiceAppointment, mapWorkOrder, mapServiceAppointmentWorkOrderId);
        Map<String, String> mapServiceAppointmentTerritory = XC_TR_AssignedResource_U_UpdateOwner_D.getMapServiceAppointmentTerritory(listNew);
        XC_TR_AssignedResource_U_UpdateOwner_W.UpdateRecordWrapper updateWOwrapper = new XC_TR_AssignedResource_U_UpdateOwner_W.UpdateRecordWrapper();
        updateWOwrapper.listWorkOrder = mapWorkOrder.values();
        updateWOwrapper.mapServiceAppointmentServiceResource = mapServiceAppointmentServiceResource;
        updateWOwrapper.mapServiceAppointmentServiceResourceAccount = mapServiceAppointmentServiceResourceAccount;
        updateWOwrapper.mapWorkOrderServiceAppointmentId = mapWorkOrderServiceAppointmentId;
        updateWOwrapper.mapServiceAppointment = mapServiceAppointment;
        updateWOwrapper.mapServiceAppointmentTerritory = mapServiceAppointmentTerritory;
        XC_TR_AssignedResource_U_UpdateOwner_U.updateWorkOrder(updateWOwrapper);

        XC_TR_AssignedResource_U_UpdateOwner_W.UpdateServiceAppointmentWrapper updateSAwrapper = new XC_TR_AssignedResource_U_UpdateOwner_W.UpdateServiceAppointmentWrapper();
        updateSAwrapper.mapServiceAppointment = mapServiceAppointment;
        updateSAwrapper.mapServiceAppointmentServiceResourceAccount = mapServiceAppointmentServiceResourceAccount;
        updateSAwrapper.mapServiceAppointmentServiceResource = mapServiceAppointmentServiceResource;
        updateSAwrapper.mapServiceAppointmentTerritory = mapServiceAppointmentTerritory;
        updateServiceAppointment(updateSAwrapper);
    }  

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param saWrapper - UpdateServiceAppointmentWrapper 
     * @date Modification 04/03/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description This method fills gives ownership of the appointmnet to the assigned Service Resource. Moreover it unchecks the field XC_AssignToPartner__c if checked.
     */ 
    private static void updateServiceAppointment(XC_TR_AssignedResource_U_UpdateOwner_W.UpdateServiceAppointmentWrapper saWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@mapServiceAppointment--> '+ saWrapper.mapServiceAppointment );  
        List<ServiceAppointment> listToUpdate = new List<ServiceAppointment>(); 
        for(Id saId : saWrapper.mapServiceAppointment.keySet()){
            ServiceAppointment saToUpdate = new ServiceAppointment();
            saToUpdate.Id = saId;       
            saToUpdate.ServiceTerritoryId = null;
            saToUpdate.XC_AssignedResource__c = null;
            saToUpdate.XC_AssignedPartner__c = null;

            if(saWrapper.mapServiceAppointmentServiceResource.containsKey(saId)){
                saToUpdate.XC_AssignedResource__c = saWrapper.mapServiceAppointmentServiceResource.get(saId);
            }
            if(saWrapper.mapServiceAppointmentServiceResourceAccount.containsKey(saId)){
                saToUpdate.XC_AssignedPartner__c = saWrapper.mapServiceAppointmentServiceResourceAccount.get(saId);
            }

            if(saWrapper.mapServiceAppointmentTerritory.containsKey(saId)) {
                saToUpdate.ServiceTerritoryId = saWrapper.mapServiceAppointmentTerritory.get(saId);
            }

            if(saWrapper.mapServiceAppointment.get(saId).XC_AssignToPartner__c){
                saToUpdate.XC_AssignToPartner__c = false;
            }
            if(saWrapper.mapServiceAppointment.get(saId).XC_IgnoreReschedulingLock__c){
                saToUpdate.XC_IgnoreReschedulingLock__c = false;
            }
            XC_TR_AssignedResource_U_UpdateOwner_U.updateServiceAppointmentMaintenance(saWrapper.mapServiceAppointment, saId, saToUpdate);
            
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ServiceAppToUpdate-->' + saToUpdate);   
            listToUpdate.add(saToUpdate);   
        } 
        XC_UTIL_Sobject.updateListRecords(listToUpdate);   
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param wrapper containing: 
     *                          listWorkOrder the list work order
     *                          mapServiceAppointmentOwner the map service appointment owner
     *                          mapWorkOrderServiceAppointmentId the map work order service appointment id
     *                          mapServiceAppointmentServiceResource the map service appointment service resource
     * @description Method to update fields for Work Order, Lead and Opportunity. It aldo populates XC_CommercialVisitAssignedResource__c on Account and Opportunity
     */
    public static void updateCommercialVisitRelatedObjects(XC_TR_AssignedResource_U_UpdateOwner_W.UpdateRecordWrapper wrapper){
        List<WorkOrder> listWorkOrder = wrapper.listWorkOrder; 
        Map<Id,Id> mapServiceAppointmentOwner = wrapper.mapServiceAppointmentOwner; 
        Map<Id,Id> mapWorkOrderServiceAppointmentId = wrapper.mapWorkOrderServiceAppointmentId; 
        Map<Id,Id> mapServiceAppointmentServiceResource = wrapper.mapServiceAppointmentServiceResource;        
        if(listWorkOrder.isEmpty()){
            return; 
        }
        
        List<Lead> listLeadToUpdate = new List<Lead>();
        List<Opportunity> listOppToUpdate = new List<Opportunity>(); 
        for(WorkOrder wo : listWorkOrder){  
            if(!mapWorkOrderServiceAppointmentId.containsKey(wo.Id)){
                continue;
            }
            Id saId = mapWorkOrderServiceAppointmentId.get(wo.Id);
            if(!mapServiceAppointmentOwner.containsKey(saId)){
                continue;
            }
            Id ownerId = mapServiceAppointmentOwner.get(saId);
            if(ownerId != null){ 
                if(wo.XC_Lead__c != null){
                    Lead ld = new Lead();
                    ld.Id = wo.XC_Lead__c; 
                    ld.OwnerId = ownerId;
                    ld.XC_CommercialVisitAssignedResource__c = mapServiceAppointmentServiceResource.get(saId);
                    ld.Status = Label.XC_CL_Lead_AppointmentScheduling;
                    listLeadToUpdate.add(ld);
                }
                if(wo.XC_Opportunity__c != null){
                    Opportunity opp = new Opportunity();
                    opp.Id = wo.XC_Opportunity__c;
                    opp.OwnerId = ownerId;
                    opp.XC_CommercialVisitAssignedResource__c = mapServiceAppointmentServiceResource.get(saId);
                    listOppToUpdate.add(opp);  
                }
            } 
        }   
        XC_UTIL_Sobject.updateListRecords(listLeadToUpdate);    
        XC_UTIL_Sobject.updateListRecords(listOppToUpdate);
    }    

    /** 
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param mapAssignedResources the map assigned resources
     * @return the map service appointment
     * @description Returns a map ServiceAppointmentId -> ServiceAppointment.
     */
    public static Map<Id, ServiceAppointment> getMapServiceAppointment(Map<Id, AssignedResource> mapAssignedResources){
        Map<Id, ServiceAppointment> mapServiceAppointment = new Map<Id, ServiceAppointment>();
        for (Id arId : mapAssignedResources.keySet()){
            AssignedResource ar = mapAssignedResources.get(arId);
            ServiceAppointment sa = new ServiceAppointment();
            sa.Id = ar.ServiceAppointmentId;
            //sa.ParentRecordId = ar.ServiceAppointment.ParentRecordId;
            sa.XC_AssignToPartner__c = ar.ServiceAppointment.XC_AssignToPartner__c;
            sa.XC_Configuration_Item__c = ar.ServiceAppointment.XC_Configuration_Item__c; 
            sa.PostalCode = ar.ServiceAppointment.PostalCode;
            sa.SchedStartTime = ar.ServiceAppointment.SchedStartTime;
            sa.Status = ar.ServiceAppointment.Status;
            sa.XC_WorkTypeCategory__c = ar.ServiceAppointment.XC_WorkTypeCategory__c;
            sa.EarliestStartTime = ar.ServiceAppointment.EarliestStartTime;
            sa.XC_IgnoreReschedulingLock__c = ar.ServiceAppointment.XC_IgnoreReschedulingLock__c;
            sa.XC_LegalEntity__c = ar.ServiceAppointment.XC_LegalEntity__c;
            mapServiceAppointment.put(ar.ServiceAppointmentId, sa);     
        }
        return mapServiceAppointment;
    }    

    /** 
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param mapAssignedResources the map assigned resources
     * @return the map service appointment resource user
     * @description Returns a map ServiceAppointmentId -> UserId (of the Service Resource)
     */
    public static Map<Id, Id> getMapServiceAppointmentResourceUser(Map<Id, AssignedResource> mapAssignedResources){
        Map<Id,Id> mapServiceAppointmentResourceUser = new Map<Id,Id>();
        for (Id arId : mapAssignedResources.keySet()){
            AssignedResource ar = mapAssignedResources.get(arId);
            mapServiceAppointmentResourceUser.put(ar.ServiceAppointmentId, ar.ServiceResource.RelatedRecordId);     
        }
        return mapServiceAppointmentResourceUser;
    }   

}