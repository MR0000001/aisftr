/**
* @author Giuseppe Di Bonito gdibonito@deloitte.it
* @date Creation  07/02/2020 
* @description XC_REST_UrgentWONotification_Mock 
*/
@isTest
global with sharing class XC_REST_UrgentWONotification_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) { 
         
        XC_REST_UrgentWONotification.WrapperResult response = new XC_REST_UrgentWONotification.WrapperResult();
        response.Result = 1;
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(response, true));
        res.setStatusCode(200);
        return res;

    }
}