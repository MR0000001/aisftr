/**
 * Created by LCONATO00 on 01/06/2020.
 */

trigger WeeklyScheduleTrigger on Weekly_Schedule__c (before insert, before update, before delete) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('WeeklyScheduleTrigger');

    if(skipTrigger == null || skipTrigger.isActive__c) {
        if(Trigger.isUpdate) {
            if(Trigger.isBefore) {
                WeeklyScheduleService.TriggerHandlerValidateUser(Trigger.new,true,false,false);
            }
        }else{
            if(Trigger.isDelete) {
                if (Trigger.isBefore) {
                    WeeklyScheduleService.TriggerHandlerValidateUser(Trigger.old,false,true,false);
                }
            } else {
                if (Trigger.isInsert) {
                    if (Trigger.isBefore) {
                        WeeklyScheduleService.TriggerHandlerValidateUser(Trigger.new, false,false,true);
                    }
                }
            }
        }
    }
}