/**
 * Created by snekkanti002 on 24/09/2021.
 */

@IsTest
public with sharing class TestOpenDataResponseHandler {

    @IsTest
    public static void doPost() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = Url.getSalesforceBaseUrl() + '/OpenDataResponseHandler';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"Esiti":[{"Esito":"1","Id":"2","errorMessage":"","errorCode":"", "isInsertDataSet" : true},{"Esito":"1","Id":"1","errorMessage":"","errorCode":""},{"Esito":"0","Id":"2","errorMessage":"Error message","errorCode":"XXX"}]}');

        RestContext.request = request;

        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{"id":"1","Esito":1}');
        RestContext.response = response;

        Test.startTest();
        OpenDataResponseHandler.doPost();
        Test.stopTest();
    }

    @IsTest
    public static void doPostFail() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = Url.getSalesforceBaseUrl() + '/OpenDataResponseHandler';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"Esito":[{"Esito":"1","Id":"1","errorMessage":"","errorCode":""},{"Esito":"0","Id":"2","errorMessage":"Error message","errorCode":"XXX"}]}');

        RestContext.request = request;

        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{"id":"1","Esito":1}');
        RestContext.response = response;

        Test.startTest();
        OpenDataResponseHandler.doPost();
        Test.stopTest();
    }
}