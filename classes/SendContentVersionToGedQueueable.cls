/**
 * Created by snekkanti002 on 19/11/2021.
 */

public without sharing class SendContentVersionToGedQueueable implements Queueable, Database.AllowsCallouts {

    private Map<Case, List<ContentVersion>> caseCvsMap;
    private Map<String, ContentVersionToGed__c> contentVersionNameToGedMap;

    public SendContentVersionToGedQueueable(Map<Case, List<ContentVersion>> caseCvsMap, Map<String, ContentVersionToGed__c> contentVersionNameToGedMap) {
        DebugService.printLimits('SendContentVersionToGedQueueable', 'constructor', 'start');
        try {
            this.caseCvsMap = caseCvsMap;
            DebugService.printMap('SendContentVersionToGedQueueable', 'constructor', 'caseCvsMap', new List<Case>(caseCvsMap.keySet()), caseCvsMap.values(), true);

            this.contentVersionNameToGedMap = contentVersionNameToGedMap;
            DebugService.printMap('SendContentVersionToGedQueueable', 'constructor', 'contentVersionNameToGedMap', new List<String>(contentVersionNameToGedMap.keySet()), contentVersionNameToGedMap.values(), true);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('SendContentVersionToGedQueueable', 'constructor', e);
        }
        DebugService.printLimits('SendContentVersionToGedQueueable', 'constructor', 'end');
    }

    public void execute(QueueableContext qc) {
        DebugService.printLimits('SendContentVersionToGedQueueable', 'execute', 'start');
        try {
            DebugService.printMap('SendContentVersionToGedQueueable', 'execute', 'caseCvsMap', new List<Case>(this.caseCvsMap.keySet()), this.caseCvsMap.values(), true);
            DebugService.printMap('SendContentVersionToGedQueueable', 'execute', 'contentVersionNameToGedMap', new List<String>(this.contentVersionNameToGedMap.keySet()), this.contentVersionNameToGedMap.values(), true);
            if(this.caseCvsMap != null && !this.caseCvsMap.isEmpty()) {
                System.debug('this.caseCvsMap is not null and is not empty');
                ContentVersionService.processPlatformEventGEDContentVersions(this.caseCvsMap);
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('SendContentVersionToGedQueueable', 'execute', e);
        }
        DebugService.printLimits('SendContentVersionToGedQueueable', 'execute', 'end');
    }
}