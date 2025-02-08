/**
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       22/11/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         public class with invocable method - Apply Coupon
 */

public without sharing class XC_IN038_ApplyCoupon {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN038_ApplyCoupon');

    /**
     * @description InputWrapper
    */
    public class InputWrapper{ 
        @Invocablevariable 
        public String stepToExecuteId;       
    }


    /**
     * @param inputWrapperList the list coming from flow
     * @description class to the the logic of Apply Coupon
    */
    @InvocableMethod 
    public static void applyCoupon(List<InputWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN038_ApplyCoupon');
        
        if(!inputWrapperList.isEmpty()){
            List<Id> listStepIds = new List<String>();
            List<XC_Provisioning_Step__c> provisioningStepsToComplete = new List<XC_Provisioning_Step__c>();
            String orderId = ''; 
            String segment = ''; 
            XC_Provisioning_Step__c step;
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepToExecuteId);
            }
            Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN038_ApplyCoupon_D.getMapSteps(listStepIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapSteps-->' +mapSteps);
            String confItemId;

            for(InputWrapper inputWr : inputWrapperList) {
                step = mapSteps.get(inputWr.stepToExecuteId);
                orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
                confItemId = step.XC_Configuration_Item__c;
                segment = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c; 

                step.XC_Status__c = Label.XC_CL_Completed_Ok; 
                provisioningStepsToComplete.add(step); 
            }

            Boolean resultGenerateWorkorders = XC_UTIL_Configuration.generateWorkorders(orderId, step.Id, 'XC_IN038_ApplyCoupon');
            if(!resultGenerateWorkorders && !Test.isRunningTest()) {
                return;
            }
            
            if(segment == 'B2C') {
                checkWBE(orderId);
            }

            /************** Get item **************/
            List<NE__OrderItem__c> configItemList =  XC_IN038_ApplyCoupon_D.getItemsByOrderId(orderId);
           /* List<NE__OrderItem__c> configItemList = New List<NE__OrderItem__c>();
            if(step.XC_Configuration_Item__r.XC_Segment__c != 'B2C'){
                configItemList =  XC_IN038_ApplyCoupon_D.getItemsByOrderIdB2B(orderId);
            }else{
                configItemList =  XC_IN038_ApplyCoupon_D.getItemsByOrderId(orderId);
            }*/
            List<Id> listIds = XC_UTIL_Sobject.getIds(configItemList);
            /************* Retrieve rate plans *******************************/
            Map<String, List<String>> prpcConfItemsMap = new Map<String, List<String>>();
            List<B2WExtCat__Work_Order_Item__c> b2wList = XC_IN038_ApplyCoupon_D.getJunctionRatePlanToItem(listIds, prpcConfItemsMap);
            if(b2wList.isEmpty()) {
                XC_IN038_ApplyCoupon_U.generateError(listIds, Label.XC_CL_ErrorMessage_NoRatePlanFound);
                return;
            }
            /*************************** ************************************/
            XC_IN038_ApplyCoupon_U.UtilWrapper wrapper = applyCouponUtil(b2wList);
            Map<String, List<String>> mapItemAddRP = wrapper.mapItemAddRP;
            Map<String, List<String>> mapItemRemoveRP = wrapper.mapItemRemoveRP;
            /********************************** **********************************************/

            XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr = XC_IN011_ChangeProvBillingProcess_D.getItemsByOldIds(listIds);

            if(String.isBlank(wr.zQuoteId)) {   // FOR Migration
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ in IN038 zquote is Blank');

                String subNumber = '';
                for(Asset a : wr.listAsset) {
                    if(String.isNotBlank(a.XC_SubscriptionName__c)) {
                        subNumber = a.XC_SubscriptionName__c;
                        break;
                    }
                }
                if(String.isNotBlank(subNumber)) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ in IN038 subName is Not Blank');
                    // call new method for amendment
                    Map<String, Object> inputMap = new Map<String, Object>{'wr' => wr,
                                                                            'mapItemAddRP' => mapItemAddRP,
                                                                            'mapItemRemoveRP' => mapItemRemoveRP,
                                                                            'subNumber' => subNumber,
                                                                            'orderId' => orderId,
                                                                            'confItemId' => confItemId,
                                                                            'stepId' => step.Id,
                                                                            'prpcConfItemsMap' => prpcConfItemsMap};
                    XC_UTIL_ChangeOrderMigration.migrationPayAndBill(inputMap);
                }
                return;
            }

            Map<String,Object> mapUtilAsset = new  Map<String,Object>{  'mapItemAddRP' => mapItemAddRP,
                                                                        'mapItemRemoveRP' => mapItemRemoveRP,
                                                                        'wr' => wr
                                                                    };


            XC_IN038_ApplyCoupon_U.RatePlanWrapper rpWrapper = XC_IN038_ApplyCoupon_U.cycleOnAsset(mapUtilAsset);
            Map<String, List<String>> mapZquoteIdAddRP = rpWrapper.mapZquoteIdAddRP;
            Map<String, List<String>> mapZquoteIdRemoveRP = rpWrapper.mapZquoteIdRemoveRP;

            Set<String> setZquoteIds = new Set<String>();
            setZquoteIds.addAll(mapZquoteIdAddRP.keySet());
            setZquoteIds.addAll(mapZquoteIdRemoveRP.keySet());
            
            /*if(setZquoteIds.isEmpty()){
                XC_IN038_ApplyCoupon_U.generateError(listIds, Label.XC_CL_NoRatePlanAddRemove); 
                return;
            }*/
            
            XC_IN011_ChangeProvBillingProcess_U.QuoteWrapper quoteWr = new XC_IN011_ChangeProvBillingProcess_U.QuoteWrapper();
            quoteWr.setZquoteIds = setZquoteIds;
            quoteWr.mapZquoteIdAddRP = mapZquoteIdAddRP;
            quoteWr.mapZquoteIdRemoveRP = mapZquoteIdRemoveRP;
            quoteWr.orderId = orderId;
            quoteWr.confItemId = confItemId;
            quoteWr.stepId = step.Id;
            quoteWr.prpcConfItemsMap = prpcConfItemsMap; 
            quoteWr.mixedVat = wr.mixedVat;
            String newZquoteID = XC_IN011_ChangeProvBillingProcess_U.addRemoveProductsAmendmentQuote(quoteWr);    
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### setZquoteIds ### ' + setZquoteIds);
            /*NE__OrderItem__c confItemToUpdate = new NE__OrderItem__c();
            confItemToUpdate = wr.mapNewItems.get(confItemId);
            confItemToUpdate.XC_ZQuoteId__c = newZquoteID;

            //Update order item
            XC_UTIL_Sobject.WrapperResult dmlResultOnItems = XC_UTIL_Sobject.updateRecord(confItemToUpdate);*/
            
            Map<Id, NE__OrderItem__c> confItemToUpdateList = new Map<Id, NE__OrderItem__c>();
            for(NE__OrderItem__c oi : wr.mapNewItems.values()) {
                oi.XC_ZQuoteId__c = newZquoteID;
                confItemToUpdateList.put(oi.Id, oi);
            }
            XC_UTIL_Sobject.updateListRecords(confItemToUpdateList.values());

            // Update the XC_Original_Configuration_Item__c field (LABEL Previous Order Item) with the actual Order Item that have the new zquote
            Map<Id, Asset> assetToUpdateList = new Map<Id, Asset>();
            for(Asset a : wr.listAsset) {
                if(confItemToUpdateList.keySet().contains(a.XC_Configuration_Item__c)) {
                    Asset aTemp = a;
                    aTemp.XC_Original_Configuration_Item__c = a.XC_Configuration_Item__c;
                    assetToUpdateList.put(aTemp.Id, aTemp);
                }
            }
            XC_UTIL_Sobject.updateListRecords(assetToUpdateList.values());
        } 

    }


    /**
     * Populate items list.
     * @description method applyCouponUtil to populate rateplan list
     * @param B2WExtCat__Work_Order_Item__c
     */
    private static XC_IN038_ApplyCoupon_U.UtilWrapper applyCouponUtil(List<B2WExtCat__Work_Order_Item__c> b2wList){
        XC_IN038_ApplyCoupon_U.UtilWrapper wrapper = new XC_IN038_ApplyCoupon_U.UtilWrapper();
        Map<String, List<String>> mapItemAddRP = new Map<String, List<String>>();
        Map<String, List<String>> mapItemRemoveRP = new Map<String, List<String>>();
        List<String> listRP = new List<String>();

        
        for(B2WExtCat__Work_Order_Item__c woItem : b2wList) {
            if(woItem.B2WExtCat__Action__c == 'Provide') {
                if(mapItemAddRP.containsKey(woItem.B2WExtCat__Configuration_Item__c)) {
                    listRP = mapItemAddRP.get(woItem.B2WExtCat__Configuration_Item__c);
                } else {
                    listRP = new List<String>();
                }
                listRP.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                mapItemAddRP.put(woItem.B2WExtCat__Configuration_Item__c, listRP);

            } else if(woItem.B2WExtCat__Action__c == 'Consume') {
                if(mapItemRemoveRP.containsKey(woItem.B2WExtCat__Configuration_Item__c)) {
                    listRP = mapItemRemoveRP.get(woItem.B2WExtCat__Configuration_Item__c);
                } else {
                    listRP = new List<String>();
                }
            listRP.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
            mapItemRemoveRP.put(woItem.B2WExtCat__Configuration_Item__c, listRP);
            } 
        }

        wrapper.mapItemAddRP = mapItemAddRP;
        wrapper.mapItemRemoveRP = mapItemRemoveRP;

        return wrapper;
    }

    /**
    *@author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    *@date 11/03/2021
    *@description Method to check and manage WBE
    *@param orderId - String
    */ 
    private static void checkWBE(String orderId) { 
        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('NE__OrderItem__c');
        query = query + ', NE__ProdId__r.XC_LIC_Product_Name__c, NE__Parent_Order_Item__r.XC_CMProfitCenter__c, NE__Parent_Order_Item__r.XC_CMCostCenter__c, NE__OrderId__r.RecordType.DeveloperName, ' +
            ' NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductLine__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductServiceType__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProfitCenter__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_CostCenter__c, ' +
            ' NE__CatalogItem__r.Id, NE__CatalogItem__r.XC_ProfitCenter__c, NE__CatalogItem__r.XC_CostCenter__c, NE__CatalogItem__r.XC_ProductServiceType__c, NE__CatalogItem__r.XC_ProductLine__c, NE__OrderId__r.XC_Country__c, NE__OrderId__r.XC_LegalEntity__c, ' +
            ' NE__OrderId__r.Id, NE__OrderId__r.NE__OptyId__r.Id, NE__OrderId__r.NE__OptyId__r.XC_Company__c, NE__OrderId__r.NE__OptyId__r.Business__c, NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__CatalogItem__r.XC_WbeMode__c, ' +
            ' (SELECT Id FROM Assets__r) ' +
            ' FROM NE__OrderItem__c ' +
            ' WHERE NE__OrderId__c = :orderId';
        query = query.replace('xc_installation_address__c,','');
        List<NE__OrderItem__c> listOrderItemFiltered = Database.query(String.escapeSingleQuotes(query));
        if(listOrderItemFiltered.isEmpty()) {
            return;
        }
        Map<Id, NE__OrderItem__c> mapOrderItem = new Map<Id, NE__OrderItem__c>();
        for(NE__OrderItem__c oi : listOrderItemFiltered) {
            mapOrderItem.put(oi.Id, oi);
        }
        List<NE__OrderItem__c> listOrderItemToUpdate = XC_TR_ConfigurationItem_U_GenerateWBE.populateWBEfields(listOrderItemFiltered);
        List<NE__OrderItem__c> listOrderItemsToUpdate = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oiProcessed : listOrderItemToUpdate) {
            listOrderItemsToUpdate.add(new NE__OrderItem__c(
                Id = oiProcessed.Id,
                XC_WBE__c = oiProcessed.XC_WBE__c,
                XC_CMProfitCenter__c = oiProcessed.XC_CMProfitCenter__c,
                XC_CMCostCenter__c = oiProcessed.XC_CMCostCenter__c
            ));
        }
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true); 
        List<XC_UTIL_Sobject.WrapperResult> listOiResults = XC_UTIL_Sobject.updateListRecords(listOrderItemsToUpdate);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false); 
        if(XC_UTIL_Sobject.checkDMLResults(listOiResults)) {
            List<Asset> listAssetsToUpdate = new List<Asset>();
            for(NE__OrderItem__c oi : listOrderItemsToUpdate) {
                for(Asset ass : mapOrderItem.get(oi.Id).Assets__r) {
                    ass.XC_WBE__c = oi.XC_WBE__c;
                    ass.XC_CMProfitCenter__c = oi.XC_CMProfitCenter__c;
                    ass.XC_CMCostCenter__c = oi.XC_CMCostCenter__c;
                    listAssetsToUpdate.add(ass);
                }
            }
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true); 
            XC_UTIL_Sobject.updateListRecords(listAssetsToUpdate);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false); 
        }
    }

}