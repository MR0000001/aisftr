/**
* @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 25/02/2020
* @description XC_TR_WorkOrder_U_CreateChildrenWO - Class to manage the creation of children work order for asset related to OK services
*/  

public without sharing class XC_TR_WorkOrder_U_CreateChildrenWO {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_CreateChildrenWO');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 26/02/2020
     * @description Queueable Class to manage Asset to create Work Order
     */
    public class ManageWorkOrderForAsset implements Queueable {
        Map<Id, Asset> mapAssetWithChildren = new Map<Id, Asset>();
        List<WorkOrder> listWorkOrderTriggered = new List<WorkOrder>();
        
        /**
         * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
         * @description Costructor for class
         * @param mapAssetWithChildren - Map<Id, Asset>
         * @param listWorkOrderTriggered - List<WorkOrder>
         */
        public ManageWorkOrderForAsset(Map<Id, Asset> mapAssetWithChildren, List<WorkOrder> listWorkOrderTriggered){
            this.mapAssetWithChildren = mapAssetWithChildren;
            this.listWorkOrderTriggered = listWorkOrderTriggered;
        }
        
        /**
         * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
         * @description Execute for Queueable class
         * @param context - QueueableContext
         */
        public void execute(QueueableContext context) {
            manageAssets(this.mapAssetWithChildren, this.listWorkOrderTriggered);
        }
    }
    
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 25/02/2020
    * @description Method to create Children WO for Maintenance/Diagnostic
    * @param listNew - List<WorkOrder>
    */  
    public static void createChildrenWorkOrders(List<WorkOrder> listNew) {
        // Retrieve only WorkOrder Maintenance and Diagnostic:
        List<WorkOrder> listToManage = new List<WorkOrder>();
        List<String> listWorkTypeToFiltered = new List<String>{Label.XC_CL_WorkType_PlannedMaintenance, Label.XC_CL_WorkType_Diagnostic};
        for(WorkOrder wo : listNew){
            if(listWorkTypeToFiltered.contains(wo.XC_workTypeCategory__c) && String.isNotBlank(wo.AssetId)) {
                listToManage.add(wo);
            }
        }
        if(listToManage.isEmpty()) {
            return;
        }

        // Retrieve Parent Asset from Work Order, and child Asset from Parent Asset:
        List<String> listAssetIds = XC_UTIL_Sobject.getListFieldValues(listToManage, 'AssetId');
        List<String> listProdType = new List<String>{Label.XC_CL_MaintenanceProdType, Label.XC_CL_DiagnosticProdType};
        List<String> listProdSubType = new List<String>{Label.XC_CL_ProductSubTypeGas, Label.XC_CL_ProductSubTypeElectric};
        Map<Id, Asset> mapAssetWithChildren = new Map<Id, Asset>([
            SELECT Id, XC_Address__c, AccountId,
                (SELECT Id, XC_Product_Name_LIC__c, XC_Product_Subtype__c
                FROM ChildAssets
                WHERE XC_Product_Subtype__c IN :listProdType)
            FROM Asset  
            WHERE Id IN :listAssetIds AND XC_Product_type__c = :Label.XC_CL_AssetType_Service AND XC_Product_Subtype__c IN :listProdSubType
        ]);

        System.enqueueJob(new ManageWorkOrderForAsset(mapAssetWithChildren, listNew));       
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 26/02/2020
    * @description Method to manage Assets to create WorkOrder
    * @param mapAssetWithChildren - Map<Id, Asset>
    * @param listWorkOrderTriggered - List<WorkOrder>
    */  
    private static void manageAssets(Map<Id, Asset> mapAssetWithChildren, List<WorkOrder> listWorkOrderTriggered) {
        // Create a map WorkOrderId -> Child Assets:
        Map<String, List<Asset>> mapWorkOrderListCoverage = new Map<String, List<Asset>>();
        for(WorkOrder wo : listWorkOrderTriggered) {
            if(mapAssetWithChildren.containsKey(wo.AssetId)) {
                List<Asset> listChildAsset = mapAssetWithChildren.get(wo.AssetId).ChildAssets;
                List<Asset> childrenAssetToConsider = new List<Asset>();
                for(Asset childAsset : listChildAsset){
                    if(checkForChildAsset(wo, childAsset)) {
                        childrenAssetToConsider.add(childAsset);
                    }
                }
                if(!childrenAssetToConsider.isEmpty()) {
                    mapWorkOrderListCoverage.put(wo.Id, childrenAssetToConsider);
                }
            }
        }
        if(mapWorkOrderListCoverage.size() == 0) {
            return;
        }
        
        // Create a Set for Product Name for Child Asset:
        Set<String> setProdLicNameAssetChildren = new Set<String>();
        for(String woId : mapWorkOrderListCoverage.keySet()) {
            for(Asset childAsset : mapWorkOrderListCoverage.get(woId)) {
                if(String.isNotBlank(childAsset.XC_Product_Name_LIC__c)) {
                    setProdLicNameAssetChildren.add(childAsset.XC_Product_Name_LIC__c);
                }
            }
        }

        // Retrieve Documentation Characterist filtered by ProdName:
        List<NE__DocumentationCharacterist__c> listDocChar = new List<NE__DocumentationCharacterist__c>([
            SELECT Id, Name, NE__Value__c, NE__Product__c, NE__Product__r.XC_LIC_Product_Name__c
            FROM NE__DocumentationCharacterist__c 
            WHERE NE__Product__r.XC_LIC_Product_Name__c IN :setProdLicNameAssetChildren AND Name = :Label.XC_CL_Asset_CoverageType
        ]);
        if(listDocChar.isEmpty()) {
            return;
        }

        // Create a map ProdName -> Value (from Documentation Characterist):
        Map<String, List<String>> mapProdNameListConverages = new Map<String, List<String>>();
        for(NE__DocumentationCharacterist__c docChar : listDocChar){
            mapProdNameListConverages.put(docChar.NE__Product__r.XC_LIC_Product_Name__c, docChar.NE__Value__c.toUpperCase().split('; '));
        }

        // Create a map WorkOrder Id -> Set Ids Asset Type to covered:
        Map<String, Set<String>> mapWOListTypesCovered = new Map<String, Set<String>>();
        for(String woId : mapWorkOrderListCoverage.keySet()) {
            for(Asset childAsset : mapWorkOrderListCoverage.get(woId)) {
                if(mapProdNameListConverages.containsKey(childAsset.XC_Product_Name_LIC__c)){
                    List<String> assetTypesCovered = mapProdNameListConverages.get(childAsset.XC_Product_Name_LIC__c);
                    if(assetTypesCovered != null && !assetTypesCovered.isEmpty()){
                        if(!mapWOListTypesCovered.containsKey(woId)){
                            mapWOListTypesCovered.put(woId, new Set<String>());
                        }                
                        mapWOListTypesCovered.get(woId).addAll(assetTypesCovered);
                    }
                }
            }
        }

        // Retrieve Asset to manage (for WorkOrder creation) with Address/Account/Subtype filtered:
        List<String> listAddressIds = XC_UTIL_Sobject.getListFieldValues(mapAssetWithChildren.values(), 'XC_Address__c');
        List<String> listAccountIds = XC_UTIL_Sobject.getListFieldValues(mapAssetWithChildren.values(), 'AccountId');
        List<String> listSubtypesTemp = XC_UTIL_Sobject.getListFieldValues(listDocChar, 'NE__Value__c');
        List<String> listSubtypes = new List<String>();
        for(String subtypeTemp : listSubtypesTemp) {
            listSubtypes.addAll(subtypeTemp.split('; '));
        }
        List<Asset> listAssetToManage = new List<Asset>([
            SELECT Id, XC_Address__c, AccountId, XC_Product_Subtype__c     
            FROM Asset    
            WHERE XC_Product_Type__c = :Label.XC_CL_ProductTypeEquipment AND XC_Product_Subtype__c IN :listSubtypes AND XC_Address__c IN :listAddressIds AND AccountId IN :listAccountIds
        ]);
        if(listAssetToManage.isEmpty()) {
            return;
        }

        // Create a map WorkOrderId -> AssetId:
        Map<String, String> mapWorkOrderAssetIds = new Map<String, String>();
        for(WorkOrder woTriggered : listWorkOrderTriggered) {
            mapWorkOrderAssetIds.put(woTriggered.Id, woTriggered.AssetId);
        }

        // Create a map WorkOrderId -> Asset to manage:
        Map<String, List<Asset>> mapIdWorkOrderListIdAssetToManage = new Map<String, List<Asset>>();
        for(Id woId : mapWorkOrderListCoverage.keySet()) {
            Asset parentAsset = mapAssetWithChildren.get(mapWorkOrderAssetIds.get(woId));
            Set<String> typeCovered = mapWOListTypesCovered.get(woId);
            for(Asset assToManage : listAssetToManage) {
                if(parentAsset.XC_Address__c == assToManage.XC_Address__c && parentAsset.AccountId == assToManage.AccountId && typeCovered.contains(assToManage.XC_Product_Subtype__c.toUpperCase())) {
                    if(!mapIdWorkOrderListIdAssetToManage.containsKey(woId)) {
                        mapIdWorkOrderListIdAssetToManage.put(woId, new List<Asset>());
                    }
                    mapIdWorkOrderListIdAssetToManage.get(woId).add(assToManage);   
                }
            }
        }

        // Manage Asset for creating child WO:
        if(!mapIdWorkOrderListIdAssetToManage.isEmpty()){
            createWorkOrders(mapIdWorkOrderListIdAssetToManage, listWorkOrderTriggered);
        }        
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 26/02/2020
    * @description Method to check for Category Work Order and SubType Asset
    * @param wo - WorkOrder
    * @param childAsset - Asset
    * @return Boolean
    */  
    private static Boolean checkForChildAsset(WorkOrder wo, Asset childAsset) {
        return (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance && childAsset.XC_Product_Subtype__c == Label.XC_CL_Subtype_Maintenance) ||
                (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Diagnostic && childAsset.XC_Product_Subtype__c == Label.XC_CL_Subtype_Maintenance);
        /*return  (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance && childAsset.XC_Product_Subtype__c == Label.XC_CL_Subtype_Maintenance) ||
                (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Diagnostic && childAsset.XC_Product_Subtype__c == Label.XC_CL_DiagnosticProdType);*/
    }
    
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 25/02/2020
    * @description Manage creation WO
    * @param listParentWo - List<WorkOrder>
    * @param mapIdWorkOrderListIdAssetToManage - Map<String, List<Asset>>
    */  
    private static void createWorkOrders(Map<String, List<Asset>> mapIdWorkOrderListIdAssetToManage, List<WorkOrder> listParentWo) {
        // Create a map Id WorkOrder -> WorkOrder:
        Map<String, WorkOrder> mapWorkOrderNew = new Map<String, WorkOrder>();
        for(WorkOrder wo : listParentWo) {
            mapWorkOrderNew.put(wo.Id, wo);
        }

        // Populate list WO to insert:
        List<WorkOrder> listWoToInsert = new List<WorkOrder>();
        for(String workOrderId : mapIdWorkOrderListIdAssetToManage.keySet()) {
            WorkOrder parentWO = mapWorkOrderNew.get(workOrderId);
            for(Asset assetToManage : mapIdWorkOrderListIdAssetToManage.get(workOrderId)) {
                WorkOrder wo = new WorkOrder(
                    ParentWorkOrderId = parentWo.Id,
                    AssetId = assetToManage.Id,
                    AccountId = parentWO.AccountId,                    
                    ContactId = parentWo.ContactId,
                    XC_Country__c = parentWo.XC_Country__c,
                    RecordTypeId = parentWo.RecordTypeId,                    
                    XC_Address__c = parentWo.XC_Address__c,
                    ServiceTerritoryId = parentWo.ServiceTerritoryId,
                    XC_AssignedPartner__c = parentWo.XC_AssignedPartner__c,
                    XC_AssignedResource__c = parentWo.XC_AssignedResource__c,
                    XC_LegalEntity__c = parentWo.XC_LegalEntity__c,
                    XC_WorkTypeCategory__c = parentWo.XC_WorkTypeCategory__c,
                    XC_ReadyToBeBooked__c = false,
                    XC_CreatedAutomaticallyBySystem__c = true
                );
                listWoToInsert.add(wo);
            }
        }

        // Manage DML operation:
        List<XC_UTIL_Sobject.WrapperResult> listWr = XC_UTIL_Sobject.insertListRecords(listWoToInsert);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result insert WorkOrder in CreateChildrenWO -> ' + JSON.serializePretty(listWr));
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 26/02/2020
     * @description Method to update Child Work Order for Diagnostic/Maintenance
     * @param listNew - List<WorkOrder>
     * @param mapOld - Map<Id, WorkOrder>
     * @param mapNew - Map<Id, WorkOrder>
     */
    public static void populateFieldOnUpdateAssignedResource(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {
        List<WorkOrder> listWoChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        List<WorkOrder> listWoAssigned = new List<WorkOrder>();
        for(WorkOrder woChanged : listWoChanged) {
            if((woChanged.Status == Label.XC_CL_WorkOrder_Assigned && 
                (woChanged.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance || woChanged.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Diagnostic)) ||
                    (woChanged.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && woChanged.XC_isTree__c == true)) {
                listWoAssigned.add(woChanged);
            }
        }
        if(listWoAssigned.isEmpty()) {
            return;
        }

        List<String> listProdSubType = new List<String>{Label.XC_CL_ProductSubTypeGas, Label.XC_CL_ProductSubTypeElectric};
        List<WorkOrder> listWoWithChildren = new List<WorkOrder>([
            SELECT Id, AssetId, XC_WorkTypeCategory__c, XC_AssignedPartner__c, XC_AssignedResource__c, ServiceTerritoryId, Status, Asset.XC_Product_type__c, Asset.XC_Product_Subtype__c,
                (SELECT Id
                FROM ChildWorkOrders)
            FROM WorkOrder 
            WHERE Id IN :listWoAssigned
        ]);

        List<WorkOrder> listChildWoToUpdate = new List<WorkOrder>();      
        for(WorkOrder parentWO : listWoWithChildren) {
            Boolean woMaintenaceOrDiagnostic = 
                (parentWO.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance || parentWO.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Diagnostic)
                && Label.XC_CL_AssetType_Service.equals(parentWO.Asset.XC_Product_type__c) && listProdSubType.contains(parentWO.Asset.XC_Product_Subtype__c);
            Boolean woMultipleDI = parentWO.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation;
            if(woMaintenaceOrDiagnostic || woMultipleDI){
                for(WorkOrder childWO : parentWO.ChildWorkOrders) {
                    WorkOrder childWoToUpdate = new WorkOrder(
                        Id = childWO.Id,
                        XC_AssignedPartner__c = parentWO.XC_AssignedPartner__c,
                        XC_AssignedResource__c = parentWO.XC_AssignedResource__c,
                        ServiceTerritoryId = parentWO.ServiceTerritoryId,
                        Status = parentWO.Status
                    );
                    listChildWoToUpdate.add(childWoToUpdate);
                }
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> listWr = XC_UTIL_Sobject.updateListRecords(listChildWoToUpdate);
        if(!XC_UTIL_Sobject.checkDMLResults(listWr)) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error to update WO children -> ' + listWr[0].errorMessage);
        }
    }

}