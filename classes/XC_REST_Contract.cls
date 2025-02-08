/**
 * The Class XC_REST_Contract.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 18/12/2018
 * @date Modification : 29/05/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : XC_REST_Contract – Rest Resource for Contract
 **/


@RestResource(urlMapping='/v1/Contract/*') 
global without sharing class XC_REST_Contract {

    /**
     * Do get.
     *
     * @description Method to get Contract from external request
     */
    @HttpGet
    global static void doGet(){

        String msgRequest = '';
        String msgResponse = '';
        String logError = ''; 

        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;

        XC_REST_Contract_W.WrapperContractResponse wrResp = new XC_REST_Contract_W.WrapperContractResponse();
        Map<String, String> mapHeader = request.headers;

        try{
            intLog.setHeader(mapHeader);
            intLog.setHttpMethod(request.httpMethod);
            String apiKey = request.params.remove('api_key');
            intLog.insertIntegReqInboundLog('Contract', JSON.serialize(request.params));        /* Insert the body of the request in the log */
            intLog.setTransactionID(mapHeader.get('TransactionID'));

            XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Contract', 'read');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }   
            
            //Validate Request
            validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
            if(validateResult.ErrorFlag) {                                                                        /* Error in parsing the url */
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                return;
            }

            XC_REST_Contract_U.manageGetContract(request.params, wrResp);           
            
        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            wrResp.Contract = null;
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError);

        } finally {
            System.debug(LoggingLevel.INFO,'-- finally --');

            if(wrResp.Result.ErrorCode == '500'){
                wrResp.Contract = null;
                if(String.isBlank(logError)) {
                    logError = wrResp.Result.Message;
                }
            }

            msgResponse = JSON.serialize(wrResp, true);
            msgResponse = msgResponse.replace('"Currency_x":', '"Currency":');
            msgResponse = msgResponse.replace('"Currency_x" :', '"Currency" :');

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