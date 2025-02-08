/**
 * *****************************************************************************************************.
 *
 * @author            : Luca Tedeschi ltedeschi@deloitte.it
 * @date Creation     : 06/06/2019
 * @date Modification : 
 * @description       : XC_REST_PodsByAddressAPI_Mock – Mock class for XC_REST_PodsByAddressAPI
 * *****************************************************************************************************
 */

@isTest
global class XC_REST_PodsByAddressAPI_Mock implements HttpCalloutMock {


    global HTTPResponse respond(HTTPRequest req) {    
        
        XC_UTIL_RESTCallout.CSWrapper intf = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_PodsByAddress); 
        
       
        
        XC_REST_PodsByAddressAPI.PodsByAddressResponse resp = new XC_REST_PodsByAddressAPI.PodsByAddressResponse();
        resp.Result = new XC_UTIL_Integration.Result();
        resp.Result.ErrorCode = '0';
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(resp, true));
        res.setStatusCode(200);
        return res;

    }
    

}