/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation  04/12/2020 
* @description XC_REST_NextBestOffer_Mock – Test class for XC_REST_NextBestOffer_TEST
*/
@isTest
global with sharing class XC_REST_RefreshLoadedDocument_MOCK implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) { 
        
        
        List<XC_REST_RefreshLoadedDocument.FileWrapper> items = new List<XC_REST_RefreshLoadedDocument.FileWrapper>(); 
       	
        XC_REST_RefreshLoadedDocument.FileWrapper i = new XC_REST_RefreshLoadedDocument.FileWrapper();
        
        i.object_id = '132';
        i.object_type = '132';
        
        items.add(i);
        
        XC_REST_RefreshLoadedDocument.ResponseWrapper o = new XC_REST_RefreshLoadedDocument.ResponseWrapper();
        o.FileItem = items;
               
        

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
  
        res.setBody(JSON.serialize(o, true));

        
        res.setStatusCode(200);
        return res;

    }
}