/**
 * Created by SNEKKANTI00 on 11/02/2021.
 */

@isTest
global with sharing class MockHttpResponseInvioAvviso implements HttpCalloutMock {

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
        String json = '{"esitoCaricamento":{"idSegnalazioneEsterna":"456321","codiceSegnalazione":"456321","esito":"OK","codiceErrore":"002","descrizioneErrore":"PER LA SEGNALAZIONE ESTERNA 456321 CANALE 13 È STATO GIÀ CREATO L\'AVVISO 000300672438"}}';
        return json;
    }
}