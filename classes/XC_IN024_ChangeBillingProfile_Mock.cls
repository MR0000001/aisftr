/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 24/06/2019 
* @description XC_IN024_ChangeBillingProfile_Mock – Mock class for XC_IN024_ChangeBillingProfile
*/
@isTest
global with sharing class XC_IN024_ChangeBillingProfile_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {    
        
        XC_REST_ZuoraOwnerTransfer_U.WrapperResponse responseWr = new XC_REST_ZuoraOwnerTransfer_U.WrapperResponse();
        responseWr.results = new List<XC_REST_ZuoraOwnerTransfer_U.WrapperResult>();
        responseWr.results[0].errors = new List<XC_REST_ZuoraOwnerTransfer_U.Errors>();
        
        XC_REST_ZuoraOwnerTransfer_U.WrapperResult wrResult = new XC_REST_ZuoraOwnerTransfer_U.WrapperResult();
        wrResult.AmendmentIds = new List<String>{'amendmentID12'};
        wrResult.SubscriptionId = 'olnfjnfjnfvfv';
        wrResult.Success = true;
        wrResult.TotalDeltaMrr = 378;
        wrResult.TotalDeltaTcv = 378;
        
        responseWr.results.add(wrResult);
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(responseWr, true));
        System.debug('##### ' + res.getBody());
        
        res.setStatusCode(200);
        return res;


    }
}