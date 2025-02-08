/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com 
* @date Creation 06/02/2019
* @date Modification 31/01/2020 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @description XC_IN008_DeprovisioningBillingProcess – This class is called from the flow XC_FL_Deprovisioning_BillingProcess
*/

public without sharing class XC_IN008_DeprovisioningBillingProcess {
 
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
            List<NE__OrderItem__c> orderItemToUpdateList = new List<NE__OrderItem__c>();
            //List<XC_Provisioning_Step__c> provisioningStepsToComplete =  new List<XC_Provisioning_Step__c>();
            Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>();
            //List<XC_REST_ZuoraCancelSubscription_U.WrapperResponse> wrList = new List<XC_REST_ZuoraCancelSubscription_U.WrapperResponse>();
            List<XC_REST_Disconnection.WrapperResponse> wrList = new List<XC_REST_Disconnection.WrapperResponse>();

            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }

            XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper listWr = populateLists(listStepIds);
            mapSteps = listWr.mapSteps;
            XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps wrappConfItem = getConfigurationItemsMap(listWr.confListId);
            Map<Id,NE__OrderItem__c> configurationItemMap = wrappConfItem.configurationItemMap;  
            Map<Id,NE__OrderItem__c> configurationItemPenaltyMap = new Map<Id,NE__OrderItem__c>();
            Map<Id,NE__OrderItem__c> configurationItemWithBundleMap = new Map<Id,NE__OrderItem__c>();
            Map<Id,NE__OrderItem__c>  mapConfItemFatherIdPenaltyItem  = new Map<Id,NE__OrderItem__c>();
            Map<Id,String> mapConfItemAssetId = new Map<Id,String>();
            Map<String,Decimal>  mapConfItemPenalty = new Map<String,Decimal>();  
            
            if(!wrappConfItem.configurationItemPenaltyMap.isEmpty()){
                configurationItemPenaltyMap = wrappConfItem.configurationItemPenaltyMap;
            }
            if(!wrappConfItem.configurationItemBundleMap.isEmpty()){
                configurationItemWithBundleMap = wrappConfItem.configurationItemBundleMap;
            }

            for(NE__OrderItem__c ordItem : configurationItemWithBundleMap.values()){
                if(!configurationItemMap.containsKey(ordItem.id) && listWr.confItemListId.contains(ordItem.id)){
                    configurationItemMap.put(ordItem.id, ordItem);
                }
            }
            List<Date> listCommunicationDate = new List<Date>(); 
            for(NE__OrderItem__c confItem : configurationItemMap.values()){
                mapConfItemAssetId.put(confItem.NE__AssetItemEnterpriseId__c, confItem.Id); //Map with Asset Id and ConfItem Id
                listCommunicationDate.add(confItem.NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c);
            }
            System.debug('Ecco: listCommunicationDate '+ listCommunicationDate);
            System.debug('Ecco: mapConfItemAssetId '+ mapConfItemAssetId);
            List<WorkOrder> listConfTime = [SELECT Id, XC_Configuration__c, XC_Coverage__c,AssetId,EndDate 
                                        FROM WorkOrder 
                                        WHERE  (AssetId IN :mapConfItemAssetId.keySet() OR XC_Coverage__c IN :mapConfItemAssetId.keySet() )
                                             AND (XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_Repair  OR XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_PlannedMaintenance)
                                             AND Status = :Label.XC_CL_WorkOrder_Completed AND EndDate > :listCommunicationDate
            ];
            System.debug('Ecco: listconfTime'+ listConfTime);
            Map<Id,String> mapConfTime= new Map<Id,String>();
            for( WorkOrder wo : listConfTime){
                if( mapConfItemAssetId.containsKey(wo.AssetId) && (!mapConfTime.containsKey(wo.XC_Configuration__c) || wo.EndDate> Date.valueOf(mapConfTime.get(wo.AssetId)) ) ){
                    mapConfTime.put(wo.AssetId, String.valueOf(wo.EndDate));
                }else if( mapConfItemAssetId.containsKey(wo.XC_Coverage__c) && ( !mapConfTime.containsKey(wo.XC_Coverage__c) || wo.EndDate> Date.valueOf(mapConfTime.get(wo.XC_Coverage__c)) ) ){
                    mapConfTime.put(wo.XC_Coverage__c, String.valueOf(wo.EndDate));
                }
            
            }
           System.debug('Ecco mapConfTime'+ mapConfTime);
            mapConfItemFatherIdPenaltyItem = populateMapWithPenalty(configurationItemPenaltyMap);
            // penalty section //
            mapConfItemPenalty = showPenalty(configurationItemWithBundleMap, mapSteps);

            XC_IN008_DeprovisioningBillingProcess_U.WrapperQuoteBillingProfile wrQuoteBilling = XC_IN008_DeprovisioningBillingProcess_U.getZuoraQuoteMap(mapConfItemAssetId);
            Map<Id, zqu__Quote__c> mapZuoraQuote = wrQuoteBilling.quoteMap;
            Map<Id, String> billingProfileMap = wrQuoteBilling.billingProfileMap;
            Map<Id, String> mapConfItemZQuote = wrQuoteBilling.mapConfItemZQuote;
            Map<String, Zuora__Subscription__c> zuoraSubscriptionMap = wrQuoteBilling.zuoraSubscriptionMap;
            Map<Id, Asset> mapConfItemIdAsset = wrQuoteBilling.mapConfItemIdAsset;

            String configurationItemId = mapSteps.values()[0].XC_Configuration_Item__c; 

            Map<String,String> mapConfItemIdZuoraSubscription = new Map<String,String>();
            //Map<String,String> mapConfItemIdZquoteError = new Map<String,String>();

            if(zuoraSubscriptionMap == null || zuoraSubscriptionMap.isEmpty()) {

                for(zqu__Quote__c quote : mapZuoraQuote.values()){
                    if(String.isNotBlank(quote.XC_LastSubscriptionId__c)) {
                        mapConfItemIdZuoraSubscription.put(configurationItemId, quote.XC_LastSubscriptionId__c);   // Take the zQuote lookup from the provisioning item      
                    } else if (String.isNotBlank(quote.zqu__ZuoraSubscriptionID__c)) {
                        mapConfItemIdZuoraSubscription.put(configurationItemId, quote.zqu__ZuoraSubscriptionID__c);   // Take the zQuote lookup from the provisioning item      
                    } /*else {
                        mapConfItemIdZquoteError.put(configurationItemId, quote.Id);
                    }*/
                }   
                
                if(!mapConfItemIdZuoraSubscription.isEmpty()) {
                    zuoraSubscriptionMap = XC_IN008_DeprovisioningBillingProcess_U.getSubscriptionInfos(mapConfItemIdZuoraSubscription.values());
                }
                
            } else {
                mapConfItemIdZuoraSubscription.put(configurationItemId, zuoraSubscriptionMap.values()[0].Zuora__External_Id__c);
            }
            
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapZuoraQuote  --->' + mapZuoraQuote);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'MAP <CONF ITEM - SUBSCRIPTION ID VALUE> -->' + mapConfItemIdZuoraSubscription);

            // ACTIONS
            List<XC_Provisioning_Step__c> provStepsSkip = new List<XC_Provisioning_Step__c>();
            for(InputWrapper inputWr : inputWrapperList){

                XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);
                
                /*if(String.isNotBlank(mapConfItemIdZquoteError.get(step.XC_Configuration_Item__c))) {
                    step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                    step.XC_ErrorMessage__c = 'Subscription Id not found on zQuote';
                    provStepsSkip.add(step);

                } else*/ if(String.isBlank(mapConfItemIdZuoraSubscription.get(step.XC_Configuration_Item__c)) && String.isBlank(mapConfItemIdAsset.get(step.XC_Configuration_Item__c).XC_External_ID__c)) {
                    step.XC_Status__c = Label.XC_CL_Step_Skipped;
                    provStepsSkip.add(step);
                    
                } else {
                    
                    XC_IN008_DeprovisioningBillingProcess_U.UtilWrapper utilWrapper = new XC_IN008_DeprovisioningBillingProcess_U.UtilWrapper();
                    utilWrapper.mapConfItemFatherIdPenaltyItem = mapConfItemFatherIdPenaltyItem;
                    utilWrapper.billingProfileMap = billingProfileMap;
                    utilWrapper.mapConfItemPenalty = mapConfItemPenalty;
                    utilWrapper.configurationItemMap = configurationItemMap;
                    utilWrapper.step = step;
                    orderItemToUpdateList = penaltyAndBillingProfile(utilWrapper);
                    
                    Map<String, Object> parametersCallZuora = new Map<String, Object>{'configurationItemMap' => configurationItemMap,
                                                                                    'mapConfItemIdZuoraSubscription' => mapConfItemIdZuoraSubscription,
                                                                                    'step' => step,
                                                                                    'zuoraSubscriptionMap' => zuoraSubscriptionMap,
                                                                                    'orderItemToUpdateList' => orderItemToUpdateList,
                                                                                    'mapConfItemZQuote' => mapConfItemZQuote,
                                                                                    'wrList' => wrList,
                                                                                    'mapConfItemIdAsset' => mapConfItemIdAsset, //TO DO Donato
                                                                                    'mapConfTime' => mapConfTime};
                                                                                    
                    System.enqueueJob(new callZuoraAndRethinking(parametersCallZuora));
                }
            }     

            if(!provStepsSkip.isEmpty()) {
                XC_UTIL_Sobject.updateListRecords(provStepsSkip);
            }
        }  
    }


    
    /**
     * @description Send Future Queuable to call Zuora for Cancel Susbscription or Rethinking
     */
    public class callZuoraAndRethinking implements Queueable, Database.AllowsCallouts {
    
        Map<String, Object> parametersCallZuora = new  Map<String, Object>();


        /**
         * @description Instantiates a new send future queuable.
         * @param parametersCallZuora the zparameters
         */
		public callZuoraAndRethinking(Map<String, Object> parametersCallZuora) {
            this.parametersCallZuora = parametersCallZuora;
		}

		public void execute(QueueableContext context) {

            List<XC_Provisioning_Step__c> provisioningStepsToComplete =  new List<XC_Provisioning_Step__c>(); 
            List<zqu__Quote__c> zquoteToUpdate = new List<zqu__Quote__c>();
            XC_Provisioning_Step__c step = (  XC_Provisioning_Step__c) parametersCallZuora.get('step');
            Map<Id, String> mapConfItemZQuote = (Map<Id, String>) parametersCallZuora.get('mapConfItemZQuote');
            //List<XC_REST_ZuoraCancelSubscription_U.WrapperResponse> wrList = (List<XC_REST_ZuoraCancelSubscription_U.WrapperResponse>) parametersCallZuora.get('wrList');
            List<XC_REST_Disconnection.WrapperResponse> wrList = (List<XC_REST_Disconnection.WrapperResponse>) parametersCallZuora.get('wrList');

            List<NE__OrderItem__c> orderItemToUpdateList = (List<NE__OrderItem__c>) parametersCallZuora.get('orderItemToUpdateList');
            
            //XC_REST_ZuoraCancelSubscription_U.WrapperResponse wrResponse = callZuoraAndRethinking(parametersCallZuora);
            XC_REST_Disconnection.WrapperResponse wrResponse = callZuoraAndRethinking(parametersCallZuora);
            wrList.add(wrResponse);

            // 4) Set the provisioning step in Completed OK/KO
            Map<String, Object> parameters = new Map<String, Object>{'wrResponse' => wrResponse,
                                                                    'mapConfItemZQuote' => mapConfItemZQuote};
            XC_IN008_DeprovisioningBillingProcess_U.setStepStatus(parameters, step, zquoteToUpdate);
            provisioningStepsToComplete.add(step);

            XC_IN008_DeprovisioningBillingProcess_U.updateProvisioningStepsAndConfigurationItem(wrList, provisioningStepsToComplete, orderItemToUpdateList);
                
            if(!zquoteToUpdate.isEmpty()) {
                List<XC_UTIL_Sobject.WrapperResult> zquoteResult = XC_UTIL_Sobject.updateListRecords(zquoteToUpdate);     
            }
        }
    }


    public static XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper populateLists(List<String> listStepIds){
        XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper listWr = new XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper();
        List<String> confListId = new List<String>();
        List<String> confItemListId = new List<String>();
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
            [SELECT ID, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.XC_ZQuoteId__c,
                    XC_Configuration_Item__r.NE__Bundle_Configuration__c, XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c
                FROM XC_Provisioning_Step__c 
                WHERE Id IN: listStepIds]); 
 
        for(Id stepId : mapSteps.keySet()){
            confListId.add(mapSteps.get(stepId). XC_Configuration_Item__r.NE__OrderId__c); 
            confItemListId.add(mapSteps.get(stepId). XC_Configuration_Item__c);

        }

        listwr.confListId = confListId;
        listwr.confItemListId = confItemListId;
        listWr.mapSteps = mapSteps;
        return listWr;
    }


    /**
     * @description populate Map With Penalty
     * @param configurationItemId
     * @param configurationItemPenaltyMap
     * @return mapConfItemFatherIdPenaltyItem
    **/
    private static Map<Id,NE__OrderItem__c> populateMapWithPenalty(Map<Id,NE__OrderItem__c> configurationItemPenaltyMap){
        Map<Id,NE__OrderItem__c>  mapConfItemFatherIdPenaltyItem  = new Map<Id,NE__OrderItem__c>();
        if(!configurationItemPenaltyMap.isEmpty()){             
            for(NE__OrderItem__c confItem : configurationItemPenaltyMap.values()){
                mapConfItemFatherIdPenaltyItem.put(confItem.NE__Parent_Order_Item__c, confItem);
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
    public static Map<String,Decimal> showPenalty(Map<Id,NE__OrderItem__c> configurationItemWithBundleMap, Map<Id, XC_Provisioning_Step__c> mapSteps){
        Map<String,Decimal>  mapConfItemPenalty = new Map<String,Decimal>();
        Map<Id,String> mapConfItemAssetOfBundleId = new Map<Id,String>();
        String assetId = '';
        if(!configurationItemWithBundleMap.isEmpty()){
            for(NE__OrderItem__c confItem : configurationItemWithBundleMap.values()){                 
                assetId = confItem.NE__AssetItemEnterpriseId__c; // ASSET OF THE BUNDLE
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'confItemBundle---> ' + confItem.Id);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'assetId---> ' + assetId);                       
            }
        }           
        if(!String.isBlank(assetId)){
            String orderSubtype = getOrderSubtypeFromSteps(mapSteps.values());
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderSubtype---> ' + orderSubtype);
            Date dateToCalculate = (configurationItemWithBundleMap.values()[0].NE__OrderId__r.XC_CaseId__c != null && configurationItemWithBundleMap.values()[0].NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c != null) ? configurationItemWithBundleMap.values()[0].NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c : Date.today();
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(assetId, orderSubtype, dateToCalculate);
            XC_UTIL_ResultWrapper rw = XC_LCC095_ShowPenalty.showAmounts(calcWr);                 //MC 20200130
            Map<String,Object> objInfoData = (Map<String,Object>)JSON.deserializeUntyped(rw.objectInfo);
            Map<String,Object> amountItems = (Map<String,Object>)objInfoData.get('AmountItems');
            Map<String,Object> item;
            if(amountItems != null){
                for(Object objItem : amountItems.values()){
                    item = (Map<String,Object>)objItem; 
                    Decimal penalty = 0;
                    if(!String.isBlank((String)(item.get('amountValue')))){
                        penalty = Decimal.valueOf(((String)item.get('amountValue')).replace(',','.')); 
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '### penalty -->' + penalty);
                    } 
                    mapConfItemPenalty.put((String)item.get('configurationItemId'), penalty); 
                }
            }
                   
        }
        return mapConfItemPenalty;
    }

    /**
     * @description getOrderSubtypeFromSteps
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param mapSteps
     * @return OrderSubtype or empty string
     **/
    public static String getOrderSubtypeFromSteps(List<XC_Provisioning_Step__c> steps){
        for(XC_Provisioning_Step__c step : steps){
            if(step != null && String.isNotBlank(step.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c))
            return step.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c;
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
     * @description Method to retrieve 3 maps with the configuration items    1) With the configuration items  (of deprovisioining)
*                                                                             2) With the configuration items with ProdName 'Penalty'
*                                                                             3) With the configuration items of the product bundle
     */  
    public static XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps getConfigurationItemsMap(List<String> confListId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '###@2 confListId -->' + confListId);
        Map<Id, NE__OrderItem__c> configurationItemGenericMap = new Map<Id, NE__OrderItem__c>();
        XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps wrapperMaps = new XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps(); 
        if(!confListId.isEmpty()){
            configurationItemGenericMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__OrderItem__c.CurrencyIsoCode, NE__OrderId__c, NE__OneTimeFeeOv__c, NE__BaseOneTimeFee__c, XC_Product_Type__c,
                                                                            NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c, NE__Account__r.Country__c, XC_ZQuoteId__c, NE__AssetItemEnterpriseId__c,
                                                                            NE__RecurringChargeOv__c, NE__ProdName__c, NE__BillingProfId__c, NE__Parent_Order_Item__c, XC_BillingProfileLineItem__r.XC_ZuoraId__c,
                                                                            NE__OrderId__r.XC_Subtype__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c,
                                                                            NE__Bundle_Configuration__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.CreatedDate,
                                                                            XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c, XC_BillingProfileLineItem__r.XC_Status__c,
                                                                            (SELECT Id, XC_DeveloperName__c, NE__Value__c FROM NE__Order_Item_Attributes__r) 
                                                                        FROM NE__OrderItem__c
                                                                        WHERE NE__OrderId__C IN : confListId]);
            //20220118 HotTopic_PROV_40.5 - [DO] – start
            List<Asset> assCurrList = [SELECT Id, XC_Configuration_Item__c FROM Asset WHERE XC_Configuration_Item__c IN :configurationItemGenericMap.keySet()];
            if(!assCurrList.isEmpty()){
                for(Asset assC :assCurrList ){
                    if(String.isNotBlank(assC.XC_Configuration_Item__c) && configurationItemGenericMap.containsKey(assC.XC_Configuration_Item__c)){
                        configurationItemGenericMap.get(assC.XC_Configuration_Item__c).NE__AssetItemEnterpriseId__c = assC.Id;
                    }
                }
            }
            //20220118 HotTopic_PROV_40.5 - [DO] – end
            wrapperMaps.allConfItemMap = configurationItemGenericMap;
        }
        

        XC_UTIL_Debug.debug(DEBUGACTIVE, '###@ configurationItemGenericMap -->' + configurationItemGenericMap);
        for(NE__OrderItem__c confItem : configurationItemGenericMap.values()){

            if(confItem.NE__Parent_Order_Item__c != null && confItem.NE__ProdName__c == Label.XC_CL_Asset_Penalty){
                wrapperMaps.configurationItemPenaltyMap.put(confItem.Id, confItem);
            }
            if(confItem.NE__ProdName__c != Label.XC_CL_Asset_Penalty){
                //20220118 HotTopic_PROV_40.5 - [DO] – start
                if(confItem.NE__Bundle_Configuration__c == null && String.isNotBlank(confItem.XC_Product_Type__c) && confItem.XC_Product_Type__c.equalsIgnoreCase(Label.XC_CL_ProductTypeBundle)){
                //if(confItem.NE__Bundle_Configuration__c == null){
                    //20220118 HotTopic_PROV_40.5 - [DO] – end
                    wrapperMaps.configurationItemBundleMap.put(confItem.Id, confItem);
                } else {
                // if(confItem.NE__Bundle_Configuration__c != null){
                    wrapperMaps.configurationItemMap.put(confItem.Id, confItem);
                }
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
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '### father confItem --->' + confItem.Id );
        List<NE__OrderItem__c> orderItemToUpdateList = new List<NE__OrderItem__c>();
        if(!mapConfItemFatherIdPenaltyItem.isEmpty()){
            for(String itemId : mapConfItemFatherIdPenaltyItem.keyset()){
                NE__OrderItem__c confItemPenalty = mapConfItemFatherIdPenaltyItem.get(itemId);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '### penalty confItem --->' + confItemPenalty.Id ); 
                if(!billingProfileMap.isEmpty() && billingProfileMap.containsKey(itemId)){
                    confItemPenalty.NE__BillingProfId__c = billingProfileMap.get(itemId);
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'NE__BillingProfId__c  -->' + confItemPenalty.NE__BillingProfId__c);
                //if(confItem.NE__OrderId__r.XC_Subtype__c != Label.XC_CL_Rethinking){
                    populateConfItemPenality(mapConfItemPenalty, itemId, confItemPenalty);
               // }
                orderItemToUpdateList.add(confItemPenalty); 
            }

        }  
        return orderItemToUpdateList;
    }

    /**
     * @description Populate ConfItem Penality
     * @param mapConfItemPenalty
     * @param step
     * @param confItemPenalty
    **/
    private static void populateConfItemPenality(Map<String,Decimal> mapConfItemPenalty, String itemId, NE__OrderItem__c confItemPenalty) {
        if(mapConfItemPenalty.containsKey(itemId) && mapConfItemPenalty.get(itemId) != null ){
            Decimal penaltyValue = mapConfItemPenalty.get(itemId);
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
    //private static XC_REST_ZuoraCancelSubscription_U.WrapperResponse callZuoraAndRethinking(Map<String, Object> parametersCallZuora){
    private static XC_REST_Disconnection.WrapperResponse callZuoraAndRethinking(Map<String, Object> parametersCallZuora){
        //XC_REST_ZuoraCancelSubscription_U.WrapperResponse wrResponse = new XC_REST_ZuoraCancelSubscription_U.WrapperResponse();
        XC_REST_Disconnection.WrapperResponse wrResponse = new XC_REST_Disconnection.WrapperResponse();
        wrResponse.reasons = new List<XC_REST_Disconnection.WrapperReason>();
        Map<Id,NE__OrderItem__c> configurationItemMap = (Map<Id,NE__OrderItem__c>) parametersCallZuora.get('configurationItemMap');
        Map<String,String> mapConfItemIdZuoraSubscription = (Map<String,String>) parametersCallZuora.get('mapConfItemIdZuoraSubscription');
        XC_Provisioning_Step__c step = (XC_Provisioning_Step__c) parametersCallZuora.get('step');
        Map<String, Zuora__Subscription__c> zuoraSubscriptionMap = (Map<String, Zuora__Subscription__c>) parametersCallZuora.get('zuoraSubscriptionMap');
        Map<Id, String> mapConfTime = (Map<Id, String>) parametersCallZuora.get('mapConfTime');
        Map<Id, Asset> mapConfItemIdAsset = (Map<Id, Asset>) parametersCallZuora.get('mapConfItemIdAsset');// TO DO Donato

        NE__OrderItem__c confItem = configurationItemMap.get(step.XC_Configuration_Item__c);
        String communicationDate =  String.isNotBlank(mapConfTime.get(confItem.NE__AssetItemEnterpriseId__c))  ? mapConfTime.get(confItem.NE__AssetItemEnterpriseId__c) : String.valueOf(confItem.NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c);
        //String legalEntity = confItem.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
        String legalEntity = (!String.isBlank(confItem.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c)) ? confItem.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c : confItem.NE__OrderId__r.XC_LegalEntity__c;
        String stream = confItem.NE__OrderId__r.XC_Segment__c;
        String subType = confItem.NE__OrderId__r.XC_Subtype__c;
        String subscriptionId = mapConfItemIdZuoraSubscription.get(step.XC_Configuration_Item__c);
        
        String startDateLocal;
        XC_ZuoraZQuoteUtil_U.EntityWrapper entityWr = XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper(legalEntity, stream, '');
        if(entityWr != null && String.isNotBlank(entityWr.timeZone)){
            startDateLocal = DateTime.now().format('yyyy-MM-dd', entityWr.timeZone);
            System.debug('StartDate (local time): ' + startDateLocal);
        } else {
            startDateLocal = String.valueOf(Date.Today());
            System.debug('StartDate (user local time): ' + startDateLocal);
        }


        if(String.isNotBlank(subscriptionId) || String.isNotBlank(mapConfItemIdAsset.get(confItem.id).XC_SubscriptionName__c) /*To Do Donato*/) {
            if(confItem.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_Rethinking){
                XC_REST_Disconnection.QFWrapperRequest wr = new XC_REST_Disconnection.QFWrapperRequest();
                wr.legalEntity = legalEntity;
                wr.stream = stream;

                map<string,Object> r = new map<string,Object>();
                r.put('SubscriptionId__c',String.isNotBlank(subscriptionId) ? subscriptionId : '');// To Do Donato
                r.put('SubscriptionName__c',String.isNotBlank(mapConfItemIdAsset.get(confItem.id).XC_SubscriptionName__c) ? mapConfItemIdAsset.get(confItem.id).XC_SubscriptionName__c : '');// To Do Donato
                r.put('CancellationDate__c',String.isNotBlank(communicationDate) ? communicationDate.split(' ')[0] : startDateLocal);
                r.put('SubType__c',subType); 
                r.put('Source__c','Salesforce');
                r.put('Reference__c',confItem.NE__OrderId__C); //order id o order name 
                r.put('Status__c','Pending'); 
                r.put('FlowName__c','Disconnection');
                wr.records = new List<Map<String,Object>>();
                wr.records.add(r);

                //wrResponse = XC_IN008_DeprovisioningBillingProcess_U.callRethinking(subscriptionId, legalEntity, stream);
                wrResponse = XC_IN008_DeprovisioningBillingProcess_U.callDisconnection(wr);
                
            } else {

                Boolean checkOverrideSubscriptionDateAttribute = false;
                for(NE__Order_Item_Attribute__c oia : confItem.NE__Order_Item_Attributes__r) {
                    if(oia.XC_DeveloperName__c == 'Override Subscription Date' && oia.NE__Value__c == 'Yes') {
                        checkOverrideSubscriptionDateAttribute = true;
                    }
                }
                String currentDateLocal = (checkOverrideSubscriptionDateAttribute && confItem.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c == 'Commodity Bill' && confItem.XC_BillingProfileLineItem__r.XC_Status__c == 'Refused') ? confItem.NE__OrderId__r.CreatedDate.format('yyyy-MM-dd') : (String.isNotBlank(String.valueOf(confItem.NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c)) ? String.valueOf(confItem.NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c) : DateTime.now().format('yyyy-MM-dd'));
                if(!zuoraSubscriptionMap.isEmpty() && zuoraSubscriptionMap.get(subscriptionId) != null ){
                    
                    if(String.valueOf(zuoraSubscriptionMap.get(subscriptionId).Zuora__TermEndDate__c)!=null && currentDateLocal > String.valueOf(zuoraSubscriptionMap.get(subscriptionId).Zuora__TermEndDate__c)){
                        currentDateLocal = String.valueOf(zuoraSubscriptionMap.get(subscriptionId).Zuora__TermEndDate__c);
                    }
                    if(zuoraSubscriptionMap.get(subscriptionId).Zuora__Status__c == 'Suspended'){
                        XC_REST_ResumeSubscription.WrapperRequest wrReqResume = new XC_REST_ResumeSubscription.WrapperRequest();
                        wrReqResume.legalEntity = legalEntity;
                        wrReqResume.stream = stream;
                        wrReqResume.resumePolicy = 'SpecificDate';
                        wrReqResume.resumeSpecificDate = currentDateLocal;
                        XC_REST_ResumeSubscription.WrapperResponse wrRespResume = XC_REST_ResumeSubscription.resumeSubscription(subscriptionId, wrReqResume);
                        if(!wrRespResume.success && !wrRespResume.reasons.isEmpty()){

                            wrResponse.success = wrRespResume.success;
                            for(XC_REST_ResumeSubscription.reasons  wrReason : wrRespResume.reasons){
                                //XC_REST_ZuoraCancelSubscription_U.WrapperReason reason = new XC_REST_ZuoraCancelSubscription_U.WrapperReason();
                                XC_REST_Disconnection.WrapperReason reason = new XC_REST_Disconnection.WrapperReason();
                                reason.code = wrReason.code;
                                reason.message = wrReason.message;
                                wrResponse.reasons.add(reason);
                            }
                            //20220113 Hot Topics | PROV_31 - start
                            String errorCodeResume = XC_CS_UtilityGlobalValues__c.getInstance('XC_IN008_Resume_SuspendDate_TxtToRem')!= null ? XC_CS_UtilityGlobalValues__c.getInstance('XC_IN008_Resume_SuspendDate_TxtToRem').Value__c :'';
                            String textErrorToRemove = XC_CS_UtilityGlobalValues__c.getInstance('XC_IN008_Resume_SuspendDate_TxtToRem')!= null ? XC_CS_UtilityGlobalValues__c.getInstance('XC_IN008_Resume_SuspendDate_TxtToRem').Value__c : '';
                            if(wrRespResume.reasons != null && wrRespResume.reasons.size() == 1 && String.isNotBlank(errorCodeResume) && String.isNotBlank(textErrorToRemove) && wrRespResume.reasons[0].message.containsIgnoreCase(errorCodeResume)){
                                String newResumeDate = wrRespResume.reasons[0].message.right(12).removeEndIgnoreCase(textErrorToRemove);
                                Date newResumeDateValue = Date.parse(newResumeDate);
								String newResumeDateString = String.valueOf(newResumeDateValue);
                                wrReqResume.legalEntity = legalEntity;
                                wrReqResume.stream = stream;
                                wrReqResume.resumePolicy = 'SpecificDate';
                                wrReqResume.resumeSpecificDate = newResumeDateString;     
                                XC_REST_ResumeSubscription.WrapperResponse wrRespResumeRetry = XC_REST_ResumeSubscription.resumeSubscription(subscriptionId, wrReqResume);
                                if(!wrRespResumeRetry.success && !wrRespResumeRetry.reasons.isEmpty()){
                                    wrResponse.reasons = new List<XC_REST_Disconnection.WrapperReason>();
                                    wrResponse.success = wrRespResumeRetry.success;
                                    for(XC_REST_ResumeSubscription.reasons  wrReason : wrRespResumeRetry.reasons){
                                        XC_REST_Disconnection.WrapperReason reason = new XC_REST_Disconnection.WrapperReason();
                                        reason.code = wrReason.code;
                                        reason.message = wrReason.message;
                                        wrResponse.reasons.add(reason);
                                    }
                                    
                                    wrReqResume.legalEntity = legalEntity;
                                    wrReqResume.stream = stream;
                                    XC_IN008_DeprovisioningBillingProcess_U.insertIntegrationLog(wrReqResume, subscriptionId, wrRespResumeRetry);
                                    
                                    return wrResponse;
                                }else {
                                    subscriptionId = wrRespResumeRetry.subscriptionId;
                                }
                            }else{
                                //20220113 Hot Topics | PROV_31 - end
                                wrReqResume.legalEntity = legalEntity;
                                wrReqResume.stream = stream;
                                //Map<String,Object> mapUtil = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(wrRespResume));
                                //wrResponse.reasons = (List<XC_REST_ZuoraCancelSubscription_U.WrapperReason>) mapUtil.get('reasons');
                                XC_IN008_DeprovisioningBillingProcess_U.insertIntegrationLog(wrReqResume, subscriptionId, wrRespResume);
                                
                                return wrResponse;
                            }//20220113 Hot Topics | PROV_31
                        }else {
                            subscriptionId = wrRespResume.subscriptionId;
                        }
                    }    
                }

                //XC_REST_ZuoraCancelSubscription_U.WrapperRequest wr =  new XC_REST_ZuoraCancelSubscription_U.WrapperRequest();

                XC_REST_Disconnection.QFWrapperRequest wr = new XC_REST_Disconnection.QFWrapperRequest();
                wr.legalEntity = legalEntity;
                wr.stream = stream;
                
                map<string,Object> r = new map<string,Object>();
                r.put('SubscriptionId__c',String.isNotBlank(subscriptionId) ? subscriptionId : '');// To Do Donato
                r.put('SubscriptionName__c',String.isNotBlank(mapConfItemIdAsset.get(confItem.id).XC_SubscriptionName__c) ? mapConfItemIdAsset.get(confItem.id).XC_SubscriptionName__c : '');// To Do Donato
                r.put('CancellationDate__c',currentDateLocal);
                r.put('SubType__c', confItem.NE__OrderId__r.XC_Subtype__c);
                r.put('Source__c','Salesforce');
                r.put('Reference__c',confItem.NE__OrderId__C); //order id o order name 
                r.put('Status__c','Pending'); 
                r.put('FlowName__c','Disconnection');
                wr.records = new List<Map<String,Object>>();
                wr.records.add(r);

                wrResponse = XC_REST_Disconnection.manageDisconnection(wr);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '### Not Rethinking wrResponse 008--->' + wrResponse);
            }

        } else {
            wrResponse.success = false;
            //wrResponse.reasons = new List<XC_REST_Disconnection.WrapperReason>();
            XC_REST_Disconnection.WrapperReason wrReason = new XC_REST_Disconnection.WrapperReason();
            wrReason.message = Label.XC_CL_Disconnection_NoSubscription;
            wrResponse.reasons.add(wrReason);
        }

        return wrResponse;
    }
}