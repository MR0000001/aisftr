/**
 * The Class XC_REST_DoxeeFileInCategory.
 *
 * @author            : Giulio Serra
 * @date Creation     : 03/01/19
 * @date Modification : 29/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : get a file in a category inside Doxee
 **/


@RestResource(urlMapping = '/v1/FileInCategory/*')
global without sharing class XC_REST_DoxeeFileInCategory {

    /**
     * Do Post.
     *
     * @description method to update the number of file for a category
     */
    @HttpPost
    global static void doPost() {

        String msgRequest = '';
        String msgResponse = '';
        String logError = '';
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
      	XC_REST_DoxeeFileInCategory_U.ResponseWrapper wrResp = new XC_REST_DoxeeFileInCategory_U.ResponseWrapper();
        Map<String, String> mapHeader = new Map<String, String>();

        try {
            mapHeader = request.headers;
            msgRequest =  request.requestbody.tostring();

            // Log
            intLog.insertIntegReqInboundLog('FileInCategory', msgRequest);
            intLog.setHeader(mapHeader);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
          	intLog.setHttpMethod(request.httpMethod);

            XC_REST_DoxeeFileInCategory_U.RequestWrapper wrReq = (XC_REST_DoxeeFileInCategory_U.RequestWrapper) JSON.deserialize(msgRequest, XC_REST_DoxeeFileInCategory_U.RequestWrapper.class);

            //Validate Request
            XC_UTIL_Integration.WrapperResult validateRequest = XC_REST_DoxeeFileInCategory_U.validateRequest(mapHeader, wrReq);
            if(validateRequest.errorFlag) {

                wrResp.Result.Message = 'ERROR. ' + validateRequest.errorMessage;
                wrResp.Result.ErrorCode = '400';
                System.debug('###' +  wrResp.Result.Message);
                return;
            }
            
            XC_REST_DoxeeFileInCategory_U.updateDocumentSignature(wrReq);
            
            wrResp = XC_REST_DoxeeFileInCategory_U.createFiles(wrReq);

            
        } catch (Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();

        } finally {

            if(wrResp.Result.ErrorCode != '0' && String.isBlank(logError)) {
                if(String.isNotBlank(wrResp.Result.logError)) {
                    logError = wrResp.Result.logError;
                } else {
                    logError = wrResp.Result.Message;
                }
            }

            wrResp.Result.logError = null;
			msgResponse = JSON.serialize(wrResp, true);
			intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0' ? '200' : wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0' ? true : false), msgResponse, logError);

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