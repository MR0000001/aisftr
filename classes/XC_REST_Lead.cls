/**
 * The Class XC_REST_Lead.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : dd/mm/yyyy
 * @date Modification : 16/04/2019 by Nicola Mariniello nmariniello@deloitte.it
 * @description       : XC_REST_Lead – Rest Resourse for Create/Update Lead
 **/


@RestResource(urlMapping='/v1/Lead/*') 
global without sharing class XC_REST_Lead {

    /**
     * DoPost.
     *
     * @description method to insert a Lead from an external request
     **/
    @HttpGet
    global static void doGet() {
    
        String requestURL = ''; 
        String msgResponse = '';
        String logError = '';
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_Lead_W.WrapperLeadResponse wrResp = new XC_REST_Lead_W.WrapperLeadResponse();
        Map<String, String> mapHeader = new Map<String, String>();
        
        try{

            mapHeader = request.headers;
            String apiKey = request.params.remove('api_key');
            intLog.insertIntegReqInboundLog('Lead', JSON.serialize(request.params));
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Lead', 'read');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return;
            } 
            
            // Check required fields
            validateResult = XC_REST_Lead_V.validateGetRequest(mapHeader, request.params); 
            if(validateResult.errorFlag) {
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                logError = 'ERROR. ' + validateResult.errorMessage;
                System.debug('####' + wrResp.Result.Message);
                return;
            }
        
            wrResp = XC_REST_Lead_S.getLeadWrapper(request.params, mapHeader); 

        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError);
            wrResp.Result.Message += logError; 
            
        } finally {
            
            if(wrResp.Result.ErrorCode != '0'){
                wrResp.Account = null;
                wrResp.Lead = null;
                logError = String.isBlank(logError) ? wrResp.Result.Message : logError;
            }
                        
            if(wrResp.Lead != null && wrResp.Lead.Stream != null) {
                wrResp.Lead.Stream = null;
            }

            msgResponse = JSON.serialize(wrResp, true);
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
     * DoPost.
     *
     * @description method to insert a Lead from an external request
     **/
    @HttpPost
    global static void doPost() {

        System.Savepoint beforeInsertLeadSavepoint = Database.setSavepoint();

        String msgRequest = ''; 
        String msgResponse = '';
        String logError = '';
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
		XC_REST_Lead_W.WrapperLeadResponse wrResp = new XC_REST_Lead_W.WrapperLeadResponse();
        Map<String, String> mapHeader = new Map<String, String>();

        try {

            mapHeader = request.headers;                            /* Retrieve the Map of the headers */
            msgRequest = request.requestbody.tostring().replace('ShippingAddress"', 'DeliveryAddress"');            /* Retrieve the body of the request*/
            intLog.insertIntegReqInboundLog('Lead', msgRequest);    /* Insert the body of the request in the log */
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            XC_REST_Lead_W.WrapperLeadRequest leadWrapperRequest =
                    (XC_REST_Lead_W.WrapperLeadRequest) JSON.deserialize(msgRequest, XC_REST_Lead_W.WrapperLeadRequest.class);

            XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Lead', 'create');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = validateResult.errorCode!=null?validateResult.errorCode:'400'; 
                return;
            } 
            
            //Validate Request
            validateResult = XC_REST_Lead_V.validateRequest(mapHeader, leadWrapperRequest, 'POST');
            if(validateResult.errorFlag) {                         /* If the lead passed was not correct */
                
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = validateResult.errorCode!=null?validateResult.errorCode:'400'; //
                return;

            } else {                                                /* If the wrapper was correctly validated */
                XC_REST_Lead_U.manageInsert(leadWrapperRequest.Lead, wrResp, mapHeader);
            }

        } catch(Exception e) {
                
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError);
        
        } finally {

            if(wrResp.Result.ErrorCode != '0'){
                
                if(wrResp.Result.ErrorCode != '501'){
                    wrResp.Lead = null;
                }
                Database.rollback(beforeInsertLeadSavepoint);
                if(String.isBlank(logError)) {
                    logError = wrResp.Result.logError;
                }
            }
            
            wrResp.Result.logError = null; 
            if(wrResp.Lead != null && wrResp.Lead.Stream != null) {
                wrResp.Lead.Stream = null;
            }
            msgResponse = JSON.serialize(wrResp, true);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);

            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.ErrorCode == '0') {
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            } else {
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader;
        }
    }


    /**
     * DoPut.
     *      
     * @description method to update a Lead from an external request
     */
    @HttpPut
    global static void doPut() {

        System.Savepoint beforeUpdateLeadSavepoint = Database.setSavepoint();

        String msgRequest = ''; 
        String msgResponse = '';
		String logError = ''; 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
		XC_REST_Lead_W.WrapperLeadResponse wrResp = new XC_REST_Lead_W.WrapperLeadResponse();
        Map<String, String> mapHeader = new Map<String, String>();

		try {
            
            mapHeader = request.headers;
            msgRequest = request.requestbody.tostring().replace('ShippingAddress', 'DeliveryAddress');      /* Retrieve the body of the request*/
            intLog.insertIntegReqInboundLog('Lead', msgRequest);                                            /* Insert the body of the request in the log */
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

			XC_REST_Lead_W.WrapperLeadRequest leadWrapperRequest = (XC_REST_Lead_W.WrapperLeadRequest) JSON.deserialize(msgRequest, XC_REST_Lead_W.WrapperLeadRequest.class);
            
            XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Lead', 'update');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            } 

            // Check required fields
            validateResult = XC_REST_Lead_V.validateRequest(mapHeader, leadWrapperRequest, 'PUT'); 
            if(validateResult.errorFlag){
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                return;
            }

            if(mapHeader.get('Operation') == 'Update') {
                XC_REST_Lead_T.manageUpdate(leadWrapperRequest.Lead, wrResp, mapHeader);
            } else {
                XC_REST_Lead_T.manageConvertLead(leadWrapperRequest.Lead, wrResp);
            }

        } catch (Exception e) {

            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError);

        } finally {
            
            if(wrResp.Result.ErrorCode != '0'){
                if(wrResp.Result.ErrorCode != '501'){
                    wrResp.Lead = null;
                }
                Database.rollback(beforeUpdateLeadSavepoint);
                if(String.isBlank(logError)) {
                    logError = wrResp.Result.logError;
                }
            }
            
            wrResp.Result.logError = null;
            
            if(wrResp.Lead != null && wrResp.Lead.Stream != null) {
                wrResp.Lead.Stream = null;
            }
            
            msgResponse =  JSON.serialize(wrResp, true);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);

            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.ErrorCode == '0'){
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            } else {
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader;
        }
    }

}