/**
 * The Class XC_REST_ShippingCost.
 *
 * @author            : Gklaras Dionysios dgklaras@deloitte.gr
 * @date Creation     : 13/04/2021
 * @date Modification : 13/04/2021
 * @description       : Rest Resourse for ShippingCost
 */

@RestResource(urlMapping='/v1/ShippingCost')
global without sharing class XC_REST_ShippingCost {

     /**
     * @description Method to manage retrieval of area
     */
    @HttpGet
    global static void doGet(){

        String msgRequest = '';
        String msgResponse = '';
        String logError = ''; 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_ShippingCost_W.WrapperResponse wrResp = new XC_REST_ShippingCost_W.WrapperResponse();
        Map<String, String> mapHeader = new Map<String, String>();
        
        try{
            mapHeader = request.headers;
            intLog.setHeader(mapHeader); 
            intLog.insertIntegReqInboundLog('ShippingCost', JSON.serialize(RestContext.request.params));
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);
            
            XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('XC_ShippingCostZone__c', 'read');
            if(validateResult.errorFlag){
                wrResp.Result.Message = validateResult.errorMessage; wrResp.Result.ErrorCode = '400';
                return; 
            }   

            // Check required fields 
            validateResult = XC_REST_ShippingCost_U.validateRequest(mapHeader, RestContext.request.params);
            if(validateResult.errorFlag) {
                wrResp.Result.Message = validateResult.errorMessage; 
                wrResp.Result.ErrorCode = '400'; 
                logError = 'ERROR. ' + validateResult.errorMessage;
                return;
            }

            XC_CM_CountryISOCodeAssociation__mdt countryAssoc = XC_CM_CountryISOCodeAssociation__mdt.getInstance(RestContext.request.params.get('Country'));
            if(countryAssoc == null) {
                wrResp.Result.Message = 'Country ISO Code Association not found'; 
                wrResp.Result.ErrorCode = '400'; 
                logError = 'ERROR. ' + 'Country ISO Code Association not found';
                return;
            }
            
            List<XC_ShippingCostZone__c> zoneList = [
                SELECT XC_Area__c
                FROM XC_ShippingCostZone__c
                WHERE XC_Country__c = :RestContext.request.params.get('Country')
                AND XC_KeyValue__c = :(String)RestContext.request.params.get(countryAssoc.XC_AreaFieldIdentifier__c)];
            
            if(zoneList.isEmpty()){
                wrResp.Result.Message = 'Shipping Cost Zone not found';
                wrResp.Result.ErrorCode = '400';
                return;
            }
                                            
            wrResp.ShippingCostArea = new XC_REST_ShippingCost_W.WrapperShippingCostArea();
            wrResp.ShippingCostArea.ShippingCostArea = zoneList[0].XC_Area__c;

            wrResp.Result.Message = 'Operation completed successfully'; wrResp.Result.ErrorCode = '0';

        } catch(QueryException e) {

            wrResp.Result.Message = 'Shipping Cost Zone not found'; wrResp.Result.ErrorCode = '400'; logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
    
        } catch(Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR'; wrResp.Result.ErrorCode = '500'; logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
        
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