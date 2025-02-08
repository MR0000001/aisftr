/**
 * ***************************************************************************************************.
 *
 * @author Luisana Rocco lrocco@deloitte.it
 * @date Creation 13/12/2018
 * @date Modification 09/11/2020
 * @description XC_REST_CreatePayment – Rest Resource in outbound to create a Payment
 * ****************************************************************************************************
 */


public without sharing class XC_REST_CreatePayment {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_CreatePayment');


    /**
     * *************************************************************************************************.
     *
     * @param wrapperPayment the wrapper payment
     * @return the x C RES T create payment u. wrapper response
     * @description : Method to send a request to create a payment
     * **************************************************************************************************
     */
    public static XC_REST_CreatePayment_U.WrapperResponse createPayment(XC_REST_CreatePayment_U.WrapperRequest wrapperPayment){
    
        XC_REST_CreatePayment_U.WrapperResponse result = new XC_REST_CreatePayment_U.WrapperResponse();
        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_CreatePayment);

        if(wrInterface.activeInterface) {

            String legalEntity = wrapperPayment.legalEntity;
            String stream = wrapperPayment.stream;
            wrapperPayment.legalEntity = null;
            wrapperPayment.stream = null;

            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            
            if(String.isBlank(entityName)) {
                result.reasons = new List<XC_REST_CreatePayment_U.Reasons>();
                XC_REST_CreatePayment_U.Reasons error = new XC_REST_CreatePayment_U.Reasons();
                error.message = Label.XC_CL_EntityNameNotFound;
                result.reasons.add(error);
                result.success = false;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[CreatePayment] RESULT -> ' + result);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);
            String url = wrInterface.url;
            //wrapperPayment.currencyName = zws.currencyIsoCode; 

            String bodyToModify =  JSON.serialize(wrapperPayment, true);
            String body = replaceValueInJSON(bodyToModify);
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type','application/json;charset=UTF-8');
            headerDefinitions.put('Authorization', 'Bearer '+ zws.token);
            headerDefinitions.put('Zuora-Entity-Ids', zws.entityId); 

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[CreatePayment] request -> ' + request);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[CreatePayment] request Body -> ' + request.getBody());

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,headerDefinitions, 'CreatePayment');            
            result = manageResponse(response);
        } 

        System.debug('@@@@ RESULT ---> ' + result);
        return result;
    }



    /**
     * *************************************************************************************************.
     *
     * @param bodyToModify the body to modify
     * @return the string
     * @description : Method to replace value in JSON with the correct Name
     * **************************************************************************************************
     */
    public static String replaceValueInJSON (String bodyToModify){

        bodyToModify = bodyToModify.replace('currencyName','currency');
        bodyToModify = bodyToModify.replace('integrationId','IntegrationId__NS');
        bodyToModify = bodyToModify.replace('integrationStatus','IntegrationStatus__NS');
        bodyToModify = bodyToModify.replace('origin','Origin__NS');
        bodyToModify = bodyToModify.replace('syncDate','SyncDate__NS');
        bodyToModify = bodyToModify.replace('transactionName','Transaction__NS');
        bodyToModify = bodyToModify.replace('XC_CRM_ConfigurationItem','XC_CRM_ConfigurationItem__c');
        bodyToModify = bodyToModify.replace('Replace', '__c');


        return bodyToModify;
    }


    /**
     * ManageResponse.
     *
     * @param response the Http Response
     * @return the wrapper response
     * @description This method manages response
     */
    @TestVisible
    private static XC_REST_CreatePayment_U.WrapperResponse manageResponse(HttpResponse response) {

        XC_REST_CreatePayment_U.WrapperResponse result = new  XC_REST_CreatePayment_U.WrapperResponse();

        if(response == null) {
            result.reasons = new List<XC_REST_CreatePayment_U.Reasons>();
            XC_REST_CreatePayment_U.Reasons error = new XC_REST_CreatePayment_U.Reasons();
            error.message = 'Response NULL of the CreatePayment API';
            result.reasons.add(error);
            result.success = false; 
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[CreatePayment] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[CreatePayment] response body -> ' + response.getBody());
            result = (XC_REST_CreatePayment_U.WrapperResponse) JSON.deserialize(response.getBody(), XC_REST_CreatePayment_U.WrapperResponse.Class);
            Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeuntyped(response.getBody());
            result.numberN = (String) mapResult.get('number');
            result.currencyName = (String) mapResult.get('currency');

        } else {
            result.reasons = new List<XC_REST_CreatePayment_U.Reasons>();
            XC_REST_CreatePayment_U.Reasons error = new XC_REST_CreatePayment_U.Reasons();
            error.message = 'Response with StatusCode ' + response.getStatusCode() + ' of the CreatePayment API';
            result.reasons.add(error);
            result.success = false; 
            return result;
        }

        return result;
    }

}