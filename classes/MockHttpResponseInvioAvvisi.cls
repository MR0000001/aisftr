@isTest
global with sharing class MockHttpResponseInvioAvvisi implements HttpCalloutMock {

    private String caseOneNumber;
    private String caseTwoNumber;

    public MockHttpResponseInvioAvvisi(String caseOneNumber, String caseTwoNumber) {
        this.caseOneNumber = caseOneNumber;
        this.caseTwoNumber = caseTwoNumber;
    }
    
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
        String json = '[{"esitoCaricamento":{"idSegnalazioneEsterna":"' + this.caseOneNumber +'","codiceSegnalazione":"000300672666","esito":"OK","codiceErrore":"000","descrizioneErrore":"E\' stato creato l\'avviso 000300672666. Aggiornata l\' anagrafica del cliente 8000000008"}},{"esitoCaricamento":{"idSegnalazioneEsterna":"'+ this.caseTwoNumber +'","codiceSegnalazione":"000300672667","esito":"KO","codiceErrore":"002","descrizioneErrore":"La via non è presente nello stradario"}}]';

    return json;
    }
}