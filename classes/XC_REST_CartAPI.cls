/**
 * The Class XC_REST_CartAPI.
 *
 * @author            :  Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  10/06/2019
 * @date Modification :  12/10/2020
 * @description       :  Rest Resourse to call Bit2Win Cart API
 */


public without sharing class XC_REST_CartAPI implements Queueable, Database.AllowsCallouts {

    /** The infos map. */
    public final Map<String, String> infos;
	public final Map<String, String> initialInfos; //20211111_DD_SO_15

    /** The result wrapper. */
    public class ResultWrapper {
        public Boolean success = false;
        public XC_Integration_Log__c intLog;
    }

	//20211111_DD_SO_15 - start
	public static final Boolean retryActive = XC_CS_UtilityGlobalValues__c.getValues('XC_REST_CartAPI_ActiveRetry').Value__c.equalsIgnoreCase('true');
    public static final String maxOccurrence = XC_CS_UtilityGlobalValues__c.getValues('XC_REST_CartAPI_Nattempts').Value__c;
    public static final List<String> errorStatusSet = XC_CS_UtilityGlobalValues__c.getValues('XC_REST_CartAPI_errorStatusSet').Value__c.split(';');
    public static final String sleepMs = XC_CS_UtilityGlobalValues__c.getValues('XC_REST_CartAPI_Sleep').Value__c;
    //20211111_DD_SO_15 - end
    
    /**
     * Instantiates a new XC_REST_CartAPI.
     *
     * @param infos the infos map
     * @description constructor of XC_REST_CartAPI
     */
    public XC_REST_CartAPI(Map<String, String> infos) {
        this.infos = infos;
        this.initialInfos = infos; //20211111_DD_SO_15
    }


    /**
     * Execute.
     *
     * @param qc the QueueableContext
     * @description execute of XC_REST_CartAPI
     */
    public void execute(QueueableContext qc) {

        List<XC_Integration_Log__c> integrationLogsToInsert = new List<XC_Integration_Log__c>();
        
        //20211111_DD_SO_15 - start
        if(infos.containsKey('ex_occurrenceStep_ex')){
            Integer currentOccurrence = Integer.valueOf(infos.get('ex_occurrenceStep_ex'));
            infos.put('ex_occurrenceStep_ex',String.valueOf(currentOccurrence+1));
            if(sleepMs!=null) XC_UTIL_RESTCallout.sleep(Integer.valueOf(sleepMs));
        }else{
            infos.put('ex_occurrenceStep_ex','1');
        }
        //20211111_DD_SO_15 - end
        
        ResultWrapper statusTok = generateTokenB2W(infos);
        integrationLogsToInsert.add(statusTok.intLog);
        System.debug('[generateToken] Map Infos -> ' + infos);
        if(!statusTok.success) {
            if(String.isNotBlank(infos.get('currentStep'))){ // For Market 
                XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU.deleteOpportunity(infos.get('NE__OptyId__c'));
                infos.put('wrResult', JSON.serialize(wrResult));
                XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'generateToken');
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
            }
            XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
            //20211111_DD_SO_15 - start
            //return;
            if(errorStatusSet.contains(statusTok.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence 
               && (!infos.containsKey('currentStep') || (infos.containsKey('currentStep') && String.isBlank(infos.get('currentStep'))))){
                XC_REST_CartAPI reCallCartAPI = new XC_REST_CartAPI(initialInfos);
                XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusTok.intLog.XC_Log_Response__c));
                   if(retryActive && !Test.isRunningTest()){
                       System.enqueueJob(reCallCartAPI);
                       return;
                   }else{
                       return;
                   }
            }else{
                return;
            }
            //20211111_DD_SO_15 - end
        }

            ResultWrapper statusCatalog = retriveCatalogs(infos);
            integrationLogsToInsert.add(statusCatalog.intLog);
            System.debug('[retriveCatalogs] Map Infos -> ' + infos);
            if(!statusCatalog.success) {
                if(String.isNotBlank(infos.get('currentStep'))){ // For Market
                    XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU.deleteOpportunity(infos.get('NE__OptyId__c'));
                    infos.put('wrResult', JSON.serialize(wrResult));
                    XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'retrieveCatalogs');
                    XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
                }
                XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                //20211111_DD_SO_15 - start
                //return;
                if(errorStatusSet.contains(statusCatalog.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence 
                   && (!infos.containsKey('currentStep') || (infos.containsKey('currentStep') && String.isBlank(infos.get('currentStep'))))){
                       XC_REST_CartAPI reCallCartAPI = new XC_REST_CartAPI(initialInfos);
                       XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusCatalog.intLog.XC_Log_Response__c));
                       if(retryActive && !Test.isRunningTest()){
                           System.enqueueJob(reCallCartAPI);
                           return;
                       }else{
                           return;
                       }
                   }else{
                       return;
                   }
                //20211111_DD_SO_15 - end
            }


        // manage retrieve and upsert item calls
        if(String.isBlank(infos.get('currentStep'))){ // for e-mobility and Market Spagna
            System.debug('[retrieveAndUpsertItems]');
            //20211111_DD_SO_15 - start
            //Boolean operationDone = managageRetrieveAndUpsertItem(integrationLogsToInsert, infos);
            ResultWrapper operationDone = managageRetrieveAndUpsertItem(integrationLogsToInsert, infos);
            //if(!operationDone){
            if(!operationDone.success){
                //20211111_DD_SO_15 - start
                //return;
                if(errorStatusSet.contains(operationDone.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence ){
                    XC_REST_CartAPI reCallCartAPI = new XC_REST_CartAPI(initialInfos);
                    XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = operationDone.intLog.XC_Log_Response__c));
                    if(retryActive && !Test.isRunningTest()){
                        System.enqueueJob(reCallCartAPI);
                        return;
                    }else{
                        return;
                    }
                }else{
                    return;
                }
                //20211111_DD_SO_15 - end
            }
        } else {  // For Market 
            System.debug('[retrieveAndUpsertItemsMarket]');
            Boolean operationDoneMarket = manageMultipleCategories(integrationLogsToInsert, infos);
            if(!operationDoneMarket){
                return;
            }
        }

        if(!String.isBlank(infos.get('Discounts'))){
                ResultWrapper statusUpsertItemsDiscount = upsertItemsDiscounts(infos); 
                integrationLogsToInsert.add(statusUpsertItemsDiscount.intLog);
                System.debug('[upsertItemsDiscount] Map Infos -> ' + infos);
                if(!statusUpsertItemsDiscount.success) {
                    if(String.isNotBlank(infos.get('currentStep'))){ // For Market
                        XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU.deleteOpportunity(infos.get('NE__OptyId__c'));
                        infos.put('wrResult', JSON.serialize(wrResult));
                        XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'upsertItemsDiscount');
                        XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
                    }
                    XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                    //20211111_DD_PROV_22 - start
                    //return;
                    if(errorStatusSet.contains(statusUpsertItemsDiscount.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence 
                       && (!infos.containsKey('currentStep') || (infos.containsKey('currentStep') && String.isBlank(infos.get('currentStep'))))){
                           XC_REST_CartAPI reCallCartAPI = new XC_REST_CartAPI(initialInfos);
                           XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusUpsertItemsDiscount.intLog.XC_Log_Response__c));
                           if(retryActive && !Test.isRunningTest()){
                               System.enqueueJob(reCallCartAPI);
                               return;
                           }else{
                               return;
                           }
                       }else{
                           return;
                       }
                    //20211111_DD_SO_15 - end
                }
            
        } //20211111_DD_SO_15 - end
            ResultWrapper statusSaveConfiguration = saveConfiguration(infos);
            integrationLogsToInsert.add(statusSaveConfiguration.intLog);
            System.debug('[saveConfiguration] Map Infos -> ' + infos);
            if(!statusSaveConfiguration.success) {
                if(String.isNotBlank(infos.get('currentStep'))){ // For Market
                    XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU.deleteOpportunity(infos.get('NE__OptyId__c'));
                    infos.put('wrResult', JSON.serialize(wrResult));
                    XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'saveConfiguration');
                    XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
                }
                XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                //20211111_DD_SO_15 - start
                //return;
                if(errorStatusSet.contains(statusSaveConfiguration.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence 
                   && (!infos.containsKey('currentStep') || (infos.containsKey('currentStep') && String.isBlank(infos.get('currentStep'))))){
                       //infos.put('ex_saveConfiguration_ex','false');
                       XC_REST_CartAPI reCallCartAPI = new XC_REST_CartAPI(initialInfos);
                       XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusSaveConfiguration.intLog.XC_Log_Response__c));
                       if(retryActive && !Test.isRunningTest()){
                           System.enqueueJob(reCallCartAPI);
                           return;
                       }else{
                           return;
                       }
                   }else{
                       return;
                   }
                //20211111_DD_SO_15 - end
            }
        
            ResultWrapper statusCheckout = cartCheckout(infos, 0);
            integrationLogsToInsert.add(statusCheckout.intLog);
            
            // For Market
            if(String.isNotBlank(infos.get('currentStep'))){
                if(String.isBlank(infos.get('confId'))){ 
                    if(infos.get('counter') == '0'){
                        XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU.deleteOpportunity(infos.get('NE__OptyId__c'));
                        infos.put('wrResult', JSON.serialize(wrResult));
                    }
                    XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'cartCheckout');
                    XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
                }else{                 
                    XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Completed_OK, 'cartCheckout');
                }
			//20211111_DD_SO_15 - start
            }else if(!statusCheckout.success && errorStatusSet.contains(statusCheckout.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence ){
               XC_REST_CartAPI reCallCartAPI = new XC_REST_CartAPI(initialInfos);
               XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusCheckout.intLog.XC_Log_Response__c));
               if(retryActive && !Test.isRunningTest()){
                   System.enqueueJob(reCallCartAPI);
                   return;
               }else{
                   return;
               }
			}else if(statusCheckout.success){
				XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Error_Description_B2W__c = ''));
			}
            //20211111_DD_SO_15 - end

        XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
    }

    
    /**
     * managageRetrieveAndUpsertItem.
     *
     * @param integrationLogsToInsert the integration log to insert 
     * @param infos the map infos
     * @description util method to manage retrieve and upsert items calls
     */
	//20211111_DD_SO_15 - start
    //public static Boolean managageRetrieveAndUpsertItem(List<XC_Integration_Log__c> integrationLogsToInsert, Map<String, String> infos){
    public static ResultWrapper managageRetrieveAndUpsertItem(List<XC_Integration_Log__c> integrationLogsToInsert, Map<String, String> infos){
        
        ResultWrapper lastResult = new ResultWrapper();
        //20211111_DD_SO_15 - end
        
        ResultWrapper statusRetrieveItems = retriveItems(infos);
        integrationLogsToInsert.add(statusRetrieveItems.intLog);
        lastResult = statusRetrieveItems;//20211111_DD_SO_15 
        System.debug('[retrieveItems] Map Infos -> ' + infos);
        if(!statusRetrieveItems.success) {
            if(String.isNotBlank(infos.get('currentStep'))){ // UniqueService
                if(String.isBlank(infos.get('assetId'))) {  //NOT Change Order. 
                    XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU.deleteOpportunity(infos.get('NE__OptyId__c'));
                    infos.put('wrResult', JSON.serialize(wrResult));
                }else{ // Change order
                    XC_REST_CartAPI_UU.deleteSObject((Id) infos.get('XC_CaseId__c'), infos);
                }
                XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'retrieveItems');
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
            }
            XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
            //20211111_DD_SO_15 - start
            //return false;
            return statusRetrieveItems;
            //20211111_DD_SO_15 - end
        }
        
        ResultWrapper statusUpsertItems = upsertItems(infos);
        integrationLogsToInsert.add(statusUpsertItems.intLog);
        lastResult = statusUpsertItems; //20211111_DD_SO_15 
        System.debug('[upsertItems] Map Infos -> ' + infos);
        if(!statusUpsertItems.success) {
            if(String.isNotBlank(infos.get('currentStep'))){ // UniqueService
                if(String.isBlank(infos.get('assetId'))) { // NOT change order
                    XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU.deleteOpportunity(infos.get('NE__OptyId__c'));
                    infos.put('wrResult', JSON.serialize(wrResult));
                }else{ // change order
                    XC_REST_CartAPI_UU.deleteSObject((Id) infos.get('XC_CaseId__c'), infos);
                }
                XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'upsertItems');
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
            }
            XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
            return statusUpsertItems;
        }

        // manage upsert child item if necessary
        Map<String, Boolean> mapCategoryHasChild =   (infos.get('mapCategoryHasChild') != null) ? (Map<String, Boolean>) JSON.deserialize(infos.get('mapCategoryHasChild'), Map<String, Boolean>.class) : null;
        String categoryId =  infos.get('categoryId');
        if(mapCategoryHasChild != null && mapCategoryHasChild.get(categoryId)){
            //20211111_DD_SO_15 - start
            //Boolean resultUpsertChildItem =  manageUpsertChildItem(integrationLogsToInsert, infos);
			//if(!resultUpsertChildItem){
                //return false;
            ResultWrapper resultUpsertChildItem =  manageUpsertChildItem(integrationLogsToInsert, infos);
            lastResult = resultUpsertChildItem; 
            //20211111_DD_SO_15 - end
        }
        
        return lastResult; //20211111_DD_SO_15 
    }

    
    /**
    * manageUpsertChildItem.
    *
    * @param integrationLogsToInsert the integration log to insert 
    * @param infos the map infos
    * @description util method to manage upsert child item
    */
    //20211111_DD_SO_15 - start
    //public static Boolean manageUpsertChildItem(List<XC_Integration_Log__c> integrationLogsToInsert, Map<String, String> infos){
    public static ResultWrapper manageUpsertChildItem(List<XC_Integration_Log__c> integrationLogsToInsert, Map<String, String> infos){
	//20211111_DD_SO_15 - end
	
        ResultWrapper statusUpsertChildItems = upsertChildItem(infos);
        integrationLogsToInsert.add(statusUpsertChildItems.intLog);
        
        System.debug('[upsertChildItems] Map Infos -> ' + infos);
        if(!statusUpsertChildItems.success) {
            if(String.isNotBlank(infos.get('currentStep'))){ // UniqueService
                if(String.isBlank(infos.get('assetId'))) {  //NOT Change Order. 
                    XC_UTIL_Sobject.WrapperResult wrResult = XC_REST_CartAPI_UU.deleteOpportunity(infos.get('NE__OptyId__c'));
                    infos.put('wrResult', JSON.serialize(wrResult));
                }else{ // Change order
                   XC_REST_CartAPI_UU.deleteSObject((Id) infos.get('XC_CaseId__c'), infos);
                }
                XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'upsertChildItems');
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
            }
            XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
            return statusUpsertChildItems;//20211111_DD_SO_15
        }
        return statusUpsertChildItems;//20211111_DD_SO_15
    }





    /**
     * manageMultipleCategories.
     *
     * @param integrationLogsToInsert the integration log to insert 
     * @param infos the map infos
     * @description util method to manage multiple catalog categories
     */
    public static Boolean manageMultipleCategories(List<XC_Integration_Log__c> integrationLogsToInsert, Map<String, String> infos){

        Map<Id, List<String>> mapCategoryIdCatalogItemList = (Map<Id, List<String>>)JSON.deserialize(JSON.Serialize((Map<Id, List<String>>) JSON.deserialize(infos.get('catalogCategoryAndCatalogItems'),Map<Id, List<String>>.class)), Map<Id, List<String>>.class);
        Map<Id, List<XC_UTIL_Order.OrderItemWrapper>> mapCategoryIdOrderItemList = (Map<Id, List<XC_UTIL_Order.OrderItemWrapper>>) JSON.deserialize(infos.get('catalogCategoryAndOrderItems'),Map<Id, List<XC_UTIL_Order.OrderItemWrapper>>.class);

        for(Id catalogCategoryId : mapCategoryIdCatalogItemList.keySet()){
            infos.put('catalogItemIds', JSON.serialize(mapCategoryIdCatalogItemList.get(catalogCategoryId)));
            infos.put('orderItemList', JSON.serialize(mapCategoryIdOrderItemList.get(catalogCategoryId)));
            infos.put('categoryId', catalogCategoryId);
            //20211111_DD_SO_15 - start
            //Boolean operationDone = managageRetrieveAndUpsertItem(integrationLogsToInsert, infos);
            ResultWrapper operationDone = managageRetrieveAndUpsertItem(integrationLogsToInsert, infos);
            if(!operationDone.success){
            //if(!operationDone){
                //20211111_DD_SO_15 - end
                return false;
            }
        }

        return true;
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
        System.debug('Response ****: '+ response);
        System.debug('[generateToken] response -> ' + response.getBody());
        
        if(response.getStatusCode() != 503) {
        
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            if(result.get('errorCode') == '0'){
                System.debug('[generateToken] OK');

                infos.put('token', (String) result.get('token'));
                resultWr.success = true;
            }

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
            XC_REST_CartAPI_U.populateConfigurationMap(confMap, infos);
            System.debug('ConfigurationMap in retriveCatalogs API -> ' + JSON.serialize(confMap));
            System.debug('Province -> ' + confMap.get('xcProvince'));
        	
            if(String.isNotBlank(infos.get('XC_eMobTransactionId__c'))) {   // FOR eMobility
                body = '{"retrieveCatalogs":{"sessionInfo":{"Id":""},"configuration":{}},"options":{' + ((String.isNotBlank(infos.get('EngineVersion'))) ? '"engineVersion":"' + infos.get('EngineVersion') + '",' : '') + '"ItemsForPage":"100","GetStructure":false,"GetAllData":false,"userLanguage":"en_US","facts":{"configuration":' + JSON.serialize(confMap) + ',"opportunity":{"createddate":"' + DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + '+0200","XC_LegalEntity__c":"'+confMap.get('XC_LegalEntity__c') + '","XC_legalentity":"'+confMap.get('XC_LegalEntity__c') + '"' + ((String.isNotBlank(infos.get('currencyISOCode'))) ?  ',"currencyIsoCode": "' + infos.get('currencyISOCode') +'"' : '' ) +'},"sessionparameter":[{"name":"sourcePlatform","value":"APP"}' +  ((String.isNotBlank(infos.get('currencyISOCode'))) ?  ', {"name":"confcurrency","value":""}' : '' ) + ']}}}';
                //body = '{"retrieveCatalogs":{"sessionInfo":{"Id":""},"configuration":{}},"options":{"ItemsForPage":"100","GetStructure":false,"GetAllData":false,"userLanguage":"en_US","facts":{"configuration":' + JSON.serialize(confMap) + ',"opportunity":{"createddate":"' + DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + '+0200","XC_LegalEntity__c":"'+confMap.get('XC_LegalEntity__c') + '"' + ((String.isNotBlank(infos.get('currencyISOCode'))) ?  ',"currencyIsoCode": "' + infos.get('currencyISOCode') +'"' : '' ) +'},"sessionparameter":[{"name":"sourcePlatform","value":"APP"}' +  ((String.isNotBlank(infos.get('currencyISOCode'))) ?  ', {"name":"confcurrency","value":""}' : '' ) + ']}}}';
            
            } else {                                                        // FOR Commodity 
                body = XC_REST_CartAPI_UU.calcutaleCommodityBodyForRetrieveCatalogs(infos, confMap);
            }

        } else {                                        // FOR eMobility ChangeOrder
            body = '{"retrieveCatalogs":{"sessionInfo":{"Id":""},"configuration":{}},"options":{' + ((String.isNotBlank(infos.get('EngineVersion'))) ? '"engineVersion":"' + infos.get('EngineVersion') + '",' : '') + '"ItemsForPage":"100","GetStructure":false,"GetAllData":false,"userLanguage":"en_US","facts":' + infos.get('changeResult') + '}}';
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

        //DCR BEGIN 26112021 - PS_ID036  
        String complexProductIdValue = '';

        if('Change Order'.equalsIgnoreCase(infos.get('OrderType')) && 'Promocode Application'.equalsIgnoreCase(infos.get('OrderSubType'))){
            complexProductIdValue = infos.get('rootItemvid');
        }
        String node6 = '"complexProductId":"'+complexProductIdValue+'"';
        //DCR END 26112021 - PS_ID036 

        String node7 = '"categoryId":"'+infos.get('categoryId')+'"';
        String node8 = '"catalogId":"'+infos.get('catalogId')+'"';
        String node9 = '"additionalData":{}';
        String node10 = '"searchParameters":{}';
        String body = '{"retrieveItems":{' + node1 + ',' + node2 + ',' + node3 + ',' + node4 + ',' + node5 + ',' + node6 + ',' + node7 + ',' + node8 + ',' + node9 + ',' + node10 + '},"options":{' + ((String.isNotBlank(infos.get('EngineVersion'))) ? '"engineVersion":"' + infos.get('EngineVersion') + '",' : '') + '"GetStructure":false,"GetAllData":false,"userLanguage":"en_US","facts":{}}}';
        
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
                //DCR BEGIN 30112021 - PS_ID036  
                if('Change Order'.equalsIgnoreCase(infos.get('OrderType')) && 'Promocode Application'.equalsIgnoreCase(infos.get('OrderSubType'))){
                    check = true;
                }
                //DCR END 30112021 - PS_ID036  
                Boolean getFullResponse = infos.containsKey('getFullStructure') && Boolean.valueOf(infos.get('getFullStructure')); 
                Map<String, List<Object>> catalogItemAttributesMap = new Map<String, List<Object>>();
                for(Map<String,Object> item : listOfItems) {
                    List<Object> listOfAttributes = (List<Object>) JSON.deserializeUntyped(Json.serialize(item.get('listOfAttributes')));
                    Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(item.get('fields')));
                    String id = (String) fields.get('id');
                    String eligible = (String) fields.get('eligible');

                    if((catalogItemIds.contains(id) || infos.get('catalogItemId') == id) && !getFullResponse) {
                        check = (String.isNotBlank(infos.get('XC_eMobTransactionId__c')) || String.isNotBlank(infos.get('orderSubtype'))) ? true : ((eligible == 'N') ? false : true);
                        if(!check) {
                            // opportunityclosedlost Commodity - product not elegible
                            if(String.isBlank(infos.get('currentStep'))){
                                Opportunity oppToClose = new Opportunity(Id = infos.get('NE__OptyId__c'), XC_LossReason__c ='Other', StageName = 'Closed Lost', XC_LossReasonDescription__c = (String) fields.get('eligibilitycomments'));
                                XC_UTIL_Sobject.updateRecord(oppToClose); 
                            }
                            resultWr.intLog.XC_Log_Error__c = (String) fields.get('eligibilitycomments');
                            resultWr.intLog.XC_Log_IsSuccess__c = false;
                            resultWr.success = false;
                            infos.put('LogError', (String) fields.get('eligibilitycomments'));
                            return resultWr;
                        }

                        catalogItemAttributesMap.put(id, listOfAttributes);
                    }                
                }


                infos.put('catalogItemAttributesMap', JSON.serialize(catalogItemAttributesMap));
                infos.put('retrieveItemFullResult',JSON.serialize(result.get('cart'))); 
                resultWr.success = check;

                if(getFullResponse){
                    infos.put('itemsFullMap',JSON.serialize(listOfItems));
                    resultWr.success = true;
                }


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
        String node9 = XC_REST_CartAPI_UU.populateItemsForUpsertItems(infos);

        String body = '{"upsertItems":{' + node1 + ',' + node2 + ',' + node3 + ',' + node4 + ',' + node5 + ',' + node6 + ',' + node7 + ',' + node8 + ',' + node9 + '},"options":{' + ((String.isNotBlank(infos.get('EngineVersion'))) ? '"engineVersion":"' + infos.get('EngineVersion') + '",' : '') + '"GetStructure":false,"GetAllData":false,"userLanguage":"en_US"}}';

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
                    XC_REST_CartAPI_UU.getItemDiscount(result, infos);
                }

                
                infos.put('upsertItemFullResult',JSON.serialize(result.get('cart'))); 
                infos.put('listOfItemsInfo',JSON.serialize(result.get('listOfItems')));

                resultWr.success = true;

            } else if(!String.isBlank(String.valueOf(result.get('errorMessage')))){
                infos.put('LogError', String.valueOf(result.get('errorMessage')));
            }
        }
        
        return resultWr;
        
    }


    /**
    * Upsert Child Item.
    *
    * @param infos the infos map
    * @return the status of response
    * @description call to UpsertItems Bit2Win API for child item
    */
    public static ResultWrapper upsertChildItem(Map<String, String> infos) {

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
        String node9 = XC_REST_CartAPI_UU.configureUpsertChildBody(infos);
        
        if(String.isBlank(node9)){ // child product or child attribute not found 
            
            String errorMessage = '';
            if(!String.isBlank(infos.get('parentChildProd'))){
                Map<String,Set<String>> parentChildProd = (Map<String,Set<String>>) JSON.deserialize(infos.get('parentChildProd'), Map<String,Set<String>>.class);
                errorMessage = '[XCustomer] Child product not found. For:' + new List<String> (parentChildProd.keySet())[0] + ' missing the following products:' + parentChildProd.values()[0];
            }else{
                Map<String,Set<String>> childProdAttr = (Map<String,Set<String>>) JSON.deserialize(infos.get('childProdAttr'), Map<String,Set<String>>.class);
                errorMessage = '[XCustomer] Attribute child product not found. For:' + new List<String> (childProdAttr.keySet())[0] + ' missing the following attributes:' + childProdAttr.values()[0];
            }
           
            XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
            logWrapper.logTransactionID = infos.get('commodityTransactionID');
            logWrapper.logIntegrationName = 'B2W_UpsertChildItems';
            logWrapper.clientSystem = 'XCustomerB2C';
            logWrapper.serverSystem = 'Bit2Win';              
            XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog(); 
            intLog.insertIntegReqOutboundLog(logWrapper);
            resultWr.intLog = (XC_UTIL_RESTCallout.getResponseLoggingError(intLog, errorMessage))[0];
            resultWr.success = false;
            infos.put('LogError', errorMessage);
            return resultWr;
        }

       
        String body = '{"upsertItems":{' + node1 + ',' + node2 + ',' + node3 + ',' + node4 + ',' + node5 + ',' + node6 + ',' + node7 + ',' + node8 + ',' + node9 + '},"options":{' + ((String.isNotBlank(infos.get('EngineVersion'))) ? '"engineVersion":"' + infos.get('EngineVersion') + '",' : '') + '"GetStructure":false,"GetAllData":false,"userLanguage":"en_US"}}';

        /** The request.*/ 
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        System.debug(LoggingLevel.FINEST, '[upsertChildItems] request -> ' + request);
        System.debug(LoggingLevel.FINEST, '[upsertChildItems] request BODY -> ' + body);
        
        /** The response.*/
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'B2W_UpsertChildItems';
        logWrapper.insertLogging = false; 

		XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        resultWr.intLog = httpRWr.integrationLog.get(0);
        
        if(response.getStatusCode() != 503) {
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(LoggingLevel.FINEST, '[upsertChildItems] result -> ' + result);
    
            if(result.get('errorCode') == '0'){
                System.debug('[upsertChildItems] OK');
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
            String body = XC_REST_CartAPI_UU.calcutaleBodyForUpsertItemsDiscount(infos);
            if(String.isBlank(body)){ // the discount is not found or not eligible for the specific product

                // opportunityclosedlost - commodity
                if(String.isBlank(infos.get('currentStep'))){
                    Opportunity oppToClose = new Opportunity(Id = infos.get('NE__OptyId__c'), XC_LossReason__c ='There is no viable offer', StageName = 'Closed Lost', XC_LossReasonDescription__c = 'The discount is not found or not eligible for the specific product');
                    XC_UTIL_Sobject.updateRecord(oppToClose); 
                }
                
                resultWr.intLog = XC_REST_CartAPI_UU.createIntegrationLogForDiscountError(infos);
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
                Opportunity oppToClose = new Opportunity(Id = infos.get('NE__OptyId__c'), XC_LossReason__c ='There is no viable offer', StageName = 'Closed Lost', XC_LossReasonDescription__c = 'There is no discount applicable for the product' );
                XC_UTIL_Sobject.updateRecord(oppToClose); 
            }

            resultWr.intLog = XC_REST_CartAPI_UU.createIntegrationLogForDiscountError(infos);
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

                XC_REST_CartAPI_U.manageUpsertItemsResponse(result, infos);
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

        //String url = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/NE/B2WGin_retrieveData';
        String url = URL.getSalesforceBaseUrl().toExternalForm();
        if(String.isNotBlank(infos.get('fromAutomotivePortal')) && infos.get('fromAutomotivePortal') == 'true') {
            url += '/portaleautomotive/services/apexrest/NE/B2WGin_retrieveData';
        } else {
            url += '/services/apexrest/NE/B2WGin_retrieveData';
        }
        
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

        if(response.getStatusCode() != 503) {
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
            infos.put('counter', String.valueOf(counter));
            
        

            if(errorCode == '0') {
                if(String.isBlank(confId)){ 
                    resultWr.intLog.XC_Log_Error__c = 'Blank configuration id after cartcheckout.';
                    return resultWr;
                }
                XC_REST_CartAPI_U.manageCheckout(confId, counter, infos);
                resultWr.intLog = (infos.get('integrationLog') != null) ? (XC_Integration_Log__c) Json.deserialize (infos.get('integrationLog'), XC_Integration_Log__c.class) : resultWr.intLog;
            }
        }

        return resultWr;
    }



    /**
     * Remove items.
     *
     * @param infos the infos map
     * @return the status of response
     * @description call to RemoveItems Bit2Win API
     */
    public static ResultWrapper removeItems(Map<String, String> infos) {

        ResultWrapper resultWr = new ResultWrapper();

        String url = infos.get('ServerURL') + 'RemoveItems';

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type','application/json');
        headerDefinitions.put('organizationId', infos.get('OrganizationId'));
        headerDefinitions.put('clientId', infos.get('ClientId'));
        headerDefinitions.put('token', infos.get('token'));

        //payload configuration
        String node1 = '"sessionInfo":{"Id":"' + infos.get('sessionId') + '"}';
        String node2 = '"sessionParameters":{}';
        String node3 = '"page":""';
        String node4 = '"language":"en_US"';
        String node5 = '"complexProductId":"'+ (!String.isBlank(infos.get('complexProductId')) ? infos.get('complexProductId') : '' ) + '"';
        String node6 = '"categoryId":"'+infos.get('categoryId')+'"';
        String node7 = '"catalogId":"'+infos.get('catalogId')+'"';
        String node8 = XC_REST_CartAPI_UU.populateItemsToRemove(infos);
        String body = '{"removeItems":{' + node1 + ',' + node2 + ',' + node3 + ',' + node4 + ',' + node5 + ',' + node6 + ',' + node7 + ',' + node8 + '}}';
        
        /** The request. */
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        System.debug(LoggingLevel.FINEST, '[removeItems] request -> ' + request);
        System.debug(LoggingLevel.FINEST, '[removeItems] request BODY -> ' + body);

        /** The response. */
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'B2W_RemoveItems';
        logWrapper.insertLogging = false; 
		XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        resultWr.intLog = httpRWr.integrationLog.get(0);
        
        String errorMessage = '';

        if(response.getStatusCode() != 503) {
            /** The result. */
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(LoggingLevel.FINEST, '[removeItems] result -> ' + result);
    
            if(result.get('errorCode') == '0'){

                System.debug('[removeItems] OK');
                resultWr.success = true;
                infos.put('upsertItemFullResult',JSON.serialize(result.get('cart')));

    
            }
        }
        return resultWr;
    }





}