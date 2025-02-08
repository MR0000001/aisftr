/**
 * Created by SNEKKANTI00 on 24/02/2021.
 */
@isTest
global with sharing class MockResponseBrogliaccioCase implements HttpCalloutMock  {
    private String caseId;
    private String contentVersionId;
    global MockResponseBrogliaccioCase(String caseId, String contentVersionId) {
        this.caseId = caseId;
        this.contentVersionId = contentVersionId;
    }
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        System.debug('req.getEndpoint() ' + req.getEndpoint());
        if(req.getEndpoint().containsIgnoreCase('BROGLIACCIO_CASE')) {
            System.debug('in BROGLIACCIO_CASE');
            res.setBody(getJSONBodyCase());
        } else {
            res.setBody(getJSONBodyContentVersion());
        }
        return res;
    }
    private String getJSONBodyCase() {
        String jsonBody = '{"InserisciSegnalazioneResponse": {"InserisciSegnalazioneResult": [{"Esito": true,"DescrEsito": "Successo","IDSegnalazione": 7015,"PortalID": ' +'"'+ this.caseId +'"'+ '}]}}';
        return jsonBody;
    }
    private String getJSONBodyContentVersion() {
        String jsonBody = '{"InserisciSegnalazioneResponse": {"InserisciImmagineSegnalazioneResult": [{"Esito": true,"DescrEsito": "Successo","IDImmagine": 98909,"AllegatoID": ' +'"'+ this.contentVersionId +'"'+ '}]}}';
        return jsonBody;
    }
}