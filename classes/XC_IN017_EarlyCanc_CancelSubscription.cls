/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com 
* @date Creation 20/03/2019
* @date Modification dd/mm/yyyy
* @description  – 
*/ 

public without sharing class XC_IN017_EarlyCanc_CancelSubscription {

    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN017_EarlyCanc_CancelSubscription');
    
    /**
     *@description UtilWrapper
     */
    private class UtilWrapper {
        List<InputWrapper> inputWrapperList = new List<InputWrapper>();
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>();
        Map<Id,NE__OrderItem__c> configurationItemMap = new Map<Id,NE__OrderItem__c>();
        Map<String,String> mapConfItemIdZuoraSubscription = new Map<String,String>();
        public Map<Id,String> mapConfItemZQuote = new Map<Id,String>();
    }

    /**
     * The Class WrapperConfItemsMaps.
     *@description WrapperConfItemsMaps
     */
    public class WrapperConfItemsMaps{
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> configurationItemPenaltyMap = new Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> configurationItemBundleMap = new Map<Id, NE__OrderItem__c>();     
    }

    /**
     * The Class WrapperQuoteBillingProfile.
     *@description WrapperConfItemsMaps
     */
    public class WrapperQuoteBillingProfile {
        Map<Id, zqu__Quote__c> quoteMap = new Map<Id, zqu__Quote__c>();
        Map<Id, String> billingProfileMap = new Map<Id, String>();
        public Map<Id,String> mapConfItemZQuote = new Map<Id,String>();
    }

    /**
     * @description Method to Update provisioning steps and configuration item.
     */ 
    public class InputWrapper{ 
        @Invocablevariable     
        public String stepId;       
    } 

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description method to do logic of cancel Subscription    
     * @param inputWrapperList the list coming from flow
     */
    @InvocableMethod 
    public static void cancelSubscription(List<InputWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN017_EarlyCanc_CancelSubscription');
        
        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            List<String> listStepIds = new List<String>();
            List<String> confItemListId = new List<String>();
            List<String> bundleItemListId = new List<String>();
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }
            WrapperConfItemsMaps wrappConfItem = new WrapperConfItemsMaps();
            Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT ID, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.XC_ZQuoteId__c,
                        XC_Configuration_Item__r.NE__Bundle_Configuration__c
                 FROM XC_Provisioning_Step__c 
                 WHERE Id IN: listStepIds]); 

            for(Id stepId : mapSteps.keySet()){
                confItemListId.add(mapSteps.get(stepId).XC_Configuration_Item__c);
                bundleItemListId.add(mapSteps.get(stepId).XC_Configuration_Item__r.NE__Bundle_Configuration__c);
            }
            wrappConfItem = getConfigurationItemsMap(confItemListId, bundleItemListId);
            Map<Id,NE__OrderItem__c> configurationItemMap = wrappConfItem.configurationItemMap;  
            Map<Id,String> mapConfItemAssetId = new Map<Id,String>();
            Map<Id,String> mapConfItemAssetOfBundleId = new Map<Id,String>();
            //Map<Id,String> mapConfItemQuoteId = new Map<Id,String>();
            Map<String,String> mapConfItemIdZuoraSubscription = new Map<String,String>();

            //Create two maps map<Asset Id,Configuration Item Id> and map<Zquote Id, Configuration Item Id>
            String configurationItemId = '';  //CONFIGURATION ITEM OF THE ACTUAL ITEM CONNECTED TO THE PROVISIOINING STEP
            String assetId = '';
            for(NE__OrderItem__c confItem : configurationItemMap.values()){
                configurationItemId = confItem.Id;
                // assetId = confItem.NE__AssetItemEnterpriseId__c; ASSET OF THE PRODUCT
                mapConfItemAssetId.put(confItem.NE__AssetItemEnterpriseId__c, confItem.Id); //Map with Asset Id and ConfItem Id
            }          

            WrapperQuoteBillingProfile wrQuoteBilling= getZuoraQuoteMap(mapConfItemAssetId);
            Map<Id, zqu__Quote__c> mapZuoraQuote = wrQuoteBilling.quoteMap;
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapZuoraQuote  --->' + mapZuoraQuote);
            Map<Id, String> billingProfileMap = wrQuoteBilling.billingProfileMap;
                       
            for(zqu__Quote__c quote : mapZuoraQuote.values()){
                if(String.isNotBlank(quote.XC_LastSubscriptionId__c)) {
                    mapConfItemIdZuoraSubscription.put(configurationItemId, quote.XC_LastSubscriptionId__c);   // Take the zQuote lookup from the provisioning item      
                } else {
                    mapConfItemIdZuoraSubscription.put(configurationItemId, quote.zqu__ZuoraSubscriptionID__c);   // Take the zQuote lookup from the provisioning item      
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'MAP <CONF ITEM - SUBSCRIPTION ID VALUE> -->' + mapConfItemIdZuoraSubscription);
            UtilWrapper utilWr = new UtilWrapper();
            utilWr.inputWrapperList = inputWrapperList;
            utilWr.mapSteps = mapSteps;
            utilWr.configurationItemMap = configurationItemMap;
            utilWr.mapConfItemIdZuoraSubscription = mapConfItemIdZuoraSubscription;
            utilWr.mapConfItemZQuote = wrQuoteBilling.mapConfItemZQuote;
            doActions(utilWr);
        }  
    }

    private static void doActions(UtilWrapper utilWr){
        List<InputWrapper> inputWrapperList = utilWr.inputWrapperList;
        Map<Id, XC_Provisioning_Step__c> mapSteps = utilWr.mapSteps;
        Map<Id,NE__OrderItem__c> configurationItemMap = utilWr.configurationItemMap;
        Map<String,String> mapConfItemIdZuoraSubscription = utilWr.mapConfItemIdZuoraSubscription;
        Map<Id,String> mapConfItemZQuote = utilWr.mapConfItemZQuote;
        
        List<XC_Provisioning_Step__c> provisioningStepsToComplete =  new List<XC_Provisioning_Step__c>();
        //List<XC_REST_ZuoraCancelSubscription_U.WrapperResponse> wrList = new List<XC_REST_ZuoraCancelSubscription_U.WrapperResponse>();
        List<XC_REST_Disconnection.WrapperResponse> wrList = new List<XC_REST_Disconnection.WrapperResponse>();
        
        List<zqu__Quote__c> zquoteToUpdate = new List<zqu__Quote__c>();
        for(InputWrapper inputWr : inputWrapperList){
            XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);
            NE__OrderItem__c confItem = configurationItemMap.get(step.XC_Configuration_Item__c);
            String legalEntity = confItem.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
            String stream = confItem.NE__OrderId__r.XC_Segment__c;
            String startDateLocal;
            XC_ZuoraZQuoteUtil_U.EntityWrapper entityWr = XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper(legalEntity, stream, '');
            if(entityWr != null && String.isNotBlank(entityWr.timeZone)){
                startDateLocal = DateTime.now().format('yyyy-MM-dd', entityWr.timeZone);
                System.debug('StartDate (local time): ' + startDateLocal);
            } else {
                startDateLocal = String.valueOf(Date.Today());
                System.debug('StartDate (user local time): ' + startDateLocal);
            }
            
            // 1) Call the Zuora method XC_REST_ZuoraCancelSubscription.cancelSubscription(subscriptionId, wr)          
            //XC_REST_ZuoraCancelSubscription_U.WrapperRequest wr =  new XC_REST_ZuoraCancelSubscription_U.WrapperRequest();
            XC_REST_Disconnection.WrapperRequest wr =  new XC_REST_Disconnection.WrapperRequest();
            //wr.cancellationEffectiveDate = startDateLocal;
            wr.cancellationDate = startDateLocal;
            //wr.cancellationPolicy = 'SpecificDate';
            wr.legalEntity = legalEntity;
            wr.stream = stream;
            wr.subType = confItem.NE__OrderId__r.XC_Subtype__c;
            String subscriptionId = mapConfItemIdZuoraSubscription.get(step.XC_Configuration_Item__c);
            wr.subscriptionId = subscriptionId;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### EffectiveDate' + wr.cancellationDate);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### subscriptionId' + subscriptionId);
           // XC_REST_ZuoraCancelSubscription_U.WrapperResponse response = new XC_REST_ZuoraCancelSubscription_U.WrapperResponse ();
            XC_REST_Disconnection.WrapperResponse response = new XC_REST_Disconnection.WrapperResponse ();

            if(!String.isBlank(subscriptionId)){
                //response = XC_REST_ZuoraCancelSubscription.cancelSubscription(subscriptionId, wr);
                response = XC_REST_Disconnection.manageDisconnection(wr);
               
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### wrResponse 008--->' + response);
            wrList.add(response);

            // 2) Set the provisioning step in Completed Ok
            if(!response.success && !response.reasons.isEmpty()) {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = response.reasons[0].message;
            } else {
                step.XC_Status__c = Label.XC_CL_Completed_Ok;

                zqu__Quote__c zquote = new zqu__Quote__c(Id = mapConfItemZQuote.get(confItem.Id),
                                                        XC_LastSubscriptionId__c = response.subscriptionId);
                zquoteToUpdate.add(zquote);
            }   

            provisioningStepsToComplete.add(step); 
        }

        if(!provisioningStepsToComplete.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> listDMLResultOnStep = XC_UTIL_Sobject.updateListRecords(provisioningStepsToComplete);
        }

        if(!zquoteToUpdate.isEmpty()) {
            List<XC_UTIL_Sobject.WrapperResult> zquoteResult = XC_UTIL_Sobject.updateListRecords(zquoteToUpdate);     
        }
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
    private static WrapperConfItemsMaps getConfigurationItemsMap(List<String> confItemListId,List<String> bundleItemListId){
        Map<Id, NE__OrderItem__c> configurationItemGenericMap = new Map<Id, NE__OrderItem__c>();
        WrapperConfItemsMaps wrapperMaps = new WrapperConfItemsMaps(); 
        if(!confItemListId.isEmpty()){
            configurationItemGenericMap = new Map<Id, NE__OrderItem__c>([
                SELECT Id, NE__OrderItem__c.CurrencyIsoCode, NE__OneTimeFeeOv__c,NE__BaseOneTimeFee__c, NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c,
                        XC_ZQuoteId__c, NE__AssetItemEnterpriseId__c, NE__RecurringChargeOv__c, NE__ProdName__c, NE__BillingProfId__c, NE__Parent_Order_Item__c,
                        NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Segment__c,NE__OrderId__r.XC_Subtype__c
                FROM NE__OrderItem__c
                WHERE (Id IN: confItemListId) 
                        OR (NE__Parent_Order_Item__c IN: confItemListId AND NE__ProdName__c =: Label.XC_CL_Asset_Penalty) 
                        OR (Id IN: bundleItemListId)]);
        }
        
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
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param mapConfItemAssetId the map conf item asset id
     * @return the zuora quote map
     * @description Method to retrieve a map with info about the zQuote.
     */ 
    private static WrapperQuoteBillingProfile getZuoraQuoteMap(Map<Id,String> mapConfItemAssetId){
        WrapperQuoteBillingProfile wrQuoteBilling = new WrapperQuoteBillingProfile();
        Map<Id,String> mapConfItemZQuote = new Map<Id,String>();
        Map<Id,String> mapConfItemBillingProfile = new Map<Id,String>();
        Map<Id, Asset> assetMap = getFieldsFromAsset(mapConfItemAssetId);

        for(Id assetId : assetMap.keyset()){       
            XC_UTIL_Debug.debug(DEBUGACTIVE, ' mapConfItemAssetId.get(assetId) --->' + mapConfItemAssetId.get(assetId));
            XC_UTIL_Debug.debug(DEBUGACTIVE, ' assetMap.get(assetId).XC_ZQuoteId__c --->' + assetMap.get(assetId).XC_ZQuoteId__c);
            //mapConfItemZQuote.put(mapConfItemAssetId.get(assetId),assetMap.get(assetId).XC_ZQuoteId__c);
            mapConfItemZQuote.put(mapConfItemAssetId.get(assetId),assetMap.get(assetId).XC_Original_Configuration_Item__r.XC_ZQuoteId__c);
            mapConfItemBillingProfile.put(mapConfItemAssetId.get(assetId), assetMap.get(assetId).XC_OriginalBillingProfile__c);
        }
        Map<Id, zqu__Quote__c> mapZuoraQuote = new Map<Id, zqu__Quote__c>([
                                                                            SELECT Id, zqu__ZuoraSubscriptionID__c, XC_LastSubscriptionId__c
                                                                            FROM zqu__Quote__c
                                                                            WHERE Id IN: mapConfItemZQuote.values()
                                                                            ]);                                                      
        wrQuoteBilling.quoteMap = mapZuoraQuote;
        wrQuoteBilling.billingProfileMap = mapConfItemBillingProfile;
        wrQuoteBilling.mapConfItemZQuote = mapConfItemZQuote;
        return wrQuoteBilling;
    }

    /**
     * Gets the fields from asset.
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param mapConfItemAssetId the map conf item asset id
     * @return the fields from asset
     * @description Method to retrieve a map with info about the Asset.
     */ 
    private static Map<Id, Asset> getFieldsFromAsset(Map<Id,String> mapConfItemAssetId){
        if(!Schema.sObjectType.Asset.isAccessible()){
            return new Map<Id, Asset>();
        }
        Map<Id, Asset> assetMap = new Map<Id, Asset> ([
                                                        SELECT Id, XC_ZQuoteId__c, XC_OriginalBillingProfile__c, XC_Original_Configuration_Item__r.XC_ZQuoteId__c 
                                                        FROM Asset 
                                                        WHERE Id IN: mapConfItemAssetId.keyset()
                                                        ]);
        return assetMap;
    }
}