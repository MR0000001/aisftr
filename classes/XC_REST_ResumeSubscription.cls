/**
 * The Class XC_REST_ResumeSubscription.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 13/12/2018
 * @date Modification : 27/02/2019
 * @description       : Rest Resourse to resume a Subscription
 **/


public without sharing class XC_REST_ResumeSubscription {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_ResumeSubscription');


    /**
     * The Class WrapperRequest.
     *
     * @description wrapper request of REST call
     */
    public class WrapperRequest {

        /** The legal entity. */
        public String legalEntity;

        /** The stream. */
        public String stream;
        
        /** The apply credit balance. */
        public Boolean applyCreditBalance;
        
        /** The collect X. */
        public Boolean collectX;
        
        /** The contract effective date. */
        public String contractEffectiveDate;
        
        /** The extends term. */
        public Boolean extendsTerm;
        
        /** The invoice. */
        public Boolean invoice;
        
        /** The invoice collect. */
        public Boolean invoiceCollect;
        
        /** The invoice target date. */
        public String invoiceTargetDate;
        
        /** The resume periods. */
        public String resumePeriods;
        
        /** The resume periods type. */
        public String resumePeriodsType;
        
        /** The resume policy. */
        public String resumePolicy;
        
        /** The resume specific date. */
        public String resumeSpecificDate;
        
        /** The run billing. */
        public Boolean runBilling;
        
        /** The target date. */
        public String targetDate;
    }

    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperResponse {
        
        /** The success. */
        public Boolean success;
        
        /** The subscription id. */
        public String subscriptionId;
        
        /** The resume date. */
        public String resumeDate;
        
        /** The term end date. */
        public String termEndDate;
        
        /** The total delta tcv. */
        public Double totalDeltaTcv;
        
        /** The reasons. */
        public List<Reasons> reasons;
    }


    /**
     * The Class Reasons.
     *
     * @description wrapper reasons of REST call
     */
    public class Reasons {
        
        /** The code. */
        public Integer code;
        
        /** The message. */
        public String message;
    }


    /**
     * Resume Subscription.
     *
     * @param subscriptionId the subscription id
     * @param wrReq the wrapper request
     * @return the wrapper response
     * @description method to send a request to resume a Subscription
     */
    public static WrapperResponse resumeSubscription(String subscriptionId, WrapperRequest wrReq) {
        WrapperResponse result = new WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_ResumeSubscription);
		if(isActiveInterface.activeInterface) {

            String legalEntity = wrReq.legalEntity;
            String stream = wrReq.stream;
            wrReq.legalEntity = null;
            wrReq.stream = null;

            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            if(String.isBlank(entityName)) {
                result.success = false;
                result.reasons = new List<Reasons>();
                Reasons reason = new Reasons();
                reason.message = Label.XC_CL_EntityNameNotFound;
                result.reasons.add(reason);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraResumeSubscription] RESULT -> ' + result);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);

			//String url = isActiveInterface.url.replace('subscriptionId', subscriptionId);
            String url = isActiveInterface.url + '/v1/subscriptions/' + subscriptionId + '/resume';
			String body =  JSON.serialize(wrReq, true);
            body = body.replace('collectX', 'collect');
            
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
            headerDefinitions.put('Authorization', 'Bearer ' + zws.token);
            headerDefinitions.put('Zuora-Entity-Ids', zws.entityId);

            if(wrReq.invoice != null || wrReq.collectX != null) {
                headerDefinitions.put('zuora-version', '196.0');
            } else if (wrReq.runBilling != null || !String.isBlank(wrReq.targetDate)) {
                headerDefinitions.put('zuora-version', '211.0');
            }

	  		HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraResumeSubscription] request -> ' + request);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraResumeSubscription] request Body -> ' + request.getBody());

	  		HttpResponse response = XC_UTIL_RESTCallout.sendRequest(request, 'ResumeSubscription');
	  		//HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'ResumeSubscription');
            result = manageResponse(response);
		} else {
            result.success = true;
            result.subscriptionId = 'FakeID';
		}

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraResumeSubscription] RESULT -> ' + result);
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
            result.reasons = new List<Reasons>();
            Reasons reason = new Reasons();
            reason.message = 'Response NULL of the ZuoraResumeSubscription API';
            result.reasons.add(reason);
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraResumeSubscription] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraResumeSubscription] response body -> ' + response.getBody());
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        } else {
            result.success = false;
            result.reasons = new List<Reasons>();
            Reasons reason = new Reasons();
            reason.message = 'Response with StatusCode ' + response.getStatusCode() + ' of the ZuoraResumeSubscription API';
            result.reasons.add(reason);
            return result;
        }
        return result;
    }
    
}