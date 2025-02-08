/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public without sharing class XC_TR_PPM_Project_Task_Handler implements XC_I_TriggerHandler {
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_BillingProfile_Handler');

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to set to true the stop recursion variable on the current trigger event
    */
    public void executedTrigger(){
        mapTriggerStopped.put(Trigger.operationType, true);
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<SObject> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        XC_TR_PPM_ProjectTask_FillFields.populateOwner_LCL_excecutor(listNew);
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        XC_TR_PPM_ProjectTask_FillFields.onUpdate((Map<Id,project_cloud__Project_Task__c>)mapOldS,(Map<Id,project_cloud__Project_Task__c>)mapNewS);

    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        XC_TR_PPM_ProjectTaskAddError.whenDeleteProjectTask((Map<Id,project_cloud__Project_Task__c>)mapOld);

    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);



    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        


    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);

    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapNew- map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);

    }

}