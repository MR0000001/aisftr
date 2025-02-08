/*****************************************************************************************************************
* @author :          : Simone Trenta - 
* @date Creation 	 : 26/07/2019
* @date Modification : 
* @description :     : XC_REST_CreateDocument - 
******************************************************************************************************************/

public without sharing class XC_REST_CreateDocument {

    /**
     * @description The input wrapper
     */
    public class RequestWrapper {
        public DocumentRequestWrapper Document;

        /**
        * @description The input wrapper builder
        * @param name the file name
        */
        public RequestWrapper(String name){
            this.Document = new DocumentRequestWrapper(name);
        }
    }
    
    /**
     * @description The output wrapper
     */
    public class ResultWrapper {
        public XC_UTIL_Integration.Result Result;
        public DocumentResponseWrapper Document;

        /**
        * @description The output wrapper builder
        */
        public ResultWrapper(){
            this.Result = new XC_UTIL_Integration.Result();
            this.Document = new DocumentResponseWrapper();
        }
    }

    private class DocumentResponseWrapper{
        public String OriginSystem;
        public List<FileWrapper> File;
    }

    private class DocumentRequestWrapper{
        public String OriginSystem;
        public String ActionType;
        public FileWrapper File;

        /**
        * @description The builder
        * @param name the file name
        */
        public DocumentRequestWrapper(String name){
            this.OriginSystem = 'ENC001';
            this.ActionType = 'CARGAR';
            this.File = new FileWrapper(name);
        }
    }

    private class FileWrapper{
        public String FileName;
        public String File;
        public String fileURL;
        public String Status;
        public String DocumentErrorCode;
        public String Description;

        /**
        * @description The builder
        * @param name the file name
        */
        public FileWrapper(String name){
            this.FileName = name;
        }

        /**
        * @description The builder
        */
        public FileWrapper(){
            this.FileName = '';
        }
    }


    /**
     * @description Call to Create Document POST.
     *
     * @param fileName the file Name
     * @param docId the Document id
     * @return the response wrapper
     */
    public static ResultWrapper sendRequest(String fileName, String docId){

        RequestWrapper wrRequest = new RequestWrapper(fileName);

        String content = getFileContent(docId);
        if(content!=''){
            wrRequest.Document.File.File = content;
        } else {
            ResultWrapper result = new ResultWrapper();
            result.Result.ErrorCode = '400';
            result.Result.Message = 'Document not found: docId = '+docId;
            system.debug(Label.XC_CL_NoDocument + ': docId = ' + docId);
            return result;
        }

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('CreateDocument'); 
        if(isActiveInterface.activeInterface){
            String url = isActiveInterface.url;
            String body = JSON.serialize(wrRequest, true);
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'CreateDocument', 'CommoditySpainB2C');

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'CreateDocument');   
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'CreateDocument');   

            /********************* Parse response ********************************************/
            ResultWrapper result = manageResponse(response);
            return result;
            
        } else {
            ResultWrapper result = new ResultWrapper();
            result.Result.Message = Label.XC_CL_InterfaceInactive;
            return result;

        }
    }

    private static String getFileContent(String docId){
        Map<id,Document> doclist = new Map<id,Document>([SELECT id, body FROM document WHERE id=:docId]);
        if(!doclist.values().isEmpty()){
            Blob content = doclist.values()[0].body;
            String myBase64String = EncodingUtil.base64Encode(content);
            return myBase64String;

        } else {
            return '';
        }
    }

    private static ResultWrapper manageResponse(HttpResponse response){
        ResultWrapper result = new ResultWrapper();

        if(response == null) {
            System.debug('No response from the server');
            return result;

        } else {
            System.debug('body: '+response.getBody());
            result = (ResultWrapper) JSON.deserialize(response.getBody(), ResultWrapper.class);
            return result;
        }
    }
    
}