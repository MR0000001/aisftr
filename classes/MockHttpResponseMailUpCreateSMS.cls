/**
 * Created by SNEKKANTI00 on 11/03/2021.
 */

global with sharing class MockHttpResponseMailUpCreateSMS implements HttpCalloutMock {
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
        String jsonBody = '{"Subject" : "Appointment #1","idList" : 1,"idMessage" : 2}';

        return jsonBody;
    }
}