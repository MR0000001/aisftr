/**
 * Created by FMARCHEGIA00 on 20/04/2021.
 */

@isTest
global with sharing class MockHttpResponseAvvisoKO implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {

        CalloutException e = new CalloutException();
        e.setMessage('This is a constructed exception!');
        throw e;
    }
}