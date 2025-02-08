/**
 * @author              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation       07/12/2018
 * @date Modification   17/04/2019
 * @description         XC_REST_Account – Rest Resourse for Create/Update Account
 */

@RestResource(urlMapping='/v1/Account/*')
global with sharing class XC_REST_Account { 


    /**
    * Do get.
    *
    * @description  Method to get an Account from an external request 
    */
    @HttpGet
    global static void doGet() {

        String requestURL = ''; 
        String msgResponse = '';
        String logError = '';
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_Account_W.WrapperResponseGET wrResp = new XC_REST_Account_W.WrapperResponseGET();
        Map<String, String> mapHeader = new Map<String, String>();
        
        try{

            mapHeader = request.headers;
            String apiKey = request.params.remove('api_key');
            intLog.insertIntegReqInboundLog('Account', JSON.serialize(request.params));
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);
            
            XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Account', 'read');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }             
            
            // Check required fields
            validateResult = XC_REST_Account_VV.validateRequestGET(mapHeader, request.params);
            if(validateResult.errorFlag) {
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                logError = 'ERROR. ' + validateResult.errorMessage;
                System.debug('####' + wrResp.Result.Message);
                return;
            }

            Map<Id, List<NE__Order__c>> mapAccIdOrder = new Map<Id, List<NE__Order__c>>();
            Map<Id, String> mapAccIdCS = new Map<Id, String>();
            
            Map<String, Object> mapUtil = new Map<String, Object>{  'params' => request.params,
                                                                    'mapAccIdOrder' => mapAccIdOrder,
                                                                    'mapAccIdCS' => mapAccIdCS
                                                                    };
            List<Account> listAcc = XC_REST_Account_U.getAccountList(mapUtil);
            
            if(!listAcc.isEmpty()) {

                if(String.isNotBlank(mapHeader.get('X-UniqueID'))){
                    validateResult = XC_UTIL_RESTInbound.wso2AuthCheck(listAcc[0].Id, mapHeader);
                    if(validateResult.errorFlag) {  
                        wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                        wrResp.Result.ErrorCode = validateResult.errorCode;
                        return;
                    }
                }

                wrResp.Result.Message = 'Operation completed successfully';
                wrResp.Result.ErrorCode = '0';
                Map<Id, Map<Individual, List<XC_LegalEntityConsent__c>>> mapIndLegal = XC_REST_Account_U.createMapIndividualLegal(listAcc);

                Map<String, Object> mapUtilResponse = new Map<String, Object>{  'listAcc' => listAcc,
                                                                                'wrResp' => wrResp,
                                                                                'mapIndLegal' => mapIndLegal,
                                                                                'mapAccIdOrder' => mapAccIdOrder,
                                                                                'mapAccIdCS' => mapAccIdCS,
                                                                                'clientSystem' => mapHeader.get('ClientSystem')
                                                                                };
                XC_REST_Account_U.createResponseGET(mapUtilResponse);
            
            } else {
                wrResp.Result.Message = Label.XC_CL_AccountNotFound;
                wrResp.Result.ErrorCode = '400';
                logError = 'ERROR. Account not found';
            }

        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError);
            
        } finally {
            
            if(wrResp.Result.ErrorCode != '0'){
                wrResp.Account = null;
                logError = String.isBlank(logError) ? wrResp.Result.Message : logError;
            }

            if(wrResp.Account != null) {
                for(XC_UTIL_Account.AccountIFWrapper accWr : wrResp.Account) {
                    accWr.Stream = null;
                }
            }
            msgResponse = JSON.serialize(wrResp, true);
            msgResponse = msgResponse.replace('CurrencyName', 'Currency');
            msgResponse = msgResponse.replace('DeliveryAddress', 'ShippingAddress');
            msgResponse = msgResponse.replace('Credit Card SIA', 'Credit Card');
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);

            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.ErrorCode == '0'){
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }else{
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader;
        }
    }


    /**
    * @description  Method to create Account and its related objects (Contacts, Addresses and Billing Profiles) from an external request
    */
    @HttpPost
    global static void doPost() {

        String msgRequest = ''; 
        String msgResponse = '';
        String logError = '';
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();
        System.Savepoint beforeInsertAccSavepoint;
        if(!Test.isRunningTest())
        {
            beforeInsertAccSavepoint = Database.setSavepoint();
        }

        try{
            mapHeader = request.headers;
            System.debug('###mapHeader' + mapHeader);

            msgRequest = request.requestbody.tostring();
            msgRequest = msgRequest.replace('Currency', 'CurrencyName');
            msgRequest = msgRequest.replace('ShippingAddress', 'DeliveryAddress');
            msgRequest = msgRequest.replace('"Codice Fiscale"', '"CF"');
            msgRequest = msgRequest.replace('"Vatican City"','"Holy See (Vatican City State)"');

            intLog.insertIntegReqInboundLog('Account', msgRequest);
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);
            
            // replace tab character and multiple space with single space            
            msgRequest = msgRequest.replaceAll('\\\\t', ' ');
            msgRequest = msgRequest.replaceAll('\\s+', ' ');

            XC_REST_Account_W.WrapperRequest wrReq = (XC_REST_Account_W.WrapperRequest) JSON.deserialize(msgRequest,XC_REST_Account_W.WrapperRequest.class);

            XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Account', 'create');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }            
            
            // Check required fields
            validateResult = XC_REST_Account_V.validateRequestPOST(mapHeader, wrReq);
            if(validateResult.errorFlag) {
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                logError = 'ERROR. ' + validateResult.errorMessage;
                System.debug('####' + wrResp.Result.Message);
                return;
            }

            XC_REST_Account_U.manageInsert(wrReq, wrResp, mapHeader);

        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError); 

        } finally {
            
            if(wrResp.Result.ErrorCode != '0'){
                List<String> errorCodeList = new List<String>{'501', '502', '503'}; 
                if(errorCodeList.contains(wrResp.Result.ErrorCode)){
                    wrResp.Contact = null;
                    wrResp.Address = null;
                    wrResp.BillingProfile = null;
                    wrResp.Identity = null;

                }else if (wrResp.Result.Message == 'INTERNAL ERROR: In Address Section, Address already exist' && mapHeader.get('ClientSystem') == 'XRecharge') {
                    wrResp.Contact = null;
                    wrResp.BillingProfile = null;
                    wrResp.Identity = null;
                    wrResp.Account = null;

                } else if ((wrResp.Result.Message == 'INTERNAL ERROR: In Contact Section, '+ Label.XC_CL_ContactDuplicationError || wrResp.Result.Message == 'INTERNAL ERROR: In Contact Section, '+ Label.XC_CL_GuestContactDuplicationError)
                            && mapHeader.get('ClientSystem') == 'XRecharge') {
                    wrResp.BillingProfile = null;
                    wrResp.Identity = null;
                    wrResp.Account = null;
                    wrResp.Address = null;

                }else {
                    wrResp.Contact = null;
                    wrResp.Address = null;
                    wrResp.BillingProfile = null;
                    wrResp.Identity = null;
                    wrResp.Account = null;
                }
                if(!Test.isRunningTest())
                {       
                    Database.rollback(beforeInsertAccSavepoint);
                }
                if(String.isBlank(logError)) {
                    logError = wrResp.Result.logError;
                }
            }
          
            wrResp.Result.logError = null;
            if(wrResp.Account != null && wrResp.Account.Stream != null) {
                wrResp.Account.Stream = null;
            }
            msgResponse = JSON.serialize(wrResp, true);
            msgResponse = msgResponse.replace('DeliveryAddress', 'ShippingAddress');
            msgResponse = msgResponse.replace('Credit Card SIA', 'Credit Card');
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);

            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.ErrorCode == '0'){
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }else{
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader;   
        }
    }



    /**
    * @description  Method to update an Account and to update/insert Contacts, Addresses, Billing Profiles related to it
    */
    @HttpPut
    global static void doPut() {

        String msgRequest = '';
        String msgResponse = '';
        String logError = ''; 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();
        System.Savepoint beforeUpdateAccSavepoint;
        if(!Test.isRunningTest()){
            beforeUpdateAccSavepoint = Database.setSavepoint();
        }
        
        try{

            mapHeader = request.headers;
            msgRequest = request.requestbody.tostring();
            msgRequest = msgRequest.replace('Currency', 'CurrencyName');
            msgRequest = msgRequest.replace('ShippingAddress', 'DeliveryAddress');
            msgRequest = msgRequest.replace('"Codice Fiscale"', '"CF"');
            msgRequest = msgRequest.replace('"Vatican City"','"Holy See (Vatican City State)"');

            intLog.insertIntegReqInboundLog('Account', msgRequest);
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);
            
            // replace tab character and multiple space with single space            
            msgRequest = msgRequest.replaceAll('\\\\t', ' ');
            msgRequest = msgRequest.replaceAll('\\s+', ' ');
            
            XC_REST_Account_W.WrapperRequest wrReq = (XC_REST_Account_W.WrapperRequest) JSON.deserialize(msgRequest,XC_REST_Account_W.WrapperRequest.class);

            XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Account', 'update');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }            
            
            // Check required fields
            validateResult = XC_REST_Account_V.validateRequestPUT(mapHeader, wrReq);
            if(validateResult.errorFlag) {
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                logError = 'ERROR. ' + validateResult.errorMessage;
                System.debug('####' + wrResp.Result.Message);
                return;
            }

            XC_REST_Account_U.manageUpdate(wrReq, wrResp, mapHeader);
            
        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError);

        } finally {
            
            if(wrResp.Result.ErrorCode != '0'){
                if(wrResp.Result.ErrorCode == '501'){
                    wrResp.Contact = null;
                    wrResp.Address = null;
                    wrResp.BillingProfile = null;
                    wrResp.Identity = null;

                } else if (wrResp.Result.Message == 'INTERNAL ERROR: In Address Section, Address already exist' && mapHeader.get('ClientSystem') == 'XRecharge') {
                    wrResp.Contact = null;
                    wrResp.BillingProfile = null;
                    wrResp.Identity = null;
                    wrResp.Account = null;

                } else if ((wrResp.Result.Message == 'INTERNAL ERROR: In Contact Section, '+ Label.XC_CL_ContactDuplicationError || wrResp.Result.Message == 'INTERNAL ERROR: In Contact Section, '+ Label.XC_CL_GuestContactDuplicationError)
                            && mapHeader.get('ClientSystem') == 'XRecharge') {
                    wrResp.BillingProfile = null;
                    wrResp.Identity = null;
                    wrResp.Account = null;
                    wrResp.Address = null;

                }else{
                    wrResp.Contact = null;
                    wrResp.Address = null;
                    wrResp.BillingProfile = null;
                    wrResp.Identity = null;
                    wrResp.Account = null;
                }
                if(!Test.isRunningTest()){
                    Database.rollback(beforeUpdateAccSavepoint);
                }
                if(String.isBlank(logError)){
                    logError = wrResp.Result.logError;
                }
            }
            wrResp.Result.logError = null;
            if(wrResp.Account != null && wrResp.Account.Stream != null) {
                wrResp.Account.Stream = null; 
            }
            msgResponse =  JSON.serialize(wrResp, true);
            msgResponse = msgResponse.replace('DeliveryAddress', 'ShippingAddress');
            msgResponse = msgResponse.replace('Credit Card SIA', 'Credit Card');
            XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
            lw.accountID = wrResp.Account!=null?wrResp.Account.AccountID:null;
            intLog.setAdditionalInformations(lw);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);
        	
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.ErrorCode == '0'){
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            else{
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader;   
        }
    }

}