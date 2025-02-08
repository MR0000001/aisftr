/**
 * Created by SNEKKANTI00 on 18/02/2021.
 */

trigger SynonymousTrigger on Synonymous__c (before insert, before update, after insert) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('SynonymousTrigger');

    if(skipTrigger == null || skipTrigger.isActive__c) {
        if(Trigger.isBefore && Trigger.isInsert) {
            SynonymousService.setSynonymousTimeStamp(Trigger.new);
        }

        if(Trigger.isAfter && Trigger.isInsert) {
            SynonymousService.doCallout(Trigger.new, true);
        }

        if(Trigger.isBefore && Trigger.isUpdate) {
            SynonymousService.setSynonymousBackupAndManageCallout(Trigger.new, trigger.oldMap);
        }
    }
}