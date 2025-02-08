/**
 * Created by SNEKKANTI00 on 02/07/2021.
 */

trigger ContentDocumentTrigger on ContentDocument (before delete) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('ContentDocumentTrigger');

    System.debug('ContentDocumentTrigger Start');
    if(skipTrigger == null || skipTrigger.isActive__c) {
        if(Trigger.isDelete) {
            if(Trigger.isBefore) {
                DebugService.printLimits('ContentDocumentTrigger', 'before delete', 'start');
                try {
                    ContentDocumentService.HandlerTriggerBeforeDelete(Trigger.old);
                } catch(Exception e) {
                    DebugService.printException('ContentDocumentTrigger', 'before delete', e);
                    ErrorLogEventHandler.standardExceptionLog(e);
                }
                DebugService.printLimits('ContentDocumentTrigger', 'before delete', 'end');
            }
        }
    }
    System.debug('ContentDocumentTrigger End');
}