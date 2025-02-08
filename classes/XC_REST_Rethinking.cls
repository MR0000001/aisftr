/**
 * The Class XC_REST_Rethinking.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 21/03/2019
 * @date Modification : dd/mm/yyyy
 * @description       : XC_REST_Rethinking – Rest Resourse for Rethinking
 **/

 
public without sharing class XC_REST_Rethinking {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_Rethinking');

    
    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
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
        
        /** The parameters. */
        public WrapperParameters parameters;
        
        /** The errors. */
        public List<WrapperErrors> errors = new List<WrapperErrors>();
    }


    /**
     * The Class WrapperParameters.
     *
     * @description wrapper parameters
     */
    public class WrapperParameters {
        
        /** The Subscription id. */
        public String SubscriptionId;
        
        /** The workflow. */
        public String workflow;
    }


    /**
     * The Class WrapperErrors.
     *
     * @description wrapper errors
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
     * ManageRethinking.
     * @param subscriptionId the subscription id
     * @return WrapperResponse
     * @description method to send a request for a rethinking
     */
    public static WrapperResponse manageRethinking(String subscriptionId, String legalEntity, String stream){
        WrapperResponse result = new WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_Rethinking);
        if(wrInterface.activeInterface) {

            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            if(String.isBlank(entityName)) {
                WrapperErrors error = new WrapperErrors();
                error.title = Label.XC_CL_EntityNameNotFound;
                result.errors.add(error);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[Rethinking] RESULT -> ' + result);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);

            String url = wrInterface.url;
            String body = '{"SubscriptionID":"' + subscriptionId + '"}';
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type','application/json');
            headerDefinitions.put('API-Token', zws.apiToken);

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Rethinking] request -> ' + request);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Rethinking] request Body -> ' + request.getBody());

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'Rethinking');
            
            result = manageResponse(response);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[Rethinking] RESULT -> ' + result);
        return result;
    }


    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description This method manages response
     * @param response the Http Response
     * @return the wrapper response
     */
    @TestVisible
    private static WrapperResponse manageResponse(HttpResponse response) {

        WrapperResponse result = new WrapperResponse();

        if(response == null) {
            WrapperErrors error = new WrapperErrors();
            error.title = 'Response NULL of the Rethinking API';
            result.errors.add(error);
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[Rethinking] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Rethinking] response body -> ' + response.getBody());
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        } else {
            WrapperErrors error = new WrapperErrors();
            error.title = 'Response with StatusCode ' + response.getStatusCode() + ' of the Rethinking API';
            result.errors.add(error);
        }

        return result;
    }

}