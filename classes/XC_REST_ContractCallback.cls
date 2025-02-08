/**
* @author B.Ramayya -- bulli.bheemanaboyana@accenture.com
* @date Creation 08/02/2022
* @description XC_REST_ContractCallback – Apex Controller to call XC_UTIL_RESTCallout integration Methods
*/
public without sharing class XC_REST_ContractCallback {
    /**
     * @description Wrapperclass with the Request Parameters
     */
    public class ContractCallbackRequest {
        @AuraEnabled
        public String ExternalDocumentId{get; set;}
        @AuraEnabled
        public String ObjectId{get; set;}
        @AuraEnabled
        public String DocumentCategory{get; set;}
        @AuraEnabled
        public String Country{get; set;}
        @AuraEnabled
        public String ObjectType{get; set;}
        @AuraEnabled
        public String Description{get; set;}
        @AuraEnabled
        public String FileName{get; set;}
        @AuraEnabled
        public String Company{get; set;}
    }
    
    /**
     * @description Wrapperclass with the Response Parameters
     */
    public class ContractCallbackResponse {
        @AuraEnabled
        public String Error{get; set;}
        @AuraEnabled
        public String Message{get; set;}
    }
    
    /**
     * @description method to create outbound request and send outbound request
     * @param wrReq ,serverSystem- Request wrapper 
     * @return ContractCallbackResponse
     */
    public static ContractCallbackResponse callToPostContractFromEE(ContractCallbackRequest wrReq, string serverSystem) {
        ContractCallbackResponse wrResp = new ContractCallbackResponse();
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('CreateContract');
        if(isActiveInterface.activeInterface){
            String url = isActiveInterface.url;
            system.debug('URL:'+url);
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'Create', serverSystem);
            String body = JSON.serialize(wrReq, true);
            /********************** Create outbound request *************************************/
                HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
                System.debug('[OrderChargerCallback] request -> ' + request);
                System.debug('[OrderChargerCallback] request BODY -> ' + body);
            /********************** Send outbound request *************************************/
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'serverSystem');
            try{
                wrResp = (ContractCallbackResponse) JSON.deserialize(response.getBody(), ContractCallbackResponse.class);
                System.debug('response -> ' + wrResp);
                return wrResp;
            } catch(exception e){
                System.debug('error in OrderChargerCallback: ' + e);
                if(response!=null && (response.getStatusCode()!=200 || response.getStatusCode()!=202)){
                    integer statusCode = response.getStatusCode();
                    wrResp.Error = String.valueof(statusCode);
                    wrResp.Message = response.getStatus();
                    System.debug('error -> ' + wrResp.Error);
                    System.debug('message -> ' + wrResp.Message);
                }
                return wrResp;
            }
        } else {
            wrResp.Error = 'Inactive interface';
             return wrResp;
        }
    }
}