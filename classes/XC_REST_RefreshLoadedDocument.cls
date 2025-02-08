/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 24/11/2020
* @description REST INTERFACE : 
*/
public with sharing class XC_REST_RefreshLoadedDocument {

    public class ResponseWrapper {
        public XC_UTIL_Integration.Result result = new XC_UTIL_Integration.Result();
        public List<FileWrapper> FileItem; 

    } 

    public class RequestWrapper {
        public List<FileWrapper> FileItem; 
    } 

    public class FileWrapper {
        public String company;
        public String country;
        public String object_id;
        public String object_type;
        public String amount;
        public String configuration_id;
        public String contract_id;
        public String contract_number;
        public String customer_name;
        public String document_description;
        public String document_group;
        public String document_due_date;
        public String file_name;
        public String fiscal_code;
        public String hash_id;
        public String id_doxee;
        public String invoice_number;
        public String loading_time;
        public String motivo;
        public String purl;
        public String sf_user;
        public String size;
        public String sub_motivo;
        public String version;
        public String version_trigger;
        public String document_category;
    }


    /**
	* @description callToDoxee
	* @param wrapperInput
	* @return the response wrapper
	*/
	public static ResponseWrapper callToDoxee(RequestWrapper wrapperInput) { 
		ResponseWrapper result = new ResponseWrapper();
		
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('RefreshLoadedDocument'); 
        if(isActiveInterface.activeInterface){

			String url = isActiveInterface.url;
            String body = JSON.serialize(wrapperInput, true);  
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'RefreshLoadedDocument', 'Doxee');

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'RefreshLoadedDocument');

			try {
                result = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);
			} catch(Exception e){
				XC_UTIL_Debug.debug(true, 'Error: '+e);
            }
            
            if(result.FileItem==null||result.FileItem.isEmpty()){
                return result;
            }

            createDocumentType(result.FileItem);
          
        } else{
            result = manageResponseFake();
        }

		return result; 
    }

    /**
	* @description createDocumentType
	* @param fileItem
	*/
    private static void createDocumentType(List<FileWrapper> fileItem){

        Map<String, Integer> numberOfFile = new Map<String, Integer>();
        for(FileWrapper file : fileItem){
            if(numberOfFile.get(file.document_category)==null){
                numberOfFile.put(file.document_category,1);
            } else {
                numberOfFile.put(file.document_category,numberOfFile.get(file.document_category)+1);
            }
        }   

        XC_REST_DoxeeFileInCategory_U.RequestWrapper docReq = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        docReq.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();

        for(FileWrapper file : fileItem){
            if(file.document_category==null){
                continue;
            }

            XC_REST_DoxeeFileInCategory_U.FileWrapper item = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
            item.ObjectID = file.object_id;
            item.Category = file.document_category;
            item.NumberOfFile = numberOfFile.get(file.document_category);
            docReq.CategoryItem.add(item);
        }

        XC_REST_DoxeeFileInCategory_U.ResponseWrapper resp = XC_REST_DoxeeFileInCategory_U.createFiles(docReq);
        system.debug('res:'+resp);
    }
    
    
    private static ResponseWrapper manageResponseFake(){
        
        ResponseWrapper response = new ResponseWrapper();
        response.result.ErrorCode = '200';
        response.result.Message = 'Interface Inactive, Fake Response Success';
        return response;
    }


}