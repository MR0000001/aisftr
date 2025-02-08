/**
 * Created by SNEKKANTI00 on 15/11/2021.
 */

public without sharing class ContentVersionToGedSelector {
    public static List<ContentVersionToGed__c> getAllContentVersionToGeds() {
        List<ContentVersionToGed__c> contentVersionToGedSelectors = [SELECT Name, ContentVersionSize__c FROM ContentVersionToGed__c];

        return contentVersionToGedSelectors;
    }

    public static List<ContentVersionToGed__c> getLimitedContentVersionToGeds(Integer recordLimit) {
        List<ContentVersionToGed__c> contentVersionToGedSelectors = [SELECT Name, CaseId__c, ContentVersionSize__c, numOfAttemptsSendAttachment__c FROM ContentVersionToGed__c LIMIT: recordLimit];

        return contentVersionToGedSelectors;
    }

    public static List<ContentVersionToGed__c> getContentVersionToGedByCvIds(List<String> cvGedIds) {
        List<ContentVersionToGed__c> contentVersionToGedSelectors = [SELECT Name, CaseId__c, ContentVersionSize__c, numOfAttemptsSendAttachment__c FROM ContentVersionToGed__c WHERE Name IN: cvGedIds];

        return contentVersionToGedSelectors;
    }

    public static List<Database.SaveResult> insertContentVersionToGeds(List<ContentVersionToGed__c> contentVersionToGeds, Boolean allOrNone) {
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        try {
            results = Database.insert(contentVersionToGeds, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('ContentVersionToGedSelector', 'insertContentVersionToGeds', e);
        }
        return results;
    }

    public static List<Database.SaveResult> updateContentVersionToGeds(List<ContentVersionToGed__c> contentVersionToGeds, Boolean allOrNone) {
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        try {
            results = Database.update(contentVersionToGeds, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('ContentVersionToGedSelector', 'updateContentVersionToGeds', e);
        }
        return results;
    }

    public static List<Database.DeleteResult> deleteContentVersionToGeds(List<String> contentVersionToGedIds, Boolean allOrNone) {
        List<Database.DeleteResult> results = new List<Database.DeleteResult>();
        try {
            results = Database.delete(contentVersionToGedIds, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('ContentVersionToGedSelector', 'deleteContentVersionToGeds', e);
        }
        return results;
    }
}