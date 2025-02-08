/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  07/06/2019 
* @description XC_REST_AddressValidation_Mock – Test class for XC_REST_AddressValidation
*/
@isTest
global class XC_REST_AddressValidation_Mock implements HttpCalloutMock{
    
    /**
     * @author Chiara Turco cturco@deloitte.it
     * @date Creation  07/06/2019 
     * @param req the request
     * @description mocks the response
     */
     global HTTPResponse respond(HTTPRequest req) { 
         
         XC_REST_AddressValidation.ResultWrapper war = new XC_REST_AddressValidation.ResultWrapper();
         war.Result = new XC_REST_AddressValidation.IntegrationResultWrapper();
         war.Result.error_code = '200';
         war.AddressX = new List<XC_REST_AddressValidation.ValidationWrapper>();
         XC_REST_AddressValidation.ValidationWrapper address = new XC_REST_AddressValidation.ValidationWrapper();
         war.AddressX.add(address);
         

         XC_REST_AddressValidation_U.WrapperAddressResponse wrapperResult = new XC_REST_AddressValidation_U.WrapperAddressResponse();
         wrapperResult.Address= new List<XC_UTIL_Address.AddressWrapper>{new XC_UTIL_Address.AddressWrapper()};
         wrapperResult.Address[0].street = 'Calle';
         wrapperResult.Address[0].province = 'Calle';
         wrapperResult.Address[0].city = 'Calle';
         wrapperResult.Address[0].country = 'Calle';
         wrapperResult.Result = new XC_UTIL_Integration.Result();
         wrapperResult.Result.ErrorCode = '0';
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(wrapperResult, true));
        res.setStatusCode(200);
         
        system.debug('+++'+res);
        return res;
         
     }
    
    

}