/**
 * The Class XC_REST_NotifyPayment.
 *
 * @author            : Riccardo Cossu - riccardo.cossu@nttdata.com
 * @date Creation     : 13/12/2018
 * @date Modification : 29/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : class to send a request to notify a payment
 **/


public class XC_REST_NotifyPayment {    
    

    /**
     * The Class WrapperResult.
     *
     * @description the wrapper result
     */
    public class WrapperResult {
        
        /** The success. */
        public Boolean success;
        
        /** The message. */
        public String message;
    }   
    

    /**
     * Creates the payment.
     *
     * @param wrapperPayment the wrapper payment
     * @return the wrapper result
     * @description method to send an external request for creating a payment
     */
    public static WrapperResult createPayment(XC_REST_NotifyPayment_U.WrapperRequest wrapperPayment) {
        
        WrapperResult result = new WrapperResult();
        Boolean activeInterface = XC_UTIL_RESTCallout.checkActiveInterface(Label.XC_CL_CreatePayment);
        if(activeInterface) {
            String url = '';
            String bodyToModify =  JSON.serialize(wrapperPayment, true);
            String body = replaceValueInJSON(bodyToModify);
            Map<String,String> headerDefinitions = new Map<String,String>{'Content-Type' => 'application/json;charset=UTF-8'};
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'CreatePayment'); 
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'CreatePayment');           
          
            result = manageResponse(response);
        } else {
            result = createWrapperResult(true, '201');
        }
        System.debug('RESULT ---> ' + result);
        return result;
    }
    

    /**
     * Creates the wrapper result.
     *
     * @param success the success
     * @param status the status
     * @return the wrapper result
     * @description method to create the wrapper result
     */
    public static WrapperResult createWrapperResult(Boolean success, String status) {
        WrapperResult wr = new WrapperResult();
        wr.success = success;
        wr.message = status;
        return wr;
    }
    

    /**
     * Manage response.
     *
     * @param response the response
     * @return the wrapper result
     * @description method to manage response
     */
    public static WrapperResult manageResponse(HttpResponse response) {
        WrapperResult result = new WrapperResult();
        XC_REST_NotifyPayment_U.WrapperResponse responseWrapper = (XC_REST_NotifyPayment_U.WrapperResponse) JSON.deserialize(response.getBody(), XC_REST_NotifyPayment_U.WrapperResponse.class);
        
        if(response.getStatusCode() != 201) {
            result = createWrapperResult(responseWrapper.success, responseWrapper.status);
        } else {
            result = createWrapperResult(responseWrapper.success,  responseWrapper.status);
        }
        return result;
    }
    
    
    /**
     * Replace value in JSON.
     *
     * @param bodyToModify the body to modify
     * @return the string
     * @description method to replace values in JSON
     */
    public static String replaceValueInJSON (String bodyToModify){
        
        bodyToModify = bodyToModify.replace('"currencyName"','"currency"');
        bodyToModify = bodyToModify.replace('"integrationId"','"IntegrationId__NS"');
        bodyToModify = bodyToModify.replace('"integrationStatus"','"IntegrationStatus__NS"');
        bodyToModify = bodyToModify.replace('"origin"','"Origin__NS"');
        bodyToModify = bodyToModify.replace('"syncDate"','"SyncDate__NS"');
        bodyToModify = bodyToModify.replace('"transactionName"','"Transaction__NS"');
        
        return bodyToModify;
    }
    
    
}