/**
 * ***************************************************************************************************.
 *
 * @author :             Nicola Mariniello nmariniello@deloitte.it
 * @date Creation :      20/02/2019
 * @date Modification :  dd/mm/yyyy
 * @description :        XC_REST_SuspendSubscription – Rest Resourse to suspend a Subscription
 * ****************************************************************************************************
 */

public class XC_REST_CreateAuthorization {

    /**
     * @description The Class WrapperRequest.
     */
    public class WrapperRequest {
        
        /** The account id. */
        public String accountId;            // Y
        
        /** The account number. */
        public String accountNumber;        // Y
        
        /** The amount. */
        public Decimal amount;              // Y
        
        /** The gateway order id. */
        public String gatewayOrderId;       // Y
        
        /** The soft descriptor. */
        public String softDescriptor;
        
        /** The soft descriptor phone. */
        public String softDescriptorPhone;
    }

    /**
     * @description The Class WrapperResponse.
     */
    public class WrapperResponse {
        
        /** The success. */
        public Boolean success;
        
        /** The gateway order id. */
        public String gatewayOrderId;
        
        /** The transaction id. */
        public String transactionId;
        
        /** The result code. */
        public Integer resultCode;
        
        /** The result message. */
        public String resultMessage;
        
        /** The process id. */
        public String processId;
        
        /** The reasons. */
        public List<Reasons> reasons = new List<Reasons>();
    }

    /**
     * @description The Class Reasons.
     */
    public class Reasons {
        
        /** The code. */
        public Integer code;
        
        /** The message. */
        public String message;
    }
    

    /**
     * *************************************************************************************************.
     *
     * @param paymentMethodId the payment method id
     * @param wrReq the wr req
     * @return the wrapper response
     * @description : Method to send a request to suspend a Subscription
     * **************************************************************************************************
     */
    public static WrapperResponse createAuthorization(String paymentMethodId, WrapperRequest wrReq) {
        WrapperResponse result = new WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_CreateAuthorization);
		if(isActiveInterface.activeInterface) {

            try {
                Map<String, String> infoZuora = XC_UTIL_Integration.getInfosForZuoraRest();

                String url = isActiveInterface.url.replace('paymentMethodId', paymentMethodId);
                String body =  JSON.serialize(wrReq, true);

                Map<String,String> headerDefinitions = new Map<String,String>();
                headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
                headerDefinitions.put('Authorization', 'Bearer ' + infoZuora.get('access_token'));
                headerDefinitions.put('Zuora-Entity-Ids', infoZuora.get('zuora_ids'));

                HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
                //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'CreateAuthorization');
                HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'CreateAuthorization');

                result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);

            } catch(Exception e) {
                result.success = false;
                Reasons r = new Reasons();
                r.message = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
                result.reasons.add(r);
            }
            
		} else {
            result.success = true;
            result.gatewayOrderId = 'FakeID';
		}

        System.debug('RESULT ---> ' + result);
        return result;
    }
}