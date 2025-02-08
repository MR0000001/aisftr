/**
 * The Class XC_REST_ZuoraCancelSubscription.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 01/02/2019
 * @date Modification : 29/07/2019 by Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : Rest Resource for cancel subscription in Zuora
 **/


public without sharing class XC_REST_ZuoraCancelSubscription {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_ZuoraCancelSubscription');

    /**
     * Cancel Subscription.
     *
     * @param subscriptionId the subscription id
     * @param wrReq the wrapper request
     * @return the wrapper response
     * @description method to send a request to resume a Subscription
     */
    public static XC_REST_ZuoraCancelSubscription_U.WrapperResponse cancelSubscription(String subscriptionId, XC_REST_ZuoraCancelSubscription_U.WrapperRequest wrReq) {

        XC_REST_ZuoraCancelSubscription_U.WrapperResponse result = new XC_REST_ZuoraCancelSubscription_U.WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_CancelSubscription);
		if(isActiveInterface.activeInterface) {

            String legalEntity = wrReq.legalEntity;
            String stream = wrReq.stream;
            wrReq.legalEntity = null;
            wrReq.stream = null;
            
            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            if(String.isBlank(entityName)) {
                result.success = false;
                result.reasons = new List<XC_REST_ZuoraCancelSubscription_U.WrapperReason>();
                XC_REST_ZuoraCancelSubscription_U.WrapperReason reason = new XC_REST_ZuoraCancelSubscription_U.WrapperReason();
                reason.message = Label.XC_CL_EntityNameNotFound;
                result.reasons.add(reason);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCancelSubscription] RESULT -> ' + result);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);

			// String url = isActiveInterface.url.replace('subscriptionId', subscriptionId);
            String url = isActiveInterface.url + '/v1/subscriptions/' + subscriptionId + '/cancel';
			String body =  JSON.serialize(wrReq, true);
            body = body.replace('collectX', 'collect');

            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
            headerDefinitions.put('Authorization', 'Bearer ' + zws.token);
            headerDefinitions.put('Zuora-Entity-Ids', zws.entityId);
            System.debug('entityId -> ' + zws.entityId);

            if(wrReq.invoice != null || wrReq.collectX != null) {
                headerDefinitions.put('zuora-version', '196.0');
            } else if(wrReq.runBilling != null || !String.isBlank(wrReq.targetDate)) {
                headerDefinitions.put('zuora-version', '211.0');
            }

	  		HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCancelSubscription] request -> ' + request);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCancelSubscription] request Body -> ' + request.getBody());

	  		//HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'ZuoraCancelSubscription');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'ZuoraCancelSubscription');
            result = manageResponse(response);

		} else {
            result.success = true;
            result.subscriptionId = 'FakeID';
		}

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCancelSubscription] RESULT -> ' + result);
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
    private static XC_REST_ZuoraCancelSubscription_U.WrapperResponse manageResponse(HttpResponse response) {

        XC_REST_ZuoraCancelSubscription_U.WrapperResponse result = new  XC_REST_ZuoraCancelSubscription_U.WrapperResponse();

        if(response == null) {
            result.success = false;
            result.reasons = new List<XC_REST_ZuoraCancelSubscription_U.WrapperReason>();
            XC_REST_ZuoraCancelSubscription_U.WrapperReason reason = new XC_REST_ZuoraCancelSubscription_U.WrapperReason();
            reason.message = 'Response NULL of the ZuorCancelSubscription API';
            result.reasons.add(reason);
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCancelSubscription] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraCancelSubscription] response body -> ' + response.getBody());
            result = (XC_REST_ZuoraCancelSubscription_U.WrapperResponse) JSON.deserialize(response.getBody(), XC_REST_ZuoraCancelSubscription_U.WrapperResponse.class);
        } else {
            result.success = false;
            result.reasons = new List<XC_REST_ZuoraCancelSubscription_U.WrapperReason>();
            XC_REST_ZuoraCancelSubscription_U.WrapperReason reason = new XC_REST_ZuoraCancelSubscription_U.WrapperReason();
            reason.message = 'Response with StatusCode ' + response.getStatusCode() + ' of the ZuorCancelSubscription API';
            result.reasons.add(reason);
            return result;
        }

        return result;
    }

}