/**
 * The Class XC_REST_SMS.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it - Simone Trenta strenta@deloitte.it
 * @date Creation     : 13/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse for SMS
 */


@RestResource(urlMapping='/v1/SMS/*')
global without sharing class XC_REST_SMS {

    /**
     * @description Method to manage the response of send sms
     */
    @HttpPut
    global static void doPut() {

        String msgRequest = '';
        String msgResponse = '';
        String logError = ''; 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_SMS_W.WrapperResponse wrResp = new XC_REST_SMS_W.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();

        String bodyResponse = '';
        String statusCode = '200';
        
        try{

            mapHeader = request.headers;
            msgRequest = request.requestbody.tostring();
            msgRequest = msgRequest.replace('"Date"', '"DateSMS"');
            intLog.setHeader(mapHeader); 
            intLog.insertIntegReqInboundLog('SMS', msgRequest);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            msgRequest = msgRequest.replace('"Date"', '"DateSMS"');
            XC_REST_SMS_W.WrapperRequest wrReq = (XC_REST_SMS_W.WrapperRequest) JSON.deserialize(msgRequest, XC_REST_SMS_W.WrapperRequest.class);
            
            XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('XC_Customer_Interaction__c', 'update');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }   

            // Check required fields 
            validateResult = XC_REST_SMS_U.validateRequest(mapHeader, wrReq);
            if(validateResult.errorFlag) {
                bodyResponse = '';
                statusCode = '400';
                logError = 'ERROR. ' + validateResult.errorMessage;
                return;
            }

            List<XC_Customer_Interaction__c> interToUpdate = XC_REST_SMS_U.retrieveCustomerInteraction(wrReq.SMS.SMSID);
            if(interToUpdate.isEmpty()){
                bodyResponse = '';
                statusCode = '400';
                logError = 'ERROR. Customer Interaction ' +  Label.XC_CL_NotFount;
                return;
            }

            XC_Customer_Interaction__c i = interToUpdate[0];
            
            i.XC_SMSStatusCode__c = wrReq.SMS.StatusCode; 
            i.XC_SMSStatusDescription__c = wrReq.SMS.StatusDescription; 
            i.XC_SMSDate__c = Datetime.valueOf(wrReq.SMS.DateSMS); 
            i.XC_Sent__c = true; 
            
            XC_UTIL_Sobject.WrapperResult resUpdate = XC_UTIL_Sobject.updaterecord(i);
            if(!resUpdate.success) {
                bodyResponse = '';
                statusCode = '400';
                logError = 'ERROR. '+resUpdate.errorMessage;
                return;

            }

            bodyResponse = 'OK ' + DateTime.Now();
            
        } catch(Exception e) {

            bodyResponse = '';
            statusCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();

            /*wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('###' + logError);*/

        } finally {
            
            intLog.insertIntegRespInboundLog(statusCode, (statusCode=='200'?true:false), bodyResponse, logError);

            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = bodyResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            restContextResponseWrapper.errorCode = statusCode;
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);



            /*if(wrResp.Result.ErrorCode != '0'){
                if(String.isBlank(logError)){
                    logError = wrResp.Result.logError;
                }
            }
            wrResp.Result.logError = null;
            msgResponse =  JSON.serialize(wrResp, true);
            msgResponse = msgResponse.replace('DeliveryAddress', 'ShippingAddress');
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);
        
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.ErrorCode == '0'){
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            else{
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader; */
        }
    }
}