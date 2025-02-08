/**
 * Created by snekkanti002 on 15/09/2021.
 */

@isTest
public with sharing class TestContentDocumentLinkSelector {

    @TestSetup
    public static void setup() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        List<ContentDocumentLink> contentDocumentLinks = TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
    }

    @isTest
    public static void getContentDocumentLinksByCaseIds() {
        List<String> caseIds = new List<String>();

        List<Case> cases = [SELECT Id FROM Case];

        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        Test.startTest();
        ContentDocumentLinkSelector.getContentDocumentLinksByCaseIds(caseIds);
        Test.stopTest();
    }

    @isTest
    public static void getContentDocumentLinksWithPDFCaseByCaseIds() {
        List<String> caseIds = new List<String>();

        List<Case> cases = [SELECT Id FROM Case];

        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        Test.startTest();
        ContentDocumentLinkSelector.getContentDocumentLinksWithPDFCaseByCaseIds(caseIds);
        Test.stopTest();
    }

    @isTest
    public static void getContentDocumentLinksByContentDocumentIds() {
        List<String> contentDocumentIds = new List<String>();

        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];

        for(ContentDocument cd : contentDocuments) {
            contentDocumentIds.add(cd.Id);
        }

        Test.startTest();
        ContentDocumentLinkSelector.getContentDocumentLinksByContentDocumentIds(contentDocumentIds);
        Test.stopTest();
    }


    @isTest
    public static void getNoOfAttachments() {
        List<String> caseIds = new List<String>();

        List<Case> cases = [SELECT Id FROM Case];

        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        Test.startTest();
        ContentDocumentLinkSelector.getNoOfAttachments(caseIds);
        Test.stopTest();
    }
}