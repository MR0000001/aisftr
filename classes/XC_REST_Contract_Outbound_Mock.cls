/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  24/06/2019 
* @description XC_REST_Contract_Outbound_Mock – Test class for XC_REST_Contract_Outbound_TEST
*/
@isTest
global with sharing class XC_REST_Contract_Outbound_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {    
        
        Map<String,Object> response = new Map<String,Object>();
        
        Map<String,Object> cont = new Map<String,Object>();
        cont.put('ContractNumber', 123);
            
        response.put('Contract', new List<Object>().add(cont));    
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
       	res.setBody(JSON.serialize(response));
        res.setStatusCode(200);
        return res;


    }
}