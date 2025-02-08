/**
 * The Class XC_REST_AddressValidation.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 30/10/2018
 * @date Modification : 22/03/2019
 * @description       : Rest Resourse for Address Validation
 **/


public without sharing class XC_REST_AddressValidation {
    
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
		@AuraEnabled
        public String address {get; set;}  
        

        public IntegrationResultWrapper Result = new IntegrationResultWrapper();
        public List<ValidationWrapper> AddressX = new List<ValidationWrapper>();       
	}

    public class ValidationWrapper{
        public String street_type;
        public String street;
        public String street_number;
        public String zip_code;
        public String city;
        public String country ;
        public String door;
        public String stair;
        public String floor;
        public String country_code;
        public String province_code;
        public String province;
        public String municipality_code;
        public String municipality_desc;
        public String city_code;
        public String street_code;
        public String latitude;
        public String longitude;
        public String country_iso;
        public String hamlet;
        public String confidence_level;
    }

    public class IntegrationResultWrapper{
        public String error_code;
        public String message;
    }



    /**
     * @description Validate address with Mashery service
     * @param inputMap the address
     * @return a map of results
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     */
    @AuraEnabled  
    public static Map<String,Object> callToAddressValidationNew(Map<String,Object> inputMap) {
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String, String> fieldsToSend = setRequestParams(inputMap);

        Map<String,Object> addr =  new Map<String, Object>{ 
            'Address' => fieldsToSend 
        };

        List<String> mf = new List<String>{'street_type', 'street', 'street_number', 'zip_code', 'city', 'country'};
        for(String field : fieldsToSend.KeySet()) {
            if((fieldsToSend.get(field)==null || fieldsToSend.get(field)+''=='') && mf.contains(fieldsToSend.get(field))) { 
                outputMap.put('ErrorCode', '400');
                outputMap.put('ErrorMessage', Label.XC_CL_MandatoryField +field);
                return outputMap;
            }
        }

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('AddressValidation');
        if(isActiveInterface.activeInterface){
            String prefixUrl = isActiveInterface.url;

            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'ValidateAddress', 'SpainAddressNormalizer');
        
            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', prefixUrl, headerDefinitions, JSON.serialize(addr, true));
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,  headerDefinitions.get('TransactionID') , 'ValidateAddress');

            /********************* Parse response ********************************************/
            ResultWrapper wrRes = new ResultWrapper();

            try {       
                String body = response.getBody().replace('Address','AddressX');
                wrRes = (ResultWrapper) JSON.deserialize(body, ResultWrapper.class);

            } catch(Exception e){
                system.debug('resp: '+response.getBody());
                system.debug('exception: '+e);
                outputMap.put('ErrorCode', '500');
                outputMap.put('ErrorMessage', 'Server Error');
                return outputMap;
            }

            if(wrRes.Result.error_code == '500') {
                outputMap.put('ErrorCode', '500');
                outputMap.put('ErrorMessage', Label.XC_CL_Address_Incorrect );
                return outputMap;
            } 
            
            if(wrRes.Result.error_code == '0') {
                if(String.isBlank(wrRes.AddressX[0].street)||String.isBlank(wrRes.AddressX[0].city)||String.isBlank(wrRes.AddressX[0].street_number)){
                    outputMap.put('ErrorCode', '500');
                    outputMap.put('ErrorMessage', Label.XC_CL_Address_Incorrect );
                    return outputMap;
                } else {
                    outputMap.put('MunicipalityDesc', wrRes.AddressX[0].municipality_desc);
                    outputMap.put('ErrorCode', '200');
                    outputMap.put('ErrorMessage', Label.XC_CL_Address_NoChange );
                    return outputMap;
                }
            }    
            outputMap.put('ErrorCode', '500');
            outputMap.put('ErrorMessage', 'Server Error');
            return outputMap;
            
        } else {
            outputMap.put('ErrorCode', '500');
            outputMap.put('ErrorMessage', 'Inactive interface');
            return outputMap;
        }
        
    }


    private static Map<String, String> setRequestParams(Map<String, Object> inputMap){
        String dc = String.valueOf(inputMap.get('country'));
        List<XC_CM_CountryISOCodeAssociation__mdt> countryCode = [SELECT XC_ISOCode__c FROM XC_CM_CountryISOCodeAssociation__mdt WHERE XC_Country__c =: dc];
        
        Map<String, String> fieldsToSend = new Map<String, String>{ 
            'street_type' => String.valueOf(inputMap.get('streetType')),
            'street' => String.valueOf(inputMap.get('address')),
            'street_number' => String.valueOf(inputMap.get('streetNumber')),
            'zip_code' => String.valueOf(inputMap.get('postalCode')),
            'city' => String.valueOf(inputMap.get('city')),
            'country' => countryCode[0].XC_ISOCode__c,
            'door' => String.valueOf(inputMap.get('door')),
            'stair' => String.valueOf(inputMap.get('stair')),
            'floor' => String.valueOf(inputMap.get('floor')),
            'province' => String.valueOf(inputMap.get('province'))
        };

        if(String.isBlank(fieldsToSend.get('door'))){
            fieldsToSend.remove('door');
        }

        if(String.isBlank(fieldsToSend.get('stair'))){
            fieldsToSend.remove('stair');
        }

        if(String.isBlank(fieldsToSend.get('floor'))){
            fieldsToSend.remove('floor');
        }

        return fieldsToSend;
    }

 
    /**
     * CallToAddressValidation.
     *
     * @param addrToValidate the addr to validate
     * @return the result wrapper
     * @description method to call to address validation
     */
    @AuraEnabled
	public static ResultWrapper callToAddressValidation(XC_UTIL_Address.AddressWrapper addrToValidate) {
		ResultWrapper result = new ResultWrapper();

        XC_UTIL_Integration.Result checkParameters = XC_REST_AddressValidation_U.checkRequiredParameters(addrToValidate);
        if(checkParameters.ErrorCode != '0') {
            result.success = false;
            result.addressResult = checkParameters.Message;
            return result;
        }

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_Address_Validation); 
        if(isActiveInterface.activeInterface){

			String url = isActiveInterface.url;

            XC_REST_AddressValidation_U.WrapperAddressRequest addRequest = new XC_REST_AddressValidation_U.WrapperAddressRequest();
            addRequest.Address = addrToValidate;
           
            System.debug('[AddressValidation] request -> ' + addRequest.Address);
            String body = JSON.serialize(addRequest, true);

            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'ValidateAddress', 'SpainAddressNormalizer');

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            System.debug('[AddressValidation] request -> ' + request);
            System.debug('[AddressValidation] request Body -> ' + body);

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'AddressValidation');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'AddressValidation');

            System.debug('[AddressValidation] response -> ' + response);
            /********************* Parse response ********************************************/
            result = manageResponse(response);
		} else {
         result.success = true;
         result.addressResult = 'Validation OK';
         result.address = JSON.serialize(addrToValidate, true); 
        }  

        System.debug('[AddressValidation] result -> ' + result);
		return result; 
	}
 	

    /**
     * Manage response fake.
     *
     * @return the result wrapper
     * @description method to manage fake response
     */
    @TestVisible
    private static ResultWrapper manageResponseFake() {
        ResultWrapper wrapper = new ResultWrapper();
        wrapper.success = true;
        wrapper.addressResult = 'Validation OK';
        return wrapper;
    }
    
	/**
	 * Manage response
     *
	 * @param response the response
	 * @return the result wrapper
     * @description method to manage response
	 */
	@TestVisible
    private static ResultWrapper manageResponse(HttpResponse response){
        System.debug('@@@@@@entrato in manageResponse');
		ResultWrapper result = new ResultWrapper();

        if(response == null) {
            result.success = false;
            return result;
        }
        
        System.debug('@@@@@@entrato in manageResponse con RESPONSE = '+response.getStatusCode());
        
        if(response.getStatusCode() == 504){
            
            result.success = false;
                result.addressResult = Label.XC_CL_AddressOutServer;
                return result;
            
        }
        
        	 
        if(response.getStatusCode() == 200){
           
            XC_REST_AddressValidation_U.WrapperAddressResponse wrapperResult =
                (XC_REST_AddressValidation_U.WrapperAddressResponse) JSON.deserialize(response.getBody(), XC_REST_AddressValidation_U.WrapperAddressResponse.class);
            
             System.debug('entrato in ok status 200 con wr = '+wrapperResult);
             
            if(wrapperResult.Address!= null && wrapperResult.Address[0]!=null){
            
            XC_UTIL_Integration.Result wrapperCheckResult = XC_REST_AddressValidation_U.checkResponseParameters(wrapperResult.Address[0]);
            
            System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@' + wrapperCheckResult.Message);
            if(wrapperCheckResult.ErrorCode == '500') {
                result.success = false;
                result.addressResult = wrapperCheckResult.Message;
                return result;
            } else if (wrapperCheckResult.ErrorCode == '0'){
                result.success = true;
                result.addressResult = 'Validation OK';
                result.address = JSON.serialize(wrapperResult.Address[0], true); 
            }else{
                result.success = false;
                result.addressResult = Label.XC_CL_AddressOutServer;
                return result;
            }

        } else {
            result.success = false;
            if(wrapperResult.Address==null){
                 result.addressResult = 'No address found';
                 System.debug('ERROR1 for AddressValidation! -> StatusCode: ' + response.getStatusCode() + '   Status: ' + response.getStatus());

            }
           
        }
        }else {
            result.success = false;
            System.debug('ERROR2 for AddressValidation! -> StatusCode: ' + response.getStatusCode() + '   Status: ' + response.getStatus());
        }
        

		return result;
	}

}