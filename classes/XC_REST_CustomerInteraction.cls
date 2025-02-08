/**
 * The Class XC_REST_CustomerInteraction.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 05/02/2019
 * @date Modification : 02/04/2019
 * @description       : Rest Resourse for Create CustomerInteraction
 **/


@RestResource(urlMapping='/v1/CustomerInteraction/*')
global with sharing class XC_REST_CustomerInteraction {

    /**
     * Do Post.
     *
     * @description method to create a Customer Interaction from an external request
     */
    @HttpPost
    global static void doPost() {

        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_CustomerInteraction_W.WrapperResponse wrResp = new XC_REST_CustomerInteraction_W.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();
       
        try{

            mapHeader = request.headers;
            msgRequest =  request.requestbody.tostring();
            XC_REST_CustomerInteraction_W.WrapperRequest wrReq = (XC_REST_CustomerInteraction_W.WrapperRequest) JSON.deserialize(msgRequest, XC_REST_CustomerInteraction_W.WrapperRequest.class);
            intLog.insertIntegReqInboundLog('CustomerInteraction', msgRequest);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_CustomerInteraction_U.validateRequest(mapHeader, wrReq);
            if(validateResult.errorFlag) {
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                return;

            } else {
                
                XC_REST_CustomerInteraction_UU.manageInsert(wrReq, wrResp);
            }

        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
        
        } finally {

            if(wrResp.Result.ErrorCode != '0' && String.isBlank(logError)){
                logError = wrResp.Result.logError;
            }

            wrResp.Result.logError = null;
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
}