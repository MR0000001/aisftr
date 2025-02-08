/**
 * Created by SNEKKANTI00 on 01/07/2021.
 */

public without sharing class ContentDocumentLinkService {

    public static void HandlerTriggerBeforeDelete(List<ContentDocumentLink> contentDocumentLinks) {
        DebugService.printLimits('ContentDocumentLinkService', 'HandlerTriggerBeforeDelete', 'start');
        processContentDocumentLinksDelete(contentDocumentLinks);
        DebugService.printLimits('ContentDocumentLinkService', 'HandlerTriggerBeforeDelete', 'end');
    }

    public static void processContentDocumentLinksDelete(List<ContentDocumentLink> contentDocumentLinks) {
        DebugService.printLimits('ContentDocumentLinkService', 'contentDocumentLinks', 'start');
        List<String> caseIds = new List<String>();
        List<String> contentDocumentIds = new List<String>();
        List<String> contentVersionIds = new List<String>();

        for(ContentDocumentLink cdl : contentDocumentLinks) {
            if(String.valueOf(cdl.LinkedEntityId).startsWith(System.Label.Case_IdStartsWith)) {
                caseIds.add(cdl.LinkedEntityId);
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
        }

        for(ContentDocument cd : ContentDocumentSelector.getContentDocumentsByIds(contentDocumentIds)) {
            contentVersionIds.add(cd.LatestPublishedVersionId);
        }

        List<ContentVersion> currentContentVersions = ContentVersionSelector.getContentVersionsGEDByIds(contentVersionIds);

        System.debug('currentContentVersions.size ' + currentContentVersions.size());
        System.debug('currentContentVersions ' + currentContentVersions);

        List<ContentDocumentLink> allContentDocumentLinks = ContentDocumentLinkSelector.getContentDocumentLinksByCaseIds(caseIds);

        Map<String, String> docIdCaseId = getDocIdCaseIdMap(allContentDocumentLinks);

        Map<String, String> cdlIdErrorMap = ContentVersionService.processContentVersionsDelete(currentContentVersions, docIdCaseId);

        addErrors(contentDocumentLinks, cdlIdErrorMap);
        DebugService.printLimits('ContentDocumentLinkService', 'contentDocumentLinks', 'end');
    }

    public static void addErrors(List<ContentDocumentLink> contentDocumentLinks, Map<String, String> cdlIdErrorMap) {
        DebugService.printLimits('ContentDocumentLinkService', 'addErrors', 'start');
        if(!cdlIdErrorMap.isEmpty()) {
            for(ContentDocumentLink cdl : contentDocumentLinks) {
                if(cdlIdErrorMap.containsKey(cdl.ContentDocumentId)) {
                    cdl.addError(cdlIdErrorMap.get(cdl.ContentDocumentId));
                }
            }
        }
        DebugService.printLimits('ContentDocumentLinkService', 'addErrors', 'end');
    }

    public static List<String> getCaseIds(List<ContentDocumentLink> contentDocumentLinks) {
        DebugService.printLimits('ContentDocumentLinkService', 'getCaseIds', 'start');
        List<String> caseIds = new List<String>();

        for(ContentDocumentLink cdl : contentDocumentLinks) {
            if(String.valueOf(cdl.LinkedEntityId).startsWith(System.Label.Case_IdStartsWith)) {
                caseIds.add(cdl.LinkedEntityId);
            }
        }
        DebugService.printLimits('ContentDocumentLinkService', 'getCaseIds', 'end');
        return caseIds;
    }

    public static Map<String, String> getDocIdCaseIdMap(List<ContentDocumentLink> contentDocumentLinks) {
        DebugService.printLimits('ContentDocumentLinkService', 'getDocIdCaseIdMap', 'start');
        Map<String, String> docIdCaseId = new Map<String, String>();

        for(ContentDocumentLink cdl : contentDocumentLinks) {
            if(String.valueOf(cdl.LinkedEntityId).startsWith(System.Label.Case_IdStartsWith)) {
                docIdCaseId.put(String.valueOf(cdl.ContentDocumentId), String.valueOf(cdl.LinkedEntityId));
            }
        }
        DebugService.printLimits('ContentDocumentLinkService', 'getDocIdCaseIdMap', 'end');
        return docIdCaseId;
    }
}