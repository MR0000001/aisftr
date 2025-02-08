/**
* @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
* @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com
* @date  : 08/02/2019
* @description XC_TR_AssignedResource_U_UpdateOwner_D – DAO Class for XC_TR_AssignedResource_U_UpdateOwner
*/

public without sharing class XC_TR_AssignedResource_U_UpdateOwner_D {

    private static List<String> listFlowAPINameBookAppointment = new List<String>{
        Label.XC_CL_ProvisioningMPBookAppointment_Flow,
        Label.XC_CL_DeprovisioningMPBookAppointment_Flow,
        Label.XC_CL_ChangeProvisioningMPBookAppointment_Flow,
        Label.XC_CL_ProvisioningTechnicalBookAppointment_Flow,
        Label.XC_CL_ProvisioningMaintenanceInspection_Flow,
        Label.XC_CL_ProvisioningMaintBook_Flow
    };
    
    /**
     * @description Retrieve list work order.
     * @param mapWorkOrderServiceAppointmentId the map work order service appointment id
     * @return the list
     */
    public static Map<Id, WorkOrder> retrieveListWorkOrder(Map<Id,Id> mapWorkOrderServiceAppointmentId){
        Map<Id,WorkOrder> listWorkOrderMap = new Map<Id,WorkOrder>([
            SELECT Id, XC_WorkTypeLabel__c, XC_WorkTypeCategory__c, AssetId, XC_Lead__c, XC_Opportunity__c, OwnerId, XC_SerialNumber__c, Status, XC_isTree__c, XC_Configuration__c,
            XC_Urgent_Repair__c, WorkOrderNumber, XC_Provisioning_Step__r.XC_Flow_API_Name__c, XC_Provisioning_Step__c, XC_AssignedPartner__c, ServiceTerritoryId, XC_AssignedResource__c,
                (SELECT Id, XC_WorkTypeCategory__c, AssetId FROM ChildWorkOrders)
            FROM WorkOrder 
            WHERE Id IN: mapWorkOrderServiceAppointmentId.keySet()]);   
        return listWorkOrderMap;        
    }
    
    /**
     * @description Retrieve map configuration items.
     * @param listConfigurationItemIds the list configuration item ids
     * @return the map
     */
    public static  Map<id,NE__OrderItem__c> retrieveMapConfigurationItems(List<String> listConfigurationItemIds){
        Map<id,NE__OrderItem__c> mapConfigurationItems = new Map<id,NE__OrderItem__c>([
            SELECT id, 
            (SELECT id, XC_Flow_API_Name__c 
             FROM Provisioning_Steps__r 
             WHERE XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress) 
            FROM NE__OrderItem__c WHERE Id IN: listConfigurationItemIds
        ]);
        
        return mapConfigurationItems;        
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param listIds the list ids
     * @return the map assigned resources
     * @description Returns a map AssignedResourceId -> AssignedResource
     */
    public static Map<Id, AssignedResource> getMapAssignedResources(List<Id> listIds){
        Map<Id, AssignedResource> mapAssignedResources = new Map<Id, AssignedResource>(
            [SELECT Id, ServiceAppointmentId, ServiceAppointment.ParentRecordId, ServiceResource.RelatedRecordId, ServiceResource.XC_Account__c, ServiceAppointment.SchedStartTime,
             ServiceAppointment.XC_AssignToPartner__c, ServiceAppointment.XC_Configuration_Item__c , ServiceAppointment.PostalCode, ServiceAppointment.XC_LegalEntity__c, 
             ServiceAppointment.Status, ServiceAppointment.XC_WorkTypeCategory__c, ServiceAppointment.EarliestStartTime, ServiceAppointment.XC_IgnoreReschedulingLock__c
             FROM AssignedResource 
             WHERE Id IN:listIds]);
    
    
        return mapAssignedResources;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 30/09/2019
    * @description Method to calculate a Map Service Appointment -> Territory
    * @param listAssignedResource - List<AssignedResource>
    * @return Map<String, String>
    */
    public static Map<String, String> getMapServiceAppointmentTerritory(List<AssignedResource> listAssignedResource) {
        Map<String, List<String>> mapServiceResourceAppointment = new Map<String, List<String>>(); 
        for(AssignedResource ar : listAssignedResource) {
            if(!mapServiceResourceAppointment.containsKey(ar.ServiceResourceId)) {
                mapServiceResourceAppointment.put(ar.ServiceResourceId, new List<String>());
            }
            mapServiceResourceAppointment.get(ar.ServiceResourceId).add(ar.ServiceAppointmentId);
        }
        List<ServiceTerritoryMember> listStm = new List<ServiceTerritoryMember>([
            SELECT Id, ServiceResourceId, ServiceTerritory.TopLevelTerritoryId
            FROM ServiceTerritoryMember
            WHERE ServiceResourceId IN :mapServiceResourceAppointment.keySet()
        ]);
    
        Map<String, String> mapServiceAppointmentTerritory = new Map<String, String>();
        for(ServiceTerritoryMember stm : listStm) {
            String idTerritory = stm.ServiceTerritory.TopLevelTerritoryId;
            for(String idSa : mapServiceResourceAppointment.get(stm.ServiceResourceId)) {
                mapServiceAppointmentTerritory.put(idSa, idTerritory);
            }
        }
    
        return mapServiceAppointmentTerritory;
    }

    /**
    * @description 
    * @author Del Prete Domenico | 4/3/2020 
    * @param listOfOrderItem 
    * @param listOfOrder 
    * @return List<XC_Provisioning_Step__c> 
    **/
    public static List<XC_Provisioning_Step__c> retrieveStep (List<String> listOfOrderItem , List<String> listOfOrder){
        if(listOfOrderItem.isEmpty()){
            List<XC_Provisioning_Step__c> listOfStep = new List<XC_Provisioning_Step__c> ([SELECT Id,
                                                                                            XC_Configuration_Item__c, XC_Configuration_Item__r.XC_LegalEntityFormula__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE XC_Configuration_Item__r.NE__OrderId__c IN:listOfOrder AND 
                                                                                            XC_Flow_API_Name__c IN:listFlowAPINameBookAppointment]);
            return listOfStep;
        }else{
            List<XC_Provisioning_Step__c> listOfStep = new List<XC_Provisioning_Step__c> ([SELECT Id,
                                                                                            XC_Configuration_Item__c, XC_Configuration_Item__r.XC_LegalEntityFormula__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE XC_Configuration_Item__c IN:listOfOrderItem AND 
                                                                                                XC_Flow_API_Name__c IN:listFlowAPINameBookAppointment]);
            return listOfStep;
        }
    }

}