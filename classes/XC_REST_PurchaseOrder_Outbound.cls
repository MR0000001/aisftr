/*****************************************************************************************************************
* @author :          : Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 	 : 26/11/2019
* @date Modification :
* @description :     : XC_REST_PurchaseOrder_Outbound 

******************************************************************************************************************/

public class XC_REST_PurchaseOrder_Outbound {    
    
    
    public class PurchaseOrderInboundResponseWrapper{
        public XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper result = new XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper();
        public List<XC_Integration_Log__c> integrationLog = new List<XC_Integration_Log__c>();
        
    }

	/**
	* @description callToPostPurchaseOrder  
	* @param wrapperInput
	* @return the response wrapper
	*/
	public static PurchaseOrderInboundResponseWrapper callToPostPurchaseOrder(XC_REST_PurchaseOrder_Inbound_U.RequestWrapper wrapperInput, String serverSystem) {
		XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper result = new XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper();
		PurchaseOrderInboundResponseWrapper purchaseOrderInboundResponseWr = new PurchaseOrderInboundResponseWrapper();
        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('CreatePurchaseOrder'); 
        if(isActiveInterface.activeInterface){

			String url = isActiveInterface.url;
           
		    String body = JSON.serialize(wrapperInput, true);
            System.debug('[PurchaseOrderOutbound] body -> ' + body);
     
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'PurchaseOrder', serverSystem);

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
			System.debug('[PurchaseOrderOutbound] request -> ' + request);
			
            // fix 08.06.2020
            XC_UTIL_RESTCallout.HttpResponseWrapper responseWrapper = XC_UTIL_RESTCallout.sendRequestLoggingNoIntegrationLog(request, headerDefinitions, 'PurchaseOrderOutbound');
            HttpResponse response = responseWrapper.response;
            List<XC_Integration_Log__c> integrationLogList = responseWrapper.integrationLog;
            
			System.debug('[PurchaseOrderOutbound] response -> ' + response);

            /********************* Parse response ********************************************/

			try {
                purchaseOrderInboundResponseWr.result = (XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper.class);
				purchaseOrderInboundResponseWr.integrationLog = integrationLogList;
			} catch(Exception e){
				XC_UTIL_Debug.debug(true, 'Error: '+e);

			}

		}

		System.debug('[PurchaseOrderOutbound] result -> ' + purchaseOrderInboundResponseWr.result);
		return purchaseOrderInboundResponseWr; 
	}

	/**
	* @description callToPutPurchaseOrder
	* @param wrapperInput
	* @return the response wrapper
	*/
	public static PurchaseOrderInboundResponseWrapper callToPutPurchaseOrder(XC_REST_PurchaseOrder_Inbound_U.RequestWrapper wrapperInput,String serverSystem) {
        PurchaseOrderInboundResponseWrapper purchaseOrderInboundResponseWr = new PurchaseOrderInboundResponseWrapper();
		XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper result = new XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper();
		
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('UpdatePurchaseOrder'); 
        if(isActiveInterface.activeInterface){

			String url = isActiveInterface.url;
           
		    String body = JSON.serialize(wrapperInput, true);
            System.debug('[PurchaseOrderOutbound] body -> ' + body);
     
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Update', 'PurchaseOrder', serverSystem);

            /********************** Send outbound request *************************************/
			XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);
			System.debug('[PurchaseOrderOutbound] request -> ' + request);
            XC_UTIL_RESTCallout.HttpResponseWrapper responseWrapper = XC_UTIL_RESTCallout.sendRequestLoggingNoIntegrationLog(request, headerDefinitions, 'PurchaseOrderOutbound');
			HttpResponse response = responseWrapper.response;
            List<XC_Integration_Log__c> integrationLogList = responseWrapper.integrationLog;
			System.debug('[PurchaseOrderOutbound] response -> ' + response);

            /********************* Parse response ********************************************/

			try {
				purchaseOrderInboundResponseWr.result = (XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper.class);
			    purchaseOrderInboundResponseWr.integrationLog = integrationLogList;
			} catch(Exception e){
				XC_UTIL_Debug.debug(true, 'Error: '+e);

			}

		}

		System.debug('[PurchaseOrderOutbound] result -> ' + purchaseOrderInboundResponseWr.result);
		return purchaseOrderInboundResponseWr; 
	}
    

}