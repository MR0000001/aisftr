/**
 * The Class XC_REST_SendPEC.
 *
 * @author            : Giuseppe DI Bonito
 * @date Creation     : 15/02/2021
 * @date Modification : 
 * @description       : Send a request for a PEC to Doxee
 **/
public class XC_REST_SendPEC {

    /**
     * sendRequest.
     *
     * @author Giuseppe DI Bonito
     * @param wrapper the wrapper
     * @return the Response Wrapper
     * @description Send a request for a PEC to Doxee
     */
    public static XC_REST_SendPEC_U.ResponseWrapper sendRequest(XC_REST_SendPEC_U.RequestWrapper wrapper){
        
        XC_REST_SendPEC_U.ResponseWrapper rw = new XC_REST_SendPEC_U.ResponseWrapper();

        XC_UTIL_Integration.ResultSnakeCase checkParameters = XC_REST_SendPEC_U.checkRequiredParameters(wrapper);
        if(checkParameters.error_code != '0') {
            rw.Result = checkParameters;
            return rw;
        }
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('SendPEC');
        if(isActiveInterface.activeInterface){
            
            try{
                String url = isActiveInterface.url;
                String body = JSON.serialize(wrapper, true);
                
                Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'SendPEC', 'DoxeeB2C');
                
                HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
                HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'SendPEC');   

                rw = (XC_REST_SendPEC_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_SendPEC_U.ResponseWrapper.class);
                
            } catch(Exception e) {
                rw.Result.error_code = '400';
                rw.Result.message = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            }
            
		} 

        system.debug('response'+rw);

        return rw;
    }
}