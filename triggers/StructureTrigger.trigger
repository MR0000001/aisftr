/**
 * Created by LCONATO00 on 01/06/2020.
 */

trigger StructureTrigger on Structure__c (before update, before insert) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('StructureTrigger');

    if(skipTrigger == null || skipTrigger.isActive__c) {
        if (Trigger.isUpdate){
            if (Trigger.isBefore) {
                StructureService.TriggerHandlerPopulateName(Trigger.new,Trigger.oldMap);
                StructureService.TriggerHandlerSetRecordType(Trigger.new,Trigger.oldMap);
                StructureService.TriggerHandlerValidateUser(Trigger.new);
                StructureService.TriggerHandlerPopulateLastModifiedWSO2(Trigger.new);
            }
        } else {
            if (Trigger.isInsert){
                if (Trigger.isBefore) {
                    StructureService.TriggerHandlerPopulateName(Trigger.new,null);
                    StructureService.TriggerHandlerSetRecordType(Trigger.new,null);
                    StructureService.TriggerHandlerPopulateLastModifiedWSO2(Trigger.new);
                }
            }
        }
    }
}