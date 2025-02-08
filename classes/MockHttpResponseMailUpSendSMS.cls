/**
 * Created by SNEKKANTI00 on 11/03/2021.
 */

global with sharing class MockHttpResponseMailUpSendSMS implements HttpCalloutMock {
    private String jsonBody;

    global MockHttpResponseMailUpSendSMS(Boolean wantException) {
        if(wantException) {
            jsonBody = null;
        } else {
            jsonBody = '{"Id":2147483647,"InvalidRecipients":[],"Sent":3,"UnprocessedRecipients":[],"idMessage":30}';
        }
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
        return jsonBody;
    }
}