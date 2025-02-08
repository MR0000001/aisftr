/**
 * Created by snekkanti002 on 28/07/2021.
 */

@isTest
public with sharing class TestContentDocumentService {
    @TestSetup static void setup() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        List<ContentDocumentLink> contentDocumentLinks = TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
    }

    @IsTest
    public static void contentDocumentServiceTest() {
        List<String> cdIds = new List<String>();

        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, CaseId__c, NumberGED__c, BlockChangesGED__c FROM ContentVersion];

        for(ContentVersion cv : contentVersions) {
            cdIds.add(cv.ContentDocumentId);
        }

        List<ContentDocument> contentDocuments = [SELECT id FROM ContentDocument WHERE Id IN: cdIds];

        Test.startTest();
        DELETE contentDocuments;
        Test.stopTest();
    }

    @IsTest
    public static void deleteContentDocuments() {
        List<String> cdIds = new List<String>();

        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];

        for(ContentDocument cd : contentDocuments) {
            cdIds.add(cd.Id);
        }

        Test.startTest();
        ContentDocumentService.deleteContentDocuments(cdIds, false);
        Test.stopTest();
    }
}