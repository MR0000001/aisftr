/**
 * Created by SNEKKANTI00 on 24/02/2021.
 */

@isTest
global with sharing class MockResponseBrogliaccioContentVersion implements HttpCalloutMock {
    private String contentVersionId;

    global MockResponseBrogliaccioContentVersion(String contentVersionId) {
        this.contentVersionId = contentVersionId;
    }

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        res.setStatusCode(200);
        res.setBody(getJSONBody());
        return res;
    }

    global String getJSONBody() {
        String jsonBody = '{"InserisciSegnalazioneResponse": {"InserisciImmagineSegnalazioneResult": [{"Esito": true,"DescrEsito": "Successo","IDImmagine": 98909,"AllegatoID": ' +'"'+ this.contentVersionId +'"'+ '}]}}';

        return jsonBody;
    }
}