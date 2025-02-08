/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  04/06/2019 
* @description XC_REST_NotifyPayment_Mock – Test class for XC_REST_NotifyPayment_TEST
*/
@isTest
global with sharing class XC_REST_NotifyPayment_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) { 
        XC_REST_NotifyPayment_U.WrapperResponse responseWrapper = new XC_REST_NotifyPayment_U.WrapperResponse();
        responseWrapper.status = '';
        responseWrapper.success = true;
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(responseWrapper, true));
        res.setStatusCode(200);
        return res;
    }

}