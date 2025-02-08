/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  03/06/2019 
* @description XC_REST_AddressByPOD_Mock – Test class for XC_REST_AddressByPOD
*/
@isTest
global class XC_REST_AddressByPOD_Mock implements HttpCalloutMock{
    
     global HTTPResponse respond(HTTPRequest req) { 
         
         XC_REST_AddressByPOD.WrapperAddressResponse war = new XC_REST_AddressByPOD.WrapperAddressResponse();
         XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_AddressByPOD);
         String prefixUrl = isActiveInterface.url;
         
         if(prefixUrl == 'test1') {
             war.Result.ErrorCode = '1';
         }else{
             war.Result.ErrorCode = '0';
         }
            
         
         
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(war));
        res.setStatusCode(200);
         
        system.debug('+++'+res);
        return res;
         
     }
    
    
    

}