/**
 * @author Roberta Cossiga - rcossiga@deloitte.it
 * @date Creation 18/03/2020
 * @description XC_TR_Asset_U_ManageProvisioning
 */

    public without sharing class XC_TR_Asset_U_ManageProvisioning {

    /**
     * @description Method to active Parent Order Item
     * @param  listNew - List<Asset>
     * @param  mapOld - Map<Id,Asset>
     * @param  mapNew - Map<Id,Asset>
     */
    public static void activeServicesConfigurationItem(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
        List<Asset> listChanged = XC_UTIL_SObject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        List<Asset> listActivedServices = new List<Asset>();
        List<Asset> listDeactivedServices = new List<Asset>();
        for(Asset ass : listChanged) {
            if(ass.Status == Label.XC_CL_Asset_StatusActive && (ass.XC_Product_Type__c == Label.XC_CL_AssetType_Service || 
                                                                (ass.XC_Product_Type__c == Label.XC_CL_ProductTypeCoverage && String.isBlank(ass.NE__Root_Order_Item__c) && String.isBlank(ass.NE__Bundle_Configuration__c) ) ) ) {
                listActivedServices.add(ass);
            } else if(ass.Status == Label.XC_CL_Asset_StatusInactive){
                listDeactivedServices.add(ass);
            }
        }
        if(listActivedServices.isEmpty() && listDeactivedServices.isEmpty()){
            return;
        }
        List<NE__OrderItem__c> listOrderItemToUpdate = new List<NE__OrderItem__c>();
        for(Asset ass : listActivedServices) {
            listOrderItemToUpdate.add(new NE__OrderItem__c(
                Id = ass.XC_Configuration_Item__c,
                XC_DeliveryStatusList__c = Label.XC_CL_ListDeliveryStatusService,
                XC_DeliveryStatus__c = Label.XC_CL_Asset_StatusActive
            ));
        }
        if(!listDeactivedServices.isEmpty()){
            Map<String,String> assetIdDeliveryStatusListMap = getOrderItemDeliveryStatusList(listDeactivedServices);
            for(Asset ass : listDeactivedServices){
                if(assetIdDeliveryStatusListMap.containsKey(ass.Id) && !String.isEmpty(assetIdDeliveryStatusListMap.get(ass.Id))){
                    listOrderItemToUpdate.add(new NE__OrderItem__c(
                        Id = ass.XC_Configuration_Item__c,
                        XC_DeliveryStatusList__c = assetIdDeliveryStatusListMap.get(ass.Id) + ',Canceled',
                        XC_DeliveryStatus__c = Label.XC_CL_DeliveryStatus_Canceled
                    ));
                }
            }
        }
        XC_UTIL_Sobject.updateListRecords(listOrderItemToUpdate);
    }
        
    /**
     * @description Check if the Provisioning Step has to be updated
     * @param  listNew - List<Asset>
     * @param  mapOld - Map<Id,Asset>
     * @param  mapNew - Map<Id,Asset>
     */
    public static void checkIfToUpdateProvisioningStep(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
        List<String> fieldList = new List<String>{'XC_ElectricalConnectionType__c', 'XC_ElectricalConnectionDate__c'};
        List<Asset> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            updateProvisioningStep(listChanged);
        }
    }
        
    /**
     * @description Update Provisionig Step
     * @param  listNew - List<Asset>
     * @param  mapOld - Map<Id,Asset>
     * @param  mapNew - Map<Id,Asset>
     */    
    public static void updateProvisioningStep(List<Asset> listNew){
        List<XC_Provisioning_Step__c> listStepToUpdate = new List<XC_Provisioning_Step__c>();
        for(Asset a : listNew){ 
            if(!String.isEmpty(a.XC_ProvisioningStep__c) && !String.isEmpty(a.XC_ElectricalConnectionType__c) && a.XC_ElectricalConnectionDate__c != null){
                XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(Id = a.XC_ProvisioningStep__c);
                step.XC_Status__c = 'Completed OK';
                listStepToUpdate.add(step);
            }
        }
        XC_UTIL_Sobject.updateListRecords(listStepToUpdate);  
    }  

    /**
     * @description Update Check Related Product Activation Provisionig Step
     * @param  listNew - List<Asset>
	 * @param  mapOld - Map<Id,Asset>
	 * @param  mapNew - Map<Id,Asset>
     */    
    public static void updateCheckRelatedProductActivationStep(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
        List<Asset> listChanged = XC_UTIL_SObject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }

        Set<String> configurationIdsSet = new Set<String>();
        Set<String> itemCodeSetActive = new Set<String>();
        Set<String> itemCodeSetInactive = new Set<String>();
        for(Asset a : listChanged) {
            if(String.isNotBlank(a.NE__Order_Config__c)) {
                configurationIdsSet.add(a.NE__Order_Config__c);
            }
            if(a.Status == Label.XC_CL_Asset_StatusActive && String.isNotBlank(a.NE__Item_Code__c)) {
                itemCodeSetActive.add(a.NE__Item_Code__c);
            } else if (a.Status == Label.XC_CL_Asset_StatusInactive && String.isNotBlank(a.NE__Item_Code__c)) {
                itemCodeSetInactive.add(a.NE__Item_Code__c);
            }
        }
        if(itemCodeSetActive.isEmpty() && itemCodeSetInactive.isEmpty()){
            return;
        }

        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_RelatedProduct__c,
                                                                                    (SELECT Id, XC_Flow_API_Name__c
                                                                                    FROM Provisioning_Steps__r 
                                                                                    WHERE (XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningCheckRelatedProdActivation_Flow OR XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningFlow_WaitForRelatedProductActivation)
                                                                                        AND  XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress)  
                                                                                FROM NE__OrderItem__c
                                                                                WHERE NE__OrderId__c IN: configurationIdsSet AND XC_NeedProvisioning__c = true AND (XC_RelatedProduct__c IN: itemCodeSetActive OR XC_RelatedProduct__c IN: itemCodeSetInactive)]);
        if(orderItemMap.isEmpty()) {
            return;
        }

        List <XC_Provisioning_Step__c> listStepToUpdate = new List<XC_Provisioning_Step__c>();
        for(NE__OrderItem__c oi : orderItemMap.values()){
            for(XC_Provisioning_Step__c step : oi.Provisioning_Steps__r) {
                if(itemCodeSetActive.contains(oi.XC_RelatedProduct__c)) {
                    step.XC_Status__c = Label.XC_CL_Completed_Ok;
                    listStepToUpdate.add(step);
                } else if(itemCodeSetInactive.contains(oi.XC_RelatedProduct__c) && step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningFlow_WaitForRelatedProductActivation) {
                    step.XC_Status__c = Label.XC_CL_Step_CompletedWarning;
                    listStepToUpdate.add(step);
                }
            }
        }

        XC_UTIL_Sobject.updateListRecords(listStepToUpdate);  
    }

    /**
     * @description Check if the Provisioning Step 'Check asset juicebox' has to be updated 
     * @author Marina Ciavarra - mciavarra@deloitte.it
     * @date Creation 01/04/2021
     * @param  listNew - List<Asset>
     * @param  mapOld - Map<Id,Asset>
     * @param  mapNew - Map<Id,Asset>
     */
    public static void checkIfUpdateCheckAssetJuicebox(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
        List<String> fieldList = new List<String>{'XC_SpecialOfferType__c'};
        List<Asset> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        List<Asset> listAssetToUpdate = new List<Asset>();
        if(listChanged.isEmpty()){
            return;
        }

        for(Asset a : listChanged) {
            if(a.XC_SpecialOfferType__c == Label.XC_CL_OpenCharge) {
                listAssetToUpdate.add(a);
            }
        }

        if(listAssetToUpdate.isEmpty()){
            return;
        }

        Set<Id> accountIds = XC_UTIL_Sobject.getSetIdsOnField(listAssetToUpdate, 'AccountId');
        Map<Id, XC_Provisioning_Step__c> stepMap = new Map<Id, XC_Provisioning_Step__c>([SELECT Id
                                                                                        FROM XC_Provisioning_Step__c
                                                                                        WHERE XC_Status__c =: Label.XC_CL_InProgress 
                                                                                            AND XC_Flow_API_Name__c = 'XC_FL_Provisioning_CheckAssetJuiceBox' 
                                                                                            AND XC_Configuration_Item__r.NE__Account__c IN :accountIds]);
        if(stepMap.isEmpty()){
            return;
        }

        List <XC_Provisioning_Step__c> listStepToUpdate = new List<XC_Provisioning_Step__c>();
        for(XC_Provisioning_Step__c step: stepMap.values()){
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
            listStepToUpdate.add(step);
        }
        XC_UTIL_Sobject.updateListRecords(listStepToUpdate);  
    }

    private static Map<String,String> getOrderItemDeliveryStatusList(List<Asset> assetList){
        Map<String,String> assetIdDeliveryStatusMap = new Map<String,String>();
        List<String> assetIdList = XC_UTIL_Sobject.getIds(assetList);
        List<Asset> assetListQueried = new List<Asset>([SELECT Id, XC_Configuration_Item__r.XC_DeliveryStatusList__c 
                                                    FROM Asset 
                                                    WHERE Id IN: assetIdList]);
        for(Asset ast : assetListQueried){
            assetIdDeliveryStatusMap.put(ast.Id, ast.XC_Configuration_Item__r.XC_DeliveryStatusList__c);
        }
        return assetIdDeliveryStatusMap;                                                   
    }
}