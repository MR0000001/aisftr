/**
	* @description callToPostDeleteODA  
	* @author Andrea Di Cicco
	* @date creation 10/09/2020
	*/
public class XC_REST_DeleteODA_Outbound {
    public class DeleteODAOutboundResponseWrapper{
        public XC_REST_DeleteODA_Outbound_U.ResponseWrapper result = new XC_REST_DeleteODA_Outbound_U.ResponseWrapper();
        public List<XC_Integration_Log__c> integrationLog = new List<XC_Integration_Log__c>();
        
    }

	/**
	* @description callToPostDeleteODA  
	* @param wrapperInput
	* @return the response wrapper
	*/
	public static DeleteODAOutboundResponseWrapper callToPostDeleteODA(XC_REST_DeleteODA_Outbound_U.RequestWrapper wrapperInput, String serverSystem) {
		XC_REST_DeleteODA_Outbound_U.ResponseWrapper result = new XC_REST_DeleteODA_Outbound_U.ResponseWrapper();
		DeleteODAOutboundResponseWrapper DeleteODAInboundResponseWr = new DeleteODAOutboundResponseWrapper();
        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('DeleteODA');
        if(isActiveInterface.activeInterface){

			String url = isActiveInterface.url;
           
		    String body = JSON.serialize(wrapperInput, true);
            System.debug('[DeleteODAOutbound] body -> ' + body);
     
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('UpdateCancellation', 'UpdateCancellation', serverSystem);

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);
			System.debug('[DeleteODAOutbound] request -> ' + request);
			
            // fix 08.06.2020
            XC_UTIL_RESTCallout.HttpResponseWrapper responseWrapper = XC_UTIL_RESTCallout.sendRequestLoggingNoIntegrationLog(request, headerDefinitions, 'DeleteODAOutbound');
            HttpResponse response = responseWrapper.response;
            List<XC_Integration_Log__c> integrationLogList = responseWrapper.integrationLog;
            
			System.debug('[DeleteODAOutbound] response -> ' + response);

            /********************* Parse response ********************************************/

			try {
                DeleteODAInboundResponseWr.result = (XC_REST_DeleteODA_Outbound_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_DeleteODA_Outbound_U.ResponseWrapper.class);
				DeleteODAInboundResponseWr.integrationLog = integrationLogList;
			} catch(Exception e){
				XC_UTIL_Debug.debug(true, 'Error: '+e);

			}

		}

		System.debug('[DeleteODAOutbound] result -> ' + DeleteODAInboundResponseWr.result);
		return DeleteODAInboundResponseWr; 
	}
}