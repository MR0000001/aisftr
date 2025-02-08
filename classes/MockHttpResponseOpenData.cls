/**
 * Created by snekkanti002 on 03/08/2021.
 */

@IsTest
global with sharing class MockHttpResponseOpenData implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Accept', 'application/json');
        res.setStatusCode(200);
        if(req.getEndpoint().containsIgnoreCase('WSO2')) {
            res.setBody(getJSONBodyWso2());
        } else {
            res.setBody(getJSONBody());
        }

        return res;
    }

    private String getJSONBody() {
        String jsonBody = '{"Esiti":[{"Esito":"1","Id":"1","errorMessage":"","errorCode":""},{"Esito":"1","Id":"2","errorMessage":"","errorCode":""}]}';

        return jsonBody;
    }

    private string getJSONBodyWso2() {
        String json = '{"access_token":"baf98fef-3c81-33b4-9889-c285e66f5bbd","scope":"am_application_scope default","token_type":"Bearer","expires_in":9223372036854775}';

        return json;
    }
}