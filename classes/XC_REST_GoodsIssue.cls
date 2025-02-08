/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 07/10/2019 
* @description REST INTERFACE : Product Object
*/
@RestResource(urlMapping='/v1/GoodsIssue/*') 
global class XC_REST_GoodsIssue {

     /**
     * @description Do post.
     */
    @HttpPost
    global static void doPost() {

        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 
        RestRequest request = RestContext.request;
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_GoodsIssue_U.ResponseWrapper wrResp = new XC_REST_GoodsIssue_U.ResponseWrapper();
        Map<String, String> mapHeader;

        try {
            mapHeader = request.headers;
            msgRequest = request.requestbody.tostring();
            intLog.insertIntegReqInboundLog('GoodsIssue', msgRequest);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(RestContext.request.httpMethod);
            
            XC_REST_GoodsIssue_U.RequestWrapper wrReq = (XC_REST_GoodsIssue_U.RequestWrapper) JSON.deserialize(msgRequest, XC_REST_GoodsIssue_U.RequestWrapper.class);
            
			XC_UTIL_Integration.WrapperResult validateResult = XC_REST_GoodsIssue_U.validateRequest(wrReq, mapHeader);
            if(validateResult.errorFlag) {
                wrResp.result.message = validateResult.errorMessage; 
                wrResp.result.error_code = '400';
                return; 
            }

            wrResp = XC_REST_GoodsIssue_U.createGoodsIssue(wrReq);    
        
        } catch(Exception e) {
            wrResp.result.message = 'INTERNAL ERROR';
            wrResp.result.error_code = '500';
            logError = 'INTERNAL ERROR: ' + e.getMessage() +'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
       
        } finally {
            msgResponse =  JSON.serialize(wrResp, true);
            intLog.insertIntegRespInboundLog((wrResp.result.error_code=='0'?'200':wrResp.result.error_code), (wrResp.result.error_code=='0'?true:false), msgResponse, logError);
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            restContextResponseWrapper.errorCode = (wrResp.result.error_code=='0'?'200':wrResp.result.error_code);
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        }

    }

}