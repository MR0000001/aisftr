/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  03/06/2019 
* @description 
*/
@isTest
global with sharing class XC_REST_ZuoraToken_Mock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) { 

        Map<String, Object> resp = new Map<String, Object>();
        resp.put('access_token','test');

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(resp, true));
        res.setStatusCode(200);
        return res;    
    }

}