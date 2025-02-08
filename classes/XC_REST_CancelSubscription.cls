/**
 * @description       : XC_REST_CancelSubscription
 * @author            : Donato Lombardi
 * @created date      : 04-02-2022
 * @last modified on  : dd-mm-yyyy
 * @last modified by  : 
 **/

public with sharing class XC_REST_CancelSubscription {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_CancelSubscription');


    public class WrapperRequest {
        public String legalEntity;
        public String stream;
        public Boolean success;
        public String messageString;
        public String subscriptionNumber;
    }

    public class WrapperResponse {
        public Boolean success;
        public List<WrapperReason> reasons;
        public HttpResponse response;
        public XC_Integration_Log__c integrationLog;
    }

    public class WrapperReason {
        public Integer code;
        public String message;
    }


    public static XC_REST_CancelSubscription.WrapperResponse cancelSubscriptionByName(String subscriptionName, XC_REST_GetSubscription.WrapperRequest wrReq) {
        
        WrapperResponse result = new WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('ContractAmendment');
        if (!isActiveInterface.activeInterface) {
            return result;
        }

        String legalEntity = wrReq.legalEntity;
        String stream = wrReq.stream;
        String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
        if (String.isBlank(entityName)) {
            result.success = false;
            result.reasons = new List<XC_REST_CancelSubscription.WrapperReason>();
            XC_REST_CancelSubscription.WrapperReason reason = new XC_REST_CancelSubscription.WrapperReason();
            reason.message = Label.XC_CL_EntityNameNotFound;
            result.reasons.add(reason);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCancelSubscription] RESULT -> ' + result);
            return result;
        }

        ZuoraWebService zws = new ZuoraWebService(entityName);
        String url = isActiveInterface.url + '/v1/subscriptions/' + subscriptionName +'/cancel';
        Map<String,String> mapStringBody = new Map<String,String>();
        mapStringBody.put('cancellationEffectiveDate', (wrReq.cancellationEffectiveDate != null) ? String.valueOf(wrReq.cancellationEffectiveDate) : String.valueOf(Date.today()));
        mapStringBody.put('cancellationPolicy','SpecificDate');
        String body = JSON.serialize(mapStringBody);

        Map<String, String> headerDefinitions = new Map<String, String>();
        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        headerDefinitions.put('Authorization', 'Bearer ' + zws.token);
        headerDefinitions.put('Zuora-Entity-Ids', zws.entityId);

        HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCancelSubscription] request -> ' + request);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCancelSubscription] request Body -> ' + request.getBody());

        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'CancelSubscription';
        logWrapper.insertLogging = false;
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
        HttpResponse response = httpRWr.response;
        result = manageResponse(response);
        result.integrationLog = httpRWr.integrationLog[0]; 

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

        WrapperResponse result = new WrapperResponse();

        if(response == null) {
            result.success = false;
            result.reasons = new List<XC_REST_CancelSubscription.WrapperReason>();
            XC_REST_CancelSubscription.WrapperReason reason = new XC_REST_CancelSubscription.WrapperReason();
            reason.message = 'Response NULL of the ZuoraCancelSubscription API';
            result.reasons.add(reason);
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCancelSubscription] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCancelSubscription] response body -> ' + response.getBody());
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        } else {
            result.success = false;
            result.reasons = new List<XC_REST_CancelSubscription.WrapperReason>();
            XC_REST_CancelSubscription.WrapperReason reason = new XC_REST_CancelSubscription.WrapperReason();
            reason.message = 'Response with StatusCode ' + response.getStatusCode() + ' of the ZuoraCancelSubscription API';
            result.reasons.add(reason);
            return result;
        }
        
        result.response = response;
        return result;
    }

}