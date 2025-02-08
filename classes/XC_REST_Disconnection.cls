/**
 * The Class XC_REST_Disconnection
 *
 * @author            : Dario Tramontin dtramontin@deloitte.it
 * @date Creation     : 03/06/2020
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse to Manage Discconection
 **/
 

public without sharing class XC_REST_Disconnection {
private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_Disconnection');


    /**
     * The Class WrapperRequest.
    *
    * @description the wrapper request
    */
    public class QFWrapperRequest {
        public List<Map<String,Object>> records;

        /** The LegalEntity Id */
        public String legalEntity;

        /** The Stream */
        public String stream;
    }

    /**
     * The Class WrapperRequest.
    *
    * @description the wrapper request
    */

    public class WrapperRequest {
        
        /** The Subscription Id */
        public String subscriptionId;

        /** The Cancellation Date */
        public String cancellationDate;

        /** The Subtype */
        public String subType; 

        /** The LegalEntity Id */
        public String legalEntity;

        /** The Stream */
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

        /** The success. */
        public Boolean success = false;

        /** The type. */
        public String type;
        
        /** The run time. */
        public String runTime;
        
        /** The created at. */
        public String createdAt;
        
        /** The updated at. */
        public String updatedAt;
                
        /** The updated at. */
        public String subscriptionId;
        
        /** The reasons. */
        public List<WrapperReason> reasons = new List<WrapperReason>();
    }
 
 
    /**
     * The Class WrapperReason.
     *
     * @description the wrapper reason
     */
    public class WrapperReason {
        
        /** The code. */
        public Integer code;
        
        /** The message. */
        public String message;
    }
          
        /**
     * manageDisconnection.
    *
    * @param wrapperDisconnection the wrapper Disconnection
    * @return the wrapper ***response***
    * @description method to send a request for a Disconnection
    */
    public static WrapperResponse manageDisconnection(QFWrapperRequest wrapperDisconnection){
        WrapperResponse result = new WrapperResponse();
        //result.reasons = new List<WrapperReason>();

        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2('ZuoraQueuedFlow');
        if(wrInterface.activeInterface) {
         
            String legalEntity = wrapperDisconnection.legalEntity;
            String stream = wrapperDisconnection.stream;
            wrapperDisconnection.legalEntity= null;
            wrapperDisconnection.stream= null;

            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] EntityName -> ' + entityName);
            if(String.isBlank(entityName)) {
                result.success = false;
                WrapperReason reason = new WrapperReason();
                reason.message = Label.XC_CL_EntityNameNotFound;
                result.reasons = new List<WrapperReason>();
                result.reasons.add(reason);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] RESULT -> ' + result);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);
            
            String url = wrInterface.url;
            String body =  JSON.serialize(wrapperDisconnection, true);
            
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type','application/json');
            headerDefinitions.put('Zuora-Entity-Ids', zws.entityId);
            headerDefinitions.put('Accept', '*/*');


            System.debug('HEADER -> ' + headerDefinitions);            
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] header-> ' + headerDefinitions);
            
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            system.debug('token : '+request.getHeader('Authorization'));

            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] request -> ' + request);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] request Body -> ' + request.getBody());

            XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
            logWrapper.logIntegrationName = 'Disconnection';
            logWrapper.insertLogging = true; 
   
            XC_UTIL_RESTCallout.HttpResponseWrapper response = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'Disconnection');

            system.debug('Response: '+ response);
            //system.debug(response.getBody() );
            result = manageResponse(response.response);
            
        }else {
            result.success = true;
            result.subscriptionId = 'FakeID';
		}

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] RESULT -> ' + result);
        return result;
    }
 
    /**
     * manageDisconnection.
    *
    * @param wrapperDisconnection the wrapper Disconnection
    * @return the wrapper ***response***
    * @description method to send a request for a Disconnection
    */
    public static WrapperResponse manageDisconnection(WrapperRequest wrapperDisconnection){
        WrapperResponse result = new WrapperResponse();
        //result.reasons = new List<WrapperReason>();

        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_ZuoraDisconnection);
        if(wrInterface.activeInterface) {
         
            String legalEntity = wrapperDisconnection.legalEntity;
            String stream = wrapperDisconnection.stream;
            wrapperDisconnection.legalEntity= null;
            wrapperDisconnection.stream= null;

            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] EntityName -> ' + entityName);
            if(String.isBlank(entityName)) {
                result.success = false;
                WrapperReason reason = new WrapperReason();
                reason.message = Label.XC_CL_EntityNameNotFound;
                result.reasons = new List<WrapperReason>();
                result.reasons.add(reason);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] RESULT -> ' + result);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);
            
            String url = wrInterface.url;
            String body =  JSON.serialize(wrapperDisconnection, true);
            
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type','application/json');
            headerDefinitions.put('API-Token', zws.apiToken);
            System.debug('HEADER -> ' + headerDefinitions);            
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] header-> ' + headerDefinitions);
            
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] request -> ' + request);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] request Body -> ' + request.getBody());

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'Disconnection');

            system.debug('Response: '+ response);
            //system.debug(response.getBody() );
            result = manageResponse(response);
            
        }else {
            result.success = true;
            result.subscriptionId = 'FakeID';
		}

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] RESULT -> ' + result);
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
        result.reasons= new List<WrapperReason>();
        if(response == null) {
            result.success = false;
            WrapperReason reason = new WrapperReason();
            reason.message = 'Response NULL of the Disconnection API';
            result.reasons.add(reason);
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[Disconnection] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ Disconnection] response body -> ' + response.getBody());
            System.debug(response.getBody());
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
            result.success=true;
        } else {
            result.success = false;
            WrapperReason reason = new WrapperReason();
            reason.message = 'Response with StatusCode ' + response.getStatusCode() + ' of the Disconnection API';
            result.reasons.add(reason);
            return result;
        }

        return result;
    }
}