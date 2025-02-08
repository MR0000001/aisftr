/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation  03/06/2019 
* @description XC_REST_UpdateMOPCallout_Mock – Test class for XC_REST_PaymentMethodSIA_TEST
*/
@isTest
global with sharing class XC_REST_UpdateMOPCallout_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) { 
        
        XC_REST_PaymentMethodSIA_U.responseWrapper resp = new XC_REST_PaymentMethodSIA_U.responseWrapper();
        resp.debtorCode = 'test123';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
      
        system.debug('asdasdasd: '+req.getEndpoint());
        
        if(req.getEndpoint().contains('accounts')){
            ZuoraWebservice.CreateZuoraAccountResponse returnResp = new ZuoraWebservice.CreateZuoraAccountResponse();
            returnResp.success = 'true';
            res.setBody(JSON.serialize(returnResp, true));
        } else {
            res.setBody(JSON.serialize(resp, true));
        }
        
        return res; 
    }





}