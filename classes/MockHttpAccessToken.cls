@isTest
global with sharing class MockHttpAccessToken implements HttpCalloutMock {
    
     global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(getJSONBody());
        res.setStatusCode(200);
        return res;
    }

    global string getJSONBody()
    {
    
    //You need to structure you'r sample JSON reponse into a String. In this reponse you'll need to specify values that you'll be using to do an Assert at the end of TestBatchClass
    String json = '{"access_token":"baf98fef-3c81-33b4-9889-c285e66f5bbd","scope":"am_application_scope default","token_type":"Bearer","expires_in":9223372036854775}';
    return json;
    }
}