/**
 * Created by snekkanti002 on 06/08/2021.
 */

@IsTest
public with sharing class TestGEDCheckAttachments {

    @TestSetup
    public static void setup() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
        TestDataFactory.createOrgManagementSettings();
    }

    @isTest
    public static void gedCheckAttachments() {
        List<Case> cases = [SELECT CreatedDate FROM Case];
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocument.LatestPublishedVersionId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: cases[0].Id];

        GEDCheckAttachments.FlowInput flowInput = new GEDCheckAttachments.FlowInput();
        flowInput.caseId = cases[0].Id;

        Test.startTest();
        GEDCheckAttachments.gedCheckAttachments(new List<GEDCheckAttachments.FlowInput>{flowInput});
        GEDCheckAttachments.gedCheckAttachments(null);
        Test.stopTest();
    }
}