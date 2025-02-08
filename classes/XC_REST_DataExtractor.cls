/**
 * The class XC_REST_DataExtractor
 *
 * @author            : Simone Trenta - strenta@deloitte.it
 * @date Creation     : 22/07/2020
 * @date Modification : dd/mm/yyyy
 * @description       : rest class XC_REST_DataExtractor
 **/

@RestResource(urlMapping='/v1/DataExtractor/*')
global class XC_REST_DataExtractor {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_DataExtractor');

    /**
     * @description Do post.
     */
    @HttpPost
    global static void doPost() { 
        
        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_DataExtractor_U.WrapperResponse wrResp = new XC_REST_DataExtractor_U.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();
            
        try {
            mapHeader = request.headers;
            msgRequest = request.requestBody.toString();
            intLog.insertIntegReqInboundLog('DataExtractor', msgRequest);                                /* Insert the body of the request in the log */
            intLog.setHeader(mapHeader);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            XC_REST_DataExtractor_U.WrapperRequest wrReq = (XC_REST_DataExtractor_U.WrapperRequest) JSON.deserialize(msgRequest, XC_REST_DataExtractor_U.WrapperRequest.class);

            //Validate Request
            XC_UTIL_Integration.WrapperResult result = XC_REST_DataExtractor_U.validateRequest(mapHeader, wrReq);
            if(result.errorFlag) {
                wrResp.Result.Message = 'ERROR. ' + result.errorMessage;
                wrResp.Result.ErrorCode = '400'; 
                return; 
            }

            wrResp = XC_REST_DataExtractor_U.getFileResponse(wrReq); 

        } catch(Exception e) {
                
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError);
        
        } finally {

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

}