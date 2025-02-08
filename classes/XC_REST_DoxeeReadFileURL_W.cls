/**
 * The Class XC_REST_DoxeeReadFileURL_W.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 09/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_DoxeeReadFileURL
 **/


public without sharing class XC_REST_DoxeeReadFileURL_W {

    
    /**
     * @description The Class WrapperResponse.
     */
    public class WrapperResponse {
        
        /** The Result. */ 
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
  
    }
    

    /**
     * @description The Class WrapperRequest.
     */
    public class WrapperRequest {
        
        /** The File item. */
        public List<WrapperRequestFile> FileItem = new List<WrapperRequestFile>();
        
    }
    

    /**
     * @description The Class WrapperRequestFile.
     */
    public class WrapperRequestFile {
        
        /** The Object type. */
        public String ObjectType;  
        
        /** The Object ID. */
        public String ObjectID;
        
        /** The Category. */
        public String Category; 
        
        /** The Document URL. */
        public String DocumentURL;
        
        /** The Document ID. */
        public String DocumentID;
        //[BEGIN, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
        /** The Document FileSize. */
        public String FileSize;
        
        /** The Document Date Of File Upload. */
        public Date DateOfFileUpload;
        //[END, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
    }

}