/**
 * Created by SNEKKANTI00 on 24/03/2021.
 */

public without sharing class ContentDocumentLinkSelector {
    public static List<ContentDocumentLink> getContentDocumentLinksByCaseIds(List<String> caseIds) {
        if(caseIds != null && !caseIds.isEmpty()) {
            List<ContentDocumentLink> contentDocumentLinks = [
                    SELECT LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN:caseIds
            ];

            return contentDocumentLinks;
        }

        return new List<ContentDocumentLink>();
    }

    public static List<ContentDocumentLink> getContentDocumentLinksWithPDFCaseByCaseIds(List<String> caseIds) {
        if(caseIds != null && !caseIds.isEmpty()) {
            List<ContentDocumentLink> contentDocumentLinks = [
                    SELECT LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN: caseIds AND ContentDocument.LatestPublishedVersion.PDF_Case__c = TRUE
            ];

            return contentDocumentLinks;
        }

        return new List<ContentDocumentLink>();
    }

    public static List<ContentDocumentLink> getContentDocumentLinksByContentDocumentIds(List<String> contentDocumentIds) {
        if(contentDocumentIds != null && !contentDocumentIds.isEmpty()) {
            List<ContentDocumentLink> contentDocumentLinks = [
                    SELECT LinkedEntityId, ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE ContentDocumentId IN: contentDocumentIds
            ];

            return contentDocumentLinks;
        }

        return new List<ContentDocumentLink>();
    }

    public static Integer getNoOfAttachments(List<String> caseIds) {
        Integer noOfAttachments = [
                SELECT COUNT()
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN:caseIds
        ];
        return noOfAttachments;
    }
}