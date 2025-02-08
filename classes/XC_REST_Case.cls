/**
 * The Class XC_REST_Case.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 24/12/2018
 * @date Modification : 03/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : XC_REST_Case – Rest Resource for case
 **/


@RestResource(urlMapping='/v1/Case/*')
global without sharing class XC_REST_Case {
    
    /*NicoloFodera 20220323 El.Sard. ToLabelTranslation [start]*/
    public static String currentClientSystem = '';
    /*NicoloFodera 20220323 El.Sard. ToLabelTranslation [end]*/
    /**
     * Do get.
     *
     * @description method to get a Case from an external request
     */
    @HttpGet
    global static void doGet() {

        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 

        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;

        XC_REST_Case_W.WrapperCaseResponseGET wrResp = new XC_REST_Case_W.WrapperCaseResponseGET();
        Map<String, String> mapHeader = request.headers;

        try{

            String apiKey = request.params.remove('api_key');
            intLog.insertIntegReqInboundLog('Case', JSON.serialize(request.params));                            /* Insert the body of the request in the log */
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);  

            XC_UTIL_Integration.WrapperResult resultWrapper = XC_UTIL_RESTInbound.checkObjectPermission('Case', 'read');
            if(resultWrapper.errorFlag){
                wrResp.Result.Message = resultWrapper.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }             
            
            resultWrapper = XC_UTIL_Integration.validateHeader(mapHeader);
            if(resultWrapper.ErrorFlag) {                                                                        /* Error in parsing the url */
                wrResp.Result.Message = 'ERROR. ' + resultWrapper.errorMessage;
                wrResp.Result.ErrorCode = '400';
                return;
            }

            /*NicoloFodera 20220323 El.Sard. ToLabelTranslation [start]*/
            currentClientSystem = mapHeader.get('ClientSystem');
            /*NicoloFodera 20220323 El.Sard. ToLabelTranslation [end]*/

            XC_REST_Case_V.manageGetCase(request.params, wrResp);
            
            if(mapHeader.get('ClientSystem')!='XRecharge' && wrResp.CaseList.size() != 0){/*NicoloFodera 20220323 Added && wrResp.CaseList.size() != 0*/
                wrResp.CaseList[0].GeolocalizationCountry = null;
            }

            XC_REST_Case_V.manageGetCase(request.params, wrResp);
            
            if(mapHeader.get('ClientSystem')!='XRecharge' && wrResp.CaseList.size() != 0){/*NicoloFodera 20220323 Added && wrResp.CaseList.size() != 0*/
                wrResp.CaseList[0].GeolocalizationCountry = null;
            }

            //UniqueID check

            if(String.isNotBlank(mapHeader.get('X-UniqueID')) && !wrResp.CaseList.isEmpty()){

                resultWrapper = XC_UTIL_RESTInbound.wso2AuthCheck(wrResp.CaseList[0].AccountID, mapHeader);
                if(resultWrapper.errorFlag) {  
                    wrResp.Result.Message = 'ERROR. ' + resultWrapper.errorMessage;
                    wrResp.Result.ErrorCode = resultWrapper.errorCode;
                    wrResp.CaseList = null;
                    return;
                }
            }

        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError);

        } finally {
            
            if(wrResp.Result.ErrorCode != '0' && String.isBlank(logError)) {
                logError = wrResp.Result.Message;
            }

            msgResponse = JSON.serialize(wrResp, true);
            msgResponse = msgResponse.replace('"CaseList"', '"Case"');
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
     * Do post.
     *
     * @description method to create a Case from an external request
     */
    @HttpPost
    global static void doPost() {
        
        System.Savepoint beforeInsertCaseSavepoint = Database.setSavepoint();

        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 

        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;

        XC_REST_Case_W.WrapperCaseResponseUpsert wrResp = new XC_REST_Case_W.WrapperCaseResponseUpsert();
        Map<String, String> mapHeader = request.headers;

        try{

            msgRequest = request.requestBody.toString();
            msgRequest = msgRequest.replace('"Case"', '"CaseX"');
            System.debug(msgRequest);
            intLog.setHeader(mapHeader);
            intLog.insertIntegReqInboundLog('Case', msgRequest);                            /* Insert the body of the request in the log */
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            /*********** Check the request body ***************/
            XC_REST_Case_W.WrapperCaseRequest caseWrapperRequest = 
                (XC_REST_Case_W.WrapperCaseRequest) JSON.deserialize(msgRequest, XC_REST_Case_W.WrapperCaseRequest.class);
           
            XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Case', 'create');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }             
            
            //Validate Request
            validateResult = XC_REST_Case_V.validateRequest(mapHeader, caseWrapperRequest, 'POST');
            if(validateResult.errorFlag){
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                return;

            } 

            //UniqueID check
            if(String.isNotBlank(mapHeader.get('X-UniqueID'))){

                validateResult = XC_UTIL_RESTInbound.wso2AuthCheck(caseWrapperRequest.casex.AccountID, mapHeader);
                if(validateResult.errorFlag) {  
                    wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                    wrResp.Result.ErrorCode = validateResult.errorCode;
                    return;
                }
            }

            wrResp = XC_REST_Case_U.insertCaseByWrapper(caseWrapperRequest, mapHeader.get('ClientSystem'));
 
        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError);

        } finally {
            
            if(wrResp.Result.ErrorCode != '0'){
                wrResp.CaseItem = null;
                Database.rollback(beforeInsertCaseSavepoint);
                if(String.isBlank(logError)) {
                    logError = wrResp.Result.Message;
                }
            }

            msgResponse = JSON.serialize(wrResp, true);
            msgResponse = msgResponse.replace('"CaseItem"', '"Case"');
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
     * Do put.
     *
     * @description method to update a Case from an external request
     */
    @HttpPut
    global static void doPut() {

        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 
        
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;

        msgRequest = msgRequest.replace('"Case"', '"CaseX"');

        XC_REST_Case_W.WrapperCaseResponseUpsert wrResp = new XC_REST_Case_W.WrapperCaseResponseUpsert();

        Map<String, String> mapHeader = request.headers;

        try{
            
            msgRequest = request.requestBody.toString();

            msgRequest = msgRequest.replace('"Case"', '"CaseX"');
            System.debug(msgRequest);

            intLog.setHeader(mapHeader);
            intLog.insertIntegReqInboundLog('Case', msgRequest);                            /* Insert the body of the request in the log */
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            /*********** Check the request body ***************/
            XC_REST_Case_W.WrapperCaseRequest caseWrapperRequest = 
                (XC_REST_Case_W.WrapperCaseRequest) JSON.deserialize(msgRequest, XC_REST_Case_W.WrapperCaseRequest.class);

            XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Case', 'update');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }   

            //Validate Request
            validateResult = XC_REST_Case_V.validateRequest(mapHeader, caseWrapperRequest, 'PUT');
            if(validateResult.errorFlag){
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                return;

            }
                
            wrResp = XC_REST_Case_U.updateCaseByWrapper(caseWrapperRequest);

        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError);

        } finally {

            if(wrResp.Result.ErrorCode != '0'){
                wrResp.CaseItem = null;
                if(String.isBlank(logError)) {
                    logError = wrResp.Result.Message;
                }
            }
            
            msgResponse =  JSON.serialize(wrResp, true);
            msgResponse = msgResponse.replace('"CaseItem"', '"Case"');
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

}