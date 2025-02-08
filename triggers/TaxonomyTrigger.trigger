/**
 * Created by SNEKKANTI00 on 18/02/2021.
 */

trigger TaxonomyTrigger on Taxonomy__c (before insert, before update, after insert) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('TaxonomyTrigger');

    if(skipTrigger == null || skipTrigger.isActive__c) {
        if (Trigger.isBefore && Trigger.isInsert) {
            TaxonomyService.setTaxonomyTimeStamp(Trigger.new);
        }

        if (Trigger.isAfter && Trigger.isInsert) {
            TaxonomyService.doCallout(Trigger.new, true, false);
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            TaxonomyService.setTaxonomyBackupAndManageCallout(Trigger.new, Trigger.oldMap);
        }
    }
}