/**
 * @author             Luisana Rocco lrocco@deloitte.it
 * @date Creation       12/02/2021
 * @date Modification   dd/mm/yyyy
 * @description         XC_REST_AssetList – Rest Resourse to retrieve asset list
 */

@RestResource(urlMapping='/v1/AssetList/*')
global without sharing class  XC_REST_AssetList {

    /**
    * @description Do get.
    */
    @HttpGet
    global static void doGet() {

        String requestURL = ''; 
        String msgResponse = '';
        String logError = '';
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_AssetList_W.WrapperResponseGET wrResp = new XC_REST_AssetList_W.WrapperResponseGET();
        Map<String, String> mapHeader = new Map<String, String>();
        
        try{

            mapHeader = request.headers;
            intLog.insertIntegReqInboundLog('AssetList', JSON.serialize(request.params));
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);
                
            
            XC_UTIL_Integration.WrapperResult resultWrapper = XC_UTIL_RESTInbound.checkObjectPermission('Asset', 'read');
            if(resultWrapper.errorFlag){
                wrResp.Result.message = resultWrapper.errorMessage; 
                wrResp.Result.logError = resultWrapper.errorMessage; 
                wrResp.Result.error_code = '400';
                return; 
            }            
            
            resultWrapper = XC_REST_AssetList_U.checkReadParams(request.params, mapHeader);
            if(resultWrapper.errorFlag) {
                wrResp.Result.message = resultWrapper.errorMessage;
                wrResp.Result.logError = resultWrapper.errorMessage;
                wrResp.Result.error_code = '400';
                return;

            } else {
                wrResp = XC_REST_AssetList_U.createWrapperResponse(request.params);
            }

        } catch(Exception e) {
            wrResp.Result.message = 'INTERNAL ERROR';
            wrResp.Result.error_code = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            
        } finally {
            
            if(String.isBlank(logError)) {
                logError = wrResp.Result.logError;
            }
            wrResp.Result.logError = null;

            msgResponse =  JSON.serialize(wrResp, true);
        
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.error_code == '0') {
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper); 
            } else {
                restContextResponseWrapper.errorCode = wrResp.Result.error_code;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }  
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader;  

            intLog.insertIntegRespInboundLog((wrResp.Result.error_code=='0'?'200':wrResp.Result.error_code), (wrResp.Result.error_code =='0'?true:false), msgResponse, logError);  
        } 
    }


}