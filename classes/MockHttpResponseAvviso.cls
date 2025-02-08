@isTest
global with sharing class MockHttpResponseAvviso implements HttpCalloutMock{
     // Implement this interface method
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
    String json = '{"esitoCaricamento":{"codiceSegnalazione":"456321121","esito":"OK","codiceErrore":"000","descrizioneErrore":"E\' stato creato l\'avviso 000300672441. Aggiornata l\' anagrafica del cliente 8000000008"}}';
    return json;
    }

}