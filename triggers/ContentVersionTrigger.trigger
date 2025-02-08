/**
 * Created by LCONATO00 on 08/01/2021.
 */

trigger ContentVersionTrigger on ContentVersion (after insert) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('ContentVersionTrigger');

    System.debug('ContentVersionTrigger Start');
    if(skipTrigger == null || skipTrigger.isActive__c) {
        if(Trigger.isInsert) {
            if(Trigger.isAfter) {
                DebugService.printLimits('ContentVersionTrigger', 'after insert', 'start');
                try {
                    ContentVersionService.HandlerTriggerAfterInsert(Trigger.new);
                } catch(Exception e) {
                    DebugService.printException('ContentVersionTrigger', 'after insert', e);
                    ErrorLogEventHandler.standardExceptionLog(e);
                }
                DebugService.printLimits('ContentVersionTrigger', 'after insert', 'end');
            }
        }
    }
    System.debug('ContentVersionTrigger End');
}