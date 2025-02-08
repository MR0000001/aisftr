/**
 * @author              Giuseppe Di Bonito - gdibonito@deloitte.it
 * @date Creation       03/11/2020
 * @date Modification   
 * @description         XC_REST_AccountOpportunity – Rest Resourse for account and opportunity creation 
 */

@RestResource(urlMapping='/v1/AccountOpportunity/*')
global without sharing class XC_REST_AccountOpportunity {

            
    /**
     * Do post.
     *
     * @description  
     */
    @HttpPost
    global static void doPost() {
        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 
        RestRequest request = RestContext.request;
        XC_REST_AccountOpportunity_U.WrapperResponse wrResp = new XC_REST_AccountOpportunity_U.WrapperResponse();
        Map<String,String> header = request.headers;
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();

        try{
            msgRequest = request.requestbody.tostring();
            intLog.insertIntegReqInboundLog('AccountOpportunity', msgRequest);
            intLog.setHeader(header); 
            intLog.setTransactionID(header.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            XC_REST_AccountOpportunity_U.WrapperRequest wrReq = (XC_REST_AccountOpportunity_U.WrapperRequest) JSON.deserialize(msgRequest, XC_REST_AccountOpportunity_U.WrapperRequest.class);

            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_AccountOpportunity_U.validateQueuedRequest(wrReq, header);
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }
            
            wrResp = XC_REST_AccountOpportunity_U.insertQueuedRequest(wrReq, header);
            
        } catch(Exception e) {
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'INTERNAL ERROR: ' + e.getMessage() +'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
                    
        } finally {

            msgResponse =  JSON.serialize(wrResp, true);
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = header;
            restContextResponseWrapper.errorCode = (wrResp.Result.ErrorCode == '0')?'200':wrResp.Result.ErrorCode;
            RestContext.response = restContextResponseWrapper.res;     
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);

            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);
          
        }

    }
}