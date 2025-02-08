/**
 * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
 * @date: 16-05-2019
 * @description Class to populate Service Type on WorkOrder
*/  

public without sharing class XC_TR_WorkOrder_U_PopulateServiceType {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_PopulateServiceType');
        
    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
 	* @description Method to populate Service Type on WorkOrder
    * @param listNew - List<WorkOrder>  
    */
	public static void populateServiceType(List<WorkOrder> listNew){
        XC_UTIL_WorkType.WorkOrderWrapper wrapper = XC_UTIL_WorkType.splitWorkOrders(listNew);
        List<WorkOrder> listWorkOrderCommercialVisit = wrapper.listWorkOrderCommercialVisit;
        List<WorkOrder> listWorkOrderByConfigurationItem = wrapper.listWorkOrderDeliveryInstallation;
        List<WorkOrder> listWorkOrderByAsset = new List<WorkOrder>(); 
        listWorkOrderByAsset.addAll(wrapper.listWorkOrderMaintenance); 
        List<WorkOrder> listWorkOrderByCase = new List<WorkOrder>();
        listWorkOrderByAsset.addAll(wrapper.listWorkOrderRepair);
        listWorkOrderByCase.addAll(wrapper.listWorkOrderReturn);
        listWorkOrderByCase.addAll(wrapper.listWorkOrderSubstitution);
        
        if(!listWorkOrderCommercialVisit.isEmpty()){
            manageCommercialVisit(listWorkOrderCommercialVisit);
        }
        if(!listWorkOrderByConfigurationItem.isEmpty()){
            manageByConfigurationItem(listWorkOrderByConfigurationItem);
        }
        if(!listWorkOrderByAsset.isEmpty()){
            manageByAsset(listWorkOrderByAsset);
        }
        if(!listWorkOrderByCase.isEmpty()){
            manageByCase(listWorkOrderByCase);
        }
    }

    private static void manageCommercialVisit(List<WorkOrder> listWorkOrder){
        List<String> productCategorieNames = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_ProductCategoryOfInterest__c'); 
        List<String> workTypeNames = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_WorkTypeCategory__c'); 
        Map<Id, XC_CM_WorkOrderServiceType__mdt> mapServiceTypes = new Map<Id, XC_CM_WorkOrderServiceType__mdt>([
            SELECT Id, XC_ProductName__c, XC_WorkType__c, XC_ServiceType__c, XC_SubType__c, XC_Bundle__c, XC_ProductCategoryOfInterest__c
            FROM XC_CM_WorkOrderServiceType__mdt
            WHERE XC_WorkType__c IN: workTypeNames
            AND XC_ProductCategoryOfInterest__c IN: productCategorieNames  
        ]); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#### mapServiceTypes' + mapServiceTypes); 
        if(mapServiceTypes.isEmpty()){
            return;
        }
        Map<String, String> mapProductCategoryServiceType = new Map<String, String>();
        for(XC_CM_WorkOrderServiceType__mdt cm : mapServiceTypes.values()){
            mapProductCategoryServiceType.put(cm.XC_ProductCategoryOfInterest__c, cm.XC_ServiceType__c);
        } 

        for(WorkOrder wo : listWorkOrder){ 
            if(mapProductCategoryServiceType.containsKey(wo.XC_ProductCategoryOfInterest__c)){
                XC_TR_WorkOrder_U_PopulateServiceType_U.populateServiceType(wo, mapProductCategoryServiceType.get(wo.XC_ProductCategoryOfInterest__c));
            }
        }  
    } 

    private static void manageByConfigurationItem(List<WorkOrder> listWorkOrder){
        Map<Id,NE__OrderItem__c> mapConfigurationItem = XC_TR_WorkOrder_U_PopulateServiceType_D.getMapConfigurationItem(listWorkOrder);
        if(mapConfigurationItem.isEmpty()){
            return;
        }
        Map<Id, XC_CM_WorkOrderServiceType__mdt> mapServiceTypes = XC_TR_WorkOrder_U_PopulateServiceType_D.retrieveCustomMetadatabyConfitem(listWorkOrder, mapConfigurationItem);  
        if(mapServiceTypes.isEmpty()){
            return;
        }
        for(WorkOrder wo : listWorkOrder){
            NE__OrderItem__c confItem = mapConfigurationItem.get(wo.XC_Configuration_Item__c);
            XC_TR_WorkOrder_U_PopulateServiceType_U.manageWorkOrderByConfItem(wo, confItem, mapServiceTypes);
        }
    } 

    private static void manageByAsset(List<WorkOrder> listWorkOrder){ 
        Map<Id,Asset> mapAsset = XC_TR_WorkOrder_U_PopulateServiceType_D.getMapAsset(listWorkOrder);
        if(mapAsset.isEmpty()){
            return;
        }
        Map<Id, XC_CM_WorkOrderServiceType__mdt> mapServiceTypes = XC_TR_WorkOrder_U_PopulateServiceType_D.retrieveCustomMetadatabyAsset(listWorkOrder, mapAsset);  
        if(mapServiceTypes.isEmpty()){
            return;
        }
        for(WorkOrder wo : listWorkOrder){
            Asset a  = mapAsset.get(wo.AssetId);
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair){ 
                XC_TR_WorkOrder_U_PopulateServiceType_U.manageMaintenanceWorkOrderByAsset(wo, a, mapServiceTypes);
            }/* else { 
                XC_TR_WorkOrder_U_PopulateServiceType_U.manageWorkOrderByAsset(wo, a, mapServiceTypes);
            }*/
        } 
    }

    private static void manageByCase(List<WorkOrder> listWorkOrder){
        Map<Id, Case> mapCase = XC_TR_WorkOrder_U_PopulateServiceType_D.getMapCase(listWorkOrder); 
        if(mapCase.isEmpty()){
            return;
        }
        Map<Id, XC_CM_WorkOrderServiceType__mdt> mapServiceTypes = XC_TR_WorkOrder_U_PopulateServiceType_D.retrieveCustomMetadatabyCase(listWorkOrder, mapCase);  
        if(mapServiceTypes.isEmpty()){
            return;
        }
        for(WorkOrder wo : listWorkOrder){
            if(mapCase.containsKey(wo.CaseId)){
                Case c = mapcase.get(wo.CaseId);
                XC_TR_WorkOrder_U_PopulateServiceType_U.manageWorkOrderByCase(wo, c, mapServiceTypes);
            } 
        }
    }
}