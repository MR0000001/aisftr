/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 18/02/2020
* @description REST INTERFACE : 
*/
@RestResource(urlMapping='/v1/WBE/*')
global class XC_REST_WBE_Inbound {

    /**
     * @description Do put.
     */
    @HttpPut
    global static void doPut() {
        String msgRequest = '';
        String msgResponse = '';
        String logError = '';
        String logResp = '';
        String logMess = '';
        String manageMess = '';
        String legalEnt = '';
        String streams = '';
        RestRequest request = RestContext.request;
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_WBE_Inbound_U.ResponseWrapper wrResp = new XC_REST_WBE_Inbound_U.ResponseWrapper();
        Map<String, String> mapHeader;

        try {
            mapHeader = request.headers;
            msgRequest = request.requestbody.tostring();
            intLog.setHeader(mapHeader);
            intLog.insertIntegReqInboundLog('WBE', msgRequest);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(RestContext.request.httpMethod);
            String checkIsActive ='';
            String checkIsFake ='';
            String fromWBE ='';
            String fromWBS ='';


            XC_REST_WBE_Inbound_U.RequestWrapper wrReq = (XC_REST_WBE_Inbound_U.RequestWrapper) JSON.deserialize(msgRequest, XC_REST_WBE_Inbound_U.RequestWrapper.class);

            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_WBE_Inbound_U.validatePutRequest(wrReq, mapHeader);
            if(validateResult.errorFlag) {
                wrResp.result.message = validateResult.errorMessage;
                system.debug('Wrapp Error Message'+' '+wrResp.result.message);
                wrResp.result.error_code = '400';
                return;
            }

            //separare
            List<String> wid = new List<String>();


            for(XC_REST_WBE_Inbound_U.WbeWrapper w : wrReq.wbes){
                wid.add(w.wbe);
            }
            Map<Id, XC_WbeTracking__c> mapW = new Map<Id, XC_WbeTracking__c>([
                    SELECT Id,XC_Wbe__c, XC_Status__c
                    FROM XC_WbeTracking__c
                    WHERE XC_Wbe__c in: wid
            ]);
            System.debug('WBE queryMap: '+mapW);

            if(mapW.isEmpty()) {
                wrResp.result.message = 'WBE not found.';
                wrResp.result.error_code = '400';
                return;
            }

            for(XC_REST_WBE_Inbound_U.WbeWrapper w : wrReq.wbes) {
                for (XC_WbeTracking__c wbt : mapW.values()) {
                    if(wbt.XC_Status__c !='Approved') {
                        if (w.wbe == wbt.XC_WBE__C) {
                            if (w.wbe_error_code == '0' || w.wbe_error_code == 'OK') {
                                wbt.XC_Status__c = 'Approved';
                                wbt.XC_ReturnDate__c = DateTime.now();
                                wbt.XC_ProjectDimension__c = w.projectDimension;

                            } else {
                                wbt.XC_Status__c = 'Rejected';
                                wbt.XC_ReturnDate__c = DateTime.now();
                                wbt.XC_ReturnErrorcode__c = w.wbe_error_code;
                                wbt.XC_ReturnErrorDescription__c = w.wbe_message;
                            }
                        }
                    }
                }
            }
            XC_UTIL_Sobject.updateListRecords(mapW.values());
            if(wid.size() == wid.size()){
                wrResp.result.message = 'SUCCESS.';
                wrResp.result.error_code = '0';
            } else {
                String success ='SUCCESS for : ';
                String fail = 'ERROR for : ';
                for(String s : wid){
                    if(mapW.keyset().contains(s)){
                        success += s +', ';
                    } else{
                        fail += s +', ';
                    }
                }
                wrResp.result.error_code = '0';
                wrResp.result.message =  success + fail.substring(0, (fail.length()-2));
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
            logMess = '';
            manageMess = '';
            msgRequest = '';
            String reslt= '';
            String checkRes= '';
            String valid= '';
            Boolean fromWBE = true;
            Boolean fromWBS = true;
            if(fromWBE){
                fromWBS= false;
                logMess = '';
                manageMess = '';
                msgRequest = '';
                reslt = 'OK';
                checkRes = 'OK';
                valid = 'KO';
            }
        }

    }


}