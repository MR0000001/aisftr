/**
 * @author            :
 * @date Creation     :
 * @date Modification : 09/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : XC_REST_AddressByPOD – Rest Resourse with ClouderaB2C
 */

public class XC_REST_AddressByPOD  {
    
    /**
     * @description The Class WrapperAddressResponse.
     */
    public class WrapperAddressResponse{

        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
	
		public XC_UTIL_Address.AddressWrapper Address;
	}

    /**
     * @description The Class ResultWrapper.
     */
    public class ResultWrapper{
        
        @AuraEnabled
        public Boolean success {get; set;} 
 
        @AuraEnabled
        public XC_UTIL_Address.AddressWrapper addressReturned {get;set;}
    }  

    /**
     * @description Call to address by POD.
     * @param cups the cups
     * @return the result wrapper
     */
    public static ResultWrapper callToAddressByPOD(String cups){
        
        ResultWrapper result = new ResultWrapper(); 

        if(String.isBlank(cups)) {
            result.success = false;
            System.debug('[AddressByPOD] result -> ' + result);
            return result;
        }
        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_AddressByPOD);
        System.debug('test' + isActiveInterface.activeInterface);
        System.debug('test' + isActiveInterface.url);

        if(isActiveInterface.activeInterface){ 
            
            String prefixUrl = isActiveInterface.url;
            Map<String,String> paramMap = new Map<String,String>();
            paramMap.put('CUPS', cups);
            String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramMap);
            
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'getAddressByPOD', 'ClouderaB2C');
            headerDefinitions.put('Authorization', 'Bearer test');
            
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
            System.debug('[AddressByPOD] request -> ' + request);

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'AddressByPOD');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'AddressByPOD');

            System.debug('[AddressByPOD] response -> ' + response);

            result = manageResponse(response); 

        } else {
            result = manageResponseFake(cups); 

        }
        
        System.debug('[AddressByPOD] result -> ' + result);
        return result;
    }
    

    /**
     * @description Manage response.
     * @param response the response
     * @return the result wrapper
     */
    private static ResultWrapper manageResponse(HttpResponse response){
        ResultWrapper resWrp = new ResultWrapper();
        
        if(response == null) {
            resWrp.success = false;
            return resWrp;
        }
        
        System.debug('[AddressByPOD] response Body -> ' + response.getBody());
        if(response.getStatusCode() == 200){
            WrapperAddressResponse wrapperResult = (WrapperAddressResponse) JSON.deserialize(response.getBody(), WrapperAddressResponse.class);
            if(wrapperResult.Result.errorCode != '0') {
                resWrp.success = false;
                System.debug('ERROR for AddressBYPOD! -> StatusCode: ' + response.getStatusCode() + '   Status: ' + response.getStatus());
            } 
            else {
                resWrp.success = true;
                resWrp.addressReturned = wrapperResult.Address;
            }
        } else {
            resWrp.success = false;
        }
        
        return resWrp;
    }

    /**
     * @description Manage response. 
     * @param cups the cups
     * @return the result wrapper
     */
    private static ResultWrapper manageResponseFake(String cups){
        ResultWrapper resWrp = new ResultWrapper();

        WrapperAddressResponse wrapperResult = new WrapperAddressResponse();
        wrapperResult.Address = new XC_UTIL_Address.AddressWrapper();

        if (cups=='ES0217010119115244VE') {
            wrapperResult.Address.Country = 'Spain';
            wrapperResult.Address.City = 'Madrid';
            wrapperResult.Address.Municipality = 'Madrid';
            wrapperResult.Address.StreetNumber = '12';
            wrapperResult.Address.StreetType = 'Calle';
            wrapperResult.Address.Address = 'Ribera del Loira';
            wrapperResult.Address.zipCode = '28042';
            wrapperResult.Address.Province = 'Madrid';
            wrapperResult.Address.Floor = '5';
            wrapperResult.Address.Door = '1';
            wrapperResult.Address.Stair = 'E A';
            wrapperResult.Address.gasCUPS = cups;
            wrapperResult.Address.electricCUPS = '';
            resWrp.success = true;

        } else if (cups=='ES0217010119115243VE') {
            wrapperResult.Address.Country = 'Spain';
            wrapperResult.Address.City = 'Madrid';
            wrapperResult.Address.Municipality = 'Madrid';
            wrapperResult.Address.StreetNumber = '12';
            wrapperResult.Address.StreetType = 'Calle';
            wrapperResult.Address.Address = 'Ribera del Loira';
            wrapperResult.Address.zipCode = '28042';
            wrapperResult.Address.Province = 'Madrid';
            wrapperResult.Address.Floor = '5';
            wrapperResult.Address.Door = '1';
            wrapperResult.Address.Stair = 'E A';
            wrapperResult.Address.electricCUPS = cups;
            wrapperResult.Address.gasCUPS = '';
            resWrp.success = true;

        } else {
            resWrp.success = false;
        }

        resWrp.addressReturned = wrapperResult.Address;

        return resWrp;
    }



}