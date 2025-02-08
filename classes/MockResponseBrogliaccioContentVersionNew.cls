/**
 * Created by snekkanti002 on 21/11/2021.
 */

@IsTest
global with sharing class MockResponseBrogliaccioContentVersionNew implements HttpCalloutMock {
    private Boolean isSuccess;

    global MockResponseBrogliaccioContentVersionNew(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        if(this.isSuccess) {
            res.setBody(getSuccessJSONBody());
        } else {
            res.setBody(getFailedJSONBody());
        }

        return res;
    }

    global String getSuccessJSONBody() {
        String jsonBody = '{"Esito": "1"}';

        return jsonBody;
    }

    global String getFailedJSONBody() {
        String jsonBody = '{"Esito": "0"}';

        return jsonBody;
    }
}