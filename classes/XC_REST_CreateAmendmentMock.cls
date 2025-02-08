/**
 * @description The Class XC_REST_CreateAmendmentMock.
 */
@isTest
public without sharing class XC_REST_CreateAmendmentMock implements HttpCalloutMock {
    
    /**
    * @description The Http response. 
    * @return the HTTP response
    * @param request the HTTP request
    */
    public HttpResponse respond (HTTPRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"id":"182829134555433421", "Success": true, "Errors" :[{"Code" : "", "Message" : ""}]}');
        response.setStatusCode(200); 
        return response;
    }
}