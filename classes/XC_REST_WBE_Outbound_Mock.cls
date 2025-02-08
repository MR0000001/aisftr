/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  24/06/2019
* @description XC_REST_Contract_Outbound_Mock – Test class for XC_REST_Contract_Outbound_TEST
*/
@isTest
global with sharing class XC_REST_WBE_Outbound_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        XC_REST_WBE_Inbound_U.ResponseWrapper response = new XC_REST_WBE_Inbound_U.ResponseWrapper();
        response.result.error_code = '200';
        response.result.message = 'Interface Inactive, Fake Response Success';


        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(response));
        res.setStatusCode(200);
        return res;



    }
}