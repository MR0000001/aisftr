/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 07/10/2019 
* @description REST INTERFACE : Product Object
*/
@RestResource(urlMapping='/v1/Product/*') 
global class XC_REST_Product {

     /**
     * @description Do GET.
     */
    @HttpGet
    global static void doGet() {

        String msgResponse = '';
        String logError = ''; 
        RestRequest request = RestContext.request;
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_Product_U.ResponseWrapper wrResp = new XC_REST_Product_U.ResponseWrapper();
        Map<String, String> mapHeader;

        try {
            mapHeader = request.headers;
            intLog.insertIntegReqInboundLog('Product', JSON.serialize(RestContext.request.params));
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(RestContext.request.httpMethod);

            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_Product_U.validateRequest(RestContext.request.params, mapHeader);
            if(validateResult.errorFlag) {
                wrResp.result.message = validateResult.errorMessage; 
                wrResp.result.error_code = '400';
                return; 
            }

            List<XC_REST_Product_U.ProductWrapper> prodList = XC_REST_Product_U.getProductFromGlovia(RestContext.request.params);

            wrResp.product = prodList;
            wrResp.result.message = 'Operation completed successfully';
            wrResp.result.error_code = '200';         
        
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