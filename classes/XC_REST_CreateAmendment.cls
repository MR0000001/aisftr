/**
 * ***************************************************************************************************.
 *
 * @author Luisana Rocco lrocco@deloitte.it
 * @date Creation 04/02/2019
 * @date Modification dd/mm/yyyy
 * @description XC_REST_CreateAmendment – Rest Resource in outbound to create an Amendment
 * ****************************************************************************************************
 */


public class XC_REST_CreateAmendment {

    
    /**
     * *************************************************************************************************.
     *
     * @param wrapperAmendment the wrapper amendment
     * @return the x C RES T create amendment u. wrapper response
     * @description : Method to send a request to create an amendment
     * **************************************************************************************************
     */
    public static XC_REST_CreateAmendment_U.WrapperResponse createAmendment(XC_REST_CreateAmendment_U.WrapperRequest wrapperAmendment){
    
        XC_REST_CreateAmendment_U.WrapperResponse result = new  XC_REST_CreateAmendment_U.WrapperResponse();
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_CreateAmendment);

        if(isActiveInterface.activeInterface) {
            
            String url = isActiveInterface.url;
            String body =  JSON.serialize(wrapperAmendment, true);
            Map<String, String> infoZuora = XC_UTIL_Integration.getInfosForZuoraRest();
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type','application/json;charset=UTF-8');
            headerDefinitions.put('Authorization', 'Bearer '+ infoZuora.get('access_token'));
            headerDefinitions.put('Zuora-Entity-Ids', infoZuora.get('zuora_ids')); 
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,'', 'XC_REST_CreateAmendment');
            result = (XC_REST_CreateAmendment_U.WrapperResponse) JSON.deserialize(response.getBody(), XC_REST_CreateAmendment_U.WrapperResponse.Class);

        } else {
            result.success = true;
        }
        System.debug('@@@@ RESULT ---> ' + result);
        return result;
    }
}