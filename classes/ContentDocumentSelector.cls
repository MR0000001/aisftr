/**
 * Created by SNEKKANTI00 on 05/07/2021.
 */

public without sharing class ContentDocumentSelector {

    public static List<ContentDocument> getContentDocumentsByIds(List<String> contentDocumentIds) {
        List<ContentDocument> contentDocuments = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id IN: contentDocumentIds];

        return contentDocuments;
    }

    public static Database.DeleteResult[] deleteContentDocuments(List<String> contentDocumentIds, Boolean allOrNone) {
        Database.DeleteResult[] results;
        try {
            results = Database.delete(contentDocumentIds, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            DebugService.printException('ContentDocumentSelector', 'deleteContentDocuments', e);
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        return results;
    }
}