/**
 * Created by snekkanti002 on 19/11/2021.
 */

trigger SendContentVersionToGedEventTrigger on SendContentVersionToGed__e (after insert) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('SendContentVersionToGedEventTrigger');

    if(skipTrigger == null || skipTrigger.isActive__c) {
        DebugService.printLimits('SendContentVersionToGedEventTrigger', 'after insert trigger', 'start');
        SendContentVersionToGedService.sendContentVersionToGed();
        DebugService.printLimits('SendContentVersionToGedEventTrigger', 'after insert trigger', 'end');
    }
}