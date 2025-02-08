/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 13/11/2020
* @description REST INTERFACE : 
*/
public class XC_REST_Subscription_Outbound {  

    public class ResponseWrapper {
        public XC_UTIL_Integration.Result result = new XC_UTIL_Integration.Result();
    } 

    public class RequestWrapper {
        public SubscriptionWrapper Subscription; 
    } 

    public class SubscriptionWrapper {
        public String asset_id;
        public String channel;
        public String pod;
        public String activation_date;
        public String result_type;
        public List<SubscriptionItemWrapper> SubscriptionItem;
    }

    public class SubscriptionItemWrapper {
        public String id;
        public String validity_from;
        public String rectification_subscr;
        public String delay_estimation;
    }


	/**
	* @description activateCall
	* @param wrapperInput
	* @return the response wrapper
	*/
	public static ResponseWrapper activateCall(RequestWrapper wrapperInput) {
		ResponseWrapper result = new ResponseWrapper();
		
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('ActivateSubscription'); 
        if(isActiveInterface.activeInterface){

			String url = isActiveInterface.url;
           
		    String body = JSON.serialize(wrapperInput, true);
            System.debug('[WbeOutbound] request body -> ' + body);
     
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'ActivateSubscription', 'Next');

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'ActivateSubscription');
	
			try {
				result = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);

			} catch(Exception e){
				XC_UTIL_Debug.debug(true, 'Error: '+e);

			}
          
        } else{
            result = manageResponseFake();
        }

		System.debug('[WbeOutbound] result -> ' + result);
		return result; 
    }

    
    /**
	* @description activateCall
	* @param wrapperInput
	* @return the response wrapper
	*/
	public static ResponseWrapper deactivateCall(RequestWrapper wrapperInput) { 
		ResponseWrapper result = new ResponseWrapper();
		
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('DeactivateSubscription'); 
        if(isActiveInterface.activeInterface){

			String url = isActiveInterface.url;
           
		    String body = JSON.serialize(wrapperInput, true);
            System.debug('[WbeOutbound] request body -> ' + body);
     
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'DeactivateSubscription', 'Next');

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'DeactivateSubscription');

			try {
				result = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);

			} catch(Exception e){
				XC_UTIL_Debug.debug(true, 'Error: '+e);

			}
          
        } else{
            result = manageResponseFake();
        }

		System.debug('[WbeOutbound] result -> ' + result);
		return result; 
    }
    
    
    public static ResponseWrapper manageResponseFake(){
        
        ResponseWrapper response = new ResponseWrapper();
        response.result.ErrorCode = '200';
        response.result.Message = 'Interface Inactive, Fake Response Success';
        return response;
    }
}