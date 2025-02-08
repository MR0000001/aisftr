/**
 * @author            :  Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  30/04/2020
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_IN051_BillingDisconnectionProcess - This class is called from the flow XC_FL_
*/

public without sharing class XC_REST_Withdrawal {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_Withdrawal');

    /**
     * The Class WrapperRequest.
     *
     * @description the wrapper request
     */
    public class WrapperRequest {
        
        /** The Subscription id. */
        public String SubscriptionId;

        /** The legal Entity. */
        public String legalEntity;

        /** The stream. */
        public String stream;
    }


    /**
     * The Class WrapperResponse.
     *
     * @description the wrapper response
     */
    public class WrapperResponse {
        
        /** The id. */
        public String id;
        
        /** The name. */
        public String name;
        
        /** The original workflow id. */
        public String originalWorkflowId;
        
        /** The type. */
        public String type;

        /** The status. */
        public String status;
        
        /** The run time. */
        public String runTime;
        
        /** The created at. */
        public String createdAt;
        
        /** The updated at. */
        public String updatedAt;
        
        /** The errors. */
        public List<WrapperErrors> errors = new List<WrapperErrors>();
    }


    /**
     * The Class WrapperErrors.
     *
     * @description the wrapper errors
     */
    public class WrapperErrors {
        
        /** The status. */
        public String status;
        
        /** The code. */
        public String code;
        
        /** The title. */
        public String title;
    }


    /**
     * requestWithdrawal.
     *
     * @param wrapperPayAndBill the wrapper pay and bill
     * @return the wrapper response
     * @description method to send a request to create payment and bill
     */
    public static WrapperResponse requestWithdrawal(WrapperRequest wrapperWithdrawal){
        WrapperResponse result = new WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_Withdrawal);
        if(wrInterface.activeInterface) {

            String legalEntity = wrapperWithdrawal.legalEntity;
            String stream = wrapperWithdrawal.stream;
            wrapperWithdrawal.legalEntity = null;
            wrapperWithdrawal.stream = null;
            
            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            if(String.isBlank(entityName)) {
                result.errors = new List<WrapperErrors>();
                WrapperErrors error = new WrapperErrors();
                error.title = Label.XC_CL_EntityNameNotFound;
                result.errors.add(error);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[Withdrawal] RESULT -> ' + result);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);

            String url = wrInterface.url;
            String body =  JSON.serialize(wrapperWithdrawal, true);
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type','application/json');
            headerDefinitions.put('API-Token', zws.apiToken);

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Withdrawal] request -> ' + request);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Withdrawal] request Body -> ' + request.getBody());

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'Withdrawal');
            result = manageResponse(response);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[Withdrawal] RESULT -> ' + result);
        return result;
    }


    /**
     * ManageResponse.
     *
     * @param response the Http Response
     * @return the wrapper response
     * @description This method manages response
     */
    @TestVisible
    private static WrapperResponse manageResponse(HttpResponse response) {

        WrapperResponse result = new  WrapperResponse();

        if(response == null) {
            result.errors = new List<WrapperErrors>();
            WrapperErrors error = new WrapperErrors();
            error.title = 'Response NULL of the Withdrawal API';
            result.errors.add(error);
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[Withdrawal] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Withdrawal] response body -> ' + response.getBody());
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        } else {
            result.errors = new List<WrapperErrors>();
            WrapperErrors error = new WrapperErrors();
            error.title = 'Response with StatusCode ' + response.getStatusCode() + ' of the Withdrawal API';
            result.errors.add(error);
            return result;
        }

        return result;
    }

}