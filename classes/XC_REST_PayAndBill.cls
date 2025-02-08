/**
 * The Class XC_REST_PayAndBill.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 22/01/2019
 * @date Modification : 30/07/2019
 * @description       : Rest Resourse to Create Pay and Bill
 **/
 

public without sharing class XC_REST_PayAndBill {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_PayAndBill');

    /**
     * The Class WrapperRequest.
     *
     * @description the wrapper request
     */
    public class WrapperRequest {
        
        /** The Account id. */
        public String AccountId;
        
        /** The Subscription id. */
        public String SubscriptionId;
        
        /** The Prepaid amount. */
        public Decimal PrepaidAmount;

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
     * CreatePayAndBill.
     *
     * @param wrapperPayAndBill the wrapper pay and bill
     * @return the wrapper response
     * @description method to send a request to create payment and bill
     */
    public static WrapperResponse createPayAndBill(WrapperRequest wrapperPayAndBill){
        WrapperResponse result = new WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_PayAndBill);
        if(wrInterface.activeInterface) {

            String legalEntity = wrapperPayAndBill.legalEntity;
            String stream = wrapperPayAndBill.stream;
            String transactionID = wrapperPayAndBill.transactionID;
            wrapperPayAndBill.legalEntity = null;
            wrapperPayAndBill.stream = null;
            wrapperPayAndBill.transactionID = null;

            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            if(String.isBlank(entityName)) {
                result.errors = new List<WrapperErrors>();
                WrapperErrors error = new WrapperErrors();
                error.title = Label.XC_CL_EntityNameNotFound;
                result.errors.add(error);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[PayAndBill] RESULT -> ' + result);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);

            String url = wrInterface.url;
            String body =  JSON.serialize(wrapperPayAndBill, true);
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type','application/json');
            headerDefinitions.put('API-Token', zws.apiToken);
            headerDefinitions.put('TransactionID', transactionID);

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[PayAndBill] request -> ' + request);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[PayAndBill] request Body -> ' + request.getBody());

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'PayAndBill');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'PayAndBill');
            result = manageResponse(response);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[PayAndBill] RESULT -> ' + result);
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
            error.title = 'Response NULL of the GenerateBillingDocument API';
            result.errors.add(error);
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[PayAndBill] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[PayAndBill] response body -> ' + response.getBody());
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        } else {
            result.errors = new List<WrapperErrors>();
            WrapperErrors error = new WrapperErrors();
            error.title = 'Response with StatusCode ' + response.getStatusCode() + ' of the GenerateBillingDocument API';
            result.errors.add(error);
            return result;
        }

        return result;
    }
}