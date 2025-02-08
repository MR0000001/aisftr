/**
* @author Lombardi Donato - dolombardi@deloitte.it
* @date Creation 10/06/2020
* @description REST INTERFACE :
*/
@RestResource(urlMapping='/v1/CalculateBillingPreview_SF')
global class XC_REST_BillingPreview_Inbound {

    /**
     * @description Do put.
     */
    @HttpPost
    global static void doPost() {
        String msgRequest = '';
        String msgResponse = '';
        String logError = '';
        RestRequest request = RestContext.request;
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_BillingPreview_Inbound_U.ResponseWrapper wrResp = new XC_REST_BillingPreview_Inbound_U.ResponseWrapper();
        Map<String, String> mapHeader;

        try {
            mapHeader = request.headers;
            msgRequest = request.requestbody.tostring();
            intLog.setHeader(mapHeader);
            intLog.insertIntegReqInboundLog('Zuora Billing Preview', msgRequest);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(RestContext.request.httpMethod);

            XC_REST_BillingPreview_Inbound_U.BillingPreviewWrapper wrReq = (XC_REST_BillingPreview_Inbound_U.BillingPreviewWrapper) JSON.deserialize(msgRequest, XC_REST_BillingPreview_Inbound_U.BillingPreviewWrapper.class);

            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_BillingPreview_Inbound_U.validatePutRequest(wrReq, mapHeader);

            Map<Id, NE__OrderItem__c> mapW = new Map<Id, NE__OrderItem__c>([
                    SELECT Id, XC_Charge_Amount__c, XC_Tax_AmountBillingPreviw__c, NE__OrderId__c, NE__OrderId__r.XC_TexVAT__c,
                            NE__OrderId__r.XC_Charge_Amount__c
                    FROM NE__OrderItem__c
                    WHERE id = :wrReq.configurationItem
            ]);

            List<NE__Order__c> listOrder = new List<NE__Order__c>();

            System.debug('OrderItem queryMap: '+mapW);  

            if(mapW.isEmpty()) {
                wrResp.result.message = 'OrderItem not found.';
                wrResp.result.error_code = '400';
                return;
            }

            if(mapW.get(wrReq.configurationItem)!= Null) {
                mapW.get(wrReq.configurationItem).XC_Charge_Amount__c = wrReq.amount;
                mapW.get(wrReq.configurationItem).XC_Tax_AmountBillingPreviw__c = wrReq.taxAmount;
            }

            List<XC_UTIL_Sobject.WrapperResult> listResult = XC_UTIL_Sobject.updateListRecords(mapW.values());
            //List<XC_UTIL_Sobject.WrapperResult> listResultOrder = XC_UTIL_Sobject.updateListRecords(listOrder);
            for(XC_UTIL_Sobject.WrapperResult res : listResult){
                if(res.success){
                    wrResp.result.message = 'SUCCESS.';
                    wrResp.result.error_code = '0';
                }else{
                    wrResp.result.error_code = '0';
                    wrResp.result.message =  res.errorMessage;
                    listOrder[0].XC_BillingPreviewStatus__c = 'Error';
                    listOrder[0].XC_BillingPreviewMessage__c = res.errorMessage;



                }

            }


        } catch(Exception e) {
            wrResp.result.message = 'INTERNAL ERROR';
            wrResp.result.error_code = '500';
            logError = 'INTERNAL ERROR: ' + e.getMessage() +'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            system.debug('logError'+' '+logError);
        } finally {
            msgResponse = JSON.serialize(wrResp, true);
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