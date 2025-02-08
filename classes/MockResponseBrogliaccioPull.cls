/**
 * Created by snekkanti002 on 23/08/2021.
 */

@isTest
public with sharing class MockResponseBrogliaccioPull implements HttpCalloutMock {

    private String state;

    public MockResponseBrogliaccioPull(String state) {
        this.state = state;
    }

    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        System.debug('req.getEndpoint() ' + req.getEndpoint());
        if(req.getEndpoint().containsIgnoreCase('BROGLIACCIO_PULL')) {
            res.setBody(getJSONBodyCase(this.state));
        } else {

        }
        return res;
    }

    private static String getJSONBodyCase(String state) {
        String jsonBody = '{"StatoSegnalazioneResponse":{"StatoSegnalazioneResult":[{"Esito":true,"CodiceEnte":null,"StatoIntervento":1,"VerbatelID":1234,"DescrStato":"Registrata","DescrEsito":"Successo","DescrStatoIntervento":"Non creato","Stato":'+state+',"EsitoIntervento":0,"DescrEsitoIntervento":"Nessuno"}]}}';
        return jsonBody;
    }
}