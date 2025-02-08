/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation  03/06/2019 
* @description XC_REST_NextBestOffer_Mock – Test class for XC_REST_NextBestOffer_TEST
*/
@isTest
global with sharing class XC_DataCentric_Mock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) { 
        
        Map<String,Object> o = new Map<String,Object>();
         
        List<Object> response = new List<Object>();
        response.add(o);

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if(req.getEndpoint().startsWith('https://online.datacentric.es/ws/postal.ajax?method=checkAddress&arguments=username=endesaXtest,password=X4BAmYSTuC,ine=true,geo=true,cga=true')) {
             res.setBody(JSON.serialize(o, true));
        } else {
            res.setBody(JSON.serialize(response, true));
        }
        
        res.setStatusCode(200);
        return res;

    }
}