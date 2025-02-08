/**
 * Created by SNEKKANTI00 on 02/07/2021.
 */

trigger ContentDocumentLinkTrigger on ContentDocumentLink (before delete) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('ContentDocumentLinkTrigger');

    System.debug('ContentDocumentLinkTrigger Start');
    if(skipTrigger == null || skipTrigger.isActive__c) {
        if(Trigger.isDelete) {
            if(Trigger.isBefore) {
                DebugService.printLimits('ContentDocumentLinkTrigger', 'before delete', 'start');
                try {
                    ContentDocumentLinkService.HandlerTriggerBeforeDelete(Trigger.old);
                } catch(Exception e) {
                    DebugService.printException('ContentDocumentLinkTrigger', 'before delete', e);
                    ErrorLogEventHandler.standardExceptionLog(e);
                }
                DebugService.printLimits('ContentDocumentLinkTrigger', 'before delete', 'end');
            }
        }
    }
    System.debug('ContentDocumentLinkTrigger End');
}