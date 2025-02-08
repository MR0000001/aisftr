/**
 * The Class XC_REST_VerifyPaymentMethods.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 13/12/2018
 * @date Modification : dd/mm/yyyy
 * @description       : XC_REST_VerifyPaymentMethods – Rest Resourse to verify a Payment Method
 **/

public class XC_REST_VerifyPaymentMethods {

    /**
     * The Class WrapperRequest.
     *
     * @description wrapper request of REST call
     */
    public class WrapperRequest {
        
        /** The gateway options. */
        public GatewayOptions gatewayOptions = new GatewayOptions();
        
        /** The payment gateway name. */
        public String paymentGatewayName;
        
        /** The security code. */
        public String securityCode;
    }


    /**
     * The Class GatewayOptions.
     *
     * @description GatewayOptions wrapper
     */
    public class GatewayOptions {
        
        /** The Comments. */
        public String Comments;
        
        /** The IP address. */
        public String IPAddress;
    }


    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperResponse {
        
        /** The success. */
        public Boolean success;
        
        /** The payment method id. */
        public String paymentMethodId;
    }


    /**
     * VerifyPaymentMethod.
     *
     * @param paymentMethodID the payment method ID
     * @param wrReq the wr req
     * @return the wrapper response
     * @description method to send a request for verifing a Payment Method
     */
    public static WrapperResponse verifyPaymentMethod(String paymentMethodID, WrapperRequest wrReq) {
        WrapperResponse result = new WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_VerifyPaymentMethods);
		if(isActiveInterface.activeInterface) {
            Map<String, String> infoZuora = XC_UTIL_Integration.getInfosForZuoraRest();

            String url = isActiveInterface.url.replace('paymentMethodID', paymentMethodID);
			String body =  JSON.serialize(wrReq, true);

            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
            headerDefinitions.put('Authorization', 'Bearer ' + infoZuora.get('access_token'));
            headerDefinitions.put('Zuora-Entity-Ids', infoZuora.get('zuora_ids'));
            
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);
	  		//HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'VerifyPaymentMethods');
 	  		HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'VerifyPaymentMethods');
   
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
		} else {
            result.success = true;
            result.paymentMethodId = 'FakeID';
		}

        System.debug('RESULT ---> ' + result);
        return result;
    }
    
}