/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */

@isTest
public with sharing class TestContentVersionService {
    @testSetup static void setup() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        TestDataFactory.createContentVersionBatchSetting();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        List<ContentDocumentLink> contentDocumentLinks = TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
        TestDataFactory.createOrgManagementSettings();
        TestDataFactory.createWSO2Keys();
        TestDataFactory.createGedCaseBatchSettings();
        TestDataFactory.createStartAttachmentGED();
    }

    @isTest
    public static void contentVersionServiceTest() {
        List<String> cdIds = new List<String>();
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, CaseId__c, NumberGED__c, BlockChangesGED__c FROM ContentVersion];
        List<Case> cases = [SELECT Id, ProtocolCFUser__c FROM Case];

        for(ContentVersion cv : contentVersions) {
            cdIds.add(cv.ContentDocumentId);
        }

        List<ContentDocument> contentDocuments = [SELECT id FROM ContentDocument];

        Test.startTest();
        try {
            ContentVersionService.updateContentVersions(contentVersions, true);
            ContentVersionService.HandlerTriggerAfterInsert(contentVersions);
            DELETE contentDocuments;
        } catch(Exception e) {
            System.debug('Exception in TestContentVersionService ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void getCaseCvsMap() {
        List<Case> cases = [SELECT Id FROM Case];

        Test.startTest();
        ContentVersionService.getCaseCvsMap(cases);
        Test.stopTest();
    }

    @isTest
    public static void getCaseIdCvsNotIntegratedMapBrogliaccio() {
        List<String> caseIds = new List<String>();

        for(Case c : [SELECT Id FROM Case]) {
            caseIds.add(c.Id);
        }

        Test.startTest();
        ContentVersionService.getCaseIdCvsNotIntegratedMapBrogliaccio(caseIds);
        Test.stopTest();
    }


    @isTest
    public static void getCaseCvsAllBrogliaccioMap() {
        List<Case> cases = [SELECT Id FROM Case];

        Test.startTest();
        ContentVersionService.getCaseCvsAllBrogliaccioMap(cases);
        Test.stopTest();
    }

    @isTest
    public static void processBatchGEDContentVersions() {
        List<Case> cases = [SELECT Id FROM Case];

        Test.startTest();
        ContentVersionService.processBatchGEDContentVersions(cases);
        Test.stopTest();
    }

    @isTest
    public static void processPlatformEventGEDContentVersions() {
        List<Case> cases = [SELECT Id FROM Case];
        Map<Case, List<ContentVersion>> caseCvsMap = ContentVersionService.getCaseCvsMap(cases);

        Test.startTest();
        ContentVersionService.processPlatformEventGEDContentVersions(caseCvsMap);
        Test.stopTest();
    }

    @isTest
    public static void handleBrogliaccioPostRequestOK() {
        String cvId = [SELECT Id FROM ContentVersion LIMIT 1].Id;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('{"allegati":[{"Esito":"1","DescrEsito":"","IDImmagine":"1212","AllegatoID":"'+cvId+'"}]}');
        request.httpMethod = 'POST';

        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{"Esito":"1"}');

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        ContentVersionService.handleBrogliaccioPostRequest();
        Test.stopTest();
    }

    @isTest
    public static void handleBrogliaccioPostRequestKO() {
        String cvId = [SELECT Id FROM ContentVersion LIMIT 1].Id;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('{"allegati":[{"Esito":"0","DescrEsito":"Error","IDImmagine":"","AllegatoID":"'+cvId+'"}]}');
        request.httpMethod = 'POST';

        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{"Esito":"1"}');

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        ContentVersionService.handleBrogliaccioPostRequest();
        Test.stopTest();
    }

    @isTest
    public static void updateSendAttachmentToGEDTrue() {
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, CaseId__c, NumberGED__c, BlockChangesGED__c FROM ContentVersion];
        List<Case> cases = [SELECT Id FROM Case];
        Map<Case, List<ContentVersion>> caseCVsMap = ContentVersionService.getCaseCvsMap(cases);

        Test.startTest();
        ContentVersionService.updateSendAttachmentToGEDTrue(contentVersions, caseCVsMap, new Map<String, String>(), false);
        Test.stopTest();
    }

    /*@isTest
    public static void processGEDContentVersions() {
        List<Case> cases = [SELECT Id FROM Case];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGEDContentVersionCallout());
        ContentVersionService.processGEDContentVersions(cases);
        Test.stopTest();
    }*/

    @isTest
    public static void batchGEDContentVersion() {
        Test.startTest();
        ContentVersionService.batchGEDContentVersion();
        Test.stopTest();
    }

    @isTest
    public static void getCaseIdsFromContentVersionIds() {
        List<String> cvIds = new List<String>();

        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, CaseId__c, NumberGED__c, BlockChangesGED__c FROM ContentVersion];

        for(ContentVersion cv : contentVersions) {
            cvIds.add(cv.Id);
        }

        Test.startTest();
        ContentVersionService.getCaseIdsFromContentVersionIds(cvIds);
        Test.stopTest();
    }

    @isTest
    public static void insertContentVersions() {
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        ContentVersion cv = new ContentVersion();

        contentVersions.add(cv);


        Test.startTest();
        ContentVersionService.insertContentVersions(contentVersions, false);
        ContentVersionService.insertContentVersions(contentVersions, true);
        Test.stopTest();
    }

    @isTest
    public static void checkAttachmentsWithinLimitsAndUpdate() {
        List<Case> cases = [SELECT Id FROM Case];
        Map<Case, List<ContentVersion>> caseCVsMap = ContentVersionService.getCaseCvsMap(cases);
        Map<String, String> caseIdOutputMap = new Map<String, String>();

        List<ContentVersion> contentVersions = [SELECT Id, CreatedDate, ContentSize FROM ContentVersion];

        Test.startTest();
        ContentVersionService.checkAttachmentsWithinLimitsAndUpdate(caseCVsMap, caseIdOutputMap, false);
        Test.stopTest();
    }

    @isTest
    public static void getCaseCvsAllGEDMap() {
        List<Case> cases = [SELECT Id FROM Case];

        Test.startTest();
        ContentVersionService.getCaseCvsAllGEDMap(cases);
        Test.stopTest();
    }

    @isTest
    public static void createContentVersionsFromPDF() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<ContentVersionWrapper> contentVersionWrappers = new List<ContentVersionWrapper>();

        ContentVersionWrapper contentVersionWrapper = new ContentVersionWrapper('Title', '.pdf', Blob.valueOf('test'), 'Origin', caseId, true, true);

        contentVersionWrappers.add(contentVersionWrapper);

        Test.startTest();
        ContentVersionService.createContentVersionsFromPDF(contentVersionWrappers, new List<FlowCreatePDF.FlowOutput>());
        Test.stopTest();
    }

    @isTest
    public static void addErrors() {
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, CaseId__c, NumberGED__c, BlockChangesGED__c FROM ContentVersion];
        Map<String, String> cvIdErrorMap = new Map<String, String>();

        for(ContentVersion cv : contentVersions) {
            cvIdErrorMap.put(cv.Id, 'Error');
        }

        Test.startTest();
        ContentVersionService.addErrors(contentVersions, cvIdErrorMap);
        Test.stopTest();
    }
}