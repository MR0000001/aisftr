/**
 * The Class XC_REST_UpdateCreditCardPaymentMethod.
 *
 * @author            : Luca Tedeschi ltedeschi@deloitte.it - Simone Trenta strenta@deloitte.it
 * @date Creation     : 01/02/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse to updates an existing credit card payment method for the specified customer account
 **/

public class XC_REST_UpdateCreditCardPaymentMethod {
    

    /**
    * UpdateCreditCardPaymentMethod
    *
    * @param paymentMethodId the payment method id
    * @param wrReq the wr req
    * @return the wrapper response
    * @description method to Updates an existing credit card payment method
    */
    public static XC_REST_UpdateCreditCardPaymentMethod_U.WrapperResponse updateCreditCardPaymentMethod(String paymentMethodId,
                                                                                                        XC_REST_UpdateCreditCardPaymentMethod_U.WrapperRequest wrReq) {
        XC_REST_UpdateCreditCardPaymentMethod_U.WrapperResponse result = new XC_REST_UpdateCreditCardPaymentMethod_U.WrapperResponse();
        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_UpdateCreditCardPaymentMethod); 
        if(isActiveInterface.activeInterface) {
            Map<String, String> infoZuora = XC_UTIL_Integration.getInfosForZuoraRest();
            
            String url = isActiveInterface.url.replace('PaymentMethodId', PaymentMethodId);
            String body =  JSON.serialize(wrReq, true);
            
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
            headerDefinitions.put('Authorization', 'Bearer ' + infoZuora.get('access_token'));
            headerDefinitions.put('Zuora-Entity-Ids', infoZuora.get('zuora_ids'));
            
            if((!String.isBlank(wrReq.cardHolderName) ||
                !String.isBlank(wrReq.expirationMonth) ||
                !String.isBlank(wrReq.expirationYear)) &&
                (String.isBlank(wrReq.securityCode))){
            	result.success = false;
                //result.reasons.message = 'The CVV or CVV2 security code for the credit card or debit card  is required if changing expirationMonth, expirationYear, or cardHolderName.';
                return result;
            }
            
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body); 
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'UpdateCreditCardPaymentMethod');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'UpdateCreditCardPaymentMethod');
            result = (XC_REST_UpdateCreditCardPaymentMethod_U.WrapperResponse) 
                        JSON.deserialize(response.getBody(), XC_REST_UpdateCreditCardPaymentMethod_U.WrapperResponse.class);               
            
        } else {
            result.success = true;
            result.paymentMethodId = 'Fake Id';
        }
        
        System.debug('RESULT ---> ' + result);
        return result;
    }
    
}