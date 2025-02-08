/**
* @author Federico Amici - federico.amici@nttdata.com
* @description XC_UTIL_RESTCallout_Mock - Mock class for the XC_UTIL_RESTCallout class
*/
@isTest
public with sharing class XC_UTIL_RESTCallout_Mock implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {    
        
        Map<String, String> mapResponse = new Map<String, String>();
        mapResponse.put('access_token', 'OPEusaoasfknm89340983u4038jf93gjmn945');

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(mapResponse, true));
        res.setStatusCode(200);
        return res;


    }
}