/**
* @author Daniele Lico
* @date Creation 06/02/2019
* @date Modification dd/mm/yyyy
* @description XC_IN008_DeprovisioningBillingProcess – This class is called from the flow XC_FL_Deprovisioning_BillingProcess
*/

public without sharing class XC_IN041_DeprovisioningBillingProcessB2B {
     public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN008_DeprovisioningBillingProcess');
     
        /**
     * The Class InputWrapper.
     * @description InputWrapper
     */
    public class InputWrapper{ 
        @Invocablevariable     
        public String stepId;       
    }
    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @param inputWrapperList the list coming from flow
     * @description class to the the logic of billing process
     */
    @InvocableMethod 
    public static void billingProcess(List<InputWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN008_DeprovisioningBillingProcess');

        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            List<String> listStepIds = new List<String>();
            List<String> confItemListId = new List<String>();
            List<String> bundleItemListId = new List<String>();
            List<NE__OrderItem__c> orderItemToUpdateList = new List<NE__OrderItem__c>();
            Map<String,Asset> AssetSubscriptionName1 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName2= new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName3 = new Map <String,Asset>();
		    Map<String,Asset> AssetSubscriptionName4 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName5 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName6 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName7 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName8 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName9 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName10 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName11 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName12 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName21 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName22= new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName23 = new Map <String,Asset>();
		    Map<String,Asset> AssetSubscriptionName24 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName25 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName26 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName27 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName28 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName29 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName30 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName31 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName32 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName33 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName44 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName43 = new Map <String,Asset>();
		    Map<String,Asset> AssetSubscriptionName54 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName55 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName56 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName57 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName58 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName59 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName50 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName61 = new Map <String,Asset>();
            Map<String,Asset> AssetSubscriptionName62 = new Map <String,Asset>();

            List<XC_Provisioning_Step__c> provisioningStepsToComplete =  new List<XC_Provisioning_Step__c>();
            Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>();
            List<XC_REST_ZuoraCancelSubscription_U.WrapperResponse> wrList = new List<XC_REST_ZuoraCancelSubscription_U.WrapperResponse>();
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }

            XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper listWr = populateLists(listStepIds);
            mapSteps = listWr.mapSteps;
            confItemListId = listWr.confItemListId;
            bundleItemListId = listWr.bundleItemListId;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '###@1.5 confItemListId  --->' + confItemListId);
            XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps wrappConfItem = getConfigurationItemsMap(confItemListId, bundleItemListId);
            Map<Id,NE__OrderItem__c> configurationItemMap = wrappConfItem.configurationItemMap;  
            Map<Id,NE__OrderItem__c> configurationItemPenaltyMap = new Map<Id,NE__OrderItem__c>();
            Map<Id,NE__OrderItem__c> configurationItemWithBundleMap = new Map<Id,NE__OrderItem__c>();
            Map<Id,NE__OrderItem__c>  mapConfItemFatherIdPenaltyItem  = new Map<Id,NE__OrderItem__c>();
            Map<Id,String> mapConfItemAssetId = new Map<Id,String>();
            Map<String,Decimal>  mapConfItemPenalty = new Map<String,Decimal>();  
             
            Map<String,String> mapConfItemIdZuoraSubscription = new Map<String,String>();
            
            if(!wrappConfItem.configurationItemPenaltyMap.isEmpty()){
                configurationItemPenaltyMap = wrappConfItem.configurationItemPenaltyMap;
            }
            if(!wrappConfItem.configurationItemBundleMap.isEmpty()){
                configurationItemWithBundleMap = wrappConfItem.configurationItemBundleMap;
            }
            //Create two maps map<Asset Id,Configuration Item Id> and map<Zquote Id, Configuration Item Id>
            String configurationItemId = '';  //CONFIGURATION ITEM OF THE ACTUAL ITEM CONNECTED TO THE PROVISIOINING STEP
            
            for(NE__OrderItem__c confItem : configurationItemMap.values()){
                configurationItemId = confItem.Id;
                // assetId = confItem.NE__AssetItemEnterpriseId__c; ASSET OF THE PRODUCT
                mapConfItemAssetId.put(confItem.NE__AssetItemEnterpriseId__c, confItem.Id); //Map with Asset Id and ConfItem Id
            }
            mapConfItemFatherIdPenaltyItem = populateMapWithPenalty(configurationItemId, configurationItemPenaltyMap);
            // penalty section //
            mapConfItemPenalty = showPenalty(configurationItemWithBundleMap,configurationItemId, mapSteps);

            XC_IN008_DeprovisioningBillingProcess_U.WrapperQuoteBillingProfile wrQuoteBilling = XC_IN008_DeprovisioningBillingProcess_U.getZuoraQuoteMap(mapConfItemAssetId);
            Map<Id, zqu__Quote__c> mapZuoraQuote = wrQuoteBilling.quoteMap;
            Map<Id, String> billingProfileMap = wrQuoteBilling.billingProfileMap;
            Map<Id, String> mapConfItemZQuote = wrQuoteBilling.mapConfItemZQuote;
            Map<String, Zuora__Subscription__c> zuoraSubscriptionMap = wrQuoteBilling.zuoraSubscriptionMap;           
            for(zqu__Quote__c quote : mapZuoraQuote.values()){
                if(String.isNotBlank(quote.XC_LastSubscriptionId__c)) {
                    mapConfItemIdZuoraSubscription.put(configurationItemId, quote.XC_LastSubscriptionId__c);   // Take the zQuote lookup from the provisioning item      
                } else {
                    mapConfItemIdZuoraSubscription.put(configurationItemId, quote.zqu__ZuoraSubscriptionID__c);   // Take the zQuote lookup from the provisioning item      
                }
            }   
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapZuoraQuote  --->' + mapZuoraQuote);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'MAP <CONF ITEM - SUBSCRIPTION ID VALUE> -->' + mapConfItemIdZuoraSubscription);

            if(mapConfItemIdZuoraSubscription.isempty())
            {
                for(Zuora__Subscription__c Subscription : zuoraSubscriptionMap.values())
                {
                    if(String.isNotBlank(Subscription.Zuora__External_Id__c)) 
                    {
                          mapConfItemIdZuoraSubscription.put(configurationItemId, Subscription.Zuora__External_Id__c);
                        //zuoraSubscriptionMap.put(Subscription.name, Subscription);  
                    } 
            	}   
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Map for Migration' + mapConfItemIdZuoraSubscription);
            }

            List<zqu__Quote__c> zquoteToUpdate = new List<zqu__Quote__c>();
            // ACTIONS
            for(InputWrapper inputWr : inputWrapperList){

                XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);

                // 1) Use the info from XC_LCC095_ShowPenalty.showPenalty to populate the currency field NE__OneTimeFeeOv__c on the penalty Conf Item (only if the subtype is different from Rethinking)
                // 2) Update the billing profile of the Penalty Configuration Item with the billing profile of the provisioning order.
                XC_IN008_DeprovisioningBillingProcess_U.UtilWrapper utilWrapper = new XC_IN008_DeprovisioningBillingProcess_U.UtilWrapper();
               
                /*utilWrapper.mapConfItemFatherIdPenaltyItem = mapConfItemFatherIdPenaltyItem;
                utilWrapper.billingProfileMap = billingProfileMap;
                utilWrapper.mapConfItemPenalty = mapConfItemPenalty;
                utilWrapper.configurationItemMap = configurationItemMap;*/
                utilWrapper.step = step;
                //orderItemToUpdateList = penaltyAndBillingProfile(utilWrapper);
                
                // 3a) Call the Zuora method XC_REST_ZuoraCancelSubscription.cancelSubscription(subscriptionId, wr) if the subtype is different than Rethinking
                // 3b) Call the interface XC_REST_Rethinking.manageRethinking(subscriptionId) if the subtype is Rethinking
                XC_REST_ZuoraCancelSubscription_U.WrapperResponse wrResponse = callZuoraAndRethinking(configurationItemMap, mapConfItemIdZuoraSubscription, step);
                wrList.add(wrResponse);

                // 4) Set the provisioning step in Completed OK/KO
                Map<String, Object> parameters = new Map<String, Object>{'wrResponse' => wrResponse,
                                                                            'mapConfItemZQuote' => mapConfItemZQuote};
                XC_IN008_DeprovisioningBillingProcess_U.setStepStatusB2B(parameters, step, zquoteToUpdate);
                provisioningStepsToComplete.add(step);
            }     
             
            XC_IN008_DeprovisioningBillingProcess_U.updateProvisioningStepsAndConfigurationItem(wrList, provisioningStepsToComplete, orderItemToUpdateList);
                
            if(!zquoteToUpdate.isEmpty()) {
                List<XC_UTIL_Sobject.WrapperResult> zquoteResult = XC_UTIL_Sobject.updateListRecords(zquoteToUpdate);     
            }
        }  
    }

    private static XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper populateLists(List<String> listStepIds){
        XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper listWr = new XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper();
        List<String> confItemListId = listWr.confItemListId;
        List<String> bundleItemListId = listWr.bundleItemListId;
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
            [SELECT ID, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.XC_ZQuoteId__c,
                    XC_Configuration_Item__r.NE__Bundle_Configuration__c, XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c
                FROM XC_Provisioning_Step__c 
                WHERE Id IN: listStepIds]); 
 
        for(Id stepId : mapSteps.keySet()){
            confItemListId.add(mapSteps.get(stepId).XC_Configuration_Item__c);
            bundleItemListId.add(mapSteps.get(stepId).XC_Configuration_Item__r.NE__Bundle_Configuration__c);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '###@ confItemListId --->' + confItemListId );
        listWr.confItemListId = confItemListId;
        listWr.bundleItemListId = bundleItemListId;
        listWr.mapSteps = mapSteps;
        return listWr;
    }
    /**
     * @description populate Map With Penalty
     * @param configurationItemId
     * @param configurationItemPenaltyMap
     * @return mapConfItemFatherIdPenaltyItem
    **/
    private static Map<Id,NE__OrderItem__c> populateMapWithPenalty(String configurationItemId, Map<Id,NE__OrderItem__c> configurationItemPenaltyMap){
        Map<Id,NE__OrderItem__c>  mapConfItemFatherIdPenaltyItem  = new Map<Id,NE__OrderItem__c>();
        if(!configurationItemPenaltyMap.isEmpty()){             
            for(NE__OrderItem__c confItem : configurationItemPenaltyMap.values()){
                mapConfItemFatherIdPenaltyItem.put(configurationItemId, confItem);
            }
        }
        return  mapConfItemFatherIdPenaltyItem;
    }

    /**
     * @description show Penalty.
     * @param configurationItemWithBundleMap
     * @param configurationItemId
     * @param mapSteps
     * @return mapConfItemPenalty
    **/
    private static Map<String,Decimal> showPenalty(Map<Id,NE__OrderItem__c> configurationItemWithBundleMap, String configurationItemId, Map<Id, XC_Provisioning_Step__c> mapSteps){
        Map<String,Decimal>  mapConfItemPenalty = new Map<String,Decimal>();
        Map<Id,String> mapConfItemAssetOfBundleId = new Map<Id,String>();
        String assetId = '';
        if(!configurationItemWithBundleMap.isEmpty()){
            for(NE__OrderItem__c confItem : configurationItemWithBundleMap.values()){                 
                assetId = confItem.NE__AssetItemEnterpriseId__c; // ASSET OF THE BUNDLE
                mapConfItemAssetOfBundleId.put(assetId, configurationItemId);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'confItemBundle---> ' + confItem.Id);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'assetId---> ' + assetId);                       
            }
        }           
        if(!String.isBlank(assetId)){
            String orderSubtype = getOrderSubtypeFromSteps(mapSteps.values());
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderSubtype---> ' + orderSubtype);
            //XC_UTIL_DisconnectAssetManager.CalculationInputWrapper calcWr = XC_UTIL_DisconnectAssetManager.getCalculationInput(assetId, orderSubtype, Date.today());
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(assetId, orderSubtype, Date.today());
            XC_UTIL_ResultWrapper rw = XC_LCC095_ShowPenalty.showPenalty(calcWr); //assetId     //MC 20191119
            String penaltyValue = rw.objectInfo;
            Decimal penalty = 0;
            if(!String.isBlank(penaltyValue)){
                penalty = Decimal.valueOf(penaltyValue); 
                XC_UTIL_Debug.debug(DEBUGACTIVE, '### penalty -->' + penalty);
            } 
            mapConfItemPenalty.put(mapConfItemAssetOfBundleId.get(assetId), penalty);            
        }
        return mapConfItemPenalty;
    }

    /**
     * @description getOrderSubtypeFromSteps
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param mapSteps
     * @return OrderSubtype or empty string
     **/
    private static String getOrderSubtypeFromSteps(List<XC_Provisioning_Step__c> steps){
        for(XC_Provisioning_Step__c step : steps){
            if(step != null && String.isNotBlank(step.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c)){
                return step.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c;
            }
        }
        //else
        return '';
    }

    /**
     * Gets the configuration items map.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param confItemListId the conf item list id
     * @param bundleItemListId the bundle item list id
     * @return the configuration items map
     * @description Method to retrieve 3 maps with the configuration items  1) With the configuration item itself (of deprovisioining)
     *                                                                             2) With the configuration item with ProdName 'Penalty'
     *                                                                             3) With the configuration item of the product bundle
     */  
    private static XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps getConfigurationItemsMap(List<String> confItemListId,List<String> bundleItemListId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '###@2 confItemListId -->' + confItemListId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '###@2 bundleItemListId -->' + bundleItemListId);
        Map<Id, NE__OrderItem__c> configurationItemGenericMap = new Map<Id, NE__OrderItem__c>();
        XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps wrapperMaps = new XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps(); 
        if(!confItemListId.isEmpty()){
            configurationItemGenericMap = new Map<Id, NE__OrderItem__c>([
                SELECT Id, NE__OrderItem__c.CurrencyIsoCode, NE__OneTimeFeeOv__c,NE__BaseOneTimeFee__c, NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c,NE__Account__r.Country__c,
                        XC_ZQuoteId__c, NE__AssetItemEnterpriseId__c, NE__RecurringChargeOv__c, NE__ProdName__c, NE__BillingProfId__c, NE__Parent_Order_Item__c,
                        NE__OrderId__r.XC_Subtype__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Segment__c
                FROM NE__OrderItem__c
                WHERE (Id IN: confItemListId) 
                        OR (NE__Parent_Order_Item__c IN: confItemListId AND NE__ProdName__c =: Label.XC_CL_Asset_Penalty) 
                        OR (Id IN: bundleItemListId)]);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '###@ configurationItemGenericMap -->' + configurationItemGenericMap);
        for(NE__OrderItem__c confItem : configurationItemGenericMap.values()){
            if(confItemListId.contains(confItem.Id)){
                wrapperMaps.configurationItemMap.put(confItem.Id, confItem);
            }
            if(confItemListId.contains(confItem.NE__Parent_Order_Item__c) && confItem.NE__ProdName__c == Label.XC_CL_Asset_Penalty){
                wrapperMaps.configurationItemPenaltyMap.put(confItem.Id, confItem);
            }
            if(bundleItemListId.contains(confItem.Id)){
                wrapperMaps.configurationItemBundleMap.put(confItem.Id, confItem);
            }
        }   
        return wrapperMaps;
    }

     /**
     * @description penalty And BillingProfile.
     * @param utilWrapper
     * @return orderItemToUpdateList
    **/
    private static List<NE__OrderItem__c> penaltyAndBillingProfile(XC_IN008_DeprovisioningBillingProcess_U.UtilWrapper utilWrapper){
        Map<Id,NE__OrderItem__c> mapConfItemFatherIdPenaltyItem = utilWrapper.mapConfItemFatherIdPenaltyItem;
        Map<Id, String> billingProfileMap = utilWrapper.billingProfileMap;
        Map<String,Decimal>  mapConfItemPenalty = utilWrapper.mapConfItemPenalty;
        Map<Id,NE__OrderItem__c> configurationItemMap = utilWrapper.configurationItemMap;
        XC_Provisioning_Step__c step = utilWrapper.step;

        NE__OrderItem__c confItem = configurationItemMap.get(step.XC_Configuration_Item__c);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### father confItem --->' + confItem.Id );
        List<NE__OrderItem__c> orderItemToUpdateList = new List<NE__OrderItem__c>();
        if(!mapConfItemFatherIdPenaltyItem.isEmpty()){
            NE__OrderItem__c confItemPenalty = mapConfItemFatherIdPenaltyItem.get(step.XC_Configuration_Item__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### penalty confItem --->' + confItemPenalty.Id ); 
            if(!billingProfileMap.isEmpty() && billingProfileMap.containsKey(step.XC_Configuration_Item__c)){
                confItemPenalty.NE__BillingProfId__c = billingProfileMap.get(step.XC_Configuration_Item__c);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'NE__BillingProfId__c  -->' + confItemPenalty.NE__BillingProfId__c);
            if(confItem.NE__OrderId__r.XC_Subtype__c != Label.XC_CL_Rethinking){
                populateConfItemPenality(mapConfItemPenalty, step, confItemPenalty);
            }
            orderItemToUpdateList.add(confItemPenalty); 
        }  
        return orderItemToUpdateList;
    }

    /**
     * @description Populate ConfItem Penality
     * @param mapConfItemPenalty
     * @param step
     * @param confItemPenalty
    **/
    private static void populateConfItemPenality(Map<String,Decimal> mapConfItemPenalty, XC_Provisioning_Step__c step, NE__OrderItem__c confItemPenalty) {
        if(mapConfItemPenalty.containsKey(step.XC_Configuration_Item__c) && mapConfItemPenalty.get(step.XC_Configuration_Item__c) != null ){
            Decimal penaltyValue = mapConfItemPenalty.get(step.XC_Configuration_Item__c);
            confItemPenalty.NE__OneTimeFeeOv__c = penaltyValue; 
            confItemPenalty.NE__BaseOneTimeFee__c = penaltyValue;
        }
    }

    /**
     * @description penalty And BillingProfile.
     * @param configurationItemMap
     * @param mapConfItemIdZuoraSubscription
     * @param step
     * @return wrResponse
     **/
    private static XC_REST_ZuoraCancelSubscription_U.WrapperResponse callZuoraAndRethinking(Map<Id,NE__OrderItem__c> configurationItemMap, Map<String,String> mapConfItemIdZuoraSubscription, XC_Provisioning_Step__c step){
        XC_REST_ZuoraCancelSubscription_U.WrapperResponse wrResponse = new XC_REST_ZuoraCancelSubscription_U.WrapperResponse();
        NE__OrderItem__c confItem = configurationItemMap.get(step.XC_Configuration_Item__c);
        String legalEntity = confItem.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
        String stream = confItem.NE__OrderId__r.XC_Segment__c;
        String subscriptionId = mapConfItemIdZuoraSubscription.get(step.XC_Configuration_Item__c);

        if(String.isNotBlank(subscriptionId)) {
            if(confItem.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_Rethinking){

                wrResponse = XC_IN008_DeprovisioningBillingProcess_U.callRethinking(subscriptionId, legalEntity, stream);
                
            } else {
                String startDateLocal;
                XC_ZuoraZQuoteUtil_U.EntityWrapper entityWr = XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper(legalEntity, stream, '');
                if(entityWr != null && String.isNotBlank(entityWr.timeZone)){
                    startDateLocal = DateTime.now().format('yyyy-MM-dd', entityWr.timeZone);
                    System.debug('StartDate (local time): ' + startDateLocal);
                } else {
                    startDateLocal = String.valueOf(Date.Today());
                    System.debug('StartDate (user local time): ' + startDateLocal);
                }

                XC_REST_ZuoraCancelSubscription_U.WrapperRequest wr =  new XC_REST_ZuoraCancelSubscription_U.WrapperRequest();
                wr.cancellationEffectiveDate = startDateLocal;
                wr.cancellationPolicy = Label.XC_CL_CancellationPolicy_SpecificDate;
                wr.legalEntity = legalEntity;
                wr.stream = stream;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '### EffectiveDate' + wr.cancellationEffectiveDate);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '### subscriptionId' + subscriptionId);
                wrResponse = XC_REST_ZuoraCancelSubscription.cancelSubscription(subscriptionId, wr);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '### Not Rethinking wrResponse 008--->' + wrResponse);
            }
        }

        return wrResponse;
    }
}