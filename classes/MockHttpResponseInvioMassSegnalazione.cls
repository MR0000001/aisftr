@isTest
global with sharing class MockHttpResponseInvioMassSegnalazione implements HttpCalloutMock {
    
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
    String json = '{"esito":[{"identificativo":"00001233","valore":"true","descrizione":"Segnalazione inoltrata correttamente"},{"identificativo":"00001267","valore":"true","descrizione":"Segnalazione inoltrata correttamente"}]}';
    return json;
    }
}