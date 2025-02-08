/**
 * Created by snekkanti002 on 31/05/2022.
 */

@isTest
public with sharing class TestSendContentVersionToGedQueueable {

    @isTest
    public static void sendContentVersionToGedQueueable() {
        Test.startTest();
        System.enqueueJob(new SendContentVersionToGedQueueable(new Map<Case, List<ContentVersion>>(), new Map<String, ContentVersionToGed__c>()));
        System.enqueueJob(new SendContentVersionToGedQueueable(null, null));
        Test.stopTest();
    }
}