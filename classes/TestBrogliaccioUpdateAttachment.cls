/**
 * Created by snekkanti002 on 26/05/2022.
 */

@IsTest
public with sharing class TestBrogliaccioUpdateAttachment {
    @TestSetup
    public static void setup() {
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
    }

    @IsTest
    public static void updateAttachmentSuccess() {
        String cvId = [SELECT Id FROM ContentVersion LIMIT 1].Id;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('{"allegati":[{"Esito":"1","DescrEsito":"","IDImmagine":"1212","AllegatoID":"'+cvId+'"}]}');
        request.httpMethod = 'POST';

        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{"Esito":1}');

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        BrogliaccioUpdateAttachment.doPost();
        Test.stopTest();
    }

    @IsTest
    public static void updateAttachmentException() {
        String cvId = [SELECT Id FROM ContentVersion LIMIT 1].Id;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();


        request.requestBody = Blob.valueOf('{"allegati":[{"Esito":"0","DescrEsito":"errore","IDImmagine":"","AllegatoID":"'+cvId+'"}]}');

        request.httpMethod = 'POST';

        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{"Esito":1}');

        RestContext.request = request;

        Test.startTest();
        try {
            BrogliaccioUpdateAttachment.doPost();
        } catch(Exception e) {
            DebugService.printException('TestBrogliaccioUpdateAttachment', 'updateAttachmentException', e);
        }
        Test.stopTest();
    }
}