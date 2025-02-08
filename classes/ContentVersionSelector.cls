/**
 * Created by SNEKKANTI00 on 23/02/2021.
 */

public without sharing class ContentVersionSelector {
    public static List<ContentVersion> getContentVersionsByCaseIds(List<String> caseIds) {
        List<ContentVersion> contentVersions = [SELECT VersionData, Title, FileExtension, CaseId__c FROM ContentVersion WHERE CaseId__c IN: caseIds AND IntegrationResult__c != 1];

        return contentVersions;
    }

    public static List<ContentVersion> getContentVersionsGEDByIds(List<String> contentVersionIds) {
        List<ContentVersion> contentVersions = [SELECT Title, FileExtension, ContentDocumentId, NumberGED__c, BlockChangesGED__c, TimeStampAcknowlegment__c, TimeStampGED__c, sendAttachmentToGED__c, CreatedDate, ContentSize FROM ContentVersion WHERE Id IN: contentVersionIds];

        return contentVersions;
    }

    public static List<ContentVersion> getContentDocumentIdsByIds(List<String> contentVersionIds) {
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionIds];

        return contentVersions;
    }

    public static Integer getContentVersionsCountSendAttachmentTrueByIds(List<String> contentVersionIds) {
        Integer contentVersionsCount = [SELECT COUNT() FROM ContentVersion WHERE Id IN: contentVersionIds AND sendAttachmentToGED__c = false];

        return contentVersionsCount;
    }

    public static List<ContentVersion> getContentVersionsNoVersionDataByDocumentIds(List<String> docIds) {
        List<ContentVersion> contentVersions = [SELECT CaseId__c, ContentDocumentId FROM ContentVersion WHERE PDF_Case__c = false AND ContentDocumentId IN: docIds AND IntegrationResult__c != 1 AND IsMajorVersion = true AND isLatest = true];

        return contentVersions;
    }

    public static List<ContentVersion> getContentVersionsGEDByDocIds(List<String> docIds) {
        List<ContentVersion> contentVersions = [SELECT Title, FileExtension, ContentDocumentId, NumberGED__c, BlockChangesGED__c, TimeStampAcknowlegment__c, TimeStampGED__c, sendAttachmentToGED__c, CreatedDate, ContentSize FROM ContentVersion WHERE ContentDocumentId IN: docIds AND IsMajorVersion = true AND isLatest = true];

        return contentVersions;
    }

    public static List<ContentVersion> getCvsNotIntegratedAndReadyGedByDocIds(List<String> docIds) {
        system.debug('docIds -> ' + docIds);
        system.debug('SELECT Title, FileExtension, ContentDocumentId, NumberGED__c, BlockChangesGED__c, TimeStampAcknowlegment__c, TimeStampGED__c, sendAttachmentToGED__c, ContentSize FROM ContentVersion WHERE ContentDocumentId IN ('+docIds+') AND IsMajorVersion = true AND isLatest = true AND NumberGED__c = null AND sendAttachmentToGED__c = true');
        List<ContentVersion> contentVersions = [SELECT Title, FileExtension, ContentDocumentId, NumberGED__c, BlockChangesGED__c, TimeStampAcknowlegment__c, TimeStampGED__c, sendAttachmentToGED__c, ContentSize FROM ContentVersion WHERE ContentDocumentId IN: docIds AND IsMajorVersion = true AND isLatest = true AND NumberGED__c = null AND sendAttachmentToGED__c = true];

        return contentVersions;
    }

    public static Map<String, ContentVersion> getCvsNotIntegratedAndReadyGedByIds(List<String> cvIds) {
        Map<String, ContentVersion> contentVersionsMap = new Map<String, ContentVersion>([SELECT Title, FileExtension, NumberGED__c, BlockChangesGED__c, TimeStampAcknowlegment__c, TimeStampGED__c, sendAttachmentToGED__c FROM ContentVersion WHERE Id IN: cvIds AND IsMajorVersion = true AND isLatest = true AND NumberGED__c = null AND sendAttachmentToGED__c = true]);

        return contentVersionsMap;
    }

    public static List<ContentVersion> getContentVersionsByIds(List<String> contentVersionIds) {
        List<ContentVersion> contentVersions = [SELECT VersionData, Title, FileExtension, CaseId__c, CaseId__r.ExternalSystemId_Brogliaccio__c, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionIds AND IntegrationResult__c != 1 AND IsMajorVersion = true AND isLatest = true AND ContentSize <=: Integer.valueOf(System.Label.Brogliaccio_AttachmentSizeLimit)];

        return contentVersions;
    }

    public static Database.SaveResult[] updateContentVersions(List<ContentVersion> contentVersions, Boolean allOrNone) {
        try {
            Database.SaveResult[] results = Database.update(contentVersions, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);

            return results;
        } catch(Exception e) {
            System.debug('Exception at ContentVersionService.updateContentVersions: ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        return null;
    }

    public static void insertContentVersions(List<ContentVersion> contentVersions, Boolean allOrNone) {
        try {
            Database.SaveResult[] results = Database.insert(contentVersions, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at ContentVersionService.insertContentVersions: ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }

    public static List<AggregateResult> getContentVersionsGEDIntegrationCountByIds(List<String> contentVersionIds) {
        List<AggregateResult> contentVersionResults = [SELECT count(Id) NumberOfAttachments, NumberGED__c, sendAttachmentToGED__c FROM ContentVersion WHERE sendAttachmentToGED__c = true AND Id IN: contentVersionIds GROUP BY sendAttachmentToGED__c, NumberGED__c ORDER BY NumberGED__c NULLS FIRST];

        return contentVersionResults;
    }

    public static List<ContentVersion> getCvsNotIntegratedBrogliaccioByDocumentIds(List<String> docIds) {
        List<ContentVersion> contentVersions = [SELECT Title, FileExtension, ContentDocumentId FROM ContentVersion WHERE PDF_Case__c = false AND ImgId__c = null AND ContentDocumentId IN: docIds AND IntegrationResult__c != 1 AND IsMajorVersion = true AND isLatest = true];

        return contentVersions;
    }

    public static List<ContentVersion> getCvsBrogliaccioByDocumentIds(List<String> docIds) {
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId, ImgId__c, DescriptionResult__c, Take_for_Brogliaccio__c, PDF_Case__c FROM ContentVersion WHERE PDF_Case__c = false AND ContentDocumentId IN: docIds AND IsMajorVersion = true AND isLatest = true];

        return contentVersions;
    }
}