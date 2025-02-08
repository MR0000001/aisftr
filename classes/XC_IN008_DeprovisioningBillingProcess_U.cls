/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com 
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description  – Util class of XC_IN008_DeprovisioningBillingProcess
*/ 
public without sharing class XC_IN008_DeprovisioningBillingProcess_U {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN008_DeprovisioningBillingProcess');

    /**
     * The Class WrapperConfItemsMaps.
     * @description WrapperConfItemsMaps 
     */
    public class WrapperConfItemsMaps{    
        public Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>();
        public Map<Id, NE__OrderItem__c> configurationItemPenaltyMap = new Map<Id, NE__OrderItem__c>();
        public Map<Id, NE__OrderItem__c> configurationItemBundleMap = new Map<Id, NE__OrderItem__c>();
        public Map<Id, NE__OrderItem__c> allConfItemMap = new Map<Id, NE__OrderItem__c>();     
    }

    /**
     * The Class WrapperQuoteBillingProfile.
     * @description WrapperQuoteBillingProfile
     */
    public class WrapperQuoteBillingProfile {
        public Map<Id, zqu__Quote__c> quoteMap = new Map<Id, zqu__Quote__c>();
        public Map<Id, String> billingProfileMap = new Map<Id, String>();
        public Map<Id,String> mapConfItemZQuote = new Map<Id,String>();
        public Map<String, Zuora__Subscription__c> zuoraSubscriptionMap = new Map<String, Zuora__Subscription__c>();
        public Map<Id, Asset> mapConfItemIdAsset = new Map<Id, Asset>();
    }

    /**
     * The Class UtilWrapper.
     * @description UtilWrapper
     */
    public class UtilWrapper {
        public Map<Id,NE__OrderItem__c> mapConfItemFatherIdPenaltyItem = new Map<Id,NE__OrderItem__c>();
        public Map<Id, String> billingProfileMap = new Map<Id, String>();
        public Map<String,Decimal>  mapConfItemPenalty = new Map<String,Decimal>();
        public Map<Id,NE__OrderItem__c> configurationItemMap = new Map<Id,NE__OrderItem__c>();
        public XC_Provisioning_Step__c step;
    }

    /**
     * The Class ListsWrapper.
     * @description ListsWrapper
     */
    public class ListsWrapper{
        public List<String> confItemListId = new List<String>();
        public List<String> bundleItemListId = new List<String>();
        public List<String> confListId = new List<String>();
        public Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>();
    }


    /**
     * Gets the zuora quote map.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param mapConfItemAssetId the map conf item asset id
     * @return the zuora quote map
     * @description Method to retrieve a map with info about the zQuote.
     */ 
    public static WrapperQuoteBillingProfile getZuoraQuoteMap(Map<Id,String> mapConfItemAssetId){
        WrapperQuoteBillingProfile wrQuoteBilling = new WrapperQuoteBillingProfile();
        Map<Id,String> mapConfItemZQuote = new Map<Id,String>();
        Map<Id,String> mapConfItemBillingProfile = new Map<Id,String>();
        Map<Id, Asset> assetMap = getFieldsFromAsset(mapConfItemAssetId);
        Map<Id, Asset> mapConfItemIdAsset = new Map<Id, Asset>();   
        String subNumber = '';

        Map<String, Zuora__Subscription__c> zuoraSubscriptionMap = new Map<String, Zuora__Subscription__c>();

        for(Id assetId : assetMap.keyset()){       
            XC_UTIL_Debug.debug(DEBUGACTIVE, ' mapConfItemAssetId.get(assetId) --->' + mapConfItemAssetId.get(assetId));
            XC_UTIL_Debug.debug(DEBUGACTIVE, ' assetMap.get(assetId).XC_ZQuoteId__c --->' + assetMap.get(assetId).XC_ZQuoteId__c);

            mapConfItemIdAsset.put(assetMap.get(assetId).XC_Configuration_Item__c, assetMap.get(assetId));

            if(String.isNotBlank(assetMap.get(assetId).XC_Subscription__c)) {
                zuoraSubscriptionMap.put(assetMap.get(assetId).XC_Subscription__r.Zuora__External_Id__c, new Zuora__Subscription__c(Id = assetMap.get(assetId).XC_Subscription__c, Zuora__External_Id__c = assetMap.get(assetId).XC_Subscription__r.Zuora__External_Id__c, Zuora__TermEndDate__c = assetMap.get(assetId).XC_Subscription__r.Zuora__TermEndDate__c,  Zuora__Status__c = assetMap.get(assetId).XC_Subscription__r.Zuora__Status__c));

            } else if(String.isNotBlank(assetMap.get(assetId).XC_Original_Configuration_Item__r.XC_ZQuoteId__c)) {
                mapConfItemZQuote.put(mapConfItemAssetId.get(assetId),assetMap.get(assetId).XC_Original_Configuration_Item__r.XC_ZQuoteId__c);

            }
            
            if(String.isNotBlank(assetMap.get(assetId).XC_SubscriptionName__c)) {
                subNumber = assetMap.get(assetId).XC_SubscriptionName__c;
            }

            mapConfItemBillingProfile.put(mapConfItemAssetId.get(assetId), assetMap.get(assetId).XC_OriginalBillingProfile__c);
        }

        Map<Id, zqu__Quote__c> mapZuoraQuote = new Map<Id, zqu__Quote__c>();
        if(zuoraSubscriptionMap == null || zuoraSubscriptionMap.isEmpty()) {
            if(!mapConfItemZQuote.isEmpty()) {
                mapZuoraQuote = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__ZuoraSubscriptionID__c, XC_LastSubscriptionId__c, zqu__Status__c 
                                                                FROM zqu__Quote__c
                                                                WHERE Id IN: mapConfItemZQuote.values() AND zqu__Status__c != 'New'
                                                                ]);

                if(mapZuoraQuote.isEmpty() && String.isNotBlank(subNumber)) {
                    Map<Id, Zuora__Subscription__c> zuoraSubMap = new  Map<Id, Zuora__Subscription__c>([SELECT Zuora__Status__c, Zuora__External_Id__c, Zuora__TermEndDate__c
                                                                                                    FROM Zuora__Subscription__c
                                                                                                    WHERE Zuora__SubscriptionNumber__c =: subNumber LIMIT 1]);
                    for(Zuora__Subscription__c sub : zuoraSubMap.values()){
                        zuoraSubscriptionMap.put(sub.Zuora__External_Id__c, sub);
                    }
                }

            } else if(String.isNotBlank(subNumber)) {    // For Migration
                Map<Id, Zuora__Subscription__c> zuoraSubMap = new  Map<Id, Zuora__Subscription__c>([SELECT Zuora__Status__c, Zuora__External_Id__c, Zuora__TermEndDate__c
                                                                                                    FROM Zuora__Subscription__c
                                                                                                    WHERE Zuora__SubscriptionNumber__c =: subNumber LIMIT 1]);
                for(Zuora__Subscription__c sub : zuoraSubMap.values()){
                    zuoraSubscriptionMap.put(sub.Zuora__External_Id__c, sub);
                }
            }
        }

        wrQuoteBilling.quoteMap = mapZuoraQuote;
        wrQuoteBilling.zuoraSubscriptionMap = zuoraSubscriptionMap;
        wrQuoteBilling.billingProfileMap = mapConfItemBillingProfile;
        wrQuoteBilling.mapConfItemZQuote = mapConfItemZQuote;
        wrQuoteBilling.mapConfItemIdAsset = mapConfItemIdAsset;
        return wrQuoteBilling;
    }


    /**
     * Gets the fields from asset.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param mapConfItemAssetId the map conf item asset id
     * @return the fields from asset
     * @description Method to retrieve a map with info about the Asset.
     */ 
    public static Map<Id, Asset> getFieldsFromAsset(Map<Id,String> mapConfItemAssetId){
        Map<Id, Asset> assetMap = new Map<Id, Asset> ([
                                                        SELECT Id, XC_ZQuoteId__c, XC_OriginalBillingProfile__c, XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_SubscriptionName__c,
                                                        XC_External_ID__c, XC_Configuration_Item__c, XC_Subscription__c, XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__TermEndDate__c, XC_Subscription__r.Zuora__Status__c 
                                                        FROM Asset 
                                                        WHERE Id IN: mapConfItemAssetId.keyset()
                                                        ]);
        return assetMap;
    }


    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param wrList
     * @param provisioningStepsToUpdate provisioning Steps To Update
     * @param orderItemsToUpdate order Items To Update
     * @description Method to update the configuration item and the provisioning step.
     */ 
    public static void updateProvisioningStepsAndConfigurationItem(List<XC_REST_Disconnection.WrapperResponse> wrList, List<XC_Provisioning_Step__c> provisioningStepsToUpdate, List<NE__OrderItem__c> orderItemsToUpdate){

    if(!wrList.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> listDMLResultOnStep = XC_UTIL_Sobject.updateListRecords(provisioningStepsToUpdate);
            if(listDMLResultOnStep[0].success){
                List<XC_UTIL_Sobject.WrapperResult> listDMLResultOnItems = XC_UTIL_Sobject.updateListRecords(orderItemsToUpdate);
            }
        }   
    }


    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param wrList
     * @param provisioningStepsToUpdate provisioning Steps To Update
     * @param orderItemsToUpdate order Items To Update
     * @description Method to update the configuration item and the provisioning step.
     */ 

    public static void updateProvisioningStepsAndConfigurationItem(List<XC_REST_ZuoraCancelSubscription_U.WrapperResponse> wrList, List<XC_Provisioning_Step__c> provisioningStepsToUpdate, List<NE__OrderItem__c> orderItemsToUpdate){

        if(!wrList.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> listDMLResultOnStep = XC_UTIL_Sobject.updateListRecords(provisioningStepsToUpdate);
            if(listDMLResultOnStep[0].success){
                List<XC_UTIL_Sobject.WrapperResult> listDMLResultOnItems = XC_UTIL_Sobject.updateListRecords(orderItemsToUpdate);
            }
        }   
    }


    /**
     * @description call Rethinking.
     * @param subscriptionId the subscription Id
     * @param legalEntity the legal Entity
     * @return wrResponse
     **/
    public static XC_REST_ZuoraCancelSubscription_U.WrapperResponse callRethinking(String subscriptionId, String legalEntity, String stream){

        XC_REST_ZuoraCancelSubscription_U.WrapperResponse wrResponse = new XC_REST_ZuoraCancelSubscription_U.WrapperResponse();
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### Rethinking - legalEntity--->' + legalEntity);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### Rethinking - subscriptionId--->' + subscriptionId);

        XC_REST_Rethinking.WrapperResponse response = XC_REST_Rethinking.manageRethinking(subscriptionId, legalEntity, stream);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### Rethinking - wrResponse 008--->' + response);
        if(response.errors == null){
            wrResponse.success = true;

        } else if(!response.errors.isEmpty()) {
            wrResponse.success = false; 
            wrResponse.reasons = new List<XC_REST_ZuoraCancelSubscription_U.WrapperReason>();
            XC_REST_ZuoraCancelSubscription_U.WrapperReason reason = new XC_REST_ZuoraCancelSubscription_U.WrapperReason();
            reason.message = response.errors[0].title;
            wrResponse.reasons.add(reason);
        }

        return wrResponse;
    }


    public static XC_REST_Disconnection.WrapperResponse callDisconnection(XC_REST_Disconnection.WrapperRequest wrapperDisconnection){
        XC_REST_Disconnection.WrapperResponse wrResponse = new  XC_REST_Disconnection.WrapperResponse();
        wrResponse.reasons = new List<XC_REST_Disconnection.WrapperReason>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### Disconnection - wrapper--->' + wrapperDisconnection);
        XC_REST_Disconnection.WrapperResponse response = XC_REST_Disconnection.manageDisconnection(wrapperDisconnection);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### Disconnection - wrResponse 008--->' + response);
        
        if(response.reasons == null){
            wrResponse.success = true;
        } else if(!response.reasons.isEmpty()) {
            wrResponse.success = false;
            //wrResponse.reasons = new List<XC_REST_Disconnection.WrapperReason>();
            XC_REST_Disconnection.WrapperReason reason = new XC_REST_Disconnection.WrapperReason();
            reason.message = response.reasons[0].message;
            wrResponse.reasons.add(reason);
        }

        return wrResponse;

    }


    public static XC_REST_Disconnection.WrapperResponse callDisconnection(XC_REST_Disconnection.QFWrapperRequest wrapperDisconnection){
        XC_REST_Disconnection.WrapperResponse wrResponse = new  XC_REST_Disconnection.WrapperResponse();
        wrResponse.reasons = new List<XC_REST_Disconnection.WrapperReason>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### Disconnection - wrapper--->' + wrapperDisconnection);
        XC_REST_Disconnection.WrapperResponse response = XC_REST_Disconnection.manageDisconnection(wrapperDisconnection);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### Disconnection - wrResponse 008--->' + response);
        
        if(response.reasons == null){
            wrResponse.success = true;
        } else if(!response.reasons.isEmpty()) {
            wrResponse.success = false;
            //wrResponse.reasons = new List<XC_REST_Disconnection.WrapperReason>();
            XC_REST_Disconnection.WrapperReason reason = new XC_REST_Disconnection.WrapperReason();
            reason.message = response.reasons[0].message;
            wrResponse.reasons.add(reason);
        }

        return wrResponse;

    }


    /**
     * @description set Step Status.
     * @param wrResponse the wrapper response
     * @param step the step
     **/
    public static void setStepStatus(Map<String, Object> parameters, XC_Provisioning_Step__c step, List<zqu__Quote__c> zquoteToUpdate) {

        //XC_REST_ZuoraCancelSubscription_U.WrapperResponse wrResponse = (XC_REST_ZuoraCancelSubscription_U.WrapperResponse) parameters.get('wrResponse');
        XC_REST_Disconnection.WrapperResponse wrResponse = (XC_REST_Disconnection.WrapperResponse) parameters.get('wrResponse');
        System.debug('wrResponse ha val: '+ wrResponse);
        System.debug('reasons ha val: '+ wrResponse.reasons);
        System.debug('success ha val: '+ wrResponse.success);
        Map<Id, String> mapConfItemZQuote = (Map<Id, String>) parameters.get('mapConfItemZQuote');

        if(!wrResponse.success && wrResponse.reasons !=null && !wrResponse.reasons.isEmpty()) {
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = wrResponse.reasons[0].message;
        } else {
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
            
            if(String.isNotBlank(mapConfItemZQuote.get(step.XC_Configuration_Item__c))) {
                zqu__Quote__c zquote = new zqu__Quote__c(Id = mapConfItemZQuote.get(step.XC_Configuration_Item__c),
                                                            XC_LastSubscriptionId__c = wrResponse.subscriptionId);
                zquoteToUpdate.add(zquote);
            }
        }
    }


    /**
     * @description set Step Status.
     * @param wrResponse the wrapper response
     * @param step the step
     **/
    public static void setStepStatusB2B(Map<String, Object> parameters, XC_Provisioning_Step__c step, List<zqu__Quote__c> zquoteToUpdate) {

        XC_REST_ZuoraCancelSubscription_U.WrapperResponse wrResponse = (XC_REST_ZuoraCancelSubscription_U.WrapperResponse) parameters.get('wrResponse');
        System.debug('wrResponse ha val: '+ wrResponse);
        System.debug('reasons ha val: '+ wrResponse.reasons);
        System.debug('success ha val: '+ wrResponse.success);
        Map<Id, String> mapConfItemZQuote = (Map<Id, String>) parameters.get('mapConfItemZQuote');

        if(!wrResponse.success && wrResponse.reasons !=null && !wrResponse.reasons.isEmpty()) {
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = wrResponse.reasons[0].message;
        } else {
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
            
            if(String.isNotBlank(mapConfItemZQuote.get(step.XC_Configuration_Item__c))) {
                zqu__Quote__c zquote = new zqu__Quote__c(Id = mapConfItemZQuote.get(step.XC_Configuration_Item__c),
                                                            XC_LastSubscriptionId__c = wrResponse.subscriptionId);
                zquoteToUpdate.add(zquote);
            }
        }
    }


    /**
     * @description get subscription infos
     * @param subscriptionIdList the subscription id list 
     * @return Map<String, Zuora__Subscription__c> map with zuoraSubscriptionId as key and Subscription as value
     **/
    public static Map<String, Zuora__Subscription__c> getSubscriptionInfos(List<String> subscriptionIdList){
        if(!subscriptionIdList.isEmpty()){

             Map<String, Zuora__Subscription__c>zuoraSubscriptionMap = new  Map<String, Zuora__Subscription__c>();
            Map<Id, Zuora__Subscription__c> zuoraSubMap = new  Map<Id, Zuora__Subscription__c>([SELECT Zuora__Status__c, Zuora__External_Id__c, Zuora__TermEndDate__c FROM Zuora__Subscription__c  WHERE Zuora__External_Id__c IN: subscriptionIdList]);
            
            for(Zuora__Subscription__c sub : zuoraSubMap.values()){
                zuoraSubscriptionMap.put(sub.Zuora__External_Id__c, sub);
            }

            return zuoraSubscriptionMap;
        }else {
            return new  Map<String, Zuora__Subscription__c>();
        }
         
    }


    /**
     * @description insert integration log 
     * @param wrReqResume the wrapper request 
     * @param subscriptionId the subscription id
     * @param wrRespResume the wrapper response
     **/
    public static void insertIntegrationLog(XC_REST_ResumeSubscription.WrapperRequest wrReqResume, String subscriptionId, XC_REST_ResumeSubscription.WrapperResponse wrRespResume){

        String logError = '';
        String body =  JSON.serialize(wrReqResume, true);
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_ResumeSubscription);
        //String url = isActiveInterface.url.replace('subscriptionId', subscriptionId);
        String url = isActiveInterface.url + '/v1/subscriptions/' + subscriptionId + '/resume';

        String legalEntity = wrReqResume.legalEntity;
        String stream = wrReqResume.stream;
        String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
        ZuoraWebService zws = new ZuoraWebService(entityName);

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        headerDefinitions.put('Authorization', 'Bearer ' + zws.token);
        headerDefinitions.put('Zuora-Entity-Ids', zws.entityId);

        if(wrReqResume.invoice != null || wrReqResume.collectX != null) {
            headerDefinitions.put('zuora-version', '196.0');
        } else if (wrReqResume.runBilling != null || !String.isBlank(wrReqResume.targetDate)) {
            headerDefinitions.put('zuora-version', '211.0');
        }

        HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);

        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();  
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        
        logWrapper.logTransactionID = headerDefinitions.get('TransactionID');
        logWrapper.logIntegrationName = 'ResumeSubscription';
        logWrapper.logEndpoint = request.getEndpoint(); 
        logWrapper.httpMethod = request.getMethod();
        logWrapper.logMessage = (request.getBody().length()>131072) ? request.getBody().substring(0, 131072) : request.getBody();
        

        intLog.setHeader(headerDefinitions);
        intLog.insertIntegReqOutboundLog(logWrapper);
        intLog.insertIntegRespOutboundLog(false, JSON.serialize(wrRespResume), '500', logError);
        
    }
    
}