/**
 * The Class XC_REST_Indemnification
 *
 * @author            : Dario Tramontin dtramontin@deloitte.it
 * @date Creation     : 22/07/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse to Create Indemnification
 **/
 

public with sharing class XC_REST_Indemnification {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_Indemnification');
   /**
     * The Class WrapperRequest.
     *
     * @description the wrapper request
     */
    public class WrapperRequest {
        
        /** The Account id. */
        public String AccountId;
        
        /** The ReasonCode id. */
        public String ReasonCode;
        
        /** The Amount. */
        public Decimal Amount;

        /** The AutomaticRefund. */
        public String AutomaticRefund;

        /** The CommentsForApproval. */
        public String CommentsForApproval;

        /** The LegalEntity Id */
        public String legalEntity;

        /** The Stream */
        public String stream;

        /** The case Id */
        public String CaseId;
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
        
        /** The run time. */
        public String runTime;
        
        /** The created at. */
        public String createdAt;
        
        /** The updated at. */
        public String updatedAt;
        
        /** The errors. */
        public List<WrapperErrors> errors;
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
     * CreateIndemnification.
     *
     * @param wrapperIndemnification the wrapper Indemnification
     * @return the wrapper ***response***
     * @description method to send a request to create Indemnification
     */
    public static WrapperResponse createIndemnification(WrapperRequest wrapperIndemnification){
        WrapperResponse result = new WrapperResponse();
        result.errors = new List<WrapperErrors>();
        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_ZuoraIndemnification);
        if(wrInterface.activeInterface) {

            String url = wrInterface.url;
            String body =  JSON.serialize(wrapperIndemnification, true);
            body=body.replace('AutomaticRefund', 'automaticRefund__c');
            System.debug('Stampo body2: '+ body);
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type','application/json');
            String legalEntity = wrapperIndemnification.legalEntity;
            String stream = wrapperIndemnification.stream;
            wrapperIndemnification.legalEntity= null;
            wrapperIndemnification.stream= null;

            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
             XC_UTIL_Debug.debug(DEBUGACTIVE, '[Indemnification] EntityName -> ' + entityName);
            if(String.isBlank(entityName)) {
                
                WrapperErrors error = new WrapperErrors();
                error.title = Label.XC_CL_EntityNameNotFound;
                result.errors.add(error);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[Indemnification] RESULT -> ' + result);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);
            
            headerDefinitions.put('API-Token', zws.apiToken);
            //token zuora uat
            //headerDefinitions.put('API-Token', '20c2c1c7dba6d7167b00cbdc315258d919f9d355af485a97eb283b3e844ab8f4'); // only for test
            System.debug('HEADER -> ' + headerDefinitions);
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            System.debug('Request:'+ request);
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'Indemnification');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'Indemnification');

            system.debug('Response: '+ response);
            system.debug(response.getBody() );
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        }

        return result;
    }
    
}