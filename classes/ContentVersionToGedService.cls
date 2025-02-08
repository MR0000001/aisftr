/**
 * Created by SNEKKANTI00 on 15/11/2021.
 */

public without sharing class ContentVersionToGedService {
    public static List<String> getAllContentVersionToGedIds() {
        DebugService.printLimits('ContentVersionToGedService', 'getAllContentVersionToGedIds', 'start');
        List<String> contentVersionIds = new List<String>();

        List<ContentVersionToGed__c> contentVersionToGeds = ContentVersionToGedSelector.getAllContentVersionToGeds();
        DebugService.printList('ContentVersionToGedService', 'getAllContentVersionToGedIds', 'contentVersionToGeds', contentVersionToGeds);

        for(ContentVersionToGed__c cvg : contentVersionToGeds) {
            contentVersionIds.add(cvg.Name);
        }
        DebugService.printList('ContentVersionToGedService', 'getAllContentVersionToGedIds', 'contentVersionIds', contentVersionIds);

        DebugService.printLimits('ContentVersionToGedService', 'getAllContentVersionToGedIds', 'end');

        return contentVersionIds;
    }

    public static void insertContentVersionToGeds(List<ContentVersionToGed__c> contentVersionToGeds, Boolean allOrNone) {
        DebugService.printLimits('ContentVersionToGedService', 'insertContentVersionToGeds', 'start');
        if(contentVersionToGeds != null && !contentVersionToGeds.isEmpty()) {
            List<Database.SaveResult> results = ContentVersionToGedSelector.insertContentVersionToGeds(contentVersionToGeds, allOrNone);
            DebugService.printDatabaseResults('ContentVersionToGedService', 'insertContentVersionToGeds', 'contentVersionToGeds', results);
        }
        DebugService.printLimits('ContentVersionToGedService', 'insertContentVersionToGeds', 'end');
    }

    public static void deleteContentVersionToGeds(List<String> contentVersionToGedIds, Boolean allOrNone) {
        DebugService.printLimits('ContentVersionToGedService', 'deleteContentVersionToGeds', 'start');
        if(contentVersionToGedIds != null && !contentVersionToGedIds.isEmpty()) {
            List<Database.DeleteResult> results = ContentVersionToGedSelector.deleteContentVersionToGeds(contentVersionToGedIds, allOrNone);
            DebugService.printDatabaseResults('ContentVersionToGedService', 'deleteContentVersionToGeds', 'contentVersionToGedIds', results);
        }
        DebugService.printLimits('ContentVersionToGedService', 'deleteContentVersionToGeds', 'end');
    }

    public static void checkContentVersionsToGedRetryabilityAndDoDml(List<String> cvIds, Boolean allOrNone) {
        Boolean toUpdate = false;
        Boolean toDelete = false;

        ContentVersionToGed_Setting__mdt contentVersionToGedSetting = ContentVersionToGed_Setting__mdt.getInstance('ContentVersionToGed');
        System.debug('contentVersionToGedSetting ' + contentVersionToGedSetting);

        Integer numMaxRetry = Integer.valueOf(contentVersionToGedSetting.numMaxRetrySendAttachmentGED__c);
        System.debug('numMaxRetry ' + numMaxRetry);

        List<ContentVersionToGed__c> contentVersionToGeds = ContentVersionToGedSelector.getContentVersionToGedByCvIds(cvIds);
        DebugService.printList('GEDUpdateAttachment', 'doPost', 'contentVersionToGeds', contentVersionToGeds, true);

        for(ContentVersionToGed__c c : contentVersionToGeds) {
            if(c.numOfAttemptsSendAttachment__c <= numMaxRetry) {
                System.debug('No retry ' + c.numOfAttemptsSendAttachment__c);
                toDelete = true;
            } else if(c.numOfAttemptsSendAttachment__c < numMaxRetry) {
                System.debug('Yes retry ' + c.numOfAttemptsSendAttachment__c);
                toUpdate= true;
                c.numOfAttemptsSendAttachment__c += 1;
            }
        }

        if(toDelete) {
            System.debug('Entered toDelete');
            ContentVersionToGedService.deleteContentVersionToGedsByCvIds(cvIds, allOrNone);
        }

        if(toUpdate) {
            System.debug('Entered toUpdate');
            ContentVersionToGedService.updateContentVersionToGeds(contentVersionToGeds, allOrNone);
        }
    }

    public static void updateContentVersionToGeds(List<ContentVersionToGed__c> contentVersionToGeds, Boolean allOrNone) {
        DebugService.printLimits('ContentVersionToGedService', 'updateContentVersionToGeds', 'start');
        if(contentVersionToGeds != null && !contentVersionToGeds.isEmpty()) {
            List<Database.SaveResult> results = ContentVersionToGedSelector.updateContentVersionToGeds(contentVersionToGeds, allOrNone);
            DebugService.printDatabaseResults('ContentVersionToGedService', 'updateContentVersionToGeds', 'contentVersionToGeds', results);
        }
        DebugService.printLimits('ContentVersionToGedService', 'updateContentVersionToGeds', 'end');
    }

    public static void deleteContentVersionToGedsByCvIds(List<String> cvIds, Boolean allOrNone) {
        DebugService.printLimits('ContentVersionToGedService', 'deleteContentVersionToGedsByCvIds', 'start');

        List<String> cvToGedIds = new List<String>();

        List<ContentVersionToGed__c> contentVersionToGeds = ContentVersionToGedSelector.getContentVersionToGedByCvIds(cvIds);

        for(ContentVersionToGed__c contentVersionToGed : contentVersionToGeds) {
            cvToGedIds.add(contentVersionToGed.Id);
        }

        deleteContentVersionToGeds(cvToGedIds, allOrNone);

        DebugService.printLimits('ContentVersionToGedService', 'deleteContentVersionToGedsByCvIds', 'end');
    }

    public static void getCaseIdCvIdsMap(List<String> cvIds, Map<String, List<String>> caseIdCvIdsMap, List<ContentVersionToGed__c> contentVersionToGeds, Map<String, ContentVersionToGed__c> contentVersionNameToGedMap, ContentVersionToGed_Setting__mdt contentVersionToGedSetting) {
        DebugService.printLimits('ContentVersionToGedService', 'getCaseIdCvIdsMap', 'start');

        Integer sizeCounter = 0;

        for(ContentVersionToGed__c c : contentVersionToGeds) {
            sizeCounter += Integer.valueOf(c.ContentVersionSize__c);
            if(sizeCounter <= contentVersionToGedSetting.cvToGedMaxSize__c) {
                System.debug('Size ' + sizeCounter + ' is less than ' + contentVersionToGedSetting.cvToGedMaxSize__c);
                if(!caseIdCvIdsMap.containsKey(c.CaseId__c)) {
                    System.debug('Contains key ' + c.CaseId__c);
                    caseIdCvIdsMap.put(c.CaseId__c, new List<String>{c.Name});
                } else {
                    System.debug('Does not contain key');
                    List<String> tmpCvIds = caseIdCvIdsMap.get(c.CaseId__c);
                    tmpCvIds.add(c.Name);
                    caseIdCvIdsMap.put(c.CaseId__c, tmpCvIds);
                }
                contentVersionNameToGedMap.put(c.Name, c);
                cvIds.add(c.Name);
            }
        }
        DebugService.printMap('ContentVersionToGedService', 'getCaseIdCvIdsMap', 'caseIdCvIdsMap', new List<String>(caseIdCvIdsMap.keySet()), caseIdCvIdsMap.values(), true);
        DebugService.printLimits('ContentVersionToGedService', 'getCaseIdCvIdsMap', 'end');
    }
}