/**
 * Created by SNEKKANTI00 on 08/03/2021.
 */

global with sharing class MockHttpResponseTaxonomy implements HttpCalloutMock {
    private Integer statusCode;

    global MockHttpResponseTaxonomy(Integer statusCode) {
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        res.setStatusCode(this.statusCode);
        res.setBody(getJSONBody());
        return res;
    }

    global String getJSONBody() {
        String jsonBody = '{"esito": "OK"}';

        return jsonBody;
    }
}