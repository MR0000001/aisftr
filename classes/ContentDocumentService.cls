/**
 * Created by SNEKKANTI00 on 02/07/2021.
 */

public without sharing class ContentDocumentService {

    public static void HandlerTriggerBeforeDelete(List<ContentDocument> contentDocuments) {
        DebugService.printLimits('ContentDocumentService', 'HandlerTriggerBeforeDelete', 'start');
        try {
            processContentDocumentsDelete(contentDocuments);
        } catch(Exception e) {
            DebugService.printException('ContentDocumentService', 'HandlerTriggerBeforeDelete', e);
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        DebugService.printLimits('ContentDocumentService', 'HandlerTriggerBeforeDelete', 'end');
    }

    public static void processContentDocumentsDelete(List<ContentDocument> contentDocuments) {
        DebugService.printLimits('ContentDocumentService', 'processContentDocumentsDelete', 'start');
        List<String> caseIds = new List<String>();
        List<String> contentDocumentIds = new List<String>();
        List<String> contentVersionIds = new List<String>();

        for(ContentDocument cd : contentDocuments) {
            contentVersionIds.add(cd.LatestPublishedVersionId);
            contentDocumentIds.add(cd.Id);
        }

        caseIds = getCaseIdsByContentDocumentIds(contentDocumentIds);

        List<ContentVersion> currentContentVersions = ContentVersionSelector.getContentVersionsGEDByIds(contentVersionIds);

        System.debug('currentContentVersions.size ' + currentContentVersions.size());
        System.debug('currentContentVersions ' + currentContentVersions);

        List<ContentDocumentLink> allContentDocumentLinks = ContentDocumentLinkSelector.getContentDocumentLinksByCaseIds(caseIds);

        Map<String, String> docIdCaseId = ContentDocumentLinkService.getDocIdCaseIdMap(allContentDocumentLinks);

        Map<String, String> cdIdErrorMap = ContentVersionService.processContentVersionsDelete(currentContentVersions, docIdCaseId);

        addErrors(contentDocuments, cdIdErrorMap);
        DebugService.printLimits('ContentDocumentService', 'processContentDocumentsDelete', 'end');
    }

    public static List<String> getCaseIdsByContentDocumentIds(List<String> contentDocumentIds) {
        DebugService.printLimits('ContentDocumentService', 'getCaseIdsByContentDocumentIds', 'start');
        List<ContentDocumentLink> contentDocumentLinks = ContentDocumentLinkSelector.getContentDocumentLinksByContentDocumentIds(contentDocumentIds);

        List<String> caseIds = ContentDocumentLinkService.getCaseIds(contentDocumentLinks);

        DebugService.printLimits('ContentDocumentService', 'getCaseIdsByContentDocumentIds', 'end');
        return caseIds;
    }

    public static void addErrors(List<ContentDocument> contentDocuments, Map<String, String> cdIdErrorMap) {
        DebugService.printLimits('ContentDocumentService', 'addErrors', 'start');
        if(!cdIdErrorMap.isEmpty()) {
            for(ContentDocument cd : contentDocuments) {
                if(cdIdErrorMap.containsKey(cd.Id)) {
                    cd.addError(cdIdErrorMap.get(cd.Id));
                }
            }
        }
        DebugService.printLimits('ContentDocumentService', 'addErrors', 'end');
    }

    public static Boolean deleteContentDocuments(List<String> contentDocumentIds, Boolean allOrNone) {
        DebugService.printLimits('ContentDocumentService', 'deleteContentDocuments', 'start');
        Boolean hasFailed = false;
        if(contentDocumentIds != null && !contentDocumentIds.isEmpty()) {
            Database.DeleteResult[] results = ContentDocumentSelector.deleteContentDocuments(contentDocumentIds, allOrNone);
            System.debug('results ' + results.size());

            if(results != null && !results.isEmpty()) {
                for(Database.DeleteResult result : results) {
                    if(!result.isSuccess()) {
                        hasFailed = true;
                        DebugService.printLimits('ContentDocumentService', 'deleteContentDocuments', 'end');
                        return hasFailed;
                    }
                }
            }
        }
        DebugService.printLimits('ContentDocumentService', 'deleteContentDocuments', 'end return');
        return hasFailed;
    }
}