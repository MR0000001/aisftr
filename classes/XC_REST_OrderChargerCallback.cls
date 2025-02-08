/**
 * The Class XC_REST_OrderChargerCallback.
 *
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @date Creation     : 02/07/2020
 * @date Modification : 
 * @description       : Market Italy callback 
 */

public without sharing class XC_REST_OrderChargerCallback {

    public class OrderCallbackRequest {
        public String source;
        public String type;
        public String integration_id;
        public String esito;
        public String codice;
        public String descrizione;
        public String lead_id;
        public String opportunity_id;
        public String result;
        public String result_message;
        public String transactionId;

    }

    public class OrderCallbackResponse {
        public Boolean success;
        public String id;
        public String integration_id;
        public String lead_id;
        public String errors;
    }

    /**
     * sendCallback.
     *
     * @param wrReq the wrapper request
     * @return the result wrapper
     * @description method to send the callback 
     */
    // public static OrderCallbackResponse sendCallback(OrderCallbackRequest wrReq, String serverSystem) {
    //     OrderCallbackResponse wrResp = new OrderCallbackResponse();
        
    //     XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('OrderChargerCallback'); 
    //     if(isActiveInterface.activeInterface){

    //         String url = isActiveInterface.url;
    //         Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'OrderChargerCallback', serverSystem);
    //         String body = JSON.serialize(wrReq, true);

    //         /********************** Create outbound request *************************************/
    //         HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
    //         System.debug('[OrderChargerCallback] request -> ' + request);
    //         System.debug('[OrderChargerCallback] request BODY -> ' + body);

    //         /********************** Send outbound request *************************************/

    //         try{
    //             HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'OrderChargerCallback');
    //             wrResp = (OrderCallbackResponse) JSON.deserialize(response.getBody(), OrderCallbackResponse.class);
    //             return wrResp;

    //         } catch(exception e){
    //             System.debug('error in OrderChargerCallback: ' + e);
    //             wrResp.success = false;
    //             return wrResp;
    //         }
            
	// 	} else {
	// 		wrResp.success = false;
    //         // wrResp.errors = new List<String>();
    //         wrResp.errors = 'Inactive interface';
    //         return wrResp;
	// 	} 
    // }

    /**
    * @description parametric sendcallback
    * @author Francesco Imperioli - fimperioli@deloitte.it | 11-03-2020 
    * @param wrReq 
    * @param serverSystem 
    * @return OrderCallbackResponse 
    **/
    public static OrderCallbackResponse sendCallback(OrderCallbackRequest wrReq, String serverSystem,String interfaceName) {
        OrderCallbackResponse wrResp = new OrderCallbackResponse();
        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(interfaceName); 
        if(isActiveInterface.activeInterface){

            String url = isActiveInterface.url;
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'OrderChargerCallback', serverSystem);
            headerDefinitions.put('TransactionID', wrReq.transactionId);
            wrReq.transactionId = null;


            String body = JSON.serialize(wrReq, true);

            /********************** Create outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            System.debug('[OrderChargerCallback] request -> ' + request);
            System.debug('[OrderChargerCallback] request BODY -> ' + body);

            /********************** Send outbound request *************************************/

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'OrderChargerCallback');

            try{
                wrResp = (OrderCallbackResponse) JSON.deserialize(response.getBody(), OrderCallbackResponse.class);
                return wrResp;

            } catch(exception e){
                System.debug('error in OrderChargerCallback: ' + e);
                wrResp.success = false;
                return wrResp;
            }
            
		} else {
			wrResp.success = false;
            // wrResp.errors = new List<String>();
            wrResp.errors = 'Inactive interface';
            return wrResp;
		} 
    }


       
}