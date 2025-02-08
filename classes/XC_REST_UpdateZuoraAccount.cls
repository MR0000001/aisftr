/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  16/06/2021
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_REST_UpdateZuoraAccount – Rest Resource in outbound to perform an update zuora account
*/

public without sharing class XC_REST_UpdateZuoraAccount {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_UpdateZuoraAccount');

    /**
     * *************************************************************************************************.
     *
     * @param Map<String,Object>){
     * @return the ZuoraWebService CreateZuoraAccountResponse wrapper response
     * @description : Method to send a request to to perform an update zuora account
     * **************************************************************************************************
     */

    public static ZuoraWebService.CreateZuoraAccountResponse updateZuoraAccount(Map<String,Object> bodyMap){
 
        ZuoraWebService.CreateZuoraAccountResponse result = new ZuoraWebService.CreateZuoraAccountResponse();
        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_UpdateZuoraAccount);

        if(wrInterface.activeInterface) {

            try{
                String legalEntity = (String)bodyMap.get('legalEntity'); // Required
                String stream = (String)bodyMap.get('stream'); // Required
                String zuoraAccountId = (String)bodyMap.get('zuoraAccountId'); // Required

                bodyMap.remove('legalEntity');
                bodyMap.remove('stream');
                bodyMap.remove('zuoraAccountId');


                String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
                
                if(String.isBlank(entityName)){
                    result.reasons = new List<ZuoraWebService.Reason>();
                    ZuoraWebService.Reason error = new ZuoraWebService.Reason();
                    error.message = Label.XC_CL_EntityNameNotFound;
                    result.reasons.add(error);
                    result.success = 'false';
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '[UpdateZuoraAccount] RESULT -> ' + result);
                    return result;
                }

                ZuoraWebService zws = new ZuoraWebService(entityName);

                // Create Request
                Map<String,String> headerDefinitions = new Map<String,String>();
                headerDefinitions.put('Content-Type', 'application/json');
                headerDefinitions.put('Zuora-Entity-Ids', zws.entityId);
                String url = wrInterface.url.replace('accountId', zuoraAccountId);
                HttpRequest req = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions,  JSON.serialize(bodyMap));

                XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
                logWrapper.logIntegrationName = 'UpdateZuoraAccount';
                logWrapper.insertLogging = false; 
                XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
                HTTPResponse response = httpRWr.response;
                result = manageResponse(response);
                result.integrationLog = httpRWr.integrationLog.get(0);
                System.Debug('[UpdateZuoraAccount] RESULT -> ' + result);
                return result; 

            }catch(Exception e){
                result.reasons = new List<ZuoraWebService.Reason>();
                ZuoraWebService.Reason error = new ZuoraWebService.Reason();
                error.message = e.getMessage() + ' Stack Trace : ' + e.getStackTraceString();
                result.reasons.add(error);
                result.success = 'false';
                XC_UTIL_Debug.debug(DEBUGACTIVE, '[UpdateZuoraAccount] RESULT -> ' + result);
                return result;
            }
        }else{
            result.reasons = new List<ZuoraWebService.Reason>();
            ZuoraWebService.Reason error = new ZuoraWebService.Reason();
            error.message = 'Interface not active';
            result.reasons.add(error);
            result.success = 'false';
            return result;
        }
    }


    /**
     * ManageResponse.
     *
     * @param response the Http Response
     * @return the wrapper response
     * @description This method manages response
     */
    private static ZuoraWebService.CreateZuoraAccountResponse manageResponse(HttpResponse response) {

        ZuoraWebService.CreateZuoraAccountResponse result = new  ZuoraWebService.CreateZuoraAccountResponse();

        if(response == null) {
            result.reasons = new List<ZuoraWebService.Reason>();
            ZuoraWebService.Reason error = new ZuoraWebService.Reason();
            error.message = 'Response NULL of the UpdateZuoraAccount API';
            result.reasons.add(error);
            result.success = 'false'; 
            return result;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '[UpdateZuoraAccount] response -> ' + response);

        if(response.getStatusCode() == 200) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '[UpdateZuoraAccount] response body -> ' + response.getBody());
            result = (ZuoraWebService.CreateZuoraAccountResponse) JSON.deserialize(response.getBody(), ZuoraWebService.CreateZuoraAccountResponse.Class);
        
        } else {
            result.reasons = new List<ZuoraWebService.Reason>();
            ZuoraWebService.Reason error = new ZuoraWebService.Reason();
            error.message = 'Response with StatusCode ' + response.getStatusCode() + ' of the UpdateZuoraAccount API';
            result.reasons.add(error);
            result.success = 'false'; 
            return result;
        }
        return result;
    }
}