/**
 * The Class XC_REST_CartAPI.
 *
 * @author            :  Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  10/06/2019
 * @date Modification :  16/06/2020
 * @description       :  Rest Resourse to call Bit2Win Cart API
 */


public without sharing class XC_REST_CartAPI_clone implements Queueable, Database.AllowsCallouts {

    /** The infos map. */
    public final Map<String, String> infos;

    /** The result wrapper. */
    public class ResultWrapper {
        public Boolean success = false;
        public XC_Integration_Log__c intLog;
    }


    /**
     * Instantiates a new XC_REST_CartAPI.
     *
     * @param infos the infos map
     * @description constructor of XC_REST_CartAPI
     */
    public XC_REST_CartAPI_clone(Map<String, String> infos) {
        this.infos = infos;
    }


    /**
     * Execute.
     *
     * @param qc the QueueableContext
     * @description execute of XC_REST_CartAPI
     */
    public void execute(QueueableContext qc) {

        List<XC_Integration_Log__c> integrationLogsToInsert = new List<XC_Integration_Log__c>();
        
        ResultWrapper statusTok = generateTokenB2W(infos);
        integrationLogsToInsert.add(statusTok.intLog);
        System.debug('[generateToken] Map Infos -> ' + infos);
        if(!statusTok.success) {
            if(String.isNotBlank(infos.get('currentStep'))){ // For Market
                XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU_clone.deleteOpportunity(infos.get('NE__OptyId__c'));
                infos.put('wrResult', JSON.serialize(wrResult));
                XC_REST_CartAPI_UU_clone.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'generateToken');
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
            }
            XC_REST_CartAPI_U_clone.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
            return;
        }

        //if(!Test.isRunningTest()) {
            ResultWrapper statusCatalog = retriveCatalogs(infos);
            integrationLogsToInsert.add(statusCatalog.intLog);
            System.debug('[retriveCatalogs] Map Infos -> ' + infos);
            if(!statusCatalog.success) {
                if(String.isNotBlank(infos.get('currentStep'))){ // For Market
                    XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU_clone.deleteOpportunity(infos.get('NE__OptyId__c'));
                    infos.put('wrResult', JSON.serialize(wrResult));
                    XC_REST_CartAPI_UU_clone.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'retrieveCatalogs');
                    XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
                }
                XC_REST_CartAPI_U_clone.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                return;
            }

            ResultWrapper statusRetrieveItems = retriveItems(infos);
            integrationLogsToInsert.add(statusRetrieveItems.intLog);
            System.debug('[retrieveItems] Map Infos -> ' + infos);
            if(!statusRetrieveItems.success) {
                if(String.isNotBlank(infos.get('currentStep'))){ // For Market
                    XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU_clone.deleteOpportunity(infos.get('NE__OptyId__c'));
                    infos.put('wrResult', JSON.serialize(wrResult));
                    XC_REST_CartAPI_UU_clone.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'retrieveItems');
                    XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
                }
                XC_REST_CartAPI_U_clone.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                return;
            }
            
            ResultWrapper statusUpsertItems = upsertItems(infos);
            integrationLogsToInsert.add(statusUpsertItems.intLog);
            System.debug('[upsertItems] Map Infos -> ' + infos);
            if(!statusUpsertItems.success) {
                if(String.isNotBlank(infos.get('currentStep'))){ // For Market
                    XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU_clone.deleteOpportunity(infos.get('NE__OptyId__c'));
                    infos.put('wrResult', JSON.serialize(wrResult));
                    XC_REST_CartAPI_UU_clone.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'upsertItems');
                    XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
                }
                XC_REST_CartAPI_U_clone.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                return;
            }

            if(!String.isBlank(infos.get('Discounts'))){
                ResultWrapper statusUpsertItemsDiscount = upsertItemsDiscounts(infos); 
                integrationLogsToInsert.add(statusUpsertItemsDiscount.intLog);
                System.debug('[upsertItemsDiscount] Map Infos -> ' + infos);
                if(!statusUpsertItemsDiscount.success) {
                    if(String.isNotBlank(infos.get('currentStep'))){ // For Market
                        XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU_clone.deleteOpportunity(infos.get('NE__OptyId__c'));
                        infos.put('wrResult', JSON.serialize(wrResult));
                        XC_REST_CartAPI_UU_clone.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'upsertItemsDiscount');
                        XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
                    }
                    XC_REST_CartAPI_U_clone.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                    return;
                }
            }
            
            ResultWrapper statusSaveConfiguration = saveConfiguration(infos);
            integrationLogsToInsert.add(statusSaveConfiguration.intLog);
            System.debug('[saveConfiguration] Map Infos -> ' + infos);
            if(!statusSaveConfiguration.success) {
                if(String.isNotBlank(infos.get('currentStep'))){ // For Market
                    XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU_clone.deleteOpportunity(infos.get('NE__OptyId__c'));
                    infos.put('wrResult', JSON.serialize(wrResult));
                    XC_REST_CartAPI_UU_clone.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'saveConfiguration');
                    XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
                }
                XC_REST_CartAPI_U_clone.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                return;
            }

            ResultWrapper statusCheckout = cartCheckout(infos, 0);
            integrationLogsToInsert.add(statusCheckout.intLog);

            // For Market
            if(String.isNotBlank(infos.get('currentStep'))){
                if(String.isBlank(infos.get('confId'))){ 
                    XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU_clone.deleteOpportunity(infos.get('NE__OptyId__c'));
                    infos.put('wrResult', JSON.serialize(wrResult));
                    XC_REST_CartAPI_UU_clone.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'cartCheckout');
                    XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
                }else{ 
                    XC_REST_CartAPI_UU_clone.updateQueuedRequestStep(infos, Label.XC_CL_Completed_OK, 'cartCheckout');
                }
            }

            XC_REST_CartAPI_U_clone.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
        //}
    }


    /**
     * GenerateTokenB2W.
     *
     * @param infos the infos map
     * @return the status of response
     * @description method to generate Bit2Win token
     */
    public static ResultWrapper generateTokenB2W(Map<String, String> infos) {

        ResultWrapper resultWr = new ResultWrapper();
        
        String url = infos.get('ServerURL') + 'generateToken';
        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type','application/json');
        headerDefinitions.put('organizationId', infos.get('OrganizationId'));
        headerDefinitions.put('clientId', infos.get('ClientId'));
        
        /** The request. */
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, '');
        System.debug('[generateToken] request -> ' + request);

        /** The response. */
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'B2W_GenerateToken';
        logWrapper.insertLogging = false; 
		XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        resultWr.intLog = httpRWr.integrationLog.get(0);
        System.debug('[generateToken] response -> ' + response.getBody());
        
        Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        if(result.get('errorCode') == '0'){
            System.debug('[generateToken] OK');

            infos.put('token', (String) result.get('token'));
            resultWr.success = true;
        }
        
        return resultWr;
    }


    /**
     * RetriveCatalogs.
     *
     * @param infos the infos map
     * @return the status of response
     * @description call to RetriveCatalogs Bit2Win API
     */
    public static ResultWrapper retriveCatalogs(Map<String, String> infos) {

        ResultWrapper resultWr = new ResultWrapper();

        String url = infos.get('ServerURL') + 'RetrieveCatalogs';

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type','application/json');
        headerDefinitions.put('organizationId', infos.get('OrganizationId'));
        headerDefinitions.put('clientId', infos.get('ClientId'));
        headerDefinitions.put('token', infos.get('token'));

        //payload configuration
        String body;
        if(String.isBlank(infos.get('changeResult'))) { // FOR inOrder

            Map<String, Object> confMap = new Map<String, Object>{'NE__type__c' => 'InOrder'};
            XC_REST_CartAPI_U_clone.populateConfigurationMap(confMap, infos);
            System.debug('ConfigurationMap in retriveCatalogs API -> ' + JSON.serialize(confMap));
            System.debug('Province -> ' + confMap.get('xcProvince'));
        	
            if(String.isNotBlank(infos.get('XC_eMobTransactionId__c'))) {   // FOR eMobility
                body = '{"retrieveCatalogs":{"sessionInfo":{"Id":""},"configuration":{}},"options":{"ItemsForPage":"100","GetStructure":false,"GetAllData":false,"userLanguage":"en_US","facts":{"configuration":' + JSON.serialize(confMap) + ',"opportunity":{"createddate":"' + DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + '+0200","XC_LegalEntity__c":"'+confMap.get('XC_LegalEntity__c')+'"},"sessionparameter":[{"name":"sourcePlatform","value":"APP"}]}}}';
            
            } else {                                                        // FOR Commodity 
                body = XC_REST_CartAPI_UU_clone.calcutaleCommodityBodyForRetrieveCatalogs(infos, confMap);
            }

        } else {                                        // FOR eMobility ChangeOrder
            body = '{"retrieveCatalogs":{"sessionInfo":{"Id":""},"configuration":{}},"options":{"ItemsForPage":"100","GetStructure":false,"GetAllData":false,"userLanguage":"en_US","facts":' + infos.get('changeResult') + '}}';
        }

        /** The request. */
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        System.debug(LoggingLevel.FINEST, '[retriveCatalogs] request -> ' + request);
        System.debug(LoggingLevel.FINEST, '[retriveCatalogs] request BODY -> ' + body);

        /** The response. */
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'B2W_RetriveCatalogs';
        logWrapper.insertLogging = false; 
		XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        resultWr.intLog = httpRWr.integrationLog.get(0);
        
        if(response.getStatusCode() != 503) {
            /** The result. */
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(LoggingLevel.FINEST, '[retriveCatalogs] result -> ' + result);
    
            if(result.get('errorCode') == '0'){
                System.debug('[retriveCatalogs] OK');
                
                /** The session info. */
                Map<String,Object> sessionInfo = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(result.get('sessionInfo')));
                infos.put('sessionId', (String) sessionInfo.get('Id'));
                System.debug('Session Info -> ' + sessionInfo.get('Id'));

                resultWr.success = true;
            }
        }

        return resultWr;
    }


    /**
     * Retrive items.
     *
     * @param infos the infos map
     * @return the status of response
     * @description call to RetriveItems Bit2Win API
     */
    public static ResultWrapper retriveItems(Map<String, String> infos) {

        ResultWrapper resultWr = new ResultWrapper();

        String url = infos.get('ServerURL') + 'RetrieveItems';

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type','application/json');
        headerDefinitions.put('organizationId', infos.get('OrganizationId'));
        headerDefinitions.put('clientId', infos.get('ClientId'));
        headerDefinitions.put('token', infos.get('token'));

        //payload configuration
        String node1 = '"sessionInfo":{"Id":"' + infos.get('sessionId') + '"}';
        String node2 = '"sessionParameters":{}';
        String node3 = '"configuration":{}';
        String node4 = '"page":""';
        String node5 = '"language":"en_US"';
        String node6 = '"complexProductId":""';
        String node7 = '"categoryId":"'+infos.get('categoryId')+'"';
        String node8 = '"catalogId":"'+infos.get('catalogId')+'"';
        String node9 = '"additionalData":{}';
        String node10 = '"searchParameters":{}';
        String body = '{"retrieveItems":{' + node1 + ',' + node2 + ',' + node3 + ',' + node4 + ',' + node5 + ',' + node6 + ',' + node7 + ',' + node8 + ',' + node9 + ',' + node10 + '},"options":{"GetStructure":false,"GetAllData":false,"userLanguage":"en_US","facts":{}}}';
        
        /** The request. */
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        System.debug(LoggingLevel.FINEST, '[retrieveItems] request -> ' + request);
        System.debug(LoggingLevel.FINEST, '[retrieveItems] request BODY -> ' + body);

        /** The response. */
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'B2W_RetriveItems';
        logWrapper.insertLogging = false; 
		XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        resultWr.intLog = httpRWr.integrationLog.get(0);
        
        String errorMessage = '';

        List<String> catalogItemIds = (infos.get('catalogItemIds') != null) ? (List<String>) JSON.deserialize(infos.get('catalogItemIds'), List<String>.class) : new List<String>();
        if(response.getStatusCode() != 503) {
            /** The result. */
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(LoggingLevel.FINEST, '[retrieveItems] result -> ' + result);
    
            if(result.get('errorCode') == '0'){
                System.debug('[retrieveItems] OK');
                
                List<Object> items = (List<Object>) result.get('listOfItems');
                List<Map<String,Object>> listOfItems = new List<Map<String,Object>>();
                for(Object obj : items) {
                    Map<String,Object> item = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
                    listOfItems.add(item);
                }
    
                Boolean check = false;  
                Map<String, List<Object>> catalogItemAttributesMap = new Map<String, List<Object>>();
                for(Map<String,Object> item : listOfItems) {
                    List<Object> listOfAttributes = (List<Object>) JSON.deserializeUntyped(Json.serialize(item.get('listOfAttributes')));
                    Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(item.get('fields')));
                    String id = (String) fields.get('id');
                    String eligible = (String) fields.get('eligible');

                    if(catalogItemIds.contains(id) || infos.get('catalogItemId') == id) {
                        check = (String.isNotBlank(infos.get('XC_eMobTransactionId__c'))) ? true : ((eligible == 'N') ? false : true);

                        if(!check) {
                            // opportunityclosedlost Commodity - product not elegible
                            if(String.isBlank(infos.get('currentStep'))){
                                Opportunity oppToClose = new Opportunity(Id = infos.get('NE__OptyId__c'), XC_LossReason__c ='Other', StageName = 'Closed Lost', XC_LossReasonDescription__c = (String) fields.get('eligibilitycomments'));
                                XC_UTIL_Sobject.updateRecord(oppToClose); 
                            }
                            resultWr.intLog.XC_Log_Error__c = (String) fields.get('eligibilitycomments');
                            resultWr.intLog.XC_Log_IsSuccess__c = false;
                            resultWr.success = false;
                            return resultWr;
                        }

                        catalogItemAttributesMap.put(id, listOfAttributes);
                    }                
                }

                infos.put('catalogItemAttributesMap', JSON.serialize(catalogItemAttributesMap));
                resultWr.success = check;
            }
        }

        return resultWr;
    }


    /**
     * Upsert items.
     *
     * @param infos the infos map
     * @return the status of response
     * @description call to UpsertItems Bit2Win API
     */
    public static ResultWrapper upsertItems(Map<String, String> infos) {

        ResultWrapper resultWr = new ResultWrapper();

        String url = infos.get('ServerURL') + 'UpsertItems';

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type','application/json');
        headerDefinitions.put('organizationId', infos.get('OrganizationId'));
        headerDefinitions.put('clientId', infos.get('ClientId'));
        headerDefinitions.put('token', infos.get('token'));

        //payload configuration
        String node1 = '"sessionInfo":{"Id":"' +infos.get('sessionId') + '"}';
        String node2 = '"sessionParameters":{}';
        String node3 = '"page":""';
        String node4 = '"language":"en_US"';
        String node5 = '"complexProductId":""';
        String node6 = '"categoryId":"' + infos.get('categoryId') + '"';
        String node7 = '"catalogId":"' + infos.get('catalogId') + '"';
        String node8 = '"additionalData":{}';
        String node9 = XC_REST_CartAPI_UU_clone.populateItemsForUpsertItems(infos);

        String body = '{"upsertItems":{' + node1 + ',' + node2 + ',' + node3 + ',' + node4 + ',' + node5 + ',' + node6 + ',' + node7 + ',' + node8 + ',' + node9 + '},"options":{"GetStructure":false,"GetAllData":false,"userLanguage":"en_US"}}';

        /** The request. */
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        System.debug(LoggingLevel.FINEST, '[upsertItems] request -> ' + request);
        System.debug(LoggingLevel.FINEST, '[upsertItems] request BODY -> ' + body);
        
        /** The response. */
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'B2W_UpsertItems';
        logWrapper.insertLogging = false; 
		XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        resultWr.intLog = httpRWr.integrationLog.get(0);
        
        if(response.getStatusCode() != 503) {
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(LoggingLevel.FINEST, '[upsertItems] result -> ' + result);
    
            if(result.get('errorCode') == '0'){
                System.debug('[upsertItems] OK');

                if(String.isBlank(infos.get('XC_eMobTransactionId__c')) && !String.isBlank(infos.get('Discounts'))){ // for commodity discount
                    XC_REST_CartAPI_UU_clone.getItemDiscount(result, infos);
                }

                resultWr.success = true;
            } 
        }
        
        return resultWr;
    }


    /**
     * Upsert items Discounts.
     *
     * @param infos the infos map
     * @return the status of response
     * @description call to UpsertItems Bit2Win API
     */
    public static ResultWrapper upsertItemsDiscounts(Map<String, String> infos) {

        ResultWrapper resultWr = new ResultWrapper();

        if(String.isNotBlank(infos.get('fieldsDiscount'))) { // FOR Commodity

            String url = infos.get('ServerURL') + 'UpsertItems';

            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type','application/json');
            headerDefinitions.put('organizationId', infos.get('OrganizationId'));
            headerDefinitions.put('clientId', infos.get('ClientId'));
            headerDefinitions.put('token', infos.get('token'));

            //payload configuration
            String body = XC_REST_CartAPI_UU_clone.calcutaleBodyForUpsertItemsDiscount(infos);
            if(String.isBlank(body)){ // the discount is not found or not eligible for the specific product

                // opportunityclosedlost - commodity
                if(String.isBlank(infos.get('currentStep'))){
                    Opportunity oppToClose = new Opportunity(Id = infos.get('NE__OptyId__c'), XC_LossReason__c ='There is no viable offer', StageName = 'Closed Lost', XC_LossReasonDescription__c = 'The discount is not found or not eligible for the specific product');
                    XC_UTIL_Sobject.updateRecord(oppToClose); 
                }

                resultWr.intLog = XC_REST_CartAPI_UU_clone.createIntegrationLogForDiscountError(infos);
                return resultWr;

            }else{

                /** The request. **/
                HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
                System.debug(LoggingLevel.FINEST, '[upsertItemsDiscount] request -> ' + request);
                System.debug(LoggingLevel.FINEST, '[upsertItemsDiscount] request BODY -> ' + body);
                
                /** The response. **/
                XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
                logWrapper.logIntegrationName = 'B2W_UpsertItemsDiscount';
                logWrapper.insertLogging = false; 
                XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
                HttpResponse response = httpRWr.response;
                resultWr.intLog = httpRWr.integrationLog.get(0);
                
                if(response.getStatusCode() != 503) {
                    Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                    System.debug(LoggingLevel.FINEST, '[upsertItemsDiscount] result -> ' + result);
            
                    if(result.get('errorCode') == '0'){
                        System.debug('[upsertItemsDiscount] OK');
                        resultWr.success = true;
                    } 
                }

                return resultWr;
            }
        }else { // there is no discount applicable for the specific product

            // opportunityclosedlost - commodity
            if(String.isBlank(infos.get('currentStep'))){
                Opportunity oppToClose = new Opportunity(Id = infos.get('NE__OptyId__c'), XC_LossReason__c ='There is no viable offer', StageName = 'Closed Lost', XC_LossReasonDescription__c = 'There is no discount applicable for the product');
                XC_UTIL_Sobject.updateRecord(oppToClose); 
            }
            
            resultWr.intLog = XC_REST_CartAPI_UU_clone.createIntegrationLogForDiscountError(infos);
            resultWr.intLog.XC_Log_Error__c = 'There is no discount applicable for the product';
            return resultWr; 
        }

    }


    /**
     * Save Configuration.
     *
     * @param infos the infos map
     * @return the status of response
     * @description call to Save Configuration Bit2Win API
     */
    public static ResultWrapper saveConfiguration(Map<String, String> infos) {

        ResultWrapper resultWr = new ResultWrapper();

        String url = infos.get('ServerURL') + 'SaveConfiguration';

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type','application/json');
        headerDefinitions.put('organizationId', infos.get('OrganizationId'));
        headerDefinitions.put('clientId', infos.get('ClientId'));
        headerDefinitions.put('token', infos.get('token'));

        String body = '{"saveConfiguration": {"sessionInfo": {"Id": "' + infos.get('sessionId') + '"}}}';

        /** The request. */
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        System.debug(LoggingLevel.FINEST, '[saveConfiguration] request -> ' + request);
        System.debug(LoggingLevel.FINEST, '[saveConfiguration] request BODY -> ' + body);
        
        /** The response. */
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'B2W_SaveConfiguration';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        resultWr.intLog = httpRWr.integrationLog.get(0);
        
        if(response.getStatusCode() != 503) {
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(LoggingLevel.FINEST, '[saveConfiguration] result -> ' + result);
    
            if(result.get('errorCode') == '0'){
                System.debug('[saveConfiguration] OK');

                XC_REST_CartAPI_U_clone.manageUpsertItemsResponse(result, infos);
                resultWr.success = true;
            } 
        }

        return resultWr;
    }


    /**
     * Cart Checkout.
     *
     * @param infos the infos map
     * @param counter the counter of cart checkout recursion
     * @description call to CartCheckout Bit2Win API
     */
    public static ResultWrapper cartCheckout(Map<String, String> infos, Integer counter) {

        ResultWrapper resultWr = new ResultWrapper();

        String url = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/NE/B2WGin_retrieveData';

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type','application/json');
        headerDefinitions.put('Authorization', 'Bearer ' + UserInfo.getSessionId());

        //payload configuration
        String body = '{"requestData":{"action":"checkoutCart","dataInterceptorString":"' + infos.get('dataInterceptorString') +'"}}';

        /** The request. */
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        System.debug(LoggingLevel.FINEST, '[cartCheckout] request -> ' + request);
        System.debug(Logginglevel.FINEST, '[cartCheckout] request BODY -> ' + body);
        
        /** The response. */
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'B2W_CartCheckout';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        resultWr.intLog = httpRWr.integrationLog.get(0);
        System.debug(LoggingLevel.FINEST, '[cartCheckout] response -> ' + response);
        System.debug(Logginglevel.FINEST, '[cartCheckout] response BODY -> ' + response.getBody());

        /** The result. */
        Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        Map<String,Object> resMap = (Map<String,Object>) JSON.deserializeUntyped((String) result.get('result'));
        Map<String,Object> conf = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(resMap.get('configuration')));
        String confId = (String) conf.get('Id');
        System.debug('[cartCheckout] confID -> ' + confId);

        String errorCode = (String) result.get('errorCode');
        System.debug('[cartCheckout] errorCode -> ' + errorCode);

        //For Market
        infos.put('confId', confId);
        
        if(errorCode == '0') {
            XC_REST_CartAPI_U_clone.manageCheckout(confId, counter, infos);
        }

        return resultWr;
    }
}