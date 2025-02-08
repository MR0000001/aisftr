public class XC_REST_CreateODA_Outbound {
    public class CreateODAOutboundResponseWrapper{
        public XC_REST_CreateODA_Outbound_U.ResponseWrapper result = new XC_REST_CreateODA_Outbound_U.ResponseWrapper();
        public List<XC_Integration_Log__c> integrationLog = new List<XC_Integration_Log__c>();
        
    }

	/**
	* @description callToPostCreateODA  
	* @param wrapperInput
	* @return the response wrapper
	*/
	public static CreateODAOutboundResponseWrapper callToPostCreateODA(XC_REST_CreateODA_Outbound_U.RequestWrapper wrapperInput, String serverSystem) {
		XC_REST_CreateODA_Outbound_U.ResponseWrapper result = new XC_REST_CreateODA_Outbound_U.ResponseWrapper();
		CreateODAOutboundResponseWrapper createODAInboundResponseWr = new CreateODAOutboundResponseWrapper();
        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('CreatePurchaseOrder');
        if(isActiveInterface.activeInterface){

			String url = isActiveInterface.url;
           
		    String body = JSON.serialize(wrapperInput, true);
		    //String body = JSON.serialize(wrapperInput);
            System.debug('[CreateODAOutbound] body -> ' + body);
     
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'PurchaseOrder', serverSystem);

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
			System.debug('[CreateODAOutbound] request -> ' + request);
			
            // fix 08.06.2020
            //dp XC_UTIL_RESTCallout.HttpResponseWrapper responseWrapper = XC_UTIL_RESTCallout.sendRequestLoggingNoIntegrationLog(request, headerDefinitions, 'PurchaseOrderOutbound');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'PurchaseOrderOutbound');
            //dp HttpResponse response = responseWrapper.response;
            //dp List<XC_Integration_Log__c> integrationLogList = responseWrapper.integrationLog;
            
			System.debug('[CreateODAOutbound] response -> ' + response);

            /********************* Parse response ********************************************/

			try {
                createODAInboundResponseWr.result = (XC_REST_CreateODA_Outbound_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_CreateODA_Outbound_U.ResponseWrapper.class);
				//dp createODAInboundResponseWr.integrationLog = integrationLogList;
			} catch(Exception e){
				XC_UTIL_Debug.debug(true, 'Error: '+e);

			}

		}

		System.debug('[CreateODAOutbound] result -> ' + createODAInboundResponseWr.result);
		return createODAInboundResponseWr; 
	}
}