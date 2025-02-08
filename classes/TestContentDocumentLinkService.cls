/**
 * Created by snekkanti002 on 28/07/2021.
 */

@IsTest
public with sharing class TestContentDocumentLinkService {

    @TestSetup
    public static void setup() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        List<ContentDocumentLink> contentDocumentLinks = TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
    }

    @IsTest
    public static void contentDocumentLinkServiceTest() {
        List<String> cdIds = new List<String>();
        List<String> caseIds = new List<String>();

        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, CaseId__c, NumberGED__c, BlockChangesGED__c FROM ContentVersion];

        for(ContentVersion cv : contentVersions) {
            cdIds.add(cv.ContentDocumentId);
        }

        List<ContentDocumentLink> contentDocumentLinks = [SELECT id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN: cdIds];

        for(ContentDocumentLink cdl : contentDocumentLinks) {
            caseIds.add(cdl.LinkedEntityId);
        }

        Test.startTest();
        ContentDocumentLinkService.getCaseIds(contentDocumentLinks);
        DELETE contentDocumentLinks;
        Test.stopTest();
    }
}