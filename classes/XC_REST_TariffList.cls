/**
 * The Class XC_REST_TariffList.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 03/01/2019
 * @date Modification : 01/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : Rest Resource for GetTariffList
 **/


@RestResource(urlMapping='/v1/TariffList/*')
global class XC_REST_TariffList {  
    
    
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
        XC_REST_TariffList_W.WrapperResponse wrResp = new XC_REST_TariffList_W.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();
            
        try {
            mapHeader = request.headers;
            msgRequest = request.requestBody.toString();
            intLog.insertIntegReqInboundLog('TariffList', msgRequest);                                /* Insert the body of the request in the log */
            intLog.setHeader(mapHeader);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            XC_REST_TariffList_W.WrapperRequest wrReq = (XC_REST_TariffList_W.WrapperRequest) JSON.deserialize(msgRequest, XC_REST_TariffList_W.WrapperRequest.class);

            //Validate Request
            XC_UTIL_Integration.WrapperResult result = XC_REST_TariffList_W.validateRequest(mapHeader, wrReq);

            if(result.errorFlag) {
                wrResp.ResultDescription = 'ERROR. ' + result.errorMessage;
                wrResp.ResultCode = '400'; 
                wrResp.Result = 'KO';
                return; 
                
            } else { 
                wrResp.EnabledRatesList = XC_REST_TariffList_U.readTariffList(wrReq); 
                
                if(wrResp.EnabledRatesList != null && wrResp.EnabledRatesList.size() > 0) {
                    wrResp.ResultDescription = 'There are enabled e-mobility rates';
                    wrResp.ResultCode = 'EMOB002';
                    wrResp.Result = 'OK';
                } else {
                    wrResp.ResultDescription = 'There are not enabled e-mobility rates'; 
                    wrResp.ResultCode = 'EMOB003';
                    wrResp.Result = 'KO';
                }
            }

        } catch(Exception e) {

            wrResp.ResultDescription = 'INTERNAL ERROR';
            wrResp.ResultCode = '500';
            wrResp.Result = 'KO';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
        
        } finally {

            if(wrResp.ResultCode != 'EMOB002'){
                wrResp.EnabledRatesList = null;
                if(String.isBlank(logError)) {
                    logError = wrResp.ResultDescription;
                }
            }
            
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = JSON.serialize(wrResp, true).replaceAll('"CurrencyX"','"Currency"');
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.ResultCode == 'EMOB002') {
                restContextResponseWrapper.errorCode = '200';
                intLog.insertIntegRespInboundLog('200', true, restContextResponseWrapper.msgResponse, logError);
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            } else if(wrResp.ResultCode == 'EMOB003') {
                restContextResponseWrapper.errorCode = '400';
                intLog.insertIntegRespInboundLog('400', false, restContextResponseWrapper.msgResponse, logError);
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            } else {
                restContextResponseWrapper.errorCode = wrResp.ResultCode;
                intLog.insertIntegRespInboundLog(wrResp.ResultCode, false, restContextResponseWrapper.msgResponse, logError);
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            mapHeader = restContextResponseWrapper.mapHeader;
                
        }
    }
}