/**
 * Created by SNEKKANTI00 on 09/02/2021.
 */

@isTest
global with sharing class MockHttpResponseMesis implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        res.setStatusCode(200);
        res.setBody(getJSONBody());
        return res;
    }

    global String getJSONBody() {
        String jsonBody = '{"msgUid": "c83e19c3-b08b-48c9-aec7-00491e544fee","timestamp": "2021-02-11T08:33:20.620+0000","retCode": 200,"domanda": {"tipoServizio": "DBLB","annoScolastico": "30","telefonoRichiedente": "232323232","alunno": {"nome": "NICCOLO\'", "cognome": "TORTOLI\'","dataNascita": "2007-08-05","statoDomanda": "BUONO EMESSO"}}}';

        return jsonBody;
    }
}