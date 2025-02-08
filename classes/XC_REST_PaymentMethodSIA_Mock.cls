/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  03/06/2019 
* @description XC_REST_PaymentMethodSIA_Mock – Test class for XC_REST_PaymentMethodSIA_TEST
*/
@isTest
global with sharing class XC_REST_PaymentMethodSIA_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) { 
        XC_UTIL_RESTCallout.CSWrapper intf = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_PaymentMethodSIA); 
        
    	// Optionally, only send a mock response for a specific endpoint

        XC_REST_PaymentMethodSIA_U.responseWrapper resp = new XC_REST_PaymentMethodSIA_U.responseWrapper();


        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(resp, true));
        res.setStatusCode(200);
        return res; 
    }





}