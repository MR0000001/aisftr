/**
 * The Class XC_REST_CreditMemo.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 29/04/2019
 * @date Modification : 30/07/2019
 * @description       : Rest Resourse to create a Credit Memo
 **/


public without sharing class XC_REST_CreditMemo {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_CreditMemo');

    /**
     * Create Credit Memo.
     *
     * @param wrReq the wrapper request
     * @return the wrapper response
     * @description method to send a request to create a Credit Memo
     */
    public static XC_REST_CreditMemo_U.WrapperResponse createCreditMemo(XC_REST_CreditMemo_U.WrapperRequest wrReq, String legalEntity, String stream) {
        XC_REST_CreditMemo_U.WrapperResponse result = new XC_REST_CreditMemo_U.WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_CreditMemo);
		if(isActiveInterface.activeInterface) {

            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            if(String.isBlank(entityName)) {
                result.success = false;
                result.reasons = new List<XC_REST_CreditMemo_U.Reasons>();
                XC_REST_CreditMemo_U.Reasons reason = new XC_REST_CreditMemo_U.Reasons();
                reason.message = Label.XC_CL_EntityNameNotFound;
                result.reasons.add(reason);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[CreditMemo] RESULT -> ' + result);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);

			String url = isActiveInterface.url;
            String body =  JSON.serialize(wrReq, true);
            body = body.replace('integrationId', 'IntegrationId__NS');
            body = body.replace('integrationStatus', 'IntegrationStatus__NS');
            body = body.replace('origin', 'Origin__NS');
            body = body.replace('syncDate', 'SyncDate__NS');
            body = body.replace('transactionX', 'Transaction__NS');

            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
            headerDefinitions.put('Authorization', 'Bearer ' + zws.token);
            headerDefinitions.put('Zuora-Entity-Ids', zws.entityId);

            for(XC_REST_CreditMemo_U.ChargesWrapper c : wrReq.charges) {
                if(c.amount != null) {
                    headerDefinitions.put('zuora-version', '224.0');
                    break;
                } else if(c.memoItemAmount != null) {
                    headerDefinitions.put('zuora-version', '223.0');
                }
            }

	  		HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[CreditMemo] request -> ' + request);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[CreditMemo] request Body -> ' + request.getBody());

	  		HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'CreditMemo');

            result = manageResponse(response);

		} else {
            result.success = true;
            result.accountId = 'FakeID';
		}

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[CreditMemo] RESULT -> ' + result);
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
    private static XC_REST_CreditMemo_U.WrapperResponse manageResponse(HttpResponse response) {

        XC_REST_CreditMemo_U.WrapperResponse result = new  XC_REST_CreditMemo_U.WrapperResponse();

        if(response == null) {
            result.success = false;
            result.reasons = new List<XC_REST_CreditMemo_U.Reasons>();
            XC_REST_CreditMemo_U.Reasons reason = new XC_REST_CreditMemo_U.Reasons();
            reason.message = Label.XC_CL_CreditMemoNULL;
            result.reasons.add(reason);
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[CreditMemo] response -> ' + response);

        if(response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            responseBody.replace('number', 'numberX');
            responseBody.replace('currency', 'currencyX');
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[CreditMemo] response body -> ' + responseBody);
            result = (XC_REST_CreditMemo_U.WrapperResponse) JSON.deserialize(responseBody, XC_REST_CreditMemo_U.WrapperResponse.class);
        } else {
            result.success = false;
            result.reasons = new List<XC_REST_CreditMemo_U.Reasons>();
            XC_REST_CreditMemo_U.Reasons reason = new XC_REST_CreditMemo_U.Reasons();
            reason.message = 'Response with StatusCode ' + response.getStatusCode() + ' of the CreditMemo API';
            result.reasons.add(reason);
            return result;
        }

        return result;
    }

}