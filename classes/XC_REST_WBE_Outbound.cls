/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 18/02/2020
* @description REST INTERFACE : 
*/
public class XC_REST_WBE_Outbound {

	/**
	* @description callToPostWBE
	* @param wrapperInput, serverSystem (S4P, D4P)
	* @return the response wrapper
	*/
	public static XC_REST_WBE_Inbound_U.ResponseWrapper callToPostWBE(XC_REST_WBE_Inbound_U.RequestWrapper wrapperInput, String serverSystem) {
		XC_REST_WBE_Inbound_U.ResponseWrapper result = new XC_REST_WBE_Inbound_U.ResponseWrapper();
		
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('CreateWBE'); 
        if(isActiveInterface.activeInterface){

			String url = isActiveInterface.url;
           
		    String body = JSON.serialize(wrapperInput, true);
            System.debug('[WbeOutbound] request body -> ' + body);
     
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'WBE', serverSystem);

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
			System.debug('[WbeOutbound] request -> ' + request);

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'WbeOutbound');

			System.debug('[WbeOutbound] response -> ' + response);

            /********************* Parse response ********************************************/
            System.debug('[WbeOutbound] response body -> ' + response.getBody());
	
			try {
				result = (XC_REST_WBE_Inbound_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_WBE_Inbound_U.ResponseWrapper.class);

			} catch(Exception e){
				XC_UTIL_Debug.debug(true, 'Error: '+e);

			}
          
        } else{
            result = manageResponseFake();
        }

		System.debug('[WbeOutbound] result -> ' + result);
		return result; 
	}
    
    public static XC_REST_WBE_Inbound_U.ResponseWrapper manageResponseFake(){
        
        XC_REST_WBE_Inbound_U.ResponseWrapper response = new XC_REST_WBE_Inbound_U.ResponseWrapper();
        response.result.error_code = '200';
        response.result.message = 'Interface Inactive, Fake Response Success';
        return response;
    }
}