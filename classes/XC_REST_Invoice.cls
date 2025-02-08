/**
* @author Simone Trenta - strenta@deloitte.it, Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 29/01/2020
* @description REST INTERFACE : Invoice Object 
*/   
@RestResource(urlMapping='/v1/Invoice/*')   
global without sharing class XC_REST_Invoice {

    /**
    * @description handle the Get request
    */
    @HttpGet 
    global static void doGet() { 
        String requestURL = ''; 
        String msgResponse = '';
        String logError = '';
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_Invoice_W.ReadInvoiceInboundResponse wrResp = new XC_REST_Invoice_W.ReadInvoiceInboundResponse();
        Map<String, String> mapHeader = new Map<String, String>();

        
        try{

            mapHeader = request.headers;
            String apiKey = request.params.remove('api_key');
            intLog.insertIntegReqInboundLog('Invoice', JSON.serialize(request.params));
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);
            
            // Check required fields
            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_Invoice_U.validateGetRequest(mapHeader, request.params);
            if(validateResult.errorFlag) {
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                logError = 'ERROR. ' + validateResult.errorMessage;
                return;
            }

            //UniqueID check
            if(String.isNotBlank(mapHeader.get('X-UniqueID'))){
                String idf = '';

                if(String.isNotBlank(request.params.get('account_id'))){
                    idf = request.params.get('account_id');
                } else if(String.isNotBlank(request.params.get('order_item_id'))){
                    idf = request.params.get('order_item_id');
                } else if(String.isNotBlank(request.params.get('asset_id'))){
                    idf = request.params.get('asset_id');
                }

                validateResult = XC_UTIL_RESTInbound.wso2AuthCheck(idf, mapHeader);
                if(validateResult.errorFlag) {  
                    wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                    wrResp.Result.ErrorCode = validateResult.errorCode;
                    return;
                }
            }
        
            wrResp.Invoice = XC_REST_Invoice_U.getInvoiceResult(request.params);
            if(wrResp.Invoice.isEmpty()){
                wrResp.Result.Message = 'ERROR. Invoice not found';
                wrResp.Result.ErrorCode = '400';
                return;
            } else {
                wrResp.Result.Message = 'Operation completed successfully';
                wrResp.Result.ErrorCode = '0';
            }
            
        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            wrResp.Result.Message += logError; 
            
        } finally {
            
            if(wrResp.Result.ErrorCode != '0'){
                wrResp.Invoice = null;
                logError = String.isBlank(logError) ? wrResp.Result.Message : logError;
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

}