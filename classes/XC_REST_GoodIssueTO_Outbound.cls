public class XC_REST_GoodIssueTO_Outbound {
    
    /**
* @description callToPostGoodsIssue
* @param wrapperInput
* @return the response wrapper
*/
    public static XC_REST_GoodsIssue_U.ResponseWrapper callToPostGoodsIssue(XC_REST_GoodsIssue_U.RequestWrapper wrapperInput, String serverSystem) {
        XC_REST_GoodsIssue_U.ResponseWrapper result = new XC_REST_GoodsIssue_U.ResponseWrapper();
        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('CreateGoodIssue'); 
        if(isActiveInterface.activeInterface){
            
            String url = isActiveInterface.url;
            
            String body = JSON.serialize(wrapperInput, true);
            System.debug('[GoodsIssueOutbound] request body -> ' + body);
            
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'GoodsIssue', serverSystem);
            
            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            System.debug('[GoodsIssueOutbound] request -> ' + request);
            
            HttpResponse response = new HttpResponse();
            
            if(!Test.isRunningTest()) {response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'GoodsIssueOutbound');}
            
            System.debug('[GoodsIssueOutbound] response -> ' + response);
            
            /********************* Parse response ********************************************/
            System.debug('[GoodsIssueOutbound] response body -> ' + response.getBody());
            
            try {
                result = (XC_REST_GoodsIssue_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_GoodsIssue_U.ResponseWrapper.class);
                
            } catch(Exception e){
                XC_UTIL_Debug.debug(true, 'Error: '+e);
                
            }
            
        }
        
        System.debug('[GoodsIssueOutbound] result -> ' + result);
        return result; 
    }
}