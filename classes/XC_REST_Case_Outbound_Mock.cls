/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  04/06/2019 
* @description XC_REST_Case_Outbound_Mock – Test class for XC_REST_Case_Outbound_TEST
*/
@isTest
global with sharing class XC_REST_Case_Outbound_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {    
        
        XC_REST_Case_W.WrapperCaseResponseUpsert response = new XC_REST_Case_W.WrapperCaseResponseUpsert();
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(response, true));
        res.setStatusCode(200);
        System.debug('???res' + res);
        return res;


    }
}