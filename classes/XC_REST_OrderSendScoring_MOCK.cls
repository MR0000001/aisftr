/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation  03/06/2019 
* @description XC_REST_NextBestOffer_Mock – Test class for XC_REST_NextBestOffer_TEST
*/
@isTest
global with sharing class XC_REST_OrderSendScoring_MOCK implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) { 
         
        XC_REST_OrderSendScoring.ResponseWrapper response = new XC_REST_OrderSendScoring.ResponseWrapper();
        response.Scoring = new XC_REST_OrderSendScoring.WrapperScoring();
        response.Scoring.accountid = 'asd';
        response.Result = new  XC_UTIL_Integration.Result();
        response.Result.Message = 'test';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(response, true));
        res.setStatusCode(200);
        return res;

    }
}