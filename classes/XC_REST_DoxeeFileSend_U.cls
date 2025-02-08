/**
 * The Class XC_REST_DoxeeFileSend_U.
 *
 * @author            : Giulio Serra gserra@deloitte.it
 * @date Creation     : 03/01/2019
 * @date Modification : 19/02/2019 by Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : Util for XC_REST_DoxeeFileSend
 **/


public class XC_REST_DoxeeFileSend_U {
    

    /**
     * The Class RequestWrapper.
     *
     * @description the wrapper request
     */
    public class RequestWrapper{
        
        /** The File. */
        public FileWrapper File;
        
        /**
         * @description Instantiates a new request wrapper.
         */
        public RequestWrapper(){
            File = new FileWrapper();
        }
    }
        

    /**
     * The Class ResponseWrapper.
     *
     * @description the wrapper response
     */
    public class ResponseWrapper{
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
        
        /** The File. */
        public FileWrapper File;
        
    }
    

    /**
     * The Class FileWrapper.
     *
     * @description the file wrapper
     */
    public class FileWrapper{
        
        /** The File size. */
        public Integer FileSize;
        
        /** The File name. */
        public String FileName;
        
        /** The String. */
        Public String FileDescription;
        
        /** The File creation date. */
        public String FileCreationDate;
        
        /** The File category. */
        public String FileCategory;
        
        /** The File base 64. */
        public String FileBase64;
        
        /** The Object type. */
        public String ObjectType;
        
        /** The Object ID. */
        public String ObjectID;
        
        /** The Company. */
        public String Company;
        
        /** The Country. */
        public String Country;
        
        /** The Id. */
        public String Id;
        
        /** The Purl. */
        public String Purl;
        
        /** The Version. */
        public String Version;
        
        /** The Product Subtype of the Order Item related to the document */
        public String ContractProductCategory;
    }

    
    /**
     * Check required parameters.
     *
     * @param wrapper the wrapper
     * @return the XC_UTIL_Integration.Result
     * @description check Required Parameters
     */
    public static XC_UTIL_Integration.Result checkRequiredParameters(RequestWrapper wrapper) {
        XC_UTIL_Integration.Result response = new XC_UTIL_Integration.Result();

        if(wrapper.File.FileSize == null) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_MandatoryField + 'File.FileSize';
            return response;
        }

        Map<String, String> requiredParameters = new Map<String, String>{'FileName' => wrapper.File.FileName,
                                                                            'FileCreationDate' => wrapper.File.FileCreationDate,
                                                                            'FileCategory' => wrapper.File.FileCategory,
                                                                            'FileBase64' => wrapper.File.FileBase64,
                                                                            'ObjectType' => wrapper.File.ObjectType,
                                                                            'ObjectID' => wrapper.File.ObjectID,
                                                                            'Company' => wrapper.File.Company,
                                                                            'Country' => wrapper.File.Country
                                                                        };
        for(String key : requiredParameters.keySet()) {
            if(String.isBlank(requiredParameters.get(key))) {
                response.Message = Label.XC_CL_MandatoryField +'File.' + key;
                response.ErrorCode = '400';
                return response;
            }
        }
        
        XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_Integration.validateFileRequest(wrapper.file.ObjectType, wrapper.file.FileCategory);
        if(validateResult.errorFlag) {
            response.ErrorCode = '400';
            response.Message = validateResult.errorMessage;
            return response;
        }

        response.ErrorCode = '0';
        return response;
    }
}