/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */

@isTest
global with sharing class MockHttpResponseAUC implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        res.setStatusCode(200);
        res.setBody(getJSONBody());
        return res;
    }

    global String getJSONBody() {

        //You need to structure you'r sample JSON reponse into a String. In this reponse you'll need to specify values that you'll be using to do an Assert at the end of TestBatchClass
        String jsonBody = '';

        return jsonBody;
    }
}