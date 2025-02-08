/*****************************************************************************************************************
* @author :          : Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 	 : 26/11/2019
* @date Modification :
* @description :     : XC_REST_GoodReceipt_Outbound 

******************************************************************************************************************/

public class XC_REST_GoodReceipt_Outbound {

	/**
	* @description callToPostGoodsReceipt
	* @param wrapperInput
	* @return the response wrapper
	*/
	public static XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper callToPostGoodsReceipt(XC_REST_GoodsReceipt_Inbound_U.RequestWrapper wrapperInput, String serverSystem) {
		XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper result = new XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper();
		
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('CreateGoodReceipt'); 
        if(isActiveInterface.activeInterface){

			String url = isActiveInterface.url;
           
		    String body = JSON.serialize(wrapperInput, true);
            System.debug('[GoodsReceiptOutbound] request body -> ' + body);
     
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'GoodsReceipt', serverSystem);

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
			System.debug('[GoodsReceiptOutbound] request -> ' + request);

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'GoodsReceiptOutbound');

			System.debug('[GoodsReceiptOutbound] response -> ' + response);

            /********************* Parse response ********************************************/
            System.debug('[GoodsReceiptOutbound] response body -> ' + response.getBody());
	
			try {
				result = (XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper.class);

			} catch(Exception e){
				XC_UTIL_Debug.debug(true, 'Error: '+e);

			}
          
		}

		System.debug('[GoodsReceiptOutbound] result -> ' + result);
		return result; 
	}


    /**
	* @description callToPutGoodsReceipt
	* @param wrapperInput
	* @return the response wrapper
	*/
	public static XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper callToPutGoodsReceipt(XC_REST_GoodsReceipt_Inbound_U.RequestWrapper wrapperInput , String serverSystem) {
		XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper result = new XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper();
		
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('UpdateGoodReceipt'); 
        if(isActiveInterface.activeInterface){
 
			String url = isActiveInterface.url;
           
		    String body = JSON.serialize(wrapperInput, true);
            System.debug('[GoodsReceiptOutbound] request body -> ' + body);
     
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Cancellation', 'GoodsReceipt', serverSystem);

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);
			System.debug('[GoodsReceiptOutbound] request -> ' + request);

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'GoodsReceiptOutbound');

			System.debug('[GoodsReceiptOutbound] response -> ' + response);

            /********************* Parse response ********************************************/
            //System.debug('[GoodsReceiptOutbound] response body -> ' + response.getBody());

			try {
            	result = (XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_GoodsReceipt_Inbound_U.ResponseWrapper.class);

			} catch(Exception e){
				XC_UTIL_Debug.debug(true, 'Error: '+e);

			}

		}

		System.debug('[GoodsReceiptOutbound] result -> ' + result);
		return result; 
	}
}