/**
* @author            : Federico Amici federico.amici@nttdata.com
* @date Creation     : 21/12/2018
* @date Modification : 01/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Modification : 23/06/2020 by Dario Tramontin - dtramontin@deloitte.it
* @description       : XC_REST_ActivateRFID – Rest Resource
*/

@RestResource(urlMapping='/v1/ActivateRFID/*')
global with sharing class XC_REST_ActivateRFID {
        

    /**
     * @description Do put.
     */
    @HttpPut
    global static void doPut() {

        String msgRequest = ''; 

        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;

        Map<String, String> mapHeader = new Map<String, String>();
        XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp = new XC_REST_ActivateRFID_U.WrapperRFIDResponse();

        try {

            mapHeader = request.headers;
            msgRequest =  request.requestbody.toString();
            intLog.insertIntegReqInboundLog('ActivateRFID', msgRequest); 
            intLog.setHeader(mapHeader);            
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod); 

            XC_REST_ActivateRFID_U.WrapperRFIDRequest wrReq = (XC_REST_ActivateRFID_U.WrapperRFIDRequest) JSON.deserialize(msgRequest,XC_REST_ActivateRFID_U.WrapperRFIDRequest.class);
            
            //Validate Request
            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_ActivateRFID_U.validateRequest(mapHeader, wrReq.requestElement);
            if(validateResult.errorFlag){
                XC_REST_ActivateRFID_U.WrapperResponseElement wrElementResp = new XC_REST_ActivateRFID_U.WrapperResponseElement();
                wrElementResp.outcome = 'KO';
                wrElementResp.outcomeDescription = validateResult.errorMessage;
                wrElementResp.outcomeCode = '400';
                wrElementResp.logError = wrElementResp.outcomeDescription;
                wrElementResp.SfaCard = null;
                wrResp.responseElement.add(wrElementResp);
                return;
            }

            //do Action
            XC_REST_ActivateRFID_U.manageActivateCards(wrReq, wrResp);

        } catch(Exception e) {

            wrResp.responseElement = new List<XC_REST_ActivateRFID_U.WrapperResponseElement>();

            XC_REST_ActivateRFID_U.WrapperResponseElement wrElementResp = new  XC_REST_ActivateRFID_U.WrapperResponseElement();
            wrElementResp.outcome = 'KO';
            wrElementResp.outcomeDescription = 'INTERNAL ERROR';
            wrElementResp.outcomeCode = '500';
            wrElementResp.logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            wrElementResp.SfaCard = null;
            wrResp.responseElement.add(wrElementResp);

        } finally {

            XC_REST_ActivateRFID_D.manageOutcomeCode(mapHeader, wrResp, intLog);
        }
    }    


}