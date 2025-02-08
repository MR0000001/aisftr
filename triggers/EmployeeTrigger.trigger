/**
 * Created by LCONATO00 on 05/05/2020.
 */

trigger EmployeeTrigger on Employee__c (before insert, before update) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('EmployeeTrigger');

    if(skipTrigger == null || skipTrigger.isActive__c) {
        if (Trigger.isInsert) {
            if (Trigger.isBefore) {
                EmployeeService.TriggerHandlerPopolateBeforeInsertBeforeUpdate(Trigger.new);
            }
        }else if (Trigger.isUpdate){
            if (Trigger.isBefore) {
                EmployeeService.TriggerHandlerPopolateBeforeInsertBeforeUpdate(Trigger.new);
            }
        }
    }
}