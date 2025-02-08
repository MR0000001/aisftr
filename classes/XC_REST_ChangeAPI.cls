/**
 * The Class XC_REST_ChangeAPI.
 *
 * @author            :  Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  17/06/2019
 * @date Modification :  dd/mm/yyyy
 * @description       :  Rest Resourse to change order
 */

public without sharing class XC_REST_ChangeAPI implements Queueable, Database.AllowsCallouts {


    /** The infos map. */
    public final Map<String, String> infos;
	public final Map<String, String> initialInfos; //20211111_DD_SO_15
       
    //20211111_DD_SO_15 - start
	public static final Boolean retryActive = XC_CS_UtilityGlobalValues__c.getValues('XC_REST_ChangeAPI_ActiveRetry').Value__c.equalsIgnoreCase('true');
    public static final String maxOccurrence = XC_CS_UtilityGlobalValues__c.getValues('XC_REST_ChangeAPI_Nattempts').Value__c;
    public static final List<String> errorStatusSet = XC_CS_UtilityGlobalValues__c.getValues('XC_REST_ChangeAPI_errorStatusSet').Value__c.split(';');
    public static final String sleepMs = XC_CS_UtilityGlobalValues__c.getValues('XC_REST_ChangeAPI_Sleep').Value__c;
    //20211111_DD_SO_15 - end
    
    /**
     * Instantiates a new XC_REST_ChangeAPI.
     *
     * @param infos the infos map
     * @description constructor of XC_REST_ChangeAPI
     */
    public XC_REST_ChangeAPI(Map<String, String> infos) {
        this.infos = infos;
        this.initialInfos = infos; //20211111_DD_SO_15
    }   


    /**
     * Execute.
     *
     * @param qc the QueueableContext
     * @description execute of XC_REST_ChangeAPI
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
        
        //String transactionId = (!String.isBlank(infos.get('XC_eMobTransactionId__c'))) ? infos.get('XC_eMobTransactionId__c') : infos.get('commodityTransactionID');
        
        XC_REST_CartAPI.ResultWrapper statusgetConf = getConfigurationXMLInputs(infos);
        integrationLogsToInsert.add(statusgetConf.intLog);
        System.debug('[getConfigurationXMLInputs] Map Infos -> ' + infos);
        if(!statusgetConf.success) {
            if(String.isNotBlank(infos.get('currentStep'))){ // Unique Service
                XC_REST_CartAPI_UU.manageRollback(infos, 'XC_CaseId__c' , 'getConfigurationXMLInputs');
                XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                //[BEGIN ACERRA PS_ID036_ID019 02.12.2021]
                XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'getConfigurationXMLInputs');
                //[END ACERRA PS_ID036_ID019 02.12.2021]
            }
            //20211111_DD_SO_15 - start
            //return;
            if(errorStatusSet.contains(statusgetConf.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence 
               && (!infos.containsKey('currentStep') || (infos.containsKey('currentStep') && String.isBlank(infos.get('currentStep'))))){
                XC_REST_ChangeAPI reCallChangeAPI = new XC_REST_ChangeAPI(initialInfos);
                XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusgetConf.intLog.XC_Log_Response__c));
                   if(retryActive && !Test.isRunningTest()){
                       System.enqueueJob(reCallChangeAPI);
                       return;
                   }else{
                       return;
                   }
            }else{
                return;
            }
            //20211111_DD_SO_15 - end
        }

        XC_REST_CartAPI.ResultWrapper statusTokenChange = generateTokenChange(infos);
        integrationLogsToInsert.add(statusTokenChange.intLog);
        System.debug('[generateToken] Map Infos -> ' + infos);
        if(!statusTokenChange.success) {
            if(String.isNotBlank(infos.get('currentStep'))){ // Unique Service
                XC_REST_CartAPI_UU.manageRollback(infos, 'XC_CaseId__c' , 'generateTokenChange');
                XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                //[BEGIN ACERRA PS_ID036_ID019 02.12.2021]
                XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'generateTokenChange');
                //[END ACERRA PS_ID036_ID019 02.12.2021]
            }
            //20211111_DD_SO_15 - start
            //return;
            if(errorStatusSet.contains(statusTokenChange.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence 
               && (!infos.containsKey('currentStep') || (infos.containsKey('currentStep') && String.isBlank(infos.get('currentStep'))))){
                XC_REST_ChangeAPI reCallChangeAPI = new XC_REST_ChangeAPI(initialInfos);
                XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusTokenChange.intLog.XC_Log_Response__c));
                   if(retryActive && !Test.isRunningTest()){
                       System.enqueueJob(reCallChangeAPI);
                       return;
                   }else{
                       return;
                   }
            }else{
                return;
            }
            //20211111_DD_SO_15 - end
        }
        
        XC_REST_CartAPI.ResultWrapper statusApplyChangeOrder = applyChangeOrder(infos);
        integrationLogsToInsert.add(statusApplyChangeOrder.intLog);
        System.debug('[applyChangeOrder] Map Infos -> ' + infos);
        if(!statusApplyChangeOrder.success) {
            if(String.isNotBlank(infos.get('currentStep'))){ // Unique Service
                XC_REST_CartAPI_UU.manageRollback(infos, 'XC_CaseId__c' , 'applyChangeOrder');
                XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                //[BEGIN ACERRA PS_ID036_ID019 02.12.2021]
                XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'applyChangeOrder');
                //[END ACERRA PS_ID036_ID019 02.12.2021]
            }
            //20211111_DD_SO_15 - start
            //return;
            if(errorStatusSet.contains(statusApplyChangeOrder.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence 
               && (!infos.containsKey('currentStep') || (infos.containsKey('currentStep') && String.isBlank(infos.get('currentStep'))))){
                XC_REST_ChangeAPI reCallChangeAPI = new XC_REST_ChangeAPI(initialInfos);
                XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusApplyChangeOrder.intLog.XC_Log_Response__c));
                   if(retryActive && !Test.isRunningTest()){
                       System.enqueueJob(reCallChangeAPI);
                       return;
                   }else{
                       return;
                   }
            }else{
                return;
            }
            //20211111_DD_SO_15 - end
        }

        XC_REST_CartAPI.ResultWrapper statusTok = XC_REST_CartAPI.generateTokenB2W(infos);
        integrationLogsToInsert.add(statusTok.intLog);
        System.debug('[generateToken] Map Infos -> ' + infos);
        if(!statusTok.success) {
            if(String.isNotBlank(infos.get('currentStep'))){ // Unique Service
                XC_REST_CartAPI_UU.manageRollback(infos, 'XC_CaseId__c' , 'generateToken');
                 //[BEGIN ACERRA PS_ID036_ID019 02.12.2021]
                 XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'generateToken');
                 //[END ACERRA PS_ID036_ID019 02.12.2021]
            }
            XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
            //20211111_DD_SO_15 - start
            //return;
            if(errorStatusSet.contains(statusTok.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence 
               && (!infos.containsKey('currentStep') || (infos.containsKey('currentStep') && String.isBlank(infos.get('currentStep'))))){
                XC_REST_ChangeAPI reCallChangeAPI = new XC_REST_ChangeAPI(initialInfos);
                XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusTok.intLog.XC_Log_Response__c));
                   if(retryActive && !Test.isRunningTest()){
                       System.enqueueJob(reCallChangeAPI);
                       return;
                   }else{
                       return;
                   }
            }else{
                return;
            }
            //20211111_DD_SO_15 - end
        }

        XC_REST_CartAPI.ResultWrapper statusCatalog = XC_REST_CartAPI.retriveCatalogs(infos);
        integrationLogsToInsert.add(statusCatalog.intLog);
        System.debug('[retriveCatalogs] Map Infos -> ' + infos);
        if(!statusCatalog.success) {
            if(String.isNotBlank(infos.get('currentStep'))){ // Unique Service
                XC_REST_CartAPI_UU.manageRollback(infos, 'XC_CaseId__c' , 'retrieveCatalogs');
                //[BEGIN ACERRA PS_ID036_ID019 02.12.2021]
                XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'retrieveCatalogs');
                //[END ACERRA PS_ID036_ID019 02.12.2021]
            }
            XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
            //20211111_DD_SO_15 - start
            //return;
            if(errorStatusSet.contains(statusCatalog.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence 
               && (!infos.containsKey('currentStep') || (infos.containsKey('currentStep') && String.isBlank(infos.get('currentStep'))))){
                XC_REST_ChangeAPI reCallChangeAPI = new XC_REST_ChangeAPI(initialInfos);
                XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusCatalog.intLog.XC_Log_Response__c));
                   if(retryActive && !Test.isRunningTest()){
                       System.enqueueJob(reCallChangeAPI);
                       return;
                   }else{
                       return;
                   }
            }else{
                return;
            }
            //20211111_DD_SO_15 - end
        }

        if(String.isBlank(infos.get('currentStep')) || ('Change Order'.equalsIgnoreCase(infos.get('OrderType')) && 'Promocode Application'.equalsIgnoreCase(infos.get('OrderSubType')))){ //DCR BEGIN 26112021 - PS_ID036  ){

            XC_REST_CartAPI.ResultWrapper statusRetrieveItems = XC_REST_CartAPI.retriveItems(infos);
            integrationLogsToInsert.add(statusRetrieveItems.intLog);
            System.debug('[retrieveItems] Map Infos -> ' + infos);
            if(!statusRetrieveItems.success) {
                XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                //20211111_DD_SO_15 - start
            //return;
            if(errorStatusSet.contains(statusRetrieveItems.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence ){
                XC_REST_ChangeAPI reCallChangeAPI = new XC_REST_ChangeAPI(initialInfos);
                XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusRetrieveItems.intLog.XC_Log_Response__c));
                   if(retryActive && !Test.isRunningTest()){
                       System.enqueueJob(reCallChangeAPI);
                       return;
                   }else{
                       return;
                   }
            }else{
                return;
            }
            //20211111_DD_SO_15 - end
            }
            
            XC_REST_CartAPI.ResultWrapper statusUpsertItems = XC_REST_CartAPI.upsertItems(infos);
            integrationLogsToInsert.add(statusUpsertItems.intLog);
            System.debug('[upsertItems] Map Infos -> ' + infos);
            if(!statusUpsertItems.success) {
                XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                    //20211111_DD_SO_15 - start
            //return;
            if(errorStatusSet.contains(statusUpsertItems.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence ){
                XC_REST_ChangeAPI reCallChangeAPI = new XC_REST_ChangeAPI(initialInfos);
                XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusUpsertItems.intLog.XC_Log_Response__c));
                   if(retryActive && !Test.isRunningTest()){
                       System.enqueueJob(reCallChangeAPI);
                       return;
                   }else{
                       return;
                   }
            }else{
                return;
            }
            //20211111_DD_SO_15 - end
            }

        }else{ /* // Unique Service
            system.debug ('SUBTYPE' + infos.get('orderSubtype'));
            system.debug ('SUBTYPEUPPER' + (infos.get('orderSubtype')).toUpperCase());
            system.debug ('CHECKSUB' + !String.isBlank(infos.get('orderSubtype')));
            system.debug('SUBTYPES_WITHOUT_UPSERT' + SUBTYPES_WITHOUT_UPSERT);
            system.debug ('CHECKSUBUPPER' + SUBTYPES_WITHOUT_UPSERT.contains(((String)infos.get('orderSubtype')).toUpperCase()));
            if(!String.isBlank(infos.get('orderSubtype')) && SUBTYPES_WITHOUT_UPSERT.contains((infos.get('orderSubtype')).toUpperCase())){ // To check
                XC_REST_CartAPI.ResultWrapper statusRetrieveItems = XC_REST_CartAPI.retriveItems(infos);
                integrationLogsToInsert.add(statusRetrieveItems.intLog);
                System.debug('[retrieveItems] Map Infos -> ' + infos);
                if(!statusRetrieveItems.success) {
                    XC_REST_CartAPI_UU.manageRollback(infos, 'XC_CaseId__c' , 'retrieveItems');
                    XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
                    return;
                }
                Boolean statusRemove = XC_REST_CartAPI.manageRemoveItem(integrationLogsToInsert, infos);
                if(!statusRemove){
                    return;
                }
            
            }else{ */
                system.debug ('IN ELSE');
                System.debug('[retrieveAndUpsertItemsMarket]');
                Boolean operationDoneMarket = XC_REST_CartAPI.manageMultipleCategories(integrationLogsToInsert, infos);
                if(!operationDoneMarket){
                    return;
                }
            //}
        }
      

        XC_REST_CartAPI.ResultWrapper statusSaveConfiguration = XC_REST_CartAPI.saveConfiguration(infos);
        integrationLogsToInsert.add(statusSaveConfiguration.intLog);
        System.debug('[saveConfiguration] Map Infos -> ' + infos);
        if(!statusSaveConfiguration.success) {
            if(String.isNotBlank(infos.get('currentStep'))){ // Unique Service
                XC_REST_CartAPI_UU.manageRollback(infos, 'XC_CaseId__c' , 'saveConfiguration');
                //[BEGIN ACERRA PS_ID036_ID019 02.12.2021]
                XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'saveConfiguration');
                //[END ACERRA PS_ID036_ID019 02.12.2021]
            }
            XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
            //20211111_DD_SO_15 - start
            //return;
            if(errorStatusSet.contains(statusSaveConfiguration.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence 
               && (!infos.containsKey('currentStep') || (infos.containsKey('currentStep') && String.isBlank(infos.get('currentStep'))))){
                XC_REST_ChangeAPI reCallChangeAPI = new XC_REST_ChangeAPI(initialInfos);
                XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusSaveConfiguration.intLog.XC_Log_Response__c));
                   if(retryActive && !Test.isRunningTest()){
                       System.enqueueJob(reCallChangeAPI);
                       return;
                   }else{
                       return;
                   }
            }else{
                return;
            }
            //20211111_DD_SO_15 - end
        }

        if(!Test.isRunningTest()) {
            XC_REST_CartAPI.ResultWrapper statusCheckout = XC_REST_CartAPI.cartCheckout(infos, 0);
            integrationLogsToInsert.add(statusCheckout.intLog);
               // Unique Service
            if(String.isNotBlank(infos.get('currentStep'))){
                if(String.isBlank(infos.get('confId'))){
                    XC_REST_CartAPI_UU.manageRollback(infos, 'XC_CaseId__c' , 'cartCheckout');
                    //[BEGIN ACERRA PS_ID036_ID019 02.12.2021]
                    XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, 'cartCheckout');
                    //[END ACERRA PS_ID036_ID019 02.12.2021]
                }else{ 
                    XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Completed_OK, 'cartCheckout');
                }
            //20211111_DD_SO_15 - start
            }else if(!statusCheckout.success && errorStatusSet.contains(statusCheckout.intLog.XC_Log_Status__c) && infos.containsKey('ex_occurrenceStep_ex') && infos.get('ex_occurrenceStep_ex') <= maxOccurrence ){
               XC_REST_ChangeAPI reCallChangeAPI = new XC_REST_ChangeAPI(initialInfos);
               XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Number_of_retry_B2W__c = Decimal.valueOf(infos.get('ex_occurrenceStep_ex')), Error_Description_B2W__c = statusCheckout.intLog.XC_Log_Response__c));
               if(retryActive && !Test.isRunningTest()){
                   System.enqueueJob(reCallChangeAPI);
                   return;
               }else{
                   return;
               }
			}else if(statusCheckout.success){
				XC_UTIL_Sobject.updateRecord(new Opportunity(Id = infos.get('NE__OptyId__c'), Error_Description_B2W__c = ''));
			}
            //20211111_DD_SO_15 - end
        }

        XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(infos));
    }

    
    /**
     * GetConfigurationXMLInputs.
     *
     * @param infos the infos map
     * @return the status of response
     * @description method to get Configuration XML Inputs
     */
    public static XC_REST_CartAPI.ResultWrapper getConfigurationXMLInputs(Map<String, String> infos) {

        XC_REST_CartAPI.ResultWrapper resultWr = new XC_REST_CartAPI.ResultWrapper();
        
        String url = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/NE/GetConfigurationXML';

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type','application/json');
        headerDefinitions.put('Authorization', 'Bearer ' + UserInfo.getSessionId());

        String body = '{"GetConfigurationXMLInputs":{"assetId":"' + infos.get('assetId') + '","orderSubType":"Changeorder","orderDate": null}}';

        /** The request. */
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        System.debug('[getConfigurationXMLInputs] request -> ' + request);
        System.debug('[getConfigurationXMLInputs] request BODY -> ' + body);

        /** The response. */
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'B2W_GetConfigurationXMLInputs';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        resultWr.intLog = httpRWr.integrationLog.get(0);

        if(response.getStatusCode() != 503) {
            System.debug('[getConfigurationXMLInputs] response -> ' + response);
            System.debug('[getConfigurationXMLInputs] response BODY -> ' + response.getBody());

            /** The result. */
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('[getConfigurationXMLInputs] result -> ' + result);

            if(result.get('errorCode') == '0'){
                System.debug('[getConfigurationXMLInputs] OK');  
                infos.put('orderXml', (String) result.get('orderXml'));
                resultWr.success = true;
            }
        }

        return resultWr;
    }


    /**
     * GenerateTokenChange.
     *
     * @param infos the infos map
     * @return the status of response
     * @description method to generate token
     */
    public static XC_REST_CartAPI.ResultWrapper generateTokenChange(Map<String, String> infos) {

        XC_REST_CartAPI.ResultWrapper resultWr = new XC_REST_CartAPI.ResultWrapper();
        
        String url = infos.get('ServerURL_Change') + 'bit2winapis/generateToken';
        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('bit2winsalesforcesource', 'true');
        headerDefinitions.put('password', infos.get('Password'));
        headerDefinitions.put('passwordtoken', infos.get('PasswordToken'));
        headerDefinitions.put('usertoken', infos.get('UserToken'));
        
        /** The request. */
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, '');
        System.debug('[generateTokenChange] request -> ' + request);

        /** The response. */
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'B2W_GenerateTokenChange';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        resultWr.intLog = httpRWr.integrationLog.get(0);

        if(response.getStatusCode() != 503) {
            System.debug('[generateTokenChange] response -> ' + response.getBody());

            String errorCode = response.getBody().substringBetween('<errorCode>', '</errorCode>');
            System.debug('errorCode: ' + errorCode);
            if(errorCode == '0'){
                System.debug('[generateTokenChange] OK');
                infos.put('token_Change', response.getBody().substringBetween('<token>', '</token>'));
                resultWr.success = true;
            }
        }

        return resultWr;
    }   


    /**
     * ApplyChangeOrder.
     *
     * @param infos the infos map
     * @return the status of response
     * @description method to generate apply Change Order
     */
    public static XC_REST_CartAPI.ResultWrapper applyChangeOrder(Map<String, String> infos) {

        XC_REST_CartAPI.ResultWrapper resultWr = new XC_REST_CartAPI.ResultWrapper();
        
        String url = infos.get('ServerURL_Change') + 'bit2winapis/applyChangeOrder';

        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('token', infos.get('token_Change'));
        headerDefinitions.put('password', infos.get('Password'));
        headerDefinitions.put('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'configurationData=' + infos.get('orderXml');  
        body = body.replace('%', '%25');
        
        /** The request. */
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        System.debug('[applyChangeOrder] request -> ' + request);
        System.debug('[applyChangeOrder] request BODY -> ' + body);

        /** The response. */
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'B2W_ApplyChangeOrder';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        resultWr.intLog = httpRWr.integrationLog.get(0);
        System.debug('[applyChangeOrder] response -> ' + response);
        System.debug('[applyChangeOrder] response BODY -> ' + response.getBody());

        if(response.getStatusCode() == 200) {
            /** The result. */
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('[applyChangeOrder] result -> ' + result);

            Map<String,Object> appChangeOrder = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(result.get('ApplyChangeOrderMessage')));
            if(appChangeOrder.get('errorCode') == '0') {
                Map<String,Object> changeResult = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(appChangeOrder.get('changeResult')));
                
                Map<String, Object> configuration = (Map<String, Object>) JSON.deserializeUntyped(Json.serialize(changeResult.get('configuration')));
                configuration.put('xcProvince', infos.get('xcProvince'));
                configuration.put('XC_LegalEntity__c', infos.get('XC_LegalEntity__c'));                              
                Map<String, Object> opportunity = new Map<String, Object>{'createddate' => (DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS')),
                                                                            'XC_LegalEntity__c' => infos.get('XC_LegalEntity__c')};
                List<Map<String, Object>> sessionparameter = new List<Map<String, Object>>();
                sessionparameter.add(new Map<String, Object>{'name' => 'sourcePlatform','value' => 'APP'});

                if(String.isNotBlank(infos.get('currentStep')) && !('Change Order'.equalsIgnoreCase(infos.get('OrderType')) && 'Promocode Application'.equalsIgnoreCase(infos.get('OrderSubType')))){ //DCR 26112021 - PS_ID036  
                    Map<String, Object> account = (Map<String, Object>) JSON.deserializeUntyped(Json.serialize(changeResult.get('account')));
                    Map<String, Object> configurationInfos = (Map<String, Object>) JSON.deserializeUntyped(infos.get('configurationInfos'));
                    sessionparameter[0].put('value', 'CRM');
                    sessionparameter.add(new Map<String, Object>{'name' => 'UserChannel','value' => 'Commodity Partner'});
                    opportunity.put('PricingRegion', infos.get('PricingRegionCommodity'));
                    configuration.putAll(configurationInfos);
                   
                    //configuration.put('pricingRegion', infos.get('PricingRegionCommodity'));
                    //configuration.put('XC_Subtype', infos.get('orderSubtype'));
                    
                    account.put('rtDeveloperName',infos.get('XC_RecordTypeDeveloperName__c'));
                    changeResult.put('account', account);

                    //manage currency
                    if(!String.isBlank(infos.get('currencyISOCode'))){
                        sessionparameter.add(new Map<String, Object>{'name' => 'confcurrency','value' => ''});
                        opportunity.put('currencyIsoCode', infos.get('currencyISOCode'));
                        configuration.put('currencyisocode', infos.get('currencyISOCode'));
                    }

                }

                //DCR BEGIN 26112021 - PS_ID036  
                if('Change Order'.equalsIgnoreCase(infos.get('OrderType')) && 'Promocode Application'.equalsIgnoreCase(infos.get('OrderSubType'))){
                    List<Object> itemsObjList = (List<Object>) JSON.deserializeUntyped(Json.serialize(changeResult.get('cartitem')));

                    List<Map<String,Object>> cartItemList = new List<Map<String,Object>>();
                    for(Object obj : itemsObjList) {
                        Map<String,Object> item = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
                        cartItemList.add(item);
                    }

                    for(Map<String,Object> item : cartItemList){
                        Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(item.get('fields')));
                        if('Product'.equalsIgnoreCase(''+fields.get('type')) && String.isBlank(''+fields.get('root'))){
                            infos.put('rootItemvid', ''+fields.get('vid'));
                        }
                    }
                }
                //DCR END 26112021 - PS_ID036  

                changeResult.put('configuration', configuration);
                changeResult.put('opportunity', opportunity);
                changeResult.put('sessionparameter', sessionparameter);

                infos.put('changeResult', Json.serialize(changeResult));
                System.debug('changeResult: ' + appChangeOrder.get('changeResult'));
                resultWr.success = true;
            }
        }

        return resultWr;
    }

}