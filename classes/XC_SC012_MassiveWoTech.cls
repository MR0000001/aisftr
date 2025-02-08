/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 24/11/2020
* @description XC_SC012_MassiveWoTech – Batch used to schedule Service Appointment to Technicians automatically
* @                                   - For Massive Assignment WorkOrder
*/

public without sharing class XC_SC012_MassiveWoTech implements Database.Batchable<sObject>, Database.Stateful {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC012_MassiveWoTech');
    private AutoScheduleTechWrapper autoscheduleWrapper = new AutoScheduleTechWrapper();

    //***************************************************************************************************************************** WRAPPER

    /** @description AutoScheduleTechWrapper */
    public class AutoScheduleTechWrapper {
        public String originPartner = '';
        public String destinationPartner = '';
        public Boolean updateDueDate = false;
        public Boolean outOfDate = false;
        public List<String> listIdWorkOrderAssignToTechnician = new List<String>();
        public String comments = 'No comments';
        public Boolean skipCheckCoverage = false;
        public List<String> listSaCreated = new List<String>();
    }

    /** @description CheckSuccessWrapper */
    public class CheckSuccessWrapper{
        public Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
        public XC_UTIL_AutoSchedule.AutoScheduleInputWrapper inputWr;
        public Map<String, String> mapIdServiceAppointmentWorkOrder = new Map<String, String>();
        public ServiceAppointment sa = new ServiceAppointment();
    }

    //************************************************************************************************************************************* 

    //***************************************************************************************************************************** COSTRUCTOR 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Costructor with params
     * @param autoscheduleWrapper - AutoScheduleTechWrapper
    */
    public XC_SC012_MassiveWoTech(AutoScheduleTechWrapper autoscheduleWrapper){
        this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician = autoscheduleWrapper.listIdWorkOrderAssignToTechnician;
        this.autoscheduleWrapper.originPartner = autoscheduleWrapper.originPartner;
        this.autoscheduleWrapper.destinationPartner = autoscheduleWrapper.destinationPartner;
        this.autoscheduleWrapper.outOfDate = autoscheduleWrapper.outOfDate;
        this.autoscheduleWrapper.updateDueDate = autoscheduleWrapper.updateDueDate;
        this.autoscheduleWrapper.comments = autoscheduleWrapper.comments;
        this.autoscheduleWrapper.listSaCreated = autoscheduleWrapper.listSaCreated;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Costructor without params
     * @param autoscheduleWrapper - AutoScheduleTechWrapper
    */
    public XC_SC012_MassiveWoTech(){
        this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician = new List<String>();
        this.autoscheduleWrapper.originPartner = '';
        this.autoscheduleWrapper.destinationPartner = '';
        this.autoscheduleWrapper.outOfDate = false;
        this.autoscheduleWrapper.updateDueDate = false;
        this.autoscheduleWrapper.comments = '';
        this.autoscheduleWrapper.listSaCreated = new List<String>();
    }

    //************************************************************************************************************************************* 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Start method for batch
     * @param bc - BatchableContext 
     * @return Database.getQueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!Schema.sObjectType.ServiceAppointment.isAccessible()) {
            return null;
        }
        List<String> listIdWorkOrderAssignToTechnician = this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician;
        return Database.getQueryLocator('SELECT Id, ParentRecordId, ArrivalWindowEndTime, ArrivalWindowStartTime, XC_Country__c, OwnerId, XC_AssignedResource__c, SchedStartTime, SchedEndTime, Status, DueDate ' +
                                        'FROM ServiceAppointment ' +
                                        'WHERE ParentRecordId IN :listIdWorkOrderAssignToTechnician AND XC_IsFinalStatus__c = false ' +
                                        'ORDER BY ParentRecordId, DueDate'); 
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Execute method for batch
     * @param bc - BatchableContext
     * @param scope - List<ServiceAppointment> 
    */
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {
        if(!scope.isEmpty()) {
            XC_SC012_UTIL_MassiveWo UtilClass = new XC_SC012_UTIL_MassiveWo();
            List<XC_MassiveAssignmentWorkOrderLog__c> listLogs = new List<XC_MassiveAssignmentWorkOrderLog__c>();

            // Split Service Appointment for Status
            XC_SC012_UTIL_MassiveWo.SplitListWrapper splitWrapper = UtilClass.splitScope(scope);
            List<ServiceAppointment> listServiceAppointmentErrorStatus = splitWrapper.listServiceAppointmentErrorStatus;
            List<ServiceAppointment> listServiceAppointmentFiltred = splitWrapper.listServiceAppointmentFiltred; 
            
            // Create util maps:
            List<String> workOrderIds = XC_UTIL_Sobject.getListFieldValues(listServiceAppointmentFiltred, 'ParentRecordId');
            Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
            Map<String, String> mapIdServiceAppointmentWorkOrder = new Map<String, String>();
            for(ServiceAppointment sa : listServiceAppointmentFiltred) {
                mapWorkOrderServiceAppointment.put(sa.ParentRecordId, sa);
                mapIdServiceAppointmentWorkOrder.put(sa.Id, sa.ParentRecordId);
            } 
            XC_SC012_UTIL_MassiveWo.UtilMapsWrapper utilMapWrapper = UtilClass.getUtilMap(workOrderIds);
            Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>([
                SELECT Id, XC_RequiredPartnerId__c
                FROM WorkOrder
                WHERE Id IN :workOrderIds
            ]);

            // Check for Skip Coverage:
            Map<String, String> mapWorkOrderOldValueRequiredPartnerId = new Map<String, String>();
            if(this.autoscheduleWrapper.skipCheckCoverage) {
                List<WorkOrder> listWo = new List<WorkOrder>();
                for(String woId : workOrderIds) {
                    if(String.isBlank(mapWorkOrder.get(woId).XC_RequiredPartnerId__c)) {
                        mapWorkOrderOldValueRequiredPartnerId.put(woId, 'blank');
                    } else {
                        mapWorkOrderOldValueRequiredPartnerId.put(woId, mapWorkOrder.get(woId).XC_RequiredPartnerId__c);
                    }
                    listWo.add(new WorkOrder(
                        Id = woId,
                        XC_RequiredPartnerId__c = this.autoscheduleWrapper.destinationPartner
                    ));
                }
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                XC_UTIL_Sobject.updateListRecords(listWo);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            }

            // Update dates SA:
            XC_SC012_UTIL_MassiveWo.UpdateDueDateWrapper uddWrapper = UtilClass.updateServiceAppointmentDueDate(listServiceAppointmentFiltred, this.autoscheduleWrapper.updateDueDate);
            Boolean updateSuccess = uddWrapper.firstUpdateSuccess;
            List<String> listSaIdsToRollback = new List<String>();
            
            // Rischedulazione Service Appointment 
            List<ServiceAppointment> listSaToDelete = new List<ServiceAppointment>();
            if(updateSuccess) {
                for(ServiceAppointment sa : listServiceAppointmentFiltred) {
                    CheckSuccessWrapper checkWrapper = new CheckSuccessWrapper();
                    checkWrapper.inputWr = populateWrapperAutoschedule(sa);
                    checkWrapper.sa = sa;
                    checkWrapper.mapIdServiceAppointmentWorkOrder = mapIdServiceAppointmentWorkOrder;
                    checkWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
                    
                    List<XC_MassiveAssignmentWorkOrderLog__c> listResultLog = autoscheduleTech(checkWrapper, utilMapWrapper.mapWorkOrderPartner);
                    if(!listResultLog[0].XC_AssignmentSuccess__c) {
                        if(autoscheduleWrapper.listSaCreated.contains(sa.Id)) {
                            listSaToDelete.add(new ServiceAppointment(Id = sa.Id));
                        } else {
                            listSaIdsToRollback.add(sa.Id);
                        }
                    }
                    listLogs.addAll(listResultLog); 
                }
            }
            if(this.autoscheduleWrapper.updateDueDate && !listSaIdsToRollback.isEmpty()) {
                List<ServiceAppointment> listSaToRollback = new List<ServiceAppointment>();
                List<WorkOrder> listWoToRollback = new List<WorkOrder>();
                for(String idSa : listSaIdsToRollback) {
                    if(uddWrapper.mapAppointmentIdOldDueDate.containsKey(idSa)) {
                        listSaToRollback.add(new ServiceAppointment(
                            Id = idSa,
                            DueDate = uddWrapper.mapAppointmentIdOldDueDate.get(idSa)
                        ));
                        if(uddWrapper.mapAppointmentWorkOrderId.containsKey(idSa)) {
                            listWoToRollback.add(new WorkOrder(
                                Id = uddWrapper.mapAppointmentWorkOrderId.get(idSa),
                                DueDate__c = uddWrapper.mapAppointmentIdOldDueDate.get(idSa),
                                XC_DueDate__c = uddWrapper.mapAppointmentIdOldDueDate.get(idSa)
                            ));
                        }
                    }
                }
                XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                XC_UTIL_Sobject.updateListRecords(listSaToRollback);
                XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                XC_UTIL_Sobject.updateListRecords(listWoToRollback);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            }

            // Insert logs:
            if(this.autoscheduleWrapper.skipCheckCoverage) {
                List<WorkOrder> listWorkOrderToRollback = new List<WorkOrder>();
                for(XC_MassiveAssignmentWorkOrderLog__c log : listLogs) {
                    if(!log.XC_AssignmentSuccess__c && mapWorkOrderOldValueRequiredPartnerId.containsKey(log.XC_WorkOrder__c)) {
                        listWorkOrderToRollback.add(new WorkOrder(
                            Id = log.XC_WorkOrder__c,
                            XC_RequiredPartnerId__c = (mapWorkOrderOldValueRequiredPartnerId.get(log.XC_WorkOrder__c)=='blank') ? null : mapWorkOrderOldValueRequiredPartnerId.get(log.XC_WorkOrder__c)
                        ));
                    }
                }
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                XC_UTIL_Sobject.updateListRecords(listWorkOrderToRollback);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            }
            listLogs.addAll(UtilClass.insertNoMathStatusLogError(listServiceAppointmentErrorStatus, this.autoscheduleWrapper.originPartner, this.autoscheduleWrapper.destinationPartner, this.autoscheduleWrapper.comments));
            XC_UTIL_Sobject.insertListRecords(listLogs);
            XC_UTIL_Sobject.deleteListRecords(listSaToDelete);
        }
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC012_MassiveWoTech'); 
    }    

    //***************************************************************************************************************************** UTIL:

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Populate wrapper for autoschedule
     * @param sa - Service Appointment
     * @return XC_UTIL_AutoSchedule.AutoScheduleInputWrapper  
    */
    private XC_UTIL_AutoSchedule.AutoScheduleInputWrapper populateWrapperAutoschedule(ServiceAppointment sa) {
        XC_UTIL_AutoSchedule.AutoScheduleInputWrapper inputWr = new XC_UTIL_AutoSchedule.AutoScheduleInputWrapper();
        if(sa.ArrivalWindowStartTime != null && sa.ArrivalWindowEndTime != null){
            inputWr.preferredStart = sa.ArrivalWindowStartTime;
            inputWr.preferredEnd = sa.ArrivalWindowEndTime;
        } else {
            inputWr.preferredStart = sa.SchedStartTime;
            inputWr.preferredEnd = sa.SchedEndTime;  
        }   
        inputWr.serviceAppointment = sa; 
        inputWr.operatingHoursId = null; 
        inputWr.preferredPartnerId = this.autoscheduleWrapper.destinationPartner;
        if(inputWr.preferredStart < Datetime.now()) {
            inputWr.preferredStart = null;
            inputWr.preferredEnd = null; 
        }
        return inputWr;
    }   

    /**  
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Check Success
     * @param checkWrapper - CheckSuccessWrapper
     * @param mapWorkOrderPartner - Map<String, String>
     * @return List<XC_MassiveAssignmentWorkOrderLog__c>
    */ 
    private List<XC_MassiveAssignmentWorkOrderLog__c> autoscheduleTech(CheckSuccessWrapper checkWrapper, Map<String, String> mapWorkOrderPartner) {
        XC_UTIL_AutoSchedule.AutoSchedulingResult res = XC_UTIL_AutoSchedule.autoScheduleAppointmentToFixedSlot(checkWrapper.inputWr); 
        // Populate logs:
        XC_SC012_UTIL_MassiveWo.LogWrapper logWrapper = new XC_SC012_UTIL_MassiveWo.LogWrapper();
        XC_SC012_UTIL_MassiveWo UtilClass = new XC_SC012_UTIL_MassiveWo();
        logWrapper.workOrderIds = new List<String>{checkWrapper.mapIdServiceAppointmentWorkOrder.get(checkWrapper.sa.Id)};
        logWrapper.mapWorkOrderServiceAppointment = checkWrapper.mapWorkOrderServiceAppointment;
        logWrapper.originPartner = this.autoscheduleWrapper.originPartner;
        logWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
        logWrapper.comments = this.autoscheduleWrapper.comments;
        logWrapper.mapWorkOrderOriginPartner = mapWorkOrderPartner;
        if(res.success) {
            return UtilClass.populateSuccessLogs(logWrapper);
        } else {
            logWrapper.errorMessage = Label.XC_CL_MassiveAssignmentWorkErrorAssignmentTech;
            return UtilClass.populateErrorLogs(logWrapper);
        }
    }   

}