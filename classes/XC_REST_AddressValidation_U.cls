/**
 * ****************************************************************************************************.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 30/10/2018
 * @date Modification : 22/03/2019
 * @description       : XC_REST_AddressValidation_U – UTIL for XC_REST_AddressValidation
 * ****************************************************************************************************
 */

public class XC_REST_AddressValidation_U {

    /**
     * @description The Class ResultWrapper.
     */
    public class ResultWrapper{
		
		/** @description The success. */
		@AuraEnabled
		public Boolean success {get; set;} 
		
		/** @description The address result. */
		@AuraEnabled
        public String addressResult {get; set;}  
	}

    /**
     * @description The Class WrapperAddressRequest.
     */
    public class WrapperAddressRequest {
        
        /** The Address. */
        public XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper('REST');
    }


    /**
     * @description  The Class WrapperAddressResponse.
     */
    /* XC_UTIL_Integration.Result */
    public class WrapperAddressResponse {
        
        /** @description The Result. */
        public XC_UTIL_Integration.Result Result;
        
        /** @description The Address. */
        public List<XC_UTIL_Address.AddressWrapper> Address;
    }


    /**
     * @description Check required parameters.
     * @param addrToValidate the addr to validate
     * @return the x C UTI L integration. result
     */
    public static XC_UTIL_Integration.Result checkRequiredParameters(XC_UTIL_Address.AddressWrapper addrToValidate) {
        XC_UTIL_Integration.Result response = new XC_UTIL_Integration.Result();

        if(String.isBlank(addrToValidate.streetType)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_RequiredFields + Label.XC_CL_StreetType;
            return response;
        }
        if(String.isBlank(addrToValidate.street)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_RequiredFields + Label.XC_CL_Address;
            return response;
        }
        if(String.isBlank(addrToValidate.streetNumber)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_RequiredFields + Label.XC_CL_StreetNumber;
            return response;
        }
        if(String.isBlank(addrToValidate.zipCode)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_RequiredFields + Label.XC_CL_PostalCode;
            return response;
        }
        if(String.isBlank(addrToValidate.city)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_RequiredFields + Label.XC_CL_City;
            return response;
        }
        if(String.isBlank(addrToValidate.country)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_RequiredFields + Label.XC_CL_Country;
            return response;
        }

        response.ErrorCode = '0';
        return response;
    }
	
     /**
     * @description Check required parameters.
     * @param addrToValidate the addr to validate
     * @return the x C UTI L integration. result
     */
    public static XC_UTIL_Integration.Result checkResponseParameters(XC_UTIL_Address.AddressWrapper addrToValidate) {
        XC_UTIL_Integration.Result response = new XC_UTIL_Integration.Result();

       
        if(String.isBlank(addrToValidate.street)) {
            response.ErrorCode = '500';
            response.Message = Label.XC_CL_Address_ErrorAddress;
            return response;
        }
        if(String.isBlank(addrToValidate.province)) {
            response.ErrorCode = '500';
            response.Message = Label.XC_CL_Address_ErrorProvince;
            return response;
        }
        if(String.isBlank(addrToValidate.city)) {
            response.ErrorCode = '500';
            response.Message = Label.XC_CL_Address_ErrorCity;
            return response;
        }
        if(String.isBlank(addrToValidate.country)) {
            response.ErrorCode = '500';
            response.Message = Label.XC_CL_Address_ErrorCountry;
            return response;
        }
         
       /* if(String.isBlank(addrToValidate.zipCode)) {
            response.ErrorCode = '500';
            response.Message = Label.XC_CL_Address_ErrorZipCode;
            return response;
        }*/

        response.ErrorCode = '0';
        return response;
    }

}