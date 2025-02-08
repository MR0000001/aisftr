/**
 * The Class XC_REST_MobilityOrder.
 *
 * @author            : Simone Trenta - strenta@deloitte.it
 * @date Creation     : 07/02/2019
 * @date Modification : 30/04/2019 by Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : REST Interface to manage Order for eMobility
 **/ 


@RestResource(urlMapping='/v1/MobilityOrder/*') 
global without sharing class XC_REST_MobilityOrder {

    
    /**
     * Do post.
     *
     * @description method to create a order from an external request
     */
    @HttpPost
    global static void doPost() {

        String msgRequest = ''; 
        String msgResponse = ''; 
        String logError = ''; 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = new XC_REST_MobilityOrder_W.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();
        System.Savepoint beforeInsert;
        if(!Test.isRunningTest())
        {
            beforeInsert = Database.setSavepoint();
        }

        try{

            mapHeader = request.headers;
            msgRequest =  request.requestbody.tostring();
            intLog.insertIntegReqInboundLog('MobilityOrder', msgRequest);
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            msgRequest = msgRequest.replace('"OrderItem"', '"OrderItemList"');
            msgRequest = msgRequest.replaceAll('\\\\t', ' ');
            msgRequest = msgRequest.replaceAll('\\s+', ' '); 
            System.debug('@@After replace ' + msgRequest);
            XC_REST_MobilityOrder_W.WrapperRequest wrReq = (XC_REST_MobilityOrder_W.WrapperRequest) JSON.deserialize(msgRequest, XC_REST_MobilityOrder_W.WrapperRequest.class);
            wrReq.Order.ClientSystem = mapHeader.get('ClientSystem');

            XC_UTIL_IntegrationLog.LogWrapper logWrapper = new  XC_UTIL_IntegrationLog.LogWrapper();
           

            if(mapHeader.get('ClientSystem') != Label.XC_CL_CommoditySpainB2C) {

                XC_UTIL_Integration.WrapperResult validateResult = XC_REST_MobilityOrder_V.validateRequest(wrReq, mapHeader, 'POST');
                if(validateResult.errorFlag){
                    wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                    wrResp.Result.ErrorCode = '400';
                    logError = 'ERROR. ' + validateResult.errorMessage;
                    return;
                }

                // set additional integration log info 
                logWrapper.accountID = 	wrReq.Order.accountID;
                logWrapper.productCode =wrReq.Order.OrderItemList[0].EngineCode;
                intLog.setAdditionalInformations(logWrapper);


                XC_REST_MobilityOrder_U.manageInsert(wrReq, wrResp, mapHeader.get('TransactionID'));

            } else { // FOR COMMODITY

                XC_UTIL_Integration.WrapperResult validateResult = XC_REST_MobilityOrder_C.validateRequestCommodity(wrReq, mapHeader);
                if(validateResult.errorFlag){
                    wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                    wrResp.Result.ErrorCode = '400';
                    logError = 'ERROR. ' + validateResult.errorMessage;
                    return;
                }

                // set additional integration log info 
                logWrapper.accountDNI = wrReq.Order.AccountFiscalCode.split('\\|')[1] ;
                logWrapper.productCode = wrReq.Order.OrderItemList[0].EngineCode;
                intLog.setAdditionalInformations(logWrapper);

                XC_REST_MobilityOrder_C.manageInsertCommodity(wrReq, wrResp, mapHeader.get('TransactionID'));
            }

        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
        
        } finally {

            if(wrResp.Result.ErrorCode != '0') {
                if(!Test.isRunningTest()) {       
                    Database.rollback(beforeInsert);
                }
                
                if(String.isBlank(logError)) {
                    logError = wrResp.Result.logError;
                }
            }

            wrResp.Result.logError = null;
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
    

    /**
     * Do put.
     *
     * @description method to change order from an external request
     */
    @HttpPut
    global static void doPut() {

        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = new XC_REST_MobilityOrder_W.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();
       
        try{

            mapHeader = request.headers;
            msgRequest =  request.requestbody.tostring();
            intLog.insertIntegReqInboundLog('MobilityOrder', msgRequest);
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            XC_REST_MobilityOrder_W.WrapperRequest wrReq = (XC_REST_MobilityOrder_W.WrapperRequest) JSON.deserialize(msgRequest, XC_REST_MobilityOrder_W.WrapperRequest.class);
            wrReq.Order.ClientSystem = mapHeader.get('ClientSystem');
            
            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_MobilityOrder_V.validateRequest(wrReq, mapHeader, 'PUT');
            if(validateResult.errorFlag){
                wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                logError = wrResp.Result.Message;
                return;
            }

            // set additional integration log info 
            XC_UTIL_IntegrationLog.LogWrapper logWrapper = new  XC_UTIL_IntegrationLog.LogWrapper();
            logWrapper.accountID =  wrReq.Order.accountID;
            logWrapper.orderID = wrReq.Order.orderID;
            logWrapper.productCode = wrReq.Order.OrderItem.NewEngineCode;
            intLog.setAdditionalInformations(logWrapper);

            XC_REST_MobilityOrder_U.manageUpdate(wrReq, wrResp, mapHeader.get('TransactionID'));

        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
        
        } finally {

            if(wrResp.Result.ErrorCode != '0'&& String.isBlank(logError)) {
                logError = wrResp.Result.logError;
            }

            wrResp.Result.logError = null;
            msgResponse = JSON.serialize(wrResp, true);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);
            
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.ErrorCode == '0'){
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            } else{
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader;
        }
    }

}