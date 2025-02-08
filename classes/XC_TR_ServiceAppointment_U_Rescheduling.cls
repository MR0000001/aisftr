/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 10/06/2019
* @date Modification 28/02/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
* @description XC_TR_ServiceAppointment_U_Rescheduling - Class to handle the Rescheduling Updates
*/
public without sharing class XC_TR_ServiceAppointment_U_Rescheduling {

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
     * @description Check Date changes
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkDateChanges(Map<Id,ServiceAppointment> mapOld, Map<Id,ServiceAppointment> mapNew){
        List<String> fieldListSchedTime = new List<String>{'SchedStartTime', 'SchedEndTime'};
        List<String> fieldListEarliestTime = new List<String>{'EarliestStartTime'};
        List<String> fieldListActualDates = new List<String>{'ActualStartTime', 'ActualEndTime'};
        List<String> fieldListActualEndTime = new List<String>{'ActualEndTime'};

        List<ServiceAppointment> listChangedSchedTime = XC_UTIL_Sobject.getListChanged(fieldListSchedTime, mapOld, mapNew);
        List<ServiceAppointment> listChangedEarliestTime = XC_UTIL_Sobject.getListChanged(fieldListEarliestTime, mapOld, mapNew);
        List<ServiceAppointment> listChangedActualDates = XC_UTIL_Sobject.getListChanged(fieldListActualDates, mapOld, mapNew);
        List<ServiceAppointment> listChangedActualEndTime = XC_UTIL_Sobject.getListChanged(fieldListActualEndTime, mapOld, mapNew);

        if(!listChangedSchedTime.isEmpty()){
            updateServiceAppointmentFields(listChangedSchedTime, mapOld);
        }
        if(!listChangedEarliestTime.isEmpty()){
            updateServiceAppointmentDueDate(listChangedEarliestTime, mapOld);
        }
        if(!listChangedActualDates.isEmpty()){
            updateServiceAppointmentActualDates(mapNew);
        }
        if(!listChangedActualEndTime.isEmpty()){
            updateTimestampEndTime(mapNew, mapOld);
        }
    }

     /**
      * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
      * @description Manage Date Fields on Service Appointment
      * @param listNew - List<ServiceAppointment>
      * @param mapOld - Map<Id,ServiceAppointment>
      */
    private static void updateServiceAppointmentFields(List<ServiceAppointment> listNew, Map<Id,ServiceAppointment> mapOld) {
        Map<String, Boolean> mapRequestRescheduling = XC_TR_ServiceAppointment_U_UpdateWO.calculateRequiresRescheduling(listNew);
        List<WorkOrder> listWoToUpdate = new List<WorkOrder>();

        for(ServiceAppointment sa : listNew){
            Boolean startTimeChangedFromNull = mapOld.get(sa.id).SchedStartTime == null && sa.SchedStartTime != null;
            Boolean startTimeChanged = mapOld.get(sa.id).SchedStartTime != null && sa.SchedStartTime != null;
            Boolean endTimeChangedFromNull = mapOld.get(sa.id).SchedEndTime == null && sa.SchedEndTime != null;
            Boolean endTimeChanged = mapOld.get(sa.id).SchedEndTime != null && sa.SchedEndTime != null;
            Boolean dateChanged = mapOld.get(sa.Id).SchedStartTime != null  || mapOld.get(sa.Id).SchedEndTime != null;

            if(dateChanged) {
                sa.XC_NumberOfRescheduling__c = sa.XC_NumberOfRescheduling__c == null ? 0 : sa.XC_NumberOfRescheduling__c + 1;
            }

            if(startTimeChanged || endTimeChanged) {
                if(sa.Status != Label.XC_CL_ServiceAppointment_CannotComplete) {
                    if(mapRequestRescheduling.containsKey(sa.Id) && mapRequestRescheduling.get(sa.Id)) {
                        //OTT_FLS50
                        /*if(sa.XC_NumberOfRescheduling__c > 1) {
                            sa.XC_StatusReason__c = Label.XC_CL_AssignedToTheTechnicianRescheduled;
                        } else {
                            sa.XC_StatusReason__c = Label.XC_CL_StatusReason_Assignedtothetechnician;
                        }*/
                       
                        if(sa.XC_StatusReason__c == Label.XC_CL_StatusReason_Assignedtothetechnician){
                            sa.XC_StatusReason__c = Label.XC_CL_AssignedToTheTechnicianRescheduled;     
                        }
                        //OTT_FLS50
                    } else {
                        sa.XC_StatusReason__c = Label.XC_CL_AssignedToTheTechnicianRescheduled;
                    }
                    continue;
                }
                if(String.isNotBlank(sa.XC_Reason_of_Rejection__c)) {
                    sa.XC_Reason_of_Rejection__c = null;
                    listWoToUpdate.add(new WorkOrder(
                        Id = sa.ParentRecordId,
                        XC_Refusing_Reason__c = null
                    ));
                }
            }

            if(startTimeChangedFromNull || endTimeChangedFromNull) {
                if(!sa.XC_AssignToPartner__c) {
                    if(mapRequestRescheduling.containsKey(sa.Id) && mapRequestRescheduling.get(sa.Id)) {
                        sa.XC_StatusReason__c = Label.XC_CL_StatusReason_ToBeScheduled;
                    } else {
                        sa.XC_StatusReason__c = Label.XC_CL_StatusReason_Assignedtothetechnician;
                    }
                } else {
                    sa.XC_StatusReason__c = Label.XC_CL_StatusReason_Pendingassigntechnician;
                }
            }     
        }

        if(!listWoToUpdate.isEmpty()) {
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);  
            XC_UTIL_Sobject.updateListRecords(listWoToUpdate);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        }
    }

    /**
     * @description Update Due Date
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
     * @param listNew - List<ServiceAppointment>
     * @param mapOld - Map<Id,ServiceAppointment>
     */
    private static void updateServiceAppointmentDueDate(List<ServiceAppointment> listNew, Map<Id,ServiceAppointment> mapOld){
        for(ServiceAppointment sa : listNew){
            DateTime originalEarliestStartTime = mapOld.get(sa.Id).EarliestStartTime;
            if(sa.EarliestStartTime != null){
                sa.Duedate = getNewDueDate(sa.EarliestStartTime, sa, originalEarliestStartTime);
            }
        }
    }

    /**
     * @description Update Due Date
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @date 07/12/2020
     * @param mapNew - Map<Id, ServiceAppointment>
     */
    private static void updateServiceAppointmentActualDates(Map<Id, ServiceAppointment> mapNew) {
        List<String> listWorkOrderIds = XC_UTIL_Sobject.getListFieldValues(mapNew.values(), 'ParentRecordId');
        Map<Id, WorkOrder> mapWorkOrders = new Map<Id, WorkOrder>([
            SELECT Id, CreatedDate
            FROM WorkOrder
            WHERE Id IN :listWorkOrderIds
        ]);
        for(ServiceAppointment sa : mapNew.values()) {
            if(sa.ActualStartTime < mapWorkOrders.get(sa.ParentRecordId).CreatedDate || sa.ActualEndTime < mapWorkOrders.get(sa.ParentRecordId).CreatedDate) {
                sa.addError(Label.XC_CL_ErrorSaActualDates);
            }
        }
    }

    /**
     * @description Update Timestamp End Time (for SA and WO) for the first time
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @date 04/05/2021
     * @param mapNew - Map<Id, ServiceAppointment>
     * @param mapOld - Map<Id, ServiceAppointment>
     */
    private static void updateTimestampEndTime(Map<Id, ServiceAppointment> mapNew, Map<Id, ServiceAppointment> mapOld) {
        List<WorkOrder> listWorkOrderToUpdate = new List<WorkOrder>();
        for(ServiceAppointment sa : mapNew.values()) {
            Boolean endDateNewNotEmpty = (sa.ActualEndTime != null);
            Boolean endDateOldEmpty = (mapOld.get(sa.Id).ActualEndTime == null);
            Boolean timestampOldEmpty = (mapOld.get(sa.Id).XC_ActualEndDateTimestamp__c == null);
            if(endDateNewNotEmpty && endDateOldEmpty && timestampOldEmpty) {
                sa.XC_ActualEndDateTimestamp__c = Datetime.now();
                listWorkOrderToUpdate.add(new WorkOrder(
                    Id = sa.ParentRecordId,
                    XC_ActualEndDateTimestamp__c = Datetime.now()
                ));
            }
        }
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);  
        XC_UTIL_Sobject.updateListRecords(listWorkOrderToUpdate);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
    }

    /**
     * @description Gets the new due date
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @param newEarliestStart - DateTime
     * @param sa - ServiceAppointment
     * @param originalEarliestStartTime - DateTime
     * @return DateTime
     */
    private static DateTime getNewDueDate(DateTime newEarliestStart, ServiceAppointment sa, DateTime originalEarliestStartTime){
        DateTime originalDueDate = sa.DueDate;
        DateTime newDueDate = newEarliestStart.addDays(originalEarliestStartTime.date().daysBetween(originalDueDate.date())).addHours(originalDueDate.hour() - originalEarliestStartTime.hour());
        return newDueDate;
    }

}