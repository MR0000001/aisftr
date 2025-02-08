/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
 * @date 19/02/2019
 * @description XC_TR_WorkOrder_U_ManageSubstitution - Class to insert two WorkOrder (with WorkType Return and Delivery&Installation) if WorkOrder has type=Substitution
 */

public without sharing class XC_TR_WorkOrder_U_ManageSubstitution {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_ManageSubstitution');

    /** @description Wrapper to populate List WorkOrder */
    private class PopulateWorkOrderWrapper {
        Map<Id, Asset> mapOldAssets = new Map<Id, Asset>();
        List<WorkOrder> woList = new List<WorkOrder>();
        Map<Id, Asset> mapNewAssets = new Map<Id, Asset>();
        List<WorkOrder> listToInsert = new List<WorkOrder>();
    }

    /** @description Wrapper to check Asset */
    private class CheckAssetWrapper {
        List<Asset> listAssets = new List<Asset>();
        List<Asset> listOldAssets = new List<Asset>();
        List<Asset> listNewAssets = new List<Asset>();
        List<String> listConfigurationItems = new List<String>();
    }

    /**
     * @description Create Children WorkOrder
     * @param listNew - List<WorkOrder>
     */
    public static void createChildrenWorkOrder(List<WorkOrder> listNew) {
        List<WorkOrder> woList = filterSubstitution(listNew);
        if(woList.isEmpty()){
            return;
        }
        List<String> listConfigurations = XC_UTIL_Sobject.getListFieldValues(woList, 'XC_Configuration__c');
        List<String> listConfigurationItems = XC_UTIL_Sobject.getListFieldValues(woList, 'XC_Configuration_Item__c');
        List<Asset> listOldAssets = new List<Asset>();
        List<Asset> listNewAssets = new List<Asset>();
        if(!Schema.SObjectType.Asset.isAccessible()) {
            return;
        }
        List<Asset> listAssets = new List<Asset>([
            SELECT Id, NE__Order_Config__c, XC_Configuration_Item__c, NE__Action__c 
            FROM Asset 
            WHERE NE__Order_Config__c IN :listConfigurations 
            AND (NE__Action__c = 'Remove' OR NE__Action__c = 'Add')        
            AND XC_Configuration_Item__r.NE__ProdName__c!=: Label.XC_CL_Asset_Penalty
            AND XC_Configuration_Item__r.XC_IsAProduct__c = true
        ]);

        if(listAssets.isEmpty()) {
            return;
        }

        CheckAssetWrapper wrapper = new CheckAssetWrapper();
        wrapper.listAssets = listAssets;
        wrapper.listOldAssets = listOldAssets;
        wrapper.listNewAssets = listNewAssets;
        wrapper.listConfigurationItems = listConfigurationItems;
        checkAssets(wrapper);

        Map<Id, Asset> mapOldAssets = new Map<Id, Asset>();
        for(Asset asset : listOldAssets) {
            mapOldAssets.put(asset.NE__Order_Config__c, asset);
        }
        Map<Id, Asset> mapNewAssets = new Map<Id, Asset>();
        for(Asset asset : listNewAssets) {
            mapNewAssets.put(asset.XC_Configuration_Item__c,asset);
        }

        PopulateWorkOrderWrapper populateWorkOrderWrapper = new PopulateWorkOrderWrapper();
        populateWorkOrderWrapper.mapOldAssets = mapOldAssets;
        populateWorkOrderWrapper.woList = woList;
        populateWorkOrderWrapper.mapNewAssets = mapNewAssets;
        populateListWorkOrder(populateWorkOrderWrapper);

        XC_UTIL_Sobject.insertListRecords(populateWorkOrderWrapper.listToInsert);
    }

    /**
     * @description Filter substituion.
     * @param listNew - List<WorkOrder>
     * @return woList - List<WorkOrder>
     */
    private static List<WorkOrder> filterSubstitution(List<WorkOrder> listNew){
        List<WorkOrder> woList = new List<WorkOrder>();
        for(WorkOrder wo : listNew){
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Substitution) {
                woList.add(wo);
            }
        }
        return woList;
    }

    /**
     * @description Populate List WorkOrder
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param wrapper - PopulateWorkOrderWrapper
     */
    private static void populateListWorkOrder(PopulateWorkOrderWrapper wrapper) {
        for(WorkOrder wo : wrapper.woList) { 
            if(wrapper.mapOldAssets.get(wo.XC_Configuration__c) != null && wrapper.mapNewAssets.get(wo.XC_Configuration_Item__c) != null) {
                wrapper.listToInsert.add(
                    new WorkOrder(
                        ParentWorkOrderId = wo.Id, 
                        XC_CreatedAutomaticallyBySystem__c = true,
                        XC_WorkTypeCategory__c = Label.XC_CL_WorkType_Return,
                        XC_Configuration_Item__c = wrapper.mapOldAssets.get(wo.XC_Configuration__c).XC_Configuration_Item__c,
                        XC_ProductSubtype__c = wo.XC_ProductSubtype__c,
                        AssetId = wrapper.mapOldAssets.get(wo.XC_Configuration__c).Id
                    )
                );
                wrapper.listToInsert.add(
                    new WorkOrder(
                        ParentWorkOrderId = wo.Id, 
                        XC_CreatedAutomaticallyBySystem__c = true,
                        XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation,
                        XC_Configuration_Item__c = wrapper.mapNewAssets.get(wo.XC_Configuration_Item__c).XC_Configuration_Item__c,
                        XC_ProductSubtype__c = wo.XC_ProductSubtype__c,
                        AssetId=wrapper.mapNewAssets.get(wo.XC_Configuration_Item__c).Id
                    )
                );
            } 
        }
    }

    /**
     * @description Populate List WorkOrder
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param wrapper - CheckAssetWrapper
     */
    private static void checkAssets(CheckAssetWrapper wrapper) {
        for(Asset asset : wrapper.listAssets) {
            if('Remove'.equals(asset.NE__Action__c)) {
                wrapper.listOldAssets.add(asset);
            }
            else if(wrapper.listConfigurationItems.contains(asset.XC_Configuration_Item__c)){
                wrapper.listNewAssets.add(asset);
            }
        }
    }
}