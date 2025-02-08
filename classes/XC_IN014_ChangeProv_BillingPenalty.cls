/** @author      
 * @date         
 * @description XC_IN014_ChangeProv_BillingPenalty
 * @date Modification 05/11/2021 Nicola Mariniello nmariniello@deloitte.it
 **/


public without sharing class XC_IN014_ChangeProv_BillingPenalty {
    
	
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN014_ChangeProv_BillingPenalty');
    
    
    /**
     * @description InputWrapper  
    */   
    public  class InputWrapper{ 
        @Invocablevariable 
        public String stepId;       
    }


    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description method to do logic of billing Penalty    
     * @param inputWrapperList the list coming from flow
    */ 
    @InvocableMethod
    public static void billingPenalty(List<InputWrapper> inputWrapperList) {
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'in XC_IN014_ChangeProv_BillingPenalty.billingPenalty');

        if(!Schema.sObjectType.Asset.isAccessible() || !Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            return;
        }

        List<String> listStepIds = new List<String>();
        for(InputWrapper inputWr : inputWrapperList){
            listStepIds.add(inputWr.stepId);
        }

        XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper listWr = XC_IN008_DeprovisioningBillingProcess.populateLists(listStepIds); 
        Map<Id, XC_Provisioning_Step__c> mapSteps = listWr.mapSteps;

        XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps wrappConfItem = XC_IN008_DeprovisioningBillingProcess.getConfigurationItemsMap(listWr.confListId);

        Map<String, Decimal> mapConfItemPenalty = XC_IN008_DeprovisioningBillingProcess.showPenalty(wrappConfItem.configurationItemBundleMap, mapSteps);

        /* Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT Id,
                                                                            (SELECT Id, XC_DeveloperName__c, NE__Value__c FROM NE__Order_Item_Attributes__r) 
                                                                            FROM NE__OrderItem__c 
                                                                            WHERE Id IN : mapConfItemPenalty.keySet()]);*/
        List<NE__OrderItem__c> confItemsList = wrappConfItem.allConfItemMap.values();
        updateItem(confItemsList, mapConfItemPenalty);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'confItemsList: ' + confItemsList);
        List<XC_UTIL_Sobject.WrapperResult> result = XC_UTIL_Sobject.updateListRecords(confItemsList);
        XC_Provisioning_Step__c step = mapSteps.get(inputWrapperList[0].stepId);
        completeStep(step, result);
		
        /*Generate the junction records item <-> rateplan */
        String orderId = mapSteps.get(inputWrapperList[0].stepId).XC_Configuration_Item__r.NE__OrderId__c; 
        String generateResult = B2WExtCat.WS_WorkOrders.generateWorkOrders(orderId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'generateWorkordersResult: ' + generateResult);
        XC_UTIL_IntegrationLog.insertGenerateWorkOrderLog(generateResult, orderId, 'GenerateWorkOrder-XC_IN014_ChangeProv_BillingPenalty');

        /* Update Asset Status */
        List<Asset> assetToUpdate = new List<Asset>();
        updateActiveAsset(mapConfItemPenalty.keyset(), assetToUpdate);
        updateInactiveAssetsFromConfItemNone(listWr.confListId.get(0), assetToUpdate);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'assetToUpdate: ' + assetToUpdate);
        XC_UTIL_Sobject.updateListRecords(assetToUpdate);
    }
	

    /**
     * @author Marco Ottaviano - maottaviano@deloitte.it
     * @description method to Asset of Configuration Item with Action None   
     * @param idConfItem 
     * @param assetToUpdate List<Asset>
     */
    @TestVisible
    private static void updateActiveAsset(Set<String> idConfItem,List<Asset> assetToUpdate) {
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'in XC_IN014_ChangeProv_BillingPenalty.updateActiveAsset');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'idConfItem: ' + idConfItem);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'BEFORE assetToUpdate: ' + assetToUpdate);
        
        /* From mapItem Find Related Asset */
        Map<Id,Asset> mapIdAssetActive = new Map<Id,Asset>([SELECT Id,RecordTypeId,XC_AssetOwnership__c,XC_BillingModel__c,XC_Configuration_Item__c,XC_Configuration_Item__r.NE__OrderId__c FROM Asset WHERE XC_Configuration_Item__c IN :idConfItem]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapIdAssetActive: ' + mapIdAssetActive);
        if(!mapIdAssetActive.isEmpty()) {
            Id idRecType = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('XC_ESP_Customer').getRecordTypeId();
            for(Asset ast: mapIdAssetActive.values()) {
                ast.XC_BillingModel__c =Label.XC_CL_BillingModel_OneShot;
                ast.RecordTypeId = idRecType;
                ast.XC_AssetOwnership__c = Label.XC_CL_AssetOwnership_Customer; //'Customer';
                assetToUpdate.add(ast);
            }
          
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'idConfItem: ' + idConfItem);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'AFTER assetToUpdate: ' + assetToUpdate);
    }

    
    /**
     * @author Marco Ottaviano - maottaviano@deloitte.it
     * @description method to Asset of Configuration Item with Action None   
     * @param orderId 
     * @param assetToUpdate List<Asset>
     */
	@TestVisible
    private static void updateInactiveAssetsFromConfItemNone(String orderId,List<Asset> assetToUpdate) {
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'in XC_IN014_ChangeProv_BillingPenalty.updateInactiveAssetsFromConfItemNone');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderId: ' + orderId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'BEFORE assetToUpdate: ' + assetToUpdate);
        
        Map<Id,NE__OrderItem__c> mapConfItemNone = new Map<Id,NE__OrderItem__c> ([SELECT Id,NE__Action__c,NE__Bundle_Configuration__c, (SELECT Id,Name,NE__Status__c,Status,XC_ContractEndDate__c FROM Assets__r ) FROM NE__OrderItem__c WHERE NE__OrderId__c=:  orderId  AND NE__Action__c ='None']);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapConfItemNone: ' + mapConfItemNone);
        if(!mapConfItemNone.isEmpty()) {
            for(NE__OrderItem__c conItem : mapConfItemNone.values()) {
                if(!conItem.Assets__r.isEmpty()) {
                    for(Asset ast : conItem.Assets__r) {
                        ast.Status = Label.XC_CL_Asset_StatusInactive;
                        ast.XC_ContractEndDate__c = System.today();
                        assetToUpdate.add(ast);
                    }
                }
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderId: ' + orderId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'AFTER assetToUpdate: ' + assetToUpdate);       
    }

    

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description method to update step    
     * @param step XC_Provisioning_Step__c
     * @param result List<XC_UTIL_Sobject.WrapperResult>
     */
    private static void completeStep(XC_Provisioning_Step__c step, List<XC_UTIL_Sobject.WrapperResult> result){
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'in XC_IN014_ChangeProv_BillingPenalty.completeStep');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'BEFORE step: ' + step);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'BEFORE result: ' + result);
        
        for(XC_UTIL_Sobject.WrapperResult res : result){
            if(res.success){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'in success');
                step.XC_Status__c = Label.XC_CL_Completed_Ok;
            } else {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = res.errorMessage;
                break;
            }
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'AFTER step: ' + step);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'AFTER result: ' + result);
        XC_UTIL_Sobject.updateRecord(step);
    }
    

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description method to do updateItem    
     * @param item List<NE__OrderItem__c>
     * @param purchaseAmountMap Map<String,Decimal> 
    */
    private static void updateItem(List<NE__OrderItem__c> itemList, Map<String,Decimal>  purchaseAmountMap) {
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'in XC_IN014_ChangeProv_BillingPenalty.updateItem');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'itemList: ' + itemList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'purchaseAmountMap: ' + purchaseAmountMap);
        
        List<NE__Order_Item_Attribute__c> listAttributeToUpdate = new List<NE__Order_Item_Attribute__c>();
        List<Id> confIdsProcessed = new List<Id>();

        for(NE__OrderItem__c item : itemList) {
            if(purchaseAmountMap.containsKey(item.Id)) {
                for(NE__Order_Item_Attribute__c attr : item.NE__Order_Item_Attributes__r) {
                    if(attr.XC_DeveloperName__c == Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel) {
                        System.debug(LoggingLevel.FINEST, attr);
                        if(attr.NE__Value__c.containsIgnoreCase('Renting')){
                            attr.NE__Value__c = Label.XC_CL_ConfItemAttr_OneShot;
                            listAttributeToUpdate.add(attr);
                        }
                    }
                    if(attr.XC_DeveloperName__c == 'Zuora Payment Method') {
                        attr.NE__Value__c = 'One Time';
                        listAttributeToUpdate.add(attr);
                    }
                }

                item.NE__OneTimeFeeOv__c = Integer.valueOf(purchaseAmountMap.get(item.Id));
                item.NE__BaseOneTimeFee__c = Integer.valueOf(purchaseAmountMap.get(item.Id));
                item.NE__Action__c = 'Add';
                item.NE__BaseRecurringCharge__c = 0;
                item.NE__RecurringChargeOv__c = 0;

                confIdsProcessed.add(item.NE__OrderId__c);
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'confIdsProcessed: ' + confIdsProcessed);

        for(NE__OrderItem__c item : itemList) {
            if(confIdsProcessed.contains(item.NE__OrderId__c) && !purchaseAmountMap.containsKey(item.Id) && item.XC_Product_Type__c == 'Equipment') {
                item.NE__Action__c = 'None';
                item.XC_BillingModel__c = 'One Shot';
                item.NE__OneTimeFeeOv__c = 0;
                item.NE__BaseOneTimeFee__c = 0;
                item.NE__BaseRecurringCharge__c = 0;
                item.NE__RecurringChargeOv__c = 0;
            }
        }
		
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'purchaseAmountMap: ' + purchaseAmountMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'itemList: ' + itemList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listAttributeToUpdate: ' + listAttributeToUpdate);
        XC_UTIL_Sobject.updateListRecords(listAttributeToUpdate);
    }

}