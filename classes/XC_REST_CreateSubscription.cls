/**
 * @description       : XC_REST_CreateSubscription
 * @author            : Donato Lombardi
 * @created date      : 04-02-2022
 * @last modified on  : dd-mm-yyyy
 * @last modified by  : 
 **/


public with sharing class XC_REST_CreateSubscription {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_CreateSubscription');


    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperResponse {
        public Boolean success;
        public String subscriptionId;
        public String subscriptionNumber;
        public Decimal contractedMrr;
        public Decimal totalContractedValue;
        public String creditMemoId;
        public String invoiceId;
        public Decimal paidAmount;
        public String paymentId;
        public String processId;
        public List<WrapperReason> reasons;
        public XC_Integration_Log__c integrationLog;
    }

    /**
     * The Class Reasons.
     *
     * @description wrapper reasons
     */
    public class WrapperReason {
        public Integer code;
        public String message;
    }


    public static WrapperResponse createSubscription(XC_REST_GetSubscription.WrapperRequest inputParameter, String body) {

        WrapperResponse result = new WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('ContractAmendment');
        if (!isActiveInterface.activeInterface) {
            result.success = true;
            result.subscriptionId = 'FakeID';
            result.subscriptionNumber = 'FakeNumber';
            return result;
        }
        
        String legalEntity = inputParameter.legalEntity;
        String stream = inputParameter.stream;
        String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
        if (String.isBlank(entityName)) {
            result.success = false;
            result.reasons = new List<XC_REST_CreateSubscription.WrapperReason>();
            XC_REST_CreateSubscription.WrapperReason reason = new XC_REST_CreateSubscription.WrapperReason();
            reason.message = Label.XC_CL_EntityNameNotFound;
            result.reasons.add(reason);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCreateSubscription] RESULT -> ' + result);
            return result;
        }

        ZuoraWebService zws = new ZuoraWebService(entityName);
        String url = isActiveInterface.url + '/v1/subscriptions';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCreateSubscription] url -> ' + url);

        Map<String, String> headerDefinitions = new Map<String, String>();
        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        headerDefinitions.put('Authorization', 'Bearer ' + zws.token);
        headerDefinitions.put('Zuora-Entity-Ids', zws.entityId);
        headerDefinitions.put('zuora-version', '315.0');

        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCreateSubscription] request -> ' + request);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCreateSubscription] request Body -> ' + request.getBody());

        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'CreateSubscription';
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
            result.reasons = new List<XC_REST_CreateSubscription.WrapperReason>();
            XC_REST_CreateSubscription.WrapperReason reason = new XC_REST_CreateSubscription.WrapperReason();
            reason.message = 'Response NULL of the ZuoraCreateSubscription API';
            result.reasons.add(reason);
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCreateSubscription] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCreateSubscription] response body -> ' + response.getBody());
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        } else {
            result.success = false;
            result.reasons = new List<XC_REST_CreateSubscription.WrapperReason>();
            XC_REST_CreateSubscription.WrapperReason reason = new XC_REST_CreateSubscription.WrapperReason();
            reason.message = 'Response with StatusCode ' + response.getStatusCode() + ' of the ZuoraCreateSubscription API';
            result.reasons.add(reason);
            return result;
        }
        
        return result;
    }

}