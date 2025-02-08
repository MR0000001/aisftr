/**
 * Created by LCONATO00 on 08/01/2021.
 */

public without sharing class ContentVersionService {
    public static void HandlerTriggerAfterInsert(List<ContentVersion> contentVersions) {
        DebugService.printLimits('ContentVersionService', 'HandlerTriggerAfterInsert', 'start');
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        for(ContentVersion cv : contentVersions){
            if(cv.CaseId__c!=null){
                ContentDocumentLink contentLink = new ContentDocumentLink(LinkedEntityId = cv.CaseId__c, ContentDocumentId = cv.ContentDocumentId, ShareType = 'I');
                cdls.add(contentLink);
            }
        }
        insert cdls;
        processNewVersionsInsert(contentVersions);
        updateCasesForNewAttachments(contentVersions);
        DebugService.printLimits('ContentVersionService', 'HandlerTriggerAfterInsert', 'end');
    }

    public static void processNewVersionsInsert(List<ContentVersion> contentVersions) {
        DebugService.printLimits('ContentVersionService', 'processNewVersionsInsert', 'start');
        try {
            Map<String, String> cvIdErrorMap = new Map<String, String>();

            for(ContentVersion cv : contentVersions) {
                if(String.isNotBlank(cv.NumberGED__c)) {
                    cvIdErrorMap.put(cv.Id, System.Label.GED_ContentNewVersionNotPossible);
                } else if(cv.BlockChangesGED__c) {
                    cvIdErrorMap.put(cv.Id, System.Label.GED_ContentAwaitingProtocol);
                }
            }

            if(!cvIdErrorMap.isEmpty()) {
                System.debug('cvIdErrorMap ' + cvIdErrorMap);
                addErrors(contentVersions, cvIdErrorMap);
            }
        } catch(Exception e) {
            DebugService.printException('ContentVersionService', 'processNewVersionsInsert', e);
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        DebugService.printLimits('ContentVersionService', 'processNewVersionsInsert', 'end');
    }

    public static void addErrors(List<ContentVersion> contentVersions, Map<String, String> cvIdErrorMap) {
        DebugService.printLimits('ContentVersionService', 'addErrors', 'start');
        if(!cvIdErrorMap.isEmpty()) {
            for(ContentVersion cv : contentVersions) {
                if(cvIdErrorMap.containsKey(cv.Id)) {
                    cv.addError(cvIdErrorMap.get(cv.Id));
                }
            }
        }
        DebugService.printLimits('ContentVersionService', 'processNewVersionsInsert', 'end');
    }

    public static void updateCasesForNewAttachments(List<ContentVersion> contentVersions) {
        DebugService.printLimits('ContentVersionService', 'updateCasesForNewAttachments', 'start');
        System.debug('updateCasesForNewAttachments Start');
        try {
            Map<String, ContentVersion> cdIdCvMap = getCdIdCvMap(contentVersions);

            if(!cdIdCvMap.isEmpty()) {
                Map<String, List<ContentVersion>> caseIdCvsMap = getCaseIdCvsMap(cdIdCvMap);
                List<ContentVersion> returnedContentVersions = CaseService.updateCaseFieldsOnNewContentVersions(caseIdCvsMap);
                updateContentVersions(returnedContentVersions, false);
            }

        } catch(Exception e) {
            DebugService.printException('ContentVersionService', 'updateCasesForNewAttachments', e);

            ErrorLogEventHandler.standardExceptionLog(e);
        }
        DebugService.printLimits('ContentVersionService', 'updateCasesForNewAttachments', 'end');
        System.debug('updateCasesForNewAttachments End');
    }

    public static Map<String, ContentVersion> getCdIdCvMap(List<ContentVersion> contentVersions) {
        DebugService.printLimits('ContentVersionService', 'getCdIdCvMap', 'start');
        Map<String, ContentVersion> cdIdCvMap = new Map<String, ContentVersion>();

        for(ContentVersion cv : contentVersions) {
            cdIdCvMap.put(cv.ContentDocumentId, cv);
            System.debug('cv.ContentDocumentId ' + cv.ContentDocumentId);
        }
        DebugService.printLimits('ContentVersionService', 'getCdIdCvMap', 'end');
        return cdIdCvMap;
    }

    public static Map<String, List<ContentVersion>> getCaseIdCvsMap(Map<String, ContentVersion> cdIdCvMap) {
        DebugService.printLimits('ContentVersionService', 'getCaseIdCvsMap', 'start');
        Map<String, List<ContentVersion>> caseIdCvsMap = new Map<String, List<ContentVersion>>();

        List<ContentDocumentLink> contentDocumentLinks = ContentDocumentLinkSelector.getContentDocumentLinksByContentDocumentIds(new List<String>(cdIdCvMap.keySet()));

        for(ContentDocumentLink cdl : contentDocumentLinks) {
            if(String.valueOf(cdl.LinkedEntityId).startsWith(System.Label.Case_IdStartsWith)) {
                if(caseIdCvsMap.containsKey(cdl.LinkedEntityId)) {
                    List<ContentVersion> contentVersions = caseIdCvsMap.get(cdl.LinkedEntityId);
                    contentVersions.add(cdIdCvMap.get(cdl.ContentDocumentId));
                    caseIdCvsMap.put(cdl.LinkedEntityId, contentVersions);
                } else {
                    caseIdCvsMap.put(cdl.LinkedEntityId, new List<ContentVersion>{cdIdCvMap.get(cdl.ContentDocumentId)});
                }
            }
        }
        DebugService.printLimits('ContentVersionService', 'getCaseIdCvsMap', 'end');
        return caseIdCvsMap;
    }

    public static Map<String, String> processContentVersionsDelete(List<ContentVersion> currentContentVersions, Map<String, String> docIdCaseId) {
        DebugService.printLimits('ContentVersionService', 'processContentVersionsDelete', 'start');
        Map<String, String> cdIdErrorMap = new Map<String, String>();
        Map<String, ContentVersion> currentDocumentIdVersionMap = new Map<String, ContentVersion>();

        for(ContentVersion cv : currentContentVersions) {
            if(String.isNotBlank(cv.NumberGED__c)) {
                System.debug('Attachment integrated cannot delete error');
                cdIdErrorMap.put(String.valueOf(cv.ContentDocumentId), System.Label.GED_ContentSentCannotDelete);
            } else if(cv.BlockChangesGED__c) {
                System.debug('Attachment awaiting integration cannot delete error');
                cdIdErrorMap.put(String.valueOf(cv.ContentDocumentId), System.Label.GED_ContentAwaitingProtocol);
            } else {
                System.debug('No attachment integrated cannot delete error');
                currentDocumentIdVersionMap.put(cv.ContentDocumentId, cv);
            }
        }

        if(!currentDocumentIdVersionMap.isEmpty()) {
            System.debug('documentIdVersionMap not empty');
            cdIdErrorMap.putAll(checkCasesUpdatabilityBeforeCvDelete(currentDocumentIdVersionMap, docIdCaseId));
        }
        DebugService.printLimits('ContentVersionService', 'processContentVersionsDelete', 'end');
        return cdIdErrorMap;
    }

    public static Map<String, String> checkCasesUpdatabilityBeforeCvDelete(Map<String, ContentVersion> documentIdVersionMap, Map<String, String> docIdCaseId) {
        DebugService.printLimits('ContentVersionService', 'checkCasesUpdatabilityBeforeCvDelete', 'start');
        System.debug('updateCasesForDeletedAttachments Start');
        Map<String, String> cdIdErrorMap = new Map<String, String>();
        Map<String, String> caseIdError = new Map<String, String>();

        List<ContentVersion> allContentVersions = ContentVersionSelector.getContentVersionsGEDByDocIds(new List<String>(docIdCaseId.keySet()));

        Map<String, List<ContentVersion>> caseIdCvsMap = getCaseIdCvsMap(docIdCaseId, allContentVersions);

        if(!caseIdCvsMap.isEmpty()) {
            caseIdError = CaseService.updateCaseFieldsOnDeleteContentVersions(caseIdCvsMap, documentIdVersionMap.values());
        }

        if(!caseIdError.isEmpty()) {
            for(String docId : docIdCaseId.keySet()) {
                cdIdErrorMap.put(docId, caseIdError.get(docIdCaseId.get(docId)));
            }
        }

        System.debug('docIdCaseId ' + docIdCaseId);
        System.debug('caseIdCvsMap ' + caseIdCvsMap);
        System.debug('caseIdError ' + caseIdError);
        System.debug('cdIdErrorMap ' + cdIdErrorMap);
        DebugService.printLimits('ContentVersionService', 'checkCasesUpdatabilityBeforeCvDelete', 'end');
        return cdIdErrorMap;
    }

    public static Map<String, List<ContentVersion>> getCaseIdCvsMap(Map<String, String> docIdCaseId, List<ContentVersion> allContentVersions) {
        DebugService.printLimits('ContentVersionService', 'getCaseIdCvsMap', 'start');
        Map<String, List<ContentVersion>> caseIdCvsMap = new Map<String, List<ContentVersion>>();

        System.debug('docIdCaseId ' + docIdCaseId);

        for(ContentVersion cv : allContentVersions) {
            if(cv.sendAttachmentToGED__c) {
                if(caseIdCvsMap.containsKey(docIdCaseId.get(cv.ContentDocumentId))) {
                    List<ContentVersion> contentVersions = caseIdCvsMap.get(docIdCaseId.get(cv.ContentDocumentId));
                    contentVersions.add(cv);
                    caseIdCvsMap.put(docIdCaseId.get(cv.ContentDocumentId), contentVersions);
                } else {
                    caseIdCvsMap.put(docIdCaseId.get(cv.ContentDocumentId), new List<ContentVersion>{cv});
                }
            }
        }
        DebugService.printLimits('ContentVersionService', 'getCaseIdCvsMap', 'end');
        return caseIdCvsMap;
    }

    public static void updateContentVersions(List<ContentVersion> contentVersions, Boolean allOrNone) {
        DebugService.printLimits('ContentVersionService', 'updateContentVersions', 'start');
        if(contentVersions != null && !contentVersions.isEmpty()) ContentVersionSelector.updateContentVersions(contentVersions, allOrNone);
        DebugService.printLimits('ContentVersionService', 'updateContentVersions', 'end');
    }

    public static void updateSendAttachmentToGEDTrue(List<ContentVersion> contentVersions, Map<Case, List<ContentVersion>> caseCVsMap, Map<String, String> caseIdOutputMap, Boolean allOrNone) {
        DebugService.printLimits('ContentVersionService', 'processSendAttachmentToGEDTrue', 'start');

       List<String> failedCvs = new List<String>();

        if(contentVersions != null && !contentVersions.isEmpty()) {
            Database.SaveResult[] results = ContentVersionSelector.updateContentVersions(contentVersions, allOrNone);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    failedCvs.add(sr.getId());
                }
            }
        }

        if(!failedCvs.isEmpty()) {
            for(Case c : caseCVsMap.keySet()) {
                Integer totalCvsCount = caseCVsMap.get(c).size();
                Integer count = 0;
                for(ContentVersion cv : caseCVsMap.get(c)) {
                    if(failedCvs.contains(cv.Id)) {
                        count++;
                    }
                }
                if(totalCvsCount == count) {
                    caseIdOutputMap.put(c.Id, 'false&Error');
                }
            }
        }

        DebugService.printLimits('ContentVersionService', 'processSendAttachmentToGEDTrue', 'end return');
    }

    public static void checkAttachmentsWithinLimitsAndUpdate(Map<Case, List<ContentVersion>> caseCVsMap, Map<String, String> caseIdOutputMap, Boolean allOrNone) {
        DebugService.printLimits('ContentVersionService', 'checkAttachmentsWithinLimitsAndUpdate', 'start');

        OrgManagement__c orgSetting = OrgManagement__c.getOrgDefaults();

        List<ContentVersion> updateContentVersions = new List<ContentVersion>();

        for(Case c : caseCVsMap.keySet()) {
            for(ContentVersion cv : caseCVsMap.get(c)) {
                if((Math.abs(cv.CreatedDate.getTime() - c.CreatedDate.getTime())/orgSetting.ms_to_secs__c) <= Integer.valueOf(orgSetting.Time_Attachment_GED__c) && (cv.ContentSize/orgSetting.Bytes_to_MB__c) <= Integer.valueOf(orgSetting.Limit_Attachment_GED__c)) {

                    if(!cv.sendAttachmentToGED__c) {
                        cv.sendAttachmentToGED__c = true;
                        updateContentVersions.add(cv);
                    }
                    caseIdOutputMap.put(c.Id, 'true');
                }
            }
        }

        if(!updateContentVersions.isEmpty()) {
            DebugService.printLimits('ContentVersionService', 'checkAttachmentsWithinLimitsAndUpdate', 'end');
            ContentVersionService.updateSendAttachmentToGEDTrue(updateContentVersions, caseCVsMap, caseIdOutputMap, allOrNone);
        }
        DebugService.printLimits('ContentVersionService', 'checkAttachmentsWithinLimitsAndUpdate', 'end return');
    }

    public static Map<Case, List<ContentVersion>> getCaseCvsMap(List<Case> cases) {
        DebugService.printLimits('ContentVersionService', 'getCaseCvsMap', 'start');
        Map<String, Case> caseIdCaseMap = CaseService.getCaseIdCaseMap(cases);
		system.debug('caseIdCaseMap -> ' + caseIdCaseMap);

        List<ContentDocumentLink> contentDocumentLinks = ContentDocumentLinkSelector.getContentDocumentLinksByCaseIds(new List<String>(caseIdCaseMap.keySet()));
		system.debug('contentDocumentLinks -> ' + contentDocumentLinks);

        Map<String, String> docIdCaseId = ContentDocumentLinkService.getDocIdCaseIdMap(contentDocumentLinks);
		system.debug('docIdCaseId -> ' + docIdCaseId);

        List<ContentVersion> contentVersions = ContentVersionSelector.getCvsNotIntegratedAndReadyGedByDocIds(new List<String>(docIdCaseId.keySet()));
		system.debug('contentVersions -> ' + contentVersions);

        Map<Case, List<ContentVersion>> caseCvsMap = new Map<Case, List<ContentVersion>>();
		system.debug('caseCvsMap -> ' + caseCvsMap);

        for(ContentVersion cv : contentVersions) {
            if(caseCvsMap.containsKey(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)))) {
                List<ContentVersion> tmpContentVersions = caseCvsMap.get(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)));
                tmpContentVersions.add(cv);
                caseCvsMap.put(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)), tmpContentVersions);
            } else {
                caseCvsMap.put(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)), new List<ContentVersion>{cv});
            }
        }
        DebugService.printMap('ContentVersionService', 'getCaseCvsMap', 'caseCvsMap', new List<Case>(caseCvsMap.keySet()), caseCvsMap.values(), true);
        DebugService.printLimits('ContentVersionService', 'getCaseCvsMap', 'end');
        return caseCvsMap;
    }

    public static Map<Case, List<ContentVersion>> getCaseCvsAllGEDMap(List<Case> cases) {
        DebugService.printLimits('ContentVersionService', 'getCaseCvsAllGEDMap', 'start');
        Map<String, Case> caseIdCaseMap = CaseService.getCaseIdCaseMap(cases);

        List<ContentDocumentLink> contentDocumentLinks = ContentDocumentLinkSelector.getContentDocumentLinksByCaseIds(new List<String>(caseIdCaseMap.keySet()));

        Map<String, String> docIdCaseId = ContentDocumentLinkService.getDocIdCaseIdMap(contentDocumentLinks);

        List<ContentVersion> contentVersions = ContentVersionSelector.getContentVersionsGEDByDocIds(new List<String>(docIdCaseId.keySet()));

        Map<Case, List<ContentVersion>> caseCvsMap = new Map<Case, List<ContentVersion>>();

        for(ContentVersion cv : contentVersions) {
            if(caseCvsMap.containsKey(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)))) {
                List<ContentVersion> tmpContentVersions = caseCvsMap.get(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)));
                tmpContentVersions.add(cv);
                caseCvsMap.put(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)), tmpContentVersions);
            } else {
                caseCvsMap.put(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)), new List<ContentVersion>{cv});
            }
        }
        DebugService.printLimits('ContentVersionService', 'getCaseCvsAllGEDMap', 'end');
        return caseCvsMap;
    }

    public static void processPlatformEventGEDContentVersions(Map<Case, List<ContentVersion>> caseCvsMap) {
        DebugService.printLimits('ContentVersionService', 'processPlatformEventGEDContentVersions', 'start');

        Boolean isSuccess = GEDContentVersionCallout.gedContentVersionCallout(caseCvsMap);
        System.debug('isSuccess ' + isSuccess);

        if(isSuccess) {
            List<List<ContentVersion>> contentVersions = caseCvsMap.values();
            List<ContentVersion> updateContentVersions = new List<ContentVersion>();

            for(List<ContentVersion> cvs : contentVersions) {
                for(ContentVersion cv : cvs) {
                    cv.TimeStampAcknowlegment__c = System.now();
                    cv.BlockChangesGED__c = true;
                }
                updateContentVersions.addAll(cvs);
            }

            DebugService.printList('ContentVersionService', 'processPlatformEventGEDContentVersions', 'updateContentVersions', updateContentVersions);
            ContentVersionService.updateContentVersions(updateContentVersions, false);
        }
        DebugService.printLimits('ContentVersionService', 'processPlatformEventGEDContentVersions', 'end');
    }

    public static void processBatchGEDContentVersions(List<Case> cases) {
        DebugService.printLimits('ContentVersionService', 'processBatchGEDContentVersions', 'start');
        ContentVersionToGed_Setting__mdt contentVersionToGedSetting = ContentVersionToGed_Setting__mdt.getInstance('ContentVersionToGed');
        List<ContentVersion> contentVersionsToUpdate = new List<ContentVersion>();
        List<ContentVersionToGed__c> contentVersionToGeds = new List<ContentVersionToGed__c>();
		system.debug('cases -> ' + cases);
		system.debug('contentVersionToGedSetting: ' + contentVersionToGedSetting);
        Map<Case, List<ContentVersion>> caseCvsMap = getCaseCvsMap(cases);
        DebugService.printMap('ContentVersionService', 'processBatchGEDContentVersions', 'caseCvsMap',  new List<Case>(caseCvsMap.keySet()), caseCvsMap.values(), true);
		system.debug('caseCvsMap -> ' + caseCvsMap);

        List<String> existingContentVersionToGedCvIds = ContentVersionToGedService.getAllContentVersionToGedIds();
        DebugService.printList('ContentVersionService', 'processBatchGEDContentVersions', 'existingContentVersionToGedCvIds', existingContentVersionToGedCvIds);
		system.debug('existingContentVersionToGedCvIds -> ' + existingContentVersionToGedCvIds);

        for(Case c : caseCvsMap.keySet()) {
            List<ContentVersion> cvs = caseCvsMap.get(c);
            System.debug('cvs ' + cvs.size());
            System.debug('cvs ' + cvs);
            for(Integer i = (cvs.size()-1) ; i >= 0 ; i--) {
                if(cvs[i].ContentSize > contentVersionToGedSetting.cvToGedMaxSize__c) {
                    System.debug('Attachment size of ' + cvs[i].ContentSize + ' is greater than ' + contentVersionToGedSetting.cvToGedMaxSize__c);
                    cvs[i].sendAttachmentToGED__c = false;
                    contentVersionsToUpdate.add(cvs[i]);
                    cvs.remove(i);
                } else if(existingContentVersionToGedCvIds.contains(cvs[i].Id)) {
                    System.debug('Cv exists in ContentVersionToGed ' + cvs[i].Id);
                    cvs.remove(i);
                } else {
                    System.debug('Create new ContentVersionToGed records ' + cvs[i].Id + ' size: ' + cvs[i].ContentSize);
                    ContentVersionToGed__c contentVersionToGed = new ContentVersionToGed__c();
                    contentVersionToGed.Name = cvs[i].Id;
                    contentVersionToGed.ContentVersionSize__c = cvs[i].ContentSize;
                    contentVersionToGed.CaseId__c = c.Id;
                    contentVersionToGed.numOfAttemptsSendAttachment__c = 1;
                    contentVersionToGeds.add(contentVersionToGed);
                }
            }
        }
        DebugService.printList('ContentVersionService', 'processBatchGEDContentVersions', 'contentVersionsToUpdate', contentVersionsToUpdate);
        DebugService.printList('ContentVersionService', 'processBatchGEDContentVersions', 'contentVersionToGeds', contentVersionToGeds);

        ContentVersionService.updateContentVersions(contentVersionsToUpdate, false);
        ContentVersionToGedService.insertContentVersionToGeds(contentVersionToGeds, false);
        DebugService.printLimits('ContentVersionService', 'processBatchGEDContentVersions', 'end');
    }

    public static void batchGEDContentVersion() {
        DebugService.printLimits('ContentVersionService', 'batchGEDContentVersion', 'start');
        Time currentTime = System.now().time();
        GEDContentVersionBatch_Setting__c gedContentVersionBatchSetting = GEDContentVersionBatch_Setting__c.getValues('BatchGEDContentVersion');
        Map<String, StartAttachmentGED__c> startAttachmentGEDMap = StartAttachmentGED__c.getAll();
		System.debug('startAttachmentGEDMap ' + startAttachmentGEDMap);
        if(!startAttachmentGEDMap.isEmpty()) {
            for(StartAttachmentGED__c setting : startAttachmentGEDMap.values()) {
                if(setting.isActive__c) {
                    System.debug('Is active');
                    String[] strStartTime = setting.StartTime__c.split(':');
                    String[] strFinishTime = setting.FinishTime__c.split(':');

                    Time startTime = Time.newInstance(Integer.valueOf(strStartTime[0]), Integer.valueOf(strStartTime[1]), 0, 0);
                    Time finishTime = Time.newInstance(Integer.valueOf(strFinishTime[0]), Integer.valueOf(strFinishTime[1]), 0, 0);
                    System.debug('currentTime ' + currentTime);
                    System.debug('startTime ' + startTime);
                    System.debug('finishTime ' + finishTime);
                    if(currentTime >= startTime && currentTime <= finishTime ) {
                        System.debug('Launch batch');
                        Database.executeBatch(new BatchGEDContentVersion(), Integer.valueOf(gedContentVersionBatchSetting.Batch_size__c));
                    }
                }
            }
        }
        DebugService.printLimits('ContentVersionService', 'batchGEDContentVersion', 'end');
    }

    public static List<String> getCaseIdsFromContentVersionIds(List<String> contentVersionIds) {
        DebugService.printLimits('ContentVersionService', 'getCaseIdsFromContentVersionIds', 'start');
        List<String> contentDocumentIds = new List<String>();
        List<ContentVersion> contentVersions = ContentVersionSelector.getContentDocumentIdsByIds(contentVersionIds);

        for(ContentVersion cv : contentVersions) {
            contentDocumentIds.add(cv.ContentDocumentId);
        }

        List<String> caseIds = ContentDocumentService.getCaseIdsByContentDocumentIds(contentDocumentIds);
        DebugService.printLimits('ContentVersionService', 'getCaseIdsFromContentVersionIds', 'end');

        return caseIds;
    }

    public static void insertContentVersions(List<ContentVersion> contentVersions, Boolean allOrNone) {
        DebugService.printLimits('ContentVersionService', 'insertContentVersions', 'start');
        if(contentVersions != null && !contentVersions.isEmpty()) ContentVersionSelector.insertContentVersions(contentVersions, allOrNone);
        DebugService.printLimits('ContentVersionService', 'insertContentVersions', 'end');
    }

    /*public static ContentVersion createContentVersionFromPDF(String title, String pathOnClient, Blob contentAsPdf, String origin, Id firstPublishLocationId, Boolean isPdfCreate, Boolean isSendAttachmentToGed) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = title;
        contentVersion.PathOnClient = pathOnClient;
        contentVersion.VersionData = contentAsPdf;
        contentVersion.Origin = origin;
        contentVersion.FirstPublishLocationId = firstPublishLocationId;
        contentVersion.PDF_Case__c = isPdfCreate;
        contentVersion.sendAttachmentToGED__c = isSendAttachmentToGed;

        ContentVersionService.insertContentVersions(new List<ContentVersion>{contentVersion}, false);

        return contentVersion;
    }*/

    public static List<ContentVersion>createContentVersionsFromPDF(List<ContentVersionWrapper> contentVersionWrappers, List<FlowCreatePDF.FlowOutput> results) {
        DebugService.printLimits('ContentVersionService', 'createContentVersionsFromPDF', 'start');
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        for(ContentVersionWrapper wrapper : contentVersionWrappers) {
            ContentVersion contentVersion = new ContentVersion();

            contentVersion.Title = wrapper.title;
            contentVersion.PathOnClient = wrapper.pathOnClient;
            contentVersion.VersionData = wrapper.contentAsPdf;
            contentVersion.Origin = wrapper.origin;
            contentVersion.FirstPublishLocationId = wrapper.firstPublishLocationId;
            contentVersion.PDF_Case__c = wrapper.isPdfCreate;
            contentVersion.sendAttachmentToGED__c = wrapper.isSendAttachmentToGed;

            FlowCreatePDF.FlowOutput singleResult = new FlowCreatePDF.FlowOutput();
            singleResult.isSuccess = true;
            results.add(singleResult);

            contentVersions.add(contentVersion);
        }

        ContentVersionService.insertContentVersions(contentVersions, false);

        DebugService.printLimits('ContentVersionService', 'createContentVersionsFromPDF', 'end');
        return contentVersions;
    }

    public static Map<String, List<ContentVersion>> getCaseIdCvsNotIntegratedMapBrogliaccio(List<String> caseIds) {
        DebugService.printLimits('ContentVersionService', 'getCaseCvsNotIntegratedMapBrogliaccio', 'start');

        Map<String, List<ContentVersion>> caseIdCvsMap = new Map<String, List<ContentVersion>>();

        List<ContentDocumentLink> contentDocumentLinks = ContentDocumentLinkSelector.getContentDocumentLinksByCaseIds(new List<String>(caseIds));

        System.debug('contentDocumentLinks ' + contentDocumentLinks);

        Map<String, String> docIdCaseId = ContentDocumentLinkService.getDocIdCaseIdMap(contentDocumentLinks);

        System.debug('docIdCaseId ' + docIdCaseId);

        List<ContentVersion> contentVersions = ContentVersionSelector.getCvsNotIntegratedBrogliaccioByDocumentIds(new List<String>(docIdCaseId.keySet()));

        System.debug('contentVersions ' + contentVersions);

        for(ContentVersion cv : contentVersions) {
            if(caseIdCvsMap.containsKey(docIdCaseId.get(cv.ContentDocumentId))) {
                List<ContentVersion> tmpContentVersions = caseIdCvsMap.get(docIdCaseId.get(cv.ContentDocumentId));
                tmpContentVersions.add(cv);
                caseIdCvsMap.put(docIdCaseId.get(cv.ContentDocumentId), tmpContentVersions);
            } else {
                caseIdCvsMap.put(docIdCaseId.get(cv.ContentDocumentId), new List<ContentVersion>{cv});
            }
        }

        for(String cId : caseIds) {
            if(!caseIdCvsMap.containsKey(cId)) {
                caseIdCvsMap.put(cId, new List<ContentVersion>());
            }
        }

        DebugService.printLimits('ContentVersionService', 'getCaseCvsNotIntegratedMapBrogliaccio', 'end');
        return caseIdCvsMap;
    }

    public static void handleBrogliaccioPostRequest() {
        DebugService.printLimits('ContentVersionService', 'handleBrogliaccioPostRequest', 'start');

        List<String> successContentVersionIds = new List<String>();
        List<ContentVersion> successContentVersions = new List<ContentVersion>();
        List<ContentVersion> failedContentVersions = new List<ContentVersion>();

        RequestBrogliaccioWebService requestBody = (RequestBrogliaccioWebService) JSON.deserialize(RestContext.request.requestBody.toString(), RequestBrogliaccioWebService.class);
        System.debug('requestBody ' + requestBody);

        for(RequestBrogliaccioWebService.Allegati attachment : requestBody.allegati) {
            if(attachment.Esito.equalsIgnoreCase('1') || attachment.Esito.equalsIgnoreCase('true')) {
                System.debug('Entered OK');
                ContentVersion contentVersion = new ContentVersion();

                contentVersion.Id = attachment.AllegatoID;
                contentVersion.ImgId__c = Decimal.valueOf(attachment.IDImmagine);
                contentVersion.DescriptionResult__c = null;
                contentVersion.IntegrationResult__c = 1;

                successContentVersionIds.add(attachment.AllegatoID);
                successContentVersions.add(contentVersion);
            } else {
                System.debug('Entered KO');
                if(String.isNotBlank(attachment.AllegatoID)) {
                    System.debug('Entered KO AllegatoID not empty');
                    String error = String.isNotBlank(attachment.DescrEsito) ? attachment.DescrEsito : 'Brogliaccio error during processing';
                    ContentVersion contentVersion = new ContentVersion();

                    contentVersion.Id = attachment.AllegatoID;
                    contentVersion.DescriptionResult__c = error;
                    contentVersion.IntegrationResult__c = null;
                    contentVersion.Take_for_Brogliaccio__c = false;

                    failedContentVersions.add(contentVersion);
                }
            }
        }

        DebugService.printList('ContentVersionService', 'handleBrogliaccioPostRequest', 'successContentVersionIds', successContentVersionIds);
        DebugService.printList('ContentVersionService', 'handleBrogliaccioPostRequest', 'successContentVersions', successContentVersions);
        DebugService.printList('ContentVersionService', 'handleBrogliaccioPostRequest', 'failedContentVersions', failedContentVersions);

        if(!failedContentVersions.isEmpty()) {
            System.debug('Entered failedContentVersions not empty');
            UPDATE failedContentVersions;
        }

        if(!successContentVersions.isEmpty()) {
            System.debug('Entered successContentVersions not empty');
            UPDATE successContentVersions;

            Map<Case, List<ContentVersion>> caseCvsAllMap = CaseService.processBrogliaccioUpdateAttachment(successContentVersionIds);
            DebugService.printMap('ContentVersionService', 'handleBrogliaccioPostRequest', 'caseCvsAllMap', new List<Case>(caseCvsAllMap.keySet()), caseCvsAllMap.values(), true);

            UPDATE new List<Case>(caseCvsAllMap.keySet());
        }
        DebugService.printLimits('ContentVersionService', 'handleBrogliaccioPostRequest', 'end');
    }

    public static Map<Case, List<ContentVersion>> getCaseCvsAllBrogliaccioMap(List<Case> cases) {
        DebugService.printLimits('ContentVersionService', 'getCaseCvsAllBrogliaccioMap', 'start');
        Map<String, Case> caseIdCaseMap = CaseService.getCaseIdCaseMap(cases);
        DebugService.printMap('CaseService', 'getCaseCvsAllBrogliaccioMap', 'caseIdCaseMap', new List<String>(caseIdCaseMap.keySet()), caseIdCaseMap.values(), true);

        List<ContentDocumentLink> contentDocumentLinks = ContentDocumentLinkSelector.getContentDocumentLinksByCaseIds(new List<String>(caseIdCaseMap.keySet()));

        Map<String, String> docIdCaseId = ContentDocumentLinkService.getDocIdCaseIdMap(contentDocumentLinks);
        DebugService.printMap('CaseService', 'getCaseCvsAllBrogliaccioMap', 'docIdCaseId', new List<String>(docIdCaseId.keySet()), docIdCaseId.values(), true);

        List<ContentVersion> contentVersions = ContentVersionSelector.getCvsBrogliaccioByDocumentIds(new List<String>(docIdCaseId.keySet()));
        DebugService.printList('CaseService', 'getCaseCvsAllBrogliaccioMap', 'contentVersions', contentVersions, true);

        Map<Case, List<ContentVersion>> caseCvsMap = new Map<Case, List<ContentVersion>>();

        for(ContentVersion cv : contentVersions) {
            if(caseCvsMap.containsKey(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)))) {
                System.debug('Entered contains key');
                List<ContentVersion> tmpContentVersions = caseCvsMap.get(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)));
                tmpContentVersions.add(cv);
                caseCvsMap.put(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)), tmpContentVersions);
            } else {
                System.debug('Entered not contains key');
                caseCvsMap.put(caseIdCaseMap.get(docIdCaseId.get(cv.ContentDocumentId)), new List<ContentVersion>{cv});
            }
        }

        DebugService.printMap('CaseService', 'getCaseCvsAllBrogliaccioMap', 'caseCvsMap', new List<Case>(caseCvsMap.keySet()), caseCvsMap.values(), true);
        DebugService.printLimits('ContentVersionService', 'getCaseCvsAllBrogliaccioMap', 'end');
        return caseCvsMap;
    }
}