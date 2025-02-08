/**
 * The Class XC_REST_ZuoraOwnerTransfer.
 *
 * @author Federico Amici - federico.amici@nttdata.com
 * @lastModify 26/07/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description This REST change the ownership of the subscription
 */


public without sharing class XC_REST_ZuoraOwnerTransfer {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_ZuoraOwnerTransfer');

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description This method invokes Zuora API to change the ownership of the subscription
     * @param wrRequest the wrapper that has to be serialized in the body
     * @return the wrapper response
     */
    public static XC_REST_ZuoraOwnerTransfer_U.WrapperResponse zuoraChangeOwnership(XC_REST_ZuoraOwnerTransfer_U.WrapperRequest wrRequest) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_REST_ZuoraOwnerTransfer.zuoraChangeOwnership');

        XC_REST_ZuoraOwnerTransfer_U.WrapperResponse wrResponse = new  XC_REST_ZuoraOwnerTransfer_U.WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_ZuoraOwnerTransfer);
        if(isActiveInterface.activeInterface) {

            String legalEntity = wrRequest.legalEntity;
            String stream = wrRequest.stream;
            String transactionID = wrRequest.transactionID;
            wrRequest.legalEntity = null;
            wrRequest.stream = null;
            wrRequest.transactionID = null;
            
            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            if(String.isBlank(entityName)) {
                wrResponse.results = new List<XC_REST_ZuoraOwnerTransfer_U.WrapperResult>();
                XC_REST_ZuoraOwnerTransfer_U.WrapperResult res = new XC_REST_ZuoraOwnerTransfer_U.WrapperResult();
                res.success = false;
                res.errors = new List<XC_REST_ZuoraOwnerTransfer_U.Errors>();
                XC_REST_ZuoraOwnerTransfer_U.Errors err = new XC_REST_ZuoraOwnerTransfer_U.Errors();
                err.message = Label.XC_CL_EntityNameNotFound;
                res.errors.add(err);
                wrResponse.results.add(res);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraOwnerTransfer] RESULT -> ' + wrResponse);
                return wrResponse;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);

			String url = isActiveInterface.url;
			String body =  JSON.serialize(wrRequest, true);
            
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Accept', 'application/json; charset=utf-8');
            headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
            headerDefinitions.put('Authorization', 'Bearer ' + zws.token);
            headerDefinitions.put('Zuora-Entity-Ids', zws.entityId);
            headerDefinitions.put('TransactionID', transactionID);
            headerDefinitions.put('Host', zws.host);
            headerDefinitions.put('accept-encoding', 'gzip, deflate');

	  		HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraOwnerTransfer] request -> ' + request);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraOwnerTransfer] request Body -> ' + request.getBody());

	  		//HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'ZuoraOwnerTransfer');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'ZuoraOwnerTransfer');
            wrResponse = manageResponse(response);
        
        } else {
            wrResponse.results = new List<XC_REST_ZuoraOwnerTransfer_U.WrapperResult>();
            XC_REST_ZuoraOwnerTransfer_U.WrapperResult res = new XC_REST_ZuoraOwnerTransfer_U.WrapperResult();
            res.success = false;
            res.errors = new List<XC_REST_ZuoraOwnerTransfer_U.Errors>();
            XC_REST_ZuoraOwnerTransfer_U.Errors err = new XC_REST_ZuoraOwnerTransfer_U.Errors();
            err.message = 'ZuoraOwnerTransfer ' + Label.XC_CL_InterfaceNotActive;
            res.errors.add(err);
            wrResponse.results.add(res);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraOwnerTransfer] RESULT -> ' + wrResponse);
        return wrResponse;
    }


    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description This method manages response
     * @param response the Http Response
     * @return the wrapper response
     */
    @TestVisible
    private static XC_REST_ZuoraOwnerTransfer_U.WrapperResponse manageResponse(HttpResponse response) {

        XC_REST_ZuoraOwnerTransfer_U.WrapperResponse wrResponse = new  XC_REST_ZuoraOwnerTransfer_U.WrapperResponse();

        if(response == null) {
            wrResponse.results = new List<XC_REST_ZuoraOwnerTransfer_U.WrapperResult>();
            XC_REST_ZuoraOwnerTransfer_U.WrapperResult res = new XC_REST_ZuoraOwnerTransfer_U.WrapperResult();
            res.success = false;
            res.errors = new List<XC_REST_ZuoraOwnerTransfer_U.Errors>();
            XC_REST_ZuoraOwnerTransfer_U.Errors err = new XC_REST_ZuoraOwnerTransfer_U.Errors();
            err.message = 'Response NULL of the ZuoraOwnerTransfer API';
            res.errors.add(err);
            wrResponse.results.add(res);
            return wrResponse;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraOwnerTransfer] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[ZuoraOwnerTransfer] response body -> ' + response.getBody());
            wrResponse = (XC_REST_ZuoraOwnerTransfer_U.WrapperResponse) JSON.deserialize(response.getBody(), XC_REST_ZuoraOwnerTransfer_U.WrapperResponse.class);
        } else {
            wrResponse.results = new List<XC_REST_ZuoraOwnerTransfer_U.WrapperResult>();
            XC_REST_ZuoraOwnerTransfer_U.WrapperResult res = new XC_REST_ZuoraOwnerTransfer_U.WrapperResult();
            res.success = false;
            res.errors = new List<XC_REST_ZuoraOwnerTransfer_U.Errors>();
            XC_REST_ZuoraOwnerTransfer_U.Errors err = new XC_REST_ZuoraOwnerTransfer_U.Errors();
            err.message = 'Response with StatusCode ' + response.getStatusCode() + ' of the ZuoraOwnerTransfer API';
            res.errors.add(err);
            wrResponse.results.add(res);
        }

        return wrResponse;
    }

}