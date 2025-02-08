/**
 * Created by snekkanti002 on 15/09/2021.
 */

@IsTest
public with sharing class TestContentDocumentSelector {
    @TestSetup static void setup() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        List<ContentDocumentLink> contentDocumentLinks = TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
    }

    @IsTest static void getContentDocumentsByIds() {
        List<String> contentDocumentIds = new List<String>();

        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];

        for(ContentDocument cd : contentDocuments) {
            contentDocumentIds.add(cd.Id);
        }

        Test.startTest();
        ContentDocumentSelector.getContentDocumentsByIds(contentDocumentIds);
        Test.stopTest();
    }

    @IsTest static void deleteContentDocuments() {
        List<String> contentDocumentIds = new List<String>();

        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];

        for(ContentDocument cd : contentDocuments) {
            contentDocumentIds.add(cd.Id);
        }

        Test.startTest();
        ContentDocumentSelector.deleteContentDocuments(contentDocumentIds, false);
        ContentDocumentSelector.deleteContentDocuments(contentDocumentIds, true);
        Test.stopTest();
    }
}