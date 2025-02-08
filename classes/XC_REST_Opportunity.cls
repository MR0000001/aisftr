/**
 * The Class XC_REST_Opportunity.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 10/12/2018
 * @date Modification : 01/04/2019
 * @description       : XC_REST_Opportunity – Rest Resourse for Create Opportunity
 **/


@RestResource(urlMapping = '/v1/Opportunity/*')
global with sharing class XC_REST_Opportunity {  

    /**
     * Do post.
     *
     * @description method to insert an Opportunity from an external request
     */
    @HttpPost
    global static void doPost() {
        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_Opportunity_U.WrapperResponse wrResp = new XC_REST_Opportunity_U.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();
       
        try { 
            mapHeader = request.headers;
            msgRequest =  request.requestbody.tostring();
            XC_REST_Opportunity_U.WrapperRequest wrReq = (XC_REST_Opportunity_U.WrapperRequest) JSON.deserialize(msgRequest,XC_REST_Opportunity_U.WrapperRequest.class);
            intLog.insertIntegReqInboundLog('Opportunity', msgRequest);
            intLog.setHeader(mapHeader); 
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);

            //Validate Request
            XC_UTIL_Integration.WrapperResult validateResult = XC_REST_Opportunity_U.validateCreateRequestOpportunity(mapHeader, wrReq, 'POST');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                return;
            } 
                
            List<Opportunity> opportunityToInsert = new List<Opportunity> {XC_REST_Opportunity_U.createOpportunityFromWrapper(wrReq)};
            XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.insertRecord(opportunityToInsert.get(0));
            if(result.success == false) {
                wrResp.Result.Message = 'INTERNAL ERROR. ' + result.errorMessage;
                wrResp.Result.ErrorCode = '500';
                logError = result.errorMessage;
                return;
            } else {
                wrResp.Result.Message = 'Operation completed successfully';
                wrResp.Result.ErrorCode = '0'; 
                wrResp.Opportunity = new XC_UTIL_Opportunity.OpportunityIFWrapper();
                wrResp.Opportunity.OpportunityID = result.recordId;
                wrResp.Opportunity.ExecuteAssignment = null;                      
            }
            
        } catch (Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();

        } finally {

            if(wrResp.Result.ErrorCode != '0' && String.isBlank(logError)){
                logError = wrResp.Result.Message;
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
     * @description Do get.
     */
    @HttpGet
    global static void doGet() {
        
        String requestURL = ''; 
        String msgResponse = '';
        String logError = ''; 
        
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        
        XC_REST_Opportunity_U.WrapperGETResponse wrResp = new XC_REST_Opportunity_U.WrapperGETResponse();
        
        Map<String, String> mapHeader = request.headers;
        
        try{            
            intLog.insertIntegReqInboundLog('Opportunity', JSON.serialize(RestContext.request.params));  
            intLog.setHeader(mapHeader); 
            intLog.setHttpMethod(request.httpMethod);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            
            XC_UTIL_Integration.WrapperResult resultWrapper = XC_REST_Opportunity_U.validateReadRequestOpportunity(mapHeader, request.params);
            if(resultWrapper.errorFlag) {
                wrResp.Result.Message = 'ERROR. ' + resultWrapper.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return;
            } 
                
            wrResp.Opportunity = XC_REST_Opportunity_U.getOppResult(request.params);
            if(wrResp.Opportunity.size() > 0) {
                wrResp.Result.Message = 'Operation completed successfully';
                wrResp.Result.ErrorCode = '0';
            } else {
                wrResp.Result.Message = 'ERROR. Opportunity not found';
                wrResp.Result.ErrorCode = '400';
                wrResp.Opportunity = null;
            }

        } catch(Exception e) {
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
                        
        } finally {
            msgResponse =  JSON.serialize(wrResp, true);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);  
        
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