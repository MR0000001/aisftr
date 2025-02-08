/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 20/06/2019
* @description XC_REST_MobilityOrderCallback_Mock – Mock for XC_REST_MobilityOrderCallback REST class
*/
@isTest
global with sharing class XC_REST_MobilityOrderCallback_Mock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) { 
        HttpResponse res = new HttpResponse();

        if(req.getEndpoint().endsWith('client_secret=oifwjf432ijroeijrew')) {
            String body = '{"code" : 200, "result" : {"access_token" : "sdjndsj"}}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
        }
        
        return res;
    }
    

}