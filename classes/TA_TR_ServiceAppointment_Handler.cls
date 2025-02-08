/**
* @author Andrea Liverani - WR
* @date Creation 21/06/2021
* @description TA_TR_ServiceAppointment_Handler – Handler for XC_TR_ServiceAppointment Trigger
*/

public without sharing class TA_TR_ServiceAppointment_Handler implements XC_I_TriggerHandler {
    
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('TA_TR_ServiceAppointment_Handler');

    /**
     * @author Andrea Liverani - WR
     * @description Method to stop recursion of the same event method in the same transaction
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }

    /**
     * @author Andrea Liverani - WR
     * @description Method to set to true the stop recursion variable on the current trigger event
    */
    public void executedTrigger() {
        //mapTriggerStopped.put(Trigger.operationType, true);
    }

    /**
     * @author Andrea Liverani - WR 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<SObject> sObjectListNew) {
    }

    public void onBeforeUpdate(Map<Id, SObject> sObjectMapOld, Map<Id, SObject> sObjectMapNew) {
        Map<Id, ServiceAppointment> servAppMapNew = (Map<Id, ServiceAppointment>) sObjectMapNew;
        Map<Id, ServiceAppointment> servAppMapOld = (Map<Id, ServiceAppointment>) sObjectMapOld;
        
        Set<Id> preserviceUpdateWoIds = new Set<Id>();
        for(ServiceAppointment sa : servAppMapNew.values()) {
            if(servAppMapOld.get(sa.Id).XC_StatusReason__c != sa.XC_StatusReason__c 
                && sa.XC_StatusReason__c == 'Assigned to the technician' 
                && sa.XC_Segment__c == 'B2C') {
                preserviceUpdateWoIds.add(sa.ParentRecordId);   
            }
        }

        if(!preserviceUpdateWoIds.isEmpty()) {
            List<WorkOrder> childWos = [SELECT Id FROM WorkOrder WHERE ParentWorkOrderId IN :preserviceUpdateWoIds];
            List<WorkOrder> preserviceUpdateWos = new List<WorkOrder>();

            if(!childWos.isEmpty()) {
                for(WorkOrder wo : childWos) {
                    preserviceUpdateWos.add(new WorkOrder(Id = wo.Id, TA_Phase__c = 'PreService'));
                }
            }

            for(Id woParentId : preserviceUpdateWoIds) {
                preserviceUpdateWos.add(new WorkOrder(Id = woParentId, TA_Phase__c = 'PreService'));
            }
            //GDB - PERFORMANCE IMPROVEMENT - MAY 2022
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateListRecords(preserviceUpdateWos);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }
    }

    /**
     * @author Andrea Liverani - WR
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    }

    public void onAfterInsert(Map<Id, SObject> sObjectMapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    }

    /**
     * @author Andrea Liverani - WR
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record 
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    }
    
    /**
     * @author Andrea Liverani - WR
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    }

    /**
     * @author Andrea Liverani - WR
     * @description Method to be executed on after undelete
     * @param mapOld - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    }
}