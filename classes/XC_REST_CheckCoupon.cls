/**
 * The Class XC_REST_CheckCoupon
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 12/12/2018
 * @date Modification : 02/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : Rest Resource for Check Coupon/Voucher
 **/


@RestResource(urlMapping='/v1/CheckCoupon/*')
global without sharing class XC_REST_CheckCoupon {

    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN018_CreateZQuote');


    /**
     * Do get.
     *
     * @description method to check a coupon
     */
    @HttpGet
    global static void doGet() {

        XC_UTIL_Debug.debug(DEBUGACTIVE, '-- IN GET METHOD --');

        String requestURL = ''; 
        String msgResponse = '';
        String logError = '';

        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;

        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp = new XC_REST_CheckCoupon_W.WrapperCheckCouponResponse();
        Map<String, String> mapHeader = new Map<String, String>();

        try{
                
            mapHeader = request.headers;
            String apiKey = request.params.remove('api_key');
            intLog.insertIntegReqInboundLog('CheckCoupon', JSON.serialize(request.params));
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            // Validate Request
            mapHeader.put('method', 'GET');
            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_CheckCoupon_V.validateRequest(mapHeader, null, request.params);
            if(validateResult.errorFlag) {
                wrResp.outcome = 'KO';
                wrResp.outcomeDescription = validateResult.errorMessage;
                wrResp.outcomeCode = '400';
                return;
            }

            // Do Actions
            request.params.put('method', 'GET');
            XC_REST_CheckCoupon_U.checkCouponGET(request.params, wrResp);

        } catch(Exception e) {
            
            wrResp.outcome = 'KO';
            wrResp.outcomeDescription = 'INTERNAL ERROR';
            wrResp.outcomeCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();

            XC_UTIL_Debug.debug(DEBUGACTIVE, '###' + logError);

        } finally {

            XC_REST_CheckCoupon_W.createHttpResponseGET(mapHeader, wrResp, intLog);
        }
    }


    /**
     * Do Post.
     *
     * @description method to check a coupon
     */
    @HttpPost
    global static void doPost() {

        XC_UTIL_Debug.debug(DEBUGACTIVE, '-- IN POST METHOD --');

        String msgRequest = '';

        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;

        XC_REST_CheckCoupon_W.WrapperResponse wrResp = new XC_REST_CheckCoupon_W.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();

        try{

            msgRequest = request.requestbody.tostring();
            mapHeader = request.headers;
            intLog.setHeader(mapHeader); 
            intLog.insertIntegReqInboundLog('CheckCoupon', msgRequest);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            XC_REST_CheckCoupon_W.WrapperCheckCouponRequest wrReq =
                (XC_REST_CheckCoupon_W.WrapperCheckCouponRequest) JSON.deserialize(msgRequest, XC_REST_CheckCoupon_W.WrapperCheckCouponRequest.class);
            
            // Validate Request
            mapHeader.put('method', 'POST');
            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_CheckCoupon_V.validateRequest(mapHeader, wrReq, null);
            if(validateResult.errorFlag) {
                XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp = new XC_REST_CheckCoupon_W.WrapperCheckCouponResponse();
                wrElementResp.outcome = 'KO';
                wrElementResp.outcomeCode = '400';
                wrElementResp.outcomeDescription = validateResult.errorMessage;
                wrElementResp.logError = null;
                wrResp.logError = wrElementResp.outcomeDescription;
                wrResp.errorCode = '400';
                wrResp.counterError++;
                wrResp.responseElement.add(wrElementResp);
                return;
            }
            
            // Do Actions
            if(mapHeader.get('Functionality') == 'CheckCoupon') {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '### Functionality: CheckCoupon');
                XC_REST_CheckCoupon_U.checkCouponPostPut(wrReq, wrResp, 'POST');
            } else if (mapHeader.get('Functionality') == 'ReadBulk') {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '### Functionality: ReadBulk');
                XC_REST_CheckCoupon_U.checkCouponReadBulk(wrReq, wrResp);
            }

        } catch(Exception e) {

            wrResp.responseElement = new List<XC_REST_CheckCoupon_W.WrapperCheckCouponResponse>();

            XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp = new XC_REST_CheckCoupon_W.WrapperCheckCouponResponse();
            wrElementResp.outcome = 'KO';
            wrElementResp.outcomeCode = '500';
            wrElementResp.outcomeDescription = 'INTERNAL ERROR';
            wrElementResp.logError = null;
            wrResp.logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            wrResp.errorCode = '500';
            wrResp.counterError++;
            wrResp.responseElement.add(wrElementResp);

            XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST, '### ' + wrElementResp.logError);

        } finally {
            XC_REST_CheckCoupon_W.createHttpResponsePostPut(mapHeader, wrResp, intLog);
        }
    }


    /**
     * Do put.
     *
     * @description method to burn a coupon
     */
    @HttpPut
    global static void doPut() {

        XC_UTIL_Debug.debug(DEBUGACTIVE, '-- IN PUT METHOD --');

        String msgRequest = '';

        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;

        XC_REST_CheckCoupon_W.WrapperResponse wrResp = new XC_REST_CheckCoupon_W.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();

        try{

            msgRequest = request.requestbody.tostring();
            mapHeader = request.headers;
            intLog.setHeader(mapHeader); 
            intLog.insertIntegReqInboundLog('CheckCoupon', msgRequest);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            XC_REST_CheckCoupon_W.WrapperCheckCouponRequest wrReq =
                (XC_REST_CheckCoupon_W.WrapperCheckCouponRequest) JSON.deserialize(msgRequest, XC_REST_CheckCoupon_W.WrapperCheckCouponRequest.class);
            
            // Validate Request
            mapHeader.put('method', 'PUT');
            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_CheckCoupon_V.validateRequest(mapHeader, wrReq, null);
            if(validateResult.errorFlag) {
                XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp = new XC_REST_CheckCoupon_W.WrapperCheckCouponResponse();
                wrElementResp.outcome = 'KO';
                wrElementResp.outcomeCode = '400';
                wrElementResp.outcomeDescription = validateResult.errorMessage;
                wrElementResp.logError = null;
                wrResp.logError = wrElementResp.outcomeDescription;
                wrResp.errorCode = '400';
                wrResp.counterError++;
                wrResp.responseElement.add(wrElementResp);
                return;
            }
            
            // Do Actions
            XC_REST_CheckCoupon_U.checkCouponPostPut(wrReq, wrResp, 'PUT');

        } catch(Exception e) {
            
            wrResp.responseElement = new List<XC_REST_CheckCoupon_W.WrapperCheckCouponResponse>();

            XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp = new XC_REST_CheckCoupon_W.WrapperCheckCouponResponse();
            wrElementResp.outcome = 'KO';
            wrElementResp.outcomeCode = '500';
            wrElementResp.outcomeDescription = 'INTERNAL ERROR';
            wrElementResp.logError = null;
            wrResp.logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            wrResp.errorCode = '500';
            wrResp.counterError++;
            wrResp.responseElement.add(wrElementResp);

            XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST, '### ' + wrElementResp.logError);

        } finally {
            XC_REST_CheckCoupon_W.createHttpResponsePostPut(mapHeader, wrResp, intLog);
        }
    }
    
}