/**
 * The Class XC_REST_UploadFreekWh.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 04/10/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse to Upload Free kWh
 **/
 

public without sharing class XC_REST_UploadFreekWh {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_UploadFreekWh');

    /**
     * The Class WrapperRequest.
     *
     * @description the wrapper request
     */
    public class WrapperRequest {
        
        /** The Quantity */
        public String Quantity;
        
        /** The Subscription id. */
        public String SubscriptionID;
        
        /** The Start DateTime */
        public String StartDateTime;

        /** The End DateTime */
        public String EndDateTime;

        /** The Account Id */
        public String AccountID;

        /** The legal Entity. */
        public String legalEntity;

        /** The stream. */
        public String stream;

        /** The transactionID. */
        public String transactionID;
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
     * Upload Free kWh
     *
     * @param wrUploadfreeKWh the wrapper upload freeKwh
     * @return the wrapper response
     * @description method to send a request to upload free kWh
     */
    public static WrapperResponse uploadFreekWh(WrapperRequest wrUploadfreeKWh){
        WrapperResponse result = new WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_UploadFreekWh);
        if(wrInterface.activeInterface) {

            String legalEntity = wrUploadfreeKWh.legalEntity;
            String stream = wrUploadfreeKWh.stream;
            String transactionID = wrUploadfreeKWh.transactionID;
            wrUploadfreeKWh.legalEntity = null;
            wrUploadfreeKWh.stream = null;
            wrUploadfreeKWh.transactionID = null;

            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            if(String.isBlank(entityName)) {
                result.errors = new List<WrapperErrors>();
                WrapperErrors error = new WrapperErrors();
                error.title = Label.XC_CL_EntityNameNotFound;
                result.errors.add(error);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[UploadFreekWh] RESULT -> ' + result);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);

            String url = wrInterface.url;
            String body =  JSON.serialize(wrUploadfreeKWh, true);
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type','application/json'); 
            headerDefinitions.put('API-Token', zws.apiToken);
            headerDefinitions.put('TransactionID', transactionID);

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[UploadFreekWh] request -> ' + request);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[UploadFreekWh] request Body -> ' + request.getBody());

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'UploadFreekWh');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'UploadFreekWh');
            
            result = manageResponse(response);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[UploadFreekWh] RESULT -> ' + result);
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
            error.title = 'Response NULL of the UploadFreekWh API';
            result.errors.add(error);
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[UploadFreekWh] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[UploadFreekWh] response body -> ' + response.getBody());
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        } else {
            result.errors = new List<WrapperErrors>();
            WrapperErrors error = new WrapperErrors();
            error.title = 'Response with StatusCode ' + response.getStatusCode() + ' of the UploadFreekWh API';
            result.errors.add(error);
            return result;
        }

        return result;
    }


}