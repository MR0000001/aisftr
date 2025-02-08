/**
 * Created by LCONATO00 on 06/05/2020.
 */

trigger RoleTrigger on Role__c (before insert, before update) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('RoleTrigger');

    if(skipTrigger == null || skipTrigger.isActive__c) {
        if (Trigger.isInsert) {
            if (Trigger.isBefore) {
                RoleService.TriggerHandlerPopolateBeforeInsertBeforeUpdate(Trigger.new);
            }
        }else if (Trigger.isUpdate){
            if (Trigger.isBefore) {
                RoleService.TriggerHandlerPopolateBeforeInsertBeforeUpdate(Trigger.new);
            }
        }
    }
}