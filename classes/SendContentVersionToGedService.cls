/**
 * Created by SNEKKANTI00 on 15/11/2021.
 */

public without sharing class SendContentVersionToGedService {
    public static void sendContentVersionToGed() {
        DebugService.printLimits('SendContentVersionToGedService', 'sendContentVersionToGed', 'start');
        try {
            List<String> cvIds = new List<String>();
            Map<String, List<String>> caseIdCvIdsMap = new Map<String, List<String>>();
            Map<String, ContentVersionToGed__c> contentVersionNameToGedMap = new Map<String, ContentVersionToGed__c>();
            Map<Case, List<ContentVersion>> caseCvsMap = new Map<Case, List<ContentVersion>>();

            ContentVersionToGed_Setting__mdt contentVersionToGedSetting = ContentVersionToGed_Setting__mdt.getInstance('ContentVersionToGed');

            System.debug('contentVersionToGedSetting: ' + contentVersionToGedSetting);

            List<ContentVersionToGed__c> contentVersionToGeds = ContentVersionToGedSelector.getLimitedContentVersionToGeds(Integer.valueOf(contentVersionToGedSetting.cvToGedNumber__c));
            DebugService.printList('SendContentVersionToGedService', 'sendContentVersionToGed', 'contentVersionToGeds', contentVersionToGeds);

            if(!contentVersionToGeds.isEmpty()) {
                ContentVersionToGedService.getCaseIdCvIdsMap(cvIds, caseIdCvIdsMap, contentVersionToGeds, contentVersionNameToGedMap, contentVersionToGedSetting);
                DebugService.printList('SendContentVersionToGedService', 'sendContentVersionToGed', 'cvIds',cvIds);
                DebugService.printMap('SendContentVersionToGedService', 'sendContentVersionToGed', 'caseIdCvIdsMap', new List<String>(caseIdCvIdsMap.keySet()), caseIdCvIdsMap.values(), true);

                if(!caseIdCvIdsMap.isEmpty()) {
                    Map<String, Case> caseMap = CaseSelector.getCasesForGedByIds(new List<String>(caseIdCvIdsMap.keySet()));
                    DebugService.printMap('SendContentVersionToGedService', 'sendContentVersionToGed', 'caseMap', new List<String>(caseMap.keySet()), caseMap.values(), true);

                    Map<String, ContentVersion> contentVersionsMap = ContentVersionSelector.getCvsNotIntegratedAndReadyGedByIds(cvIds);
                    DebugService.printMap('SendContentVersionToGedService', 'sendContentVersionToGed', 'contentVersionsMap', new List<String>(contentVersionsMap.keySet()), contentVersionsMap.values(), true);

                    for(Case c : caseMap.values()) {
                        if(!caseCvsMap.containsKey(c)) {
                            List<String> tmpCvIds = caseIdCvIdsMap.get(c.Id);
                            List<ContentVersion> tmpCvs = new List<ContentVersion>();
                            for(String cvId : tmpCvIds) {
                                tmpCvs.add(contentVersionsMap.get(cvId));
                            }
                            caseCvsMap.put(c, tmpCvs);
                        }
                    }
                    DebugService.printMap('SendContentVersionToGedService', 'sendContentVersionToGed', 'caseCvsMap', new List<Case>(caseCvsMap.keySet()), caseCvsMap.values(), true);
                    System.enqueueJob(new SendContentVersionToGedQueueable(caseCvsMap, contentVersionNameToGedMap));
                }
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('SendContentVersionToGedService', 'sendContentVersionToGed', e);
        }
    }
}