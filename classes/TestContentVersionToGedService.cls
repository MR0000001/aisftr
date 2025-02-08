/**
 * Created by snekkanti002 on 26/05/2022.
 */

@IsTest
public with sharing class TestContentVersionToGedService {
    @TestSetup
    public static void setup() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        TestDataFactory.createContentVersionToGeds(cases);
    }

    @IsTest
    public static void getAllContentVersionToGedIds() {
        Test.startTest();
        ContentVersionToGedService.getAllContentVersionToGedIds();
        Test.stopTest();
    }

    @IsTest
    public static void insertContentVersionToGeds() {
        List<ContentVersionToGed__c> contentVersionToGeds = [SELECT Id, CaseId__c, ContentVersionSize__c, numOfAttemptsSendAttachment__c FROM ContentVersionToGed__c];

        Test.startTest();
        ContentVersionToGedService.insertContentVersionToGeds(contentVersionToGeds, true);
        Test.stopTest();
    }

    @IsTest
    public static void deleteContentVersionToGeds() {
        List<ContentVersionToGed__c> contentVersionToGeds = [SELECT Id, CaseId__c, ContentVersionSize__c, numOfAttemptsSendAttachment__c FROM ContentVersionToGed__c];
        List<String> contentVersionToGedIds = new List<String>();

        for(ContentVersionToGed__c g : contentVersionToGeds) {
            contentVersionToGedIds.add(g.Id);
        }

        Test.startTest();
        ContentVersionToGedService.deleteContentVersionToGeds(contentVersionToGedIds, true);
        Test.stopTest();
    }

    @IsTest
    public static void checkContentVersionsToGedRetryabilityAndDoDml() {

        Test.startTest();
        ContentVersionToGedService.checkContentVersionsToGedRetryabilityAndDoDml(new List<String>(), true);
        Test.stopTest();
    }

    @IsTest
    public static void updateContentVersionToGeds() {
        List<ContentVersionToGed__c> contentVersionToGeds = [SELECT Id, CaseId__c, ContentVersionSize__c, numOfAttemptsSendAttachment__c FROM ContentVersionToGed__c];

        Test.startTest();
        ContentVersionToGedService.updateContentVersionToGeds(contentVersionToGeds, true);
        Test.stopTest();
    }
}