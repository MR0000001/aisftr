/**
 * The Class XC_REST_DoxeeFileSend.
 *
 * @author            : Giulio Serra
 * @date Creation     : 03/01/2019
 * @date Modification : 29/04/2019 by Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : create a file on doxee
 **/


public class XC_REST_DoxeeFileSend {
        

    /**
     * CreateFile.
     *
     * @author Giulio Serra
     * @param wrapper the wrapper
     * @return the Response Wrapper
     * @description create a file on Doxee
     */
    public static XC_REST_DoxeeFileSend_U.ResponseWrapper createFile(XC_REST_DoxeeFileSend_U.RequestWrapper wrapper){
        
        XC_REST_DoxeeFileSend_U.ResponseWrapper rw = new XC_REST_DoxeeFileSend_U.ResponseWrapper();
        
        XC_UTIL_Integration.Result checkParameters = XC_REST_DoxeeFileSend_U.checkRequiredParameters(wrapper);
        if(checkParameters.ErrorCode != '0') {
            rw.Result = checkParameters;
            return rw;
        }
        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_CreateFile);
        if(isActiveInterface.activeInterface){
            
            try{
                String url = isActiveInterface.url;
                String body = JSON.serialize(wrapper, true);
                
                Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'FileSend', 'DoxeeB2C');
                
                HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
                //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'DoxeeFileSend');   
                HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'DoxeeFileSend');   

                System.debug('RESPONSE -> ' + response.getBody());
                rw = (XC_REST_DoxeeFileSend_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_DoxeeFileSend_U.ResponseWrapper.class);
                
            } catch(Exception e) {
                rw.Result.ErrorCode = '400';
                rw.Result.Message = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            }
            
		} else {
			rw = createFakeResponseWrapper();
		}
        
        return rw;
    }
    
    
    /**
     * Creates the fake response wrapper.
     *
     * @author Giulio Serra
     * @return the response wrapper
     * @description create a fake response wrapper
     */
    private static XC_REST_DoxeeFileSend_U.ResponseWrapper createFakeResponseWrapper(){
        
        XC_REST_DoxeeFileSend_U.ResponseWrapper rw = new XC_REST_DoxeeFileSend_U.ResponseWrapper();
        
        rw.Result.Message = Label.XC_CL_Document_created;
        rw.Result.ErrorCode = '0';
        
        return rw;
    }
}