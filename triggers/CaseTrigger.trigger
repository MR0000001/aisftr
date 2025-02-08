trigger CaseTrigger on Case (before insert, before update) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('CaseTrigger');

    if(skipTrigger == null || skipTrigger.isActive__c) {
        if(Trigger.isInsert) {
            if(Trigger.isBefore) {
                DebugService.printLimits('CaseTrigger', 'before insert', 'start');
                CaseService.splitAddress(Trigger.new);
                CaseService.TriggerHandler(Trigger.new,null);
                DebugService.printLimits('CaseTrigger', 'before insert', 'end');
            }
        } else {
            if(Trigger.isUpdate) {
                if (Trigger.isBefore) {
                    DebugService.printLimits('CaseTrigger', 'before update', 'start');
                    CaseService.splitAddress(Trigger.new);
                    CaseService.TriggerHandler(Trigger.new, Trigger.oldMap);
                    DebugService.printLimits('CaseTrigger', 'before update', 'end');
                }
            }
        }
    }
}