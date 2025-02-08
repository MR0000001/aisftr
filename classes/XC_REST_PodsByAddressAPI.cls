/**
 * The Class XC_REST_PodsByAddressAPI.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 09/04/2019
 * @date Modification : 29/04/2019
 * @description       : Rest Resourse with ClouderaB2C
 **/

 
public without sharing class XC_REST_PodsByAddressAPI {
	
    /**
     * The Class PodsByAddressResponse. 
     *
     * @description the wrapper response
     */
    public class PodsByAddressResponse {
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
		
		/** The Address cups. */
		public XC_UTIL_Address.AddressWrapper AddressCups;
		
		/** The Points of delivery. */
		public List<XC_UTIL_Address.AddressWrapper> PointsOfDelivery;
	}
    
    
    /**
     * The Class ResultWrapper.
     *
     * @description the wrapper result
     */
    public class ResultWrapper{
        
        /**@description  The success. */
        @AuraEnabled
        public Boolean success {get; set;} 
        
        /** @description The error code. */
        @AuraEnabled
        public Integer errorCode {get; set;} 
        
        /** @description The message. */
        @AuraEnabled 
        public String message {get; set;} 
        
        /** @description The pod address. */
        @AuraEnabled
        public PodsByAddressResponse podAddress {get;set;}
    }
    
    
    /**
     * Call to POD by address.
     *
     * @param addrWrapper the addr wrapper
     * @return the result wrapper
     * @description method to call POD by address
     */
    public static ResultWrapper callToPODByAddress(XC_UTIL_Address.AddressWrapper addrWrapper){
        
        ResultWrapper result = new ResultWrapper();
        
        XC_UTIL_Integration.Result checkParameters = checkRequiredParameters(addrWrapper);
        if(checkParameters.ErrorCode != '0') {
            result.success = false;
            result.errorCode = Integer.valueOf(checkParameters.ErrorCode);
            result.message = checkParameters.Message;
            return result;
        }
        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_PodsByAddress);
        if(isActiveInterface.activeInterface){
            String prefixUrl = isActiveInterface.url;
            Map<String,String> paramMap = new Map<String,String>();
            if(String.isNotBlank(addrWrapper.streetType)) {
                paramMap.put('StreetType', addrWrapper.streetType);
            }
            paramMap.put('Address', EncodingUtil.urlEncode(addrWrapper.address, 'UTF-8'));
            paramMap.put('StreetNumber', EncodingUtil.urlEncode(addrWrapper.streetNumber, 'UTF-8'));
            paramMap.put('ZipCode', EncodingUtil.urlEncode(addrWrapper.zipCode, 'UTF-8'));
            paramMap.put('Province', EncodingUtil.urlEncode(addrWrapper.province, 'UTF-8'));
            paramMap.put('City', EncodingUtil.urlEncode(addrWrapper.city, 'UTF-8'));
            String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramMap);
            
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'getPodsByAddress', 'ClouderaB2C');
            headerDefinitions.put('Authorization', 'Bearer iusfuoqvf');
            
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
            System.debug('[PodsByAddress] request -> ' + request);

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'PodsByAddress');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'PodsByAddress');

			System.debug('[PodsByAddress] response -> ' + response);

            result = manageResponse(response);
        } else {
            result.success = true;
            result = manageResponseFake();
        }
        
        System.debug('[PodsByAddress] result -> ' + result);
        return result;
    }

    
	/**
	 * Manage response.
	 *
	 * @param response the response
	 * @return the result wrapper
     * @description method to manage response
	 */
	private static ResultWrapper manageResponse(HttpResponse response){
		ResultWrapper resWrp = new ResultWrapper();
        
        if(response == null) {
            resWrp.success = false;
            resWrp.message = '';
            resWrp.errorCode = 23;
            return resWrp;
        }
        
        System.debug('[PodsByAddress] response Body -> ' + response.getBody());
        if(response.getStatusCode() == 200){
            
            PodsByAddressResponse wrapperResult = (PodsByAddressResponse) JSON.deserialize(response.getBody(), PodsByAddressResponse.class);
            if(wrapperResult.Result.ErrorCode != '0') {
                resWrp.success = false;     
                resWrp.message = '';
                resWrp.errorCode = 23;
                System.debug('ERROR for AddressBYPOD! -> StatusCode: ' + response.getStatusCode() + '   Status: ' + response.getStatus());
            } else {
                resWrp.success = true;
                resWrp.message = 'OK';
                resWrp.podAddress = wrapperResult;
            }

        } else {
            resWrp.success = false;     
            resWrp.message = '';
        }
        
        return resWrp;
	}

    /**
	 * Manage response.
	 *
	 * @param response the response
	 * @return the result wrapper
     * @description method to manage response
	 */
	private static ResultWrapper manageResponseFake(){

        String fakeRes = '{"Result": {"ErrorCode": "0", "Message": "Operation completed successfully" },'+
                        '"AddressCups": { "Address": "SANT JOSEP 2, 1", "StreetNumber": "2", "ZipCode": "08660", "Province": null, "City": "BALSARENY" },'+
                        '"PointsOfDelivery": [ { "CUPS": "ES0031405417811001BD0F", "Stair": null, "Floor": null, "Door": null },'+
                        '{ "CUPS": "ES0031405417811001BD1F", "Stair": null, "Floor": null, "Door": null } ] }';

        PodsByAddressResponse wrapperResult = (PodsByAddressResponse) JSON.deserialize(fakeRes, PodsByAddressResponse.class);
        ResultWrapper resWrp = new ResultWrapper();
        resWrp.success = true;
        resWrp.message = 'OK';
        resWrp.podAddress = wrapperResult;
        return resWrp;
    }
    
    
    /**
     * Check required parameters.
     *
     * @param addrToValidate the addr to validate
     * @return the result
     * @description method to check the required parameters
     */
    private static XC_UTIL_Integration.Result checkRequiredParameters(XC_UTIL_Address.AddressWrapper addrToValidate) {
        XC_UTIL_Integration.Result response = new XC_UTIL_Integration.Result();

        if(String.isBlank(addrToValidate.address)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_MandatoryField + ' Address';
            return response;
        }
        if(String.isBlank(addrToValidate.streetNumber)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_MandatoryField + ' StreetNumber';
            return response;
        }
        if(String.isBlank(addrToValidate.zipCode)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_MandatoryField + ' ZipCode';
            return response;
        }
        if(String.isBlank(addrToValidate.province)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_MandatoryField + ' Province';
            return response;
        }
        if(String.isBlank(addrToValidate.city)) {
            response.ErrorCode = '400';
            response.Message = Label.XC_CL_MandatoryField + ' City';
            return response;
        }

        response.ErrorCode = '0';
        return response;
    }
    
}