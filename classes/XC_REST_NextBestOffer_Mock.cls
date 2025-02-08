/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  03/06/2019 
* @description XC_REST_NextBestOffer_Mock – Test class for XC_REST_NextBestOffer_TEST
*/
@isTest
global with sharing class XC_REST_NextBestOffer_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) { 
         
        XC_REST_NextBestOffer.WrapperResponse response = new XC_REST_NextBestOffer.WrapperResponse();
        response.Result = new  XC_UTIL_Integration.Result();
        response.Result.Message = 'test';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(response, true));
        res.setStatusCode(200);
        return res;

    }
}