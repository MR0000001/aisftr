/**
 * The Class XC_REST_DoxeeFileDelete.
 *
 * @author            : Simone Trenta
 * @date Creation     : 12/06/2020
 * @date Modification : 
 * @description       : delete file on doxee
 **/

public with sharing class XC_REST_DoxeeFileDelete {

    /**
     * The Class RequestWrapper.
     *
     * @description the wrapper request
     */
    public class RequestWrapper{
        public List<FileWrapper> File;  
    }

    /**
     * The Class ResponseWrapper.
     *
     * @description the wrapper response
     */
    public class ResponseWrapper{
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
        public List<FileWrapper> File;  
    }

    public class FileWrapper{
        public string Category;
        public string ObjectType;
        public string ObjectID;
        public string Company;
        public string Country;
        public string NumberOfFileDeleted;
    }

    /**
     * sendRequest.
     *
     * @author Simone Trenta
     * @param wrReq the wrapper
     * @return the Response Wrapper
     * @description delete file on Doxee
     */
    public static ResponseWrapper sendRequest(RequestWrapper wrReq){
        ResponseWrapper wrRes = new ResponseWrapper();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('FileDelete');
        if(isActiveInterface.activeInterface){

            try{
                String url = isActiveInterface.url;
                String body = JSON.serialize(wrReq, true);
                
                Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('FileDelete', 'FileDelete', 'DoxeeB2C');
                
                HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
                //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'DoxeeFileSend');   
                HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'DoxeeFileDelete');   

                System.debug('RESPONSE -> ' + response.getBody());
                wrRes = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);
                
            } catch(Exception e) {
                wrRes.Result.ErrorCode = '400';
                wrRes.Result.Message = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            }
            
		} else {
            wrRes.Result.ErrorCode = '400';
            wrRes.Result.Message = 'Inactive interface';
		}

        return wrRes;
    }

}