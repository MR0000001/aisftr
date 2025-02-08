/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 24/11/2020
* @description XC_SC012_UTIL_MassiveWo – Util for batch classes SC012
*/ 

public without sharing class XC_SC012_UTIL_MassiveWo {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC012_MassiveWoPartner');

    /** @description UtilMapsWrapper */ 
    public class UtilMapsWrapper {
        public Map<String, String> mapWorkOrderPartner = new Map<String, String>();
        public Map<Id, WorkOrder> mapWorkOrdersWithSkill = new Map<Id, WorkOrder>();
    }

    /** @description SplitListWrapper */ 
    public class SplitListWrapper {
        public List<ServiceAppointment> listServiceAppointmentErrorStatus = new List<ServiceAppointment>();
        public List<ServiceAppointment> listServiceAppointmentFiltred = new List<ServiceAppointment>();
    }

    /** @description UpdateDueDateWrapper */ 
    public class UpdateDueDateWrapper {
        public Map<String, Datetime> mapAppointmentIdOldDueDate = new Map<String, Datetime>();
        public Map<String, String> mapAppointmentWorkOrderId = new Map<String, String>();
        public Boolean firstUpdateSuccess = false;
    }

    /** @description LogWrapper */
    public class LogWrapper {
        public String errorMessage = '';
        public List<String> workOrderIds = new List<String>();
        public String workOrderId = '';
        public Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
        public String originPartner = '';
        public String destinationPartner = '';
        public String comments = 'No comments';
        public Map<String, String> mapWorkOrderOriginPartner = new Map<String, String>();
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Split scope into two list
     * @param scope - List<ServiceAppointment> 
     * @return SplitListWrapper
    */
    public SplitListWrapper splitScope(List<ServiceAppointment> scope) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ <--- ENTER in splitScope ---> ');
        SplitListWrapper wr = new SplitListWrapper();
        Map<String, ServiceAppointment> mapWoSaCannotComplete = new Map<String, ServiceAppointment>();
        for(ServiceAppointment sa : scope) {
            if(sa.Status == Label.XC_CL_ServiceAppointment_Scheduled    ||
                sa.Status == Label.XC_CL_ServiceAppointment_Dispatched  ||
                sa.Status == Label.XC_CL_ServiceAppointment_OnHold      ||
                sa.Status == Label.XC_CL_ServiceAppointment_None) {
                    wr.listServiceAppointmentFiltred.add(sa);
            }
            else if(sa.Status == Label.XC_CL_ServiceAppointment_CannotComplete) {
                mapWoSaCannotComplete.put(sa.ParentRecordId, sa);
            }
            else {
                wr.listServiceAppointmentErrorStatus.add(sa);
            }
        }
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_SC012_UTIL_MassiveWo.mapWoSaCannotComplete ---> ' + mapWoSaCannotComplete);
        // Check for Service Appointment in Cannot Complete:
        if(!mapWoSaCannotComplete.keySet().isEmpty()) {
            List<WorkOrder> listWorkOrder = new List<WorkOrder>([
                SELECT Id   
                FROM WorkOrder
                WHERE Id IN :mapWoSaCannotComplete.keySet() AND Status = :Label.XC_CL_OnHold
            ]);
            if(listWorkOrder.isEmpty()) {
                wr.listServiceAppointmentErrorStatus.addAll(mapWoSaCannotComplete.values());
            } else {
                List<String> listWoIdsOnHold = XC_UTIL_Sobject.getIds(listWorkOrder);
                for(String key : mapWoSaCannotComplete.keySet()) {
                    if(listWoIdsOnHold.contains(key)) {
                        wr.listServiceAppointmentFiltred.add(mapWoSaCannotComplete.get(key));
                    } else {
                        wr.listServiceAppointmentErrorStatus.add(mapWoSaCannotComplete.get(key));
                    }
                }
            }
        }
        return wr;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Populate error log for Service Appoint with wrong status
     * @param listServiceAppointmentErrorStatus - List<ServiceAppointment>
     * @param originPartner - String 
     * @param destinationPartner - String
     * @param comments - String
     * @return List<XC_MassiveAssignmentWorkOrderLog__c>
    */
    public List<XC_MassiveAssignmentWorkOrderLog__c> insertNoMathStatusLogError(List<ServiceAppointment> listServiceAppointmentErrorStatus, String originPartner, String destinationPartner, String comments) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.insertNoMathStatusLogError listServiceAppointmentErrorStatus ---> ' + listServiceAppointmentErrorStatus);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.insertNoMathStatusLogError originPartner ---> ' + originPartner);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.insertNoMathStatusLogError destinationPartner ---> ' + destinationPartner);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.insertNoMathStatusLogError comments ---> ' + comments);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.insertNoMathStatusLogError insertNoMathStatusLogError ---> ');        
        List<XC_MassiveAssignmentWorkOrderLog__c> listMassiveAssignmentLog = new List<XC_MassiveAssignmentWorkOrderLog__c>();
        List<String> workOrderIdsError = XC_UTIL_Sobject.getListFieldValues(listServiceAppointmentErrorStatus, 'ParentRecordId');
        Map<String, ServiceAppointment> mapWorkOrderServiceAppointmentError = new Map<String, ServiceAppointment>();
        for(ServiceAppointment sa : listServiceAppointmentErrorStatus) {
            mapWorkOrderServiceAppointmentError.put(sa.ParentRecordId, sa);
        }
        Set<String> setWorkOrderIds = new Set<String>();
        setWorkOrderIds.addAll(workOrderIdsError);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.insertNoMathStatusLogError setWorkOrderIds ---> ' + setWorkOrderIds);
        if(!setWorkOrderIds.isEmpty()) {
            for(String workOrderId : setWorkOrderIds) {
                if(String.isBlank(workOrderId)) {
                    continue;
                }
                XC_MassiveAssignmentWorkOrderLog__c massiveAssignmentLog = new XC_MassiveAssignmentWorkOrderLog__c();
                massiveAssignmentLog.XC_OriginPartner__c = originPartner;
                massiveAssignmentLog.XC_DestinationPartner__c = destinationPartner;
                if(mapWorkOrderServiceAppointmentError.containsKey(workOrderId)) {
                    massiveAssignmentLog.XC_ServiceAppointment__c = mapWorkOrderServiceAppointmentError.get(workOrderId).Id;
                }
                massiveAssignmentLog.XC_WorkOrder__c = workOrderId;
                massiveAssignmentLog.XC_AssignmentMessage__c = Label.XC_CL_MassiveAssignmentWorkOrderImpossibleErrorStatus;
                massiveAssignmentLog.XC_AssignmentSuccess__c = false;
                massiveAssignmentLog.XC_Reason__c = comments;
                listMassiveAssignmentLog.add(massiveAssignmentLog);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.insertNoMathStatusLogError listMassiveAssignmentLog ---> ' + listMassiveAssignmentLog);
        return listMassiveAssignmentLog;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 24/11/2020
     * @description Method to insert error logs
     * @param logWrapper - LogWrapper
    */
    public void insertErrorLogs(LogWrapper logWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.insertErrorLogs logWrapper ---> ' + logWrapper);
        if(!logWrapper.workOrderIds.isEmpty()) { 
            List<XC_MassiveAssignmentWorkOrderLog__c> listMassiveAssignmentLog = new List<XC_MassiveAssignmentWorkOrderLog__c>();
            Set<String> setWorkOrderIds = new Set<String>();
            setWorkOrderIds.addAll(logWrapper.workOrderIds);
            for(String workOrderId : setWorkOrderIds) {
                if(String.isBlank(workOrderId)) {
                    continue;
                }
                XC_MassiveAssignmentWorkOrderLog__c massiveAssignmentLog = new XC_MassiveAssignmentWorkOrderLog__c();
                if(String.isNotBlank(logWrapper.originPartner)) {
                    massiveAssignmentLog.XC_OriginPartner__c = logWrapper.originPartner;
                } else if(logWrapper.mapWorkOrderOriginPartner.containsKey(workOrderId) && String.isNotBlank(logWrapper.mapWorkOrderOriginPartner.get(workOrderId))) {
                    massiveAssignmentLog.XC_OriginPartner__c = logWrapper.mapWorkOrderOriginPartner.get(workOrderId);
                }
                massiveAssignmentLog.XC_DestinationPartner__c = logWrapper.destinationPartner;
                if(logWrapper.mapWorkOrderServiceAppointment.containsKey(workOrderId)) {
                    massiveAssignmentLog.XC_ServiceAppointment__c = logWrapper.mapWorkOrderServiceAppointment.get(workOrderId).Id;
                }
                massiveAssignmentLog.XC_WorkOrder__c = workOrderId;
                massiveAssignmentLog.XC_AssignmentMessage__c = logWrapper.errorMessage;
                massiveAssignmentLog.XC_AssignmentSuccess__c = false;
                massiveAssignmentLog.XC_Reason__c = logWrapper.comments;
                listMassiveAssignmentLog.add(massiveAssignmentLog);
            }
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultListMassiveAssignmentLog = XC_UTIL_Sobject.insertListRecords(listMassiveAssignmentLog);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 24/11/2020
     * @description Method to populate error logs
     * @param logWrapper - LogWrapper
     * @return List<XC_MassiveAssignmentWorkOrderLog__c>
    */
    public List<XC_MassiveAssignmentWorkOrderLog__c> populateErrorLogs(LogWrapper logWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.populateErrorLogs logWrapper ---> ' + logWrapper);
        List<XC_MassiveAssignmentWorkOrderLog__c> listMassiveAssignmentLog = new List<XC_MassiveAssignmentWorkOrderLog__c>();
        if(!logWrapper.workOrderIds.isEmpty()) { 
            Set<String> setWorkOrderIds = new Set<String>();
            setWorkOrderIds.addAll(logWrapper.workOrderIds);
            for(String workOrderId : setWorkOrderIds) {
                if(String.isBlank(workOrderId)) {
                    continue;
                }
                XC_MassiveAssignmentWorkOrderLog__c massiveAssignmentLog = new XC_MassiveAssignmentWorkOrderLog__c();
                if(String.isNotBlank(logWrapper.originPartner)) {
                    massiveAssignmentLog.XC_OriginPartner__c = logWrapper.originPartner;
                } else if(logWrapper.mapWorkOrderOriginPartner.containsKey(workOrderId) && String.isNotBlank(logWrapper.mapWorkOrderOriginPartner.get(workOrderId))) {
                    massiveAssignmentLog.XC_OriginPartner__c = logWrapper.mapWorkOrderOriginPartner.get(workOrderId);
                }
                massiveAssignmentLog.XC_DestinationPartner__c = logWrapper.destinationPartner;
                if(logWrapper.mapWorkOrderServiceAppointment.containsKey(workOrderId)) {
                    massiveAssignmentLog.XC_ServiceAppointment__c = logWrapper.mapWorkOrderServiceAppointment.get(workOrderId).Id;
                }
                massiveAssignmentLog.XC_WorkOrder__c = workOrderId;
                massiveAssignmentLog.XC_AssignmentMessage__c = logWrapper.errorMessage;
                massiveAssignmentLog.XC_AssignmentSuccess__c = false;
                massiveAssignmentLog.XC_Reason__c = logWrapper.comments;
                listMassiveAssignmentLog.add(massiveAssignmentLog);
            }
        }
        return listMassiveAssignmentLog;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 24/11/2020
     * @description Method to create a map WorkOrderId -> OriginPartner
     * @param listWoIds - List<String>
     * @return UtilMapsWrapper
    */
    public UtilMapsWrapper getUtilMap(List<String> listWoIds) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.getUtilMap listWoIds ---> ' + listWoIds);
        UtilMapsWrapper utilMapWrapper = new UtilMapsWrapper();
        utilMapWrapper.mapWorkOrdersWithSkill = new Map<Id, WorkOrder>([
            SELECT Id, XC_WorkTypeCategory__c, PostalCode, WorkTypeId, XC_AssignedPartner__c,
                (SELECT Id, SkillId, SkillLevel FROM SkillRequirements)
            FROM WorkOrder  
            WHERE Id IN :listWoIds
        ]);
        for(WorkOrder wo : utilMapWrapper.mapWorkOrdersWithSkill.values()) {
            if(String.isNotBlank(wo.XC_AssignedPartner__c)) {
                utilMapWrapper.mapWorkOrderPartner.put(wo.Id, wo.XC_AssignedPartner__c);
            }
        }
        return utilMapWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 24/11/2020
     * @description Method to update dates Service Appointment 
     * @param listServiceAppointment - List<ServiceAppointment>
     * @param updateDueDate - Boolean
     * @return UpdateDueDateWrapper
    */
    public UpdateDueDateWrapper updateServiceAppointmentDueDate(List<ServiceAppointment> listServiceAppointment, Boolean updateDueDate) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.updateServiceAppointmentDueDate listServiceAppointment ---> ' + listServiceAppointment);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.updateDueDate updateDueDate ---> ' + updateDueDate);
        UpdateDueDateWrapper uddWr = new UpdateDueDateWrapper();
        List<ServiceAppointment> listServiceAppointmentToUpdateForDueDate = new List<ServiceAppointment>();
        List<WorkOrder> listWoDueDateToUpdate = new List<WorkOrder>();
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        XC_CM_ServiceAppointment_Default_Value__mdt saCM  = [SELECT XC_DaysForUpdateDueDate__c FROM XC_CM_ServiceAppointment_Default_Value__mdt LIMIT 1];
        for(ServiceAppointment sa : listServiceAppointment) {
            ServiceAppointment saToUpdate = new ServiceAppointment();
            saToUpdate.Id = sa.Id;
            if(updateDueDate) {
                uddWr.mapAppointmentIdOldDueDate.put(sa.Id, sa.DueDate);
                saToUpdate.DueDate = Datetime.Now().addDays(Integer.valueOf(saCM.XC_DaysForUpdateDueDate__c));
                listWoDueDateToUpdate.add(new WorkOrder(
                    Id = sa.ParentRecordId,
                    DueDate__c = saToUpdate.DueDate, 
                    XC_DueDate__c = saToUpdate.DueDate
                ));
            }
            saToUpdate.FSL__Pinned__c = false;
            listServiceAppointmentToUpdateForDueDate.add(saToUpdate);
            if(sa.ArrivalWindowEndTime != null && sa.ArrivalWindowEndTime < Datetime.now()) {
                sa.ArrivalWindowEndTime = null;
                sa.ArrivalWindowStartTime = null;
            }
            uddWr.mapAppointmentWorkOrderId.put(sa.Id, sa.ParentRecordId);
        }
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.updateListRecords(listServiceAppointmentToUpdateForDueDate);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        resultList.addAll(XC_UTIL_Sobject.updateListRecords(listWoDueDateToUpdate));
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        Boolean success = true;
        for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(!wr.success){
                success = false;
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC012_AutoScheduleToPartner';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Update Due Date';
                bel.XC_RecordId__c = wr.errorObjectId;
                errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog);
        uddWr.firstUpdateSuccess = success;
        return uddWr;
    }
 
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 24/11/2020
     * @description Method to schedule service appointment
     * @param updateDueDate - Boolean
     * @param mapAppointmentIdOldDueDate - Map<String, Datetime>
     * @param mapWorkOrderOriginPartner - Map<String, String>
     * @param workOrderIds - List<Id>
     * @param mapWorkOrderServiceAppointment - Map<String, ServiceAppointment>
     * @param listCapacityBasedResource - List<ServiceResource>
     * @param listErrorLogs - List<XC_MassiveAssignmentWorkOrderLog__c>  
     * @param listSuccessLogs - List<XC_MassiveAssignmentWorkOrderLog__c>
     * @param originPartner - String
     * @param destinationPartner - String
     * @param comments - String
    */
    public void scheduleServiceAppointment(Boolean updateDueDate, Map<String, Datetime> mapAppointmentIdOldDueDate, Map<String, String> mapWorkOrderOriginPartner, List<String> workOrderIds, Map<String, ServiceAppointment> mapWorkOrderServiceAppointment, List<ServiceResource> listCapacityBasedResource, List<XC_MassiveAssignmentWorkOrderLog__c> listErrorLogs, List<XC_MassiveAssignmentWorkOrderLog__c> listSuccessLogs, String originPartner, String destinationPartner, String comments) {
       	XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment updateDueDate ---> ' + updateDueDate);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment mapAppointmentIdOldDueDate ---> ' + mapAppointmentIdOldDueDate);
       	XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment mapWorkOrderOriginPartner ---> ' + mapWorkOrderOriginPartner);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment workOrderIds ---> ' + workOrderIds);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment mapWorkOrderServiceAppointment ---> ' + mapWorkOrderServiceAppointment);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment listCapacityBasedResource ---> ' + listCapacityBasedResource);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment listErrorLogs ---> ' + listErrorLogs);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment listSuccessLogs ---> ' + listSuccessLogs);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment originPartner ---> ' + originPartner);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment destinationPartner ---> ' + destinationPartner);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment comments ---> ' + comments);
        List<AssignedResource> listAssignResourceToUpdate = new List<AssignedResource>();
        List<AssignedResource> listAssignResourceToInsert = new List<AssignedResource>();
        Map<String, String> mapIdServiceAppointmentWorkOrder = new Map<String, String>();
        for(String workOrderId : workOrderIds) {
            mapIdServiceAppointmentWorkOrder.put(mapWorkOrderServiceAppointment.get(workOrderId).Id, workOrderId);
        }

        // Manage existing Service Appointment:
        List<String> listServiceAppointmentIds = XC_UTIL_Sobject.getIds(mapWorkOrderServiceAppointment.values());
        Map<Id, AssignedResource> mapAssignResource = new Map<Id, AssignedResource>([
            SELECT Id, ServiceAppointmentId 
            FROM AssignedResource 
            WHERE ServiceAppointmentId IN :listServiceAppointmentIds AND ServiceAppointment.Status != :Label.XC_CL_ServiceAppointment_CannotComplete
        ]);
        List<String> listServiceAppointmentIdsWithAssignedResource = XC_UTIL_Sobject.getListFieldValues(mapAssignResource.values(), 'ServiceAppointmentId');
        for(AssignedResource ar : mapAssignResource.values()) {
            ar.ServiceResourceId = listCapacityBasedResource[0].Id;
            listAssignResourceToUpdate.add(ar);
        } 
        // Manage new Service Appointment:
        List<String> listWorkOrderIdsNew = new List<String>();
        for(String saId : listServiceAppointmentIds) {
            if(!listServiceAppointmentIdsWithAssignedResource.contains(saId)) {
                AssignedResource ar = new AssignedResource(
                    ServiceResourceId = listCapacityBasedResource[0].Id,
                    ServiceAppointmentId = saId
                );
                listAssignResourceToInsert.add(ar);
                listWorkOrderIdsNew.add(mapIdServiceAppointmentWorkOrder.get(saId));
            }
        }
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.scheduleServiceAppointment listWorkOrderIdsNew ---> ' + listWorkOrderIdsNew);
        // DML operation and LOG management:
        List<String> listSaIdsToRollback = new List<String>();
        if(!listAssignResourceToUpdate.isEmpty()) {
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultListAssignedResourceToUpdate = XC_UTIL_Sobject.updateListRecords(listAssignResourceToUpdate, false);
            for(XC_UTIL_Sobject.WrapperResult wr : wrapperResultListAssignedResourceToUpdate) {
                LogWrapper logWrapper = new LogWrapper();
                logWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
                logWrapper.mapWorkOrderOriginPartner = mapWorkOrderOriginPartner;
                logWrapper.originPartner = originPartner;
                logWrapper.destinationPartner = destinationPartner;
                logWrapper.comments = comments;
                if(wr.success) { 
                    AssignedResource ar = mapAssignResource.get(wr.recordId);
                    logWrapper.workOrderIds = new List<String>{mapIdServiceAppointmentWorkOrder.get(ar.ServiceAppointmentId)};
                    listSuccessLogs.addAll(populateSuccessLogs(logWrapper));
                }
                else {
                    AssignedResource ar = mapAssignResource.get(wr.errorObjectId);
                    logWrapper.workOrderIds = new List<String>{mapIdServiceAppointmentWorkOrder.get(ar.ServiceAppointmentId)};
                    logWrapper.errorMessage = wr.errorMessage;
                    listErrorLogs.addAll(populateErrorLogs(logWrapper));
                    listSaIdsToRollback.add(ar.ServiceAppointmentId);
                }
            }
        }
        if(!listSaIdsToRollback.isEmpty() && updateDueDate) {
            List<ServiceAppointment> listSaToRollback = new List<ServiceAppointment>();
            for(String idSa : listSaIdsToRollback) {
                if(mapAppointmentIdOldDueDate.containsKey(idSa)) {
                    listSaToRollback.add(new ServiceAppointment(
                        Id = idSa,
                        DueDate = mapAppointmentIdOldDueDate.get(idSa)
                    ));
                }
            }
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateListRecords(listSaToRollback);
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }

        if(!listAssignResourceToInsert.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.listAssignResourceToInsert listAssignResourceToInsert ---> ' + listAssignResourceToInsert);
            Map<Id,WorkOrder> mapIdWo = new Map<Id,WorkOrder>([SELECT Id, XC_EarliestStartPermitted__c, DurationInMinutes FROM WorkOrder WHERE Id IN: mapWorkOrderServiceAppointment.keySet()]);
            List<ServiceAppointment> listOfServiceAppointmentToUpdateScheduled = new List<ServiceAppointment>();
            for(ServiceAppointment sa : mapWorkOrderServiceAppointment.values()){
                if (sa.Status == Label.XC_CL_ServiceAppointment_None){
                    sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
                    DateTime startTime = String.isNotBlank(String.valueOf(mapIdWo.get(sa.ParentRecordId).XC_EarliestStartPermitted__c)) ? mapIdWo.get(sa.ParentRecordId).XC_EarliestStartPermitted__c : Datetime.now();
                    sa.SchedStartTime = startTime;
                    sa.SchedEndTime = startTime.addMinutes(Integer.valueOf(mapIdWo.get(sa.ParentRecordId).DurationInMinutes));
                    listOfServiceAppointmentToUpdateScheduled.add(sa);
                }
            }
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultListSAUpdate = XC_UTIL_Sobject.updateListRecords(listOfServiceAppointmentToUpdateScheduled);
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultListAssignedResourceToInsert = XC_UTIL_Sobject.insertListRecords(listAssignResourceToInsert, false);
            Boolean checkDmlInsert = XC_UTIL_Sobject.checkDMLResults(wrapperResultListAssignedResourceToInsert);
            if(checkDmlInsert) {
                for(AssignedResource ar : listAssignResourceToInsert) {
                    LogWrapper logWrapper = new LogWrapper();
                    logWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
                    logWrapper.mapWorkOrderOriginPartner = mapWorkOrderOriginPartner;
                    logWrapper.originPartner = originPartner;
                    logWrapper.destinationPartner = destinationPartner;
                    logWrapper.comments = comments;
                    logWrapper.workOrderIds = new List<String>{mapIdServiceAppointmentWorkOrder.get(ar.ServiceAppointmentId)};
                    listSuccessLogs.addAll(populateSuccessLogs(logWrapper));
                }
            } else {
                List<WorkOrder> listWorkOrderStatus = new List<WorkOrder>([
                    SELECT Id, Status
                    FROM WorkOrder
                    WHERE Id IN :listWorkOrderIdsNew 
                ]);
                if(!listWorkOrderStatus.isEmpty()) {
                    for(WorkOrder woNew : listWorkOrderStatus) {
                        LogWrapper logWrapper = new LogWrapper();
                        logWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
                        logWrapper.mapWorkOrderOriginPartner = mapWorkOrderOriginPartner;
                        logWrapper.originPartner = originPartner;
                        logWrapper.destinationPartner = destinationPartner;
                        logWrapper.comments = comments;
                        logWrapper.workOrderIds = new List<String>{woNew.Id};
                        if(woNew.Status == Label.XC_CL_WorkOrder_New) {
                            logWrapper.errorMessage = 'Impossible to assign this Work Order';
                            listErrorLogs.addAll(populateErrorLogs(logWrapper));
                        } else {
                            listSuccessLogs.addAll(populateSuccessLogs(logWrapper));
                        }
                    }
                }
            }
        }
    }

    /** 
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 24/11/2020
     * @description Method to insert error log
     * @param logWrapper - LogWrapper
    */
    public void insertErrorLog(LogWrapper logWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.insertErrorLog logWrapper ---> ' + logWrapper);
        logWrapper.workOrderIds = new List<String>{logWrapper.workOrderId};
        insertErrorLogs(logWrapper);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 24/11/2020
     * @description Method to insert success logs
     * @param logWrapper - LogWrapper 
    */
    public void insertSuccessLogs(LogWrapper logWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.insertSuccessLogs logWrapper ---> ' + logWrapper);
        if(!logWrapper.workOrderIds.isEmpty()) {
            List<XC_MassiveAssignmentWorkOrderLog__c> listMassiveAssignmentLog = new List<XC_MassiveAssignmentWorkOrderLog__c>();
            Set<String> setWorkOrderIds = new Set<String>();
            setWorkOrderIds.addAll(logWrapper.workOrderIds);
            for(String workOrderId : setWorkOrderIds) {
                if(String.isBlank(workOrderId)) {
                    continue;
                }
                XC_MassiveAssignmentWorkOrderLog__c massiveAssignmentLog = new XC_MassiveAssignmentWorkOrderLog__c();
                if(String.isNotBlank(logWrapper.originPartner)) {
                    massiveAssignmentLog.XC_OriginPartner__c = logWrapper.originPartner;
                } else if(logWrapper.mapWorkOrderOriginPartner.containsKey(workOrderId) && String.isNotBlank(logWrapper.mapWorkOrderOriginPartner.get(workOrderId))) {
                    massiveAssignmentLog.XC_OriginPartner__c = logWrapper.mapWorkOrderOriginPartner.get(workOrderId);
                }
                massiveAssignmentLog.XC_DestinationPartner__c = logWrapper.destinationPartner;
                massiveAssignmentLog.XC_ServiceAppointment__c = (logWrapper.mapWorkOrderServiceAppointment.containsKey(workOrderId)) ? logWrapper.mapWorkOrderServiceAppointment.get(workOrderId).Id : null;
                massiveAssignmentLog.XC_WorkOrder__c = workOrderId;
                massiveAssignmentLog.XC_AssignmentSuccess__c = true;
                massiveAssignmentLog.XC_Reason__c = logWrapper.comments;
                listMassiveAssignmentLog.add(massiveAssignmentLog);
            }
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultListMassiveAssignmentLog = XC_UTIL_Sobject.insertListRecords(listMassiveAssignmentLog);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 24/11/2020
     * @description Method to insert success logs
     * @param logWrapper - LogWrapper 
     * @return List<XC_MassiveAssignmentWorkOrderLog__c>
    */
    public List<XC_MassiveAssignmentWorkOrderLog__c> populateSuccessLogs(LogWrapper logWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC012_UTIL_MassiveWo.populateSuccessLogs logWrapper ---> ' + logWrapper);
        List<XC_MassiveAssignmentWorkOrderLog__c> listMassiveAssignmentLog = new List<XC_MassiveAssignmentWorkOrderLog__c>();
        if(!logWrapper.workOrderIds.isEmpty()) {
            Set<String> setWorkOrderIds = new Set<String>();
            setWorkOrderIds.addAll(logWrapper.workOrderIds);
            for(String workOrderId : setWorkOrderIds) {
                if(String.isBlank(workOrderId)) {
                    continue;
                }
                XC_MassiveAssignmentWorkOrderLog__c massiveAssignmentLog = new XC_MassiveAssignmentWorkOrderLog__c();
                if(String.isNotBlank(logWrapper.originPartner)) {
                    massiveAssignmentLog.XC_OriginPartner__c = logWrapper.originPartner;
                } else if(logWrapper.mapWorkOrderOriginPartner.containsKey(workOrderId) && String.isNotBlank(logWrapper.mapWorkOrderOriginPartner.get(workOrderId))) {
                    massiveAssignmentLog.XC_OriginPartner__c = logWrapper.mapWorkOrderOriginPartner.get(workOrderId);
                }
                massiveAssignmentLog.XC_DestinationPartner__c = logWrapper.destinationPartner;
                massiveAssignmentLog.XC_ServiceAppointment__c = (logWrapper.mapWorkOrderServiceAppointment.containsKey(workOrderId)) ? logWrapper.mapWorkOrderServiceAppointment.get(workOrderId).Id : null;
                massiveAssignmentLog.XC_WorkOrder__c = workOrderId;
                massiveAssignmentLog.XC_AssignmentSuccess__c = true;
                massiveAssignmentLog.XC_Reason__c = logWrapper.comments;
                listMassiveAssignmentLog.add(massiveAssignmentLog);
            }
        }
        return listMassiveAssignmentLog;
    }

}