/**
 * Created by snekkanti002 on 15/09/2021.
 */

@IsTest
public with sharing class TestContentVersionSelector {
    @TestSetup static void setup() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        List<ContentDocumentLink> contentDocumentLinks = TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
    }

    @IsTest static void getContentVersionsByCaseIds() {
        List<String> caseIds = new List<String>();

        List<Case> cases = [SELECT Id FROM Case];

        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        Test.startTest();
        ContentVersionSelector.getContentVersionsByCaseIds(caseIds);
        Test.stopTest();
    }

    @IsTest static void getContentVersionsGEDByIds() {
        List<String> cvIds = new List<String>();

        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];

        for(ContentVersion cv : contentVersions) {
            cvIds.add(cv.Id);
        }

        Test.startTest();
        ContentVersionSelector.getContentVersionsGEDByIds(cvIds);
        Test.stopTest();
    }

    @IsTest static void getContentVersionsGEDIntegrationCountByIds() {
        List<String> cvIds = new List<String>();

        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];

        for(ContentVersion cv : contentVersions) {
            cvIds.add(cv.Id);
        }

        Test.startTest();
        ContentVersionSelector.getContentVersionsGEDIntegrationCountByIds(cvIds);
        Test.stopTest();
    }

    @IsTest static void getContentDocumentIdsByIds() {
        List<String> cvIds = new List<String>();

        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];

        for(ContentVersion cv : contentVersions) {
            cvIds.add(cv.Id);
        }

        Test.startTest();
        ContentVersionSelector.getContentDocumentIdsByIds(cvIds);
        Test.stopTest();
    }

    @IsTest static void getContentVersionsCountSendAttachmentTrueByIds() {
        List<String> cvIds = new List<String>();

        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];

        for(ContentVersion cv : contentVersions) {
            cvIds.add(cv.Id);
        }

        Test.startTest();
        ContentVersionSelector.getContentVersionsCountSendAttachmentTrueByIds(cvIds);
        Test.stopTest();
    }

    @IsTest static void getContentVersionsByIds() {
        List<String> cvIds = new List<String>();

        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];

        for(ContentVersion cv : contentVersions) {
            cvIds.add(cv.Id);
        }

        Test.startTest();
        ContentVersionSelector.getContentVersionsByIds(cvIds);
        Test.stopTest();
    }


    @IsTest static void getContentVersionsNoVersionDataByDocumentIds() {
        List<String> cdIds = new List<String>();

        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];

        for(ContentDocument cd : contentDocuments) {
            cdIds.add(cd.Id);
        }

        Test.startTest();
        ContentVersionSelector.getContentVersionsNoVersionDataByDocumentIds(cdIds);
        Test.stopTest();
    }

    @IsTest static void getCvsNotIntegratedAndReadyGedByDocIds() {
        List<String> cdIds = new List<String>();

        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];

        for(ContentDocument cd : contentDocuments) {
            cdIds.add(cd.Id);
        }

        Test.startTest();
        ContentVersionSelector.getCvsNotIntegratedAndReadyGedByDocIds(cdIds);
        Test.stopTest();
    }

    @IsTest static void getContentVersionsGEDByDocIds() {
        List<String> cdIds = new List<String>();

        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];

        for(ContentDocument cd : contentDocuments) {
            cdIds.add(cd.Id);
        }

        Test.startTest();
        ContentVersionSelector.getContentVersionsGEDByDocIds(cdIds);
        Test.stopTest();
    }

    @IsTest static void getCvsNotIntegratedBrogliaccioByDocumentIds() {
        List<String> cdIds = new List<String>();

        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];

        for(ContentDocument cd : contentDocuments) {
            cdIds.add(cd.Id);
        }

        Test.startTest();
        ContentVersionSelector.getCvsNotIntegratedBrogliaccioByDocumentIds(cdIds);
        Test.stopTest();
    }

    @IsTest static void updateContentVersions() {
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];

        Test.startTest();
        ContentVersionSelector.updateContentVersions(contentVersions, false);
        Test.stopTest();
    }

    @IsTest static void insertContentVersions() {
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        ContentVersion cv = new ContentVersion();

        contentVersions.add(cv);

        Test.startTest();
        ContentVersionSelector.insertContentVersions(contentVersions, false);
        ContentVersionSelector.insertContentVersions(contentVersions, true);
        Test.stopTest();
    }
}