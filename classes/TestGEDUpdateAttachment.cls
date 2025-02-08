/**
 * Created by snekkanti002 on 28/07/2021.
 */

@IsTest
public with sharing class TestGEDUpdateAttachment {
    @TestSetup
    public static void setup() {
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
    }

    @IsTest
    public static void updateAttachmentSuccess() {
        String cvId = [SELECT Id FROM ContentVersion LIMIT 1].Id;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('{"id":"'+cvId+'","numeroAllegato":"1234","errorCode":null,"errorMessage":null}');
        request.httpMethod = 'POST';

        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{"id":"'+cvId+'",numeroAllegato:"1234","Esito":1}');

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        GEDUpdateAttachment.doPost();
        Test.stopTest();
    }

    @IsTest
    public static void updateAttachmentFail() {
        String cvId = [SELECT Id FROM ContentVersion LIMIT 1].Id;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('{"id":"'+cvId+'","numeroAllegato":"","errorCode":"1234","errorMessage":"Error"}');
        request.httpMethod = 'POST';

        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{"id":"'+cvId+'",numeroAllegato:"1234","Esito":1}');

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        GEDUpdateAttachment.doPost();
        Test.stopTest();
    }

    @IsTest
    public static void updateAttachmentException() {
        String cvId = [SELECT Id FROM ContentVersion LIMIT 1].Id;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('{"id":"'+cvId+'","numeroAllegato":"","errorCode":"1234","errorMessage":"Error"}');
        request.httpMethod = 'POST';

        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{"id":"'+cvId+'",numeroAllegato:"1234","Esito":1}');

        RestContext.request = request;

        Test.startTest();
        try {
            GEDUpdateAttachment.doPost();
        } catch(Exception e) {
            DebugService.printException('TestGEDUpdateAttachment', 'updateAttachmentException', e);
        }
        Test.stopTest();
    }
}