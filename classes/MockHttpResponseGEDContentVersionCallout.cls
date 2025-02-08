/**
 * Created by snekkanti002 on 28/07/2021.
 */

global with sharing class MockHttpResponseGEDContentVersionCallout implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Accept', 'application/json');
        res.setStatusCode(200);
        System.debug('req.getEndpoint() ' + req.getEndpoint());
        if(req.getEndpoint().containsIgnoreCase('WSO2')) {
            res.setBody(getJSONBodyWso2());
        } else {
            res.setBody(getJSONBody());
        }

        return res;
    }

    private String getJSONBody() {
        String jsonBody = '';

        return jsonBody;
    }

    private string getJSONBodyWso2() {

        //You need to structure you'r sample JSON reponse into a String. In this reponse you'll need to specify values that you'll be using to do an Assert at the end of TestBatchClass
        String json = '{"access_token":"baf98fef-3c81-33b4-9889-c285e66f5bbd","scope":"am_application_scope default","token_type":"Bearer","expires_in":9223372036854775}';
        return json;
    }
}