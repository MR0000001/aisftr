/**
* @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 11/04/2019
* @description XC_SC012_AutoScheduleToPartner – Batch used to automatically schedule Service Appointment to Partners (capacity based service resources)
*/

public with sharing class XC_SC012_AutoScheduleToPartner implements Database.Batchable<sObject>, Database.Stateful {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC106_MassiveAssignmentWorkOrder');
    private AutoSchedulePartnerWrapper autoscheduleWrapper = new AutoSchedulePartnerWrapper();

    /** @description CheckSkillWrapper */
    private class CheckSkillWrapper {
        List<ServiceResourceSkill> listSkillsPartner = new List<ServiceResourceSkill>();
        Map<Id, List<SkillRequirement>> mapWorkOrderSkills = new Map<Id, List<SkillRequirement>>();
        String workOrderId = '';
        Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 15/04/2019
    * @description AutoSchedulePartnerWrapper
    */ 
    public class AutoSchedulePartnerWrapper {
        public List<String> listIdWorkOrderAssignToPartner = new List<String>();
        public List<String> listIdWorkOrderAssignToTechnician = new List<String>(); 
        public String destinationPartner = '';
        public String originPartner = '';
        public Boolean updateDueDate = false;
        public Boolean outOfDate = false;
        public String comments = 'No comments';
        public Boolean skipCheckCoverage = false;
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Costructor with params
     * @param wrapper - AutoSchedulePartnerWrapper
    */
    public XC_SC012_AutoScheduleToPartner(AutoSchedulePartnerWrapper wrapper){
        this.autoscheduleWrapper.listIdWorkOrderAssignToPartner = wrapper.listIdWorkOrderAssignToPartner;
        this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician = wrapper.listIdWorkOrderAssignToTechnician;
        this.autoscheduleWrapper.originPartner = wrapper.originPartner;
        this.autoscheduleWrapper.destinationPartner = wrapper.destinationPartner;
        this.autoscheduleWrapper.updateDueDate = wrapper.updateDueDate;
        this.autoscheduleWrapper.outOfDate = wrapper.outOfDate;
        this.autoscheduleWrapper.comments = wrapper.comments;
        this.autoscheduleWrapper.skipCheckCoverage = wrapper.skipCheckCoverage;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Costructor without params 
    */
    public XC_SC012_AutoScheduleToPartner(){
        this.autoscheduleWrapper.listIdWorkOrderAssignToPartner = new List<String>();
        this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician = new List<String>();
        this.autoscheduleWrapper.originPartner = '';
        this.autoscheduleWrapper.destinationPartner = '';
        this.autoscheduleWrapper.updateDueDate = false;
        this.autoscheduleWrapper.outOfDate = false;
        this.autoscheduleWrapper.skipCheckCoverage = false;
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description start
     * @param bc - BatchableContext 
     * @return Database.getQueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!Schema.sObjectType.ServiceAppointment.isAccessible()){
            return null;
        }
        List<String> listIdWorkOrderAssignToPartner = this.autoscheduleWrapper.listIdWorkOrderAssignToPartner;
        return Database.getQueryLocator('SELECT Id, DueDate, ParentRecordId, ArrivalWindowEndTime, ArrivalWindowStartTime, XC_Country__c, OwnerId, XC_AssignedResource__c, Status, SchedStartTime, SchedEndTime ' +
                                        'FROM ServiceAppointment ' +
                                        'WHERE ParentRecordId IN :listIdWorkOrderAssignToPartner ' +
                                        'ORDER BY ParentRecordId, DueDate');
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description execute
     * @param bc - BatchableContext 
     * @param scope - List<ServiceAppointment> 
    */
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ [In XC_SC012_AutoScheduleToPartner] For List of WorkOrder to assign to Partner');
        if(!scope.isEmpty()) {
            XC_SC012_AutoSchedule_U scAU = new XC_SC012_AutoSchedule_U();
            XC_SC012_AutoSchedule_U.SplitListWrapper splitWrapper = scAU.splitScope(scope);
            List<ServiceAppointment> listServiceAppointmentErrorStatus = splitWrapper.listServiceAppointmentErrorStatus;
            List<ServiceAppointment> listServiceAppointmentFiltred = splitWrapper.listServiceAppointmentFiltred;            
            // Creazione lista workOrderId e mappa key->workOrderId, value->serviceAppointment
            List<String> workOrderIds = XC_UTIL_Sobject.getListFieldValues(listServiceAppointmentFiltred, 'ParentRecordId');
            Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
            for(ServiceAppointment sa : listServiceAppointmentFiltred) {
                mapWorkOrderServiceAppointment.put(sa.ParentRecordId, sa);
            }
            
            // Controllo Service Resource
            List<ServiceResource> listCapacityBasedResource = [
                SELECT Id, 
                    (SELECT SkillLevel, Skill.MasterLabel, SkillId, EffectiveStartDate, EffectiveEndDate 
                    FROM ServiceResourceSkills)
                FROM ServiceResource
                WHERE XC_Account__r.Id = :this.autoscheduleWrapper.destinationPartner AND XC_IsManager__c = true];
            if(listCapacityBasedResource.isEmpty()) {
                XC_SC012_AutoSchedule_U.LogWrapper logWrapper = new XC_SC012_AutoSchedule_U.LogWrapper();
                logWrapper.workOrderIds = workOrderIds;
                logWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
                if(String.isNotBlank(this.autoscheduleWrapper.originPartner)) {
                    logWrapper.originPartner = this.autoscheduleWrapper.originPartner;
                }
                logWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
                logWrapper.errorMessage = Label.XC_CL_MassiveAssignmentWorkOrderImpossibleAssign;
                insertErrorLogs(logWrapper);
                //return;
            } else {
                // Controllo skills
                List<ServiceResourceSkill> listSkillsPartner = new List<ServiceResourceSkill>();
                for(ServiceResource sr : listCapacityBasedResource) {
                    listSkillsPartner.addAll(sr.ServiceResourceSkills);
                }
                //List<String> listNameSkillPartner = XC_UTIL_Sobject.getListFieldValues(listSkillsPartner, 'MasterLabel');

                Map<Id, WorkOrder> mapWorkOrdersWithSkill = new Map<Id, WorkOrder>([
                    SELECT Id, XC_WorkTypeCategory__c, PostalCode, WorkTypeId,
                        (SELECT Id, SkillId, SkillLevel FROM SkillRequirements)
                    FROM WorkOrder  
                    WHERE Id IN :workOrderIds
                ]);
                List<WorkOrder> listWoWithSkills = mapWorkOrdersWithSkill.values();
                Map<Id, List<SkillRequirement>> mapWorkOrderSkills = new Map<Id, List<SkillRequirement>>();
                for(WorkOrder wo : listWoWithSkills){
                    if(!wo.SkillRequirements.isEmpty()){
                        mapWorkOrderSkills.put(wo.Id, wo.SkillRequirements);
                    }
                }
                List<String> listExternalIdCoverage = new List<String>();
                for(WorkOrder wo : listWoWithSkills) {
                    listExternalIdCoverage.add(this.autoscheduleWrapper.destinationPartner + '_' + wo.PostalCode + '_' + wo.WorkTypeId);
                }
                List<XC_PartnerCoverage__c> listPcCoverage = new List<XC_PartnerCoverage__c>([
                    SELECT Id, XC_ExternalIdForDuplication__c   
                    FROM XC_PartnerCoverage__c
                    WHERE XC_ExternalIdForDuplication__c IN :listExternalIdCoverage
                ]);

                List<String> listWorkOrderWithSkill = new List<String>();
                List<String> listWorkOrderWithoutSkill = new List<String>();
                List<ServiceAppointment> listSaToManage = new List<ServiceAppointment>();
                for(String workOrderId : workOrderIds) {
                    CheckSkillWrapper checkSkillWrapper = new CheckSkillWrapper();
                    checkSkillWrapper.listSkillsPartner = listSkillsPartner;
                    checkSkillWrapper.mapWorkOrderSkills = mapWorkOrderSkills;
                    checkSkillWrapper.workOrderId = workOrderId;
                    checkSkillWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
                    Boolean checkedSkill = checkSkill(checkSkillWrapper);
                    Boolean checkedCoverage = this.autoscheduleWrapper.skipCheckCoverage ? true : checkCoverage(listPcCoverage, mapWorkOrdersWithSkill.get(workOrderId), this.autoscheduleWrapper.destinationPartner);
                    if(checkedSkill && checkedCoverage) {
                        listWorkOrderWithSkill.add(workOrderId);
                        listSaToManage.add(mapWorkOrderServiceAppointment.get(workOrderId));
                    } else {
                        listWorkOrderWithoutSkill.add(workOrderId);
                    }
                }
                if(!listWorkOrderWithoutSkill.isEmpty()) {
                    XC_SC012_AutoSchedule_U.LogWrapper logWrapper = new XC_SC012_AutoSchedule_U.LogWrapper();
                    logWrapper.workOrderIds = listWorkOrderWithoutSkill;
                    logWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
                    if(String.isNotBlank(this.autoscheduleWrapper.originPartner)) {
                        logWrapper.originPartner = this.autoscheduleWrapper.originPartner;
                    }
                    logWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
                    logWrapper.errorMessage = Label.XC_CL_MassAssWoMissingSkill;
                    insertErrorLogs(logWrapper);
                }
                if(listWorkOrderWithSkill.isEmpty() && !Test.isRunningTest()) {
                    return;
                }

                // Aggiornamento Service Appointment prima della rischedulazione:
                updateServiceAppointmentDueDate(listServiceAppointmentFiltred, this.autoscheduleWrapper.updateDueDate, this.autoscheduleWrapper.outOfDate);

                // Rischedulazione Service Appointment e assegnazione risorsa
                scheduleServiceAppointment(listWorkOrderWithSkill, mapWorkOrderServiceAppointment, listCapacityBasedResource);

                scAU.insertNoMathStatusLogError(listServiceAppointmentErrorStatus, this.autoscheduleWrapper.originPartner, this.autoscheduleWrapper.destinationPartner);
            }
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to check coverage for Work order
    * @date 13/11/2020
    * @param listExistingPc - List<XC_PartnerCoverage__c>
    * @param wo - WorkOrder
    * @param destinationPartner - String
    * @return Boolean
    */
    private Boolean checkCoverage(List<XC_PartnerCoverage__c> listExistingPc, WorkOrder wo, String destinationPartner) {
        for(XC_PartnerCoverage__c pc : listExistingPc) {
            if(pc.XC_ExternalIdForDuplication__c == destinationPartner+'_'+wo.PostalCode+'_'+wo.WorkTypeId) {
                return true;
            }
        }
        return false;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to check skill for Work order
    * @date 16/07/2019
    * @param wrapper - CheckSkillWrapper
    * @return Boolean
    */
    private Boolean checkSkill(CheckSkillWrapper wrapper) {
        if(wrapper.workOrderId != null && !wrapper.mapWorkOrderSkills.containsKey(wrapper.workOrderId)) {
            return true;
        }
        Boolean found = XC_UTIL_Skill.checkSkills(wrapper.mapWorkOrderSkills.get(wrapper.workOrderId), wrapper.listSkillsPartner);
        if(!found) {
            XC_SC012_AutoSchedule_U.LogWrapper logWrapper = new XC_SC012_AutoSchedule_U.LogWrapper();
            logWrapper.workOrderId = wrapper.workOrderId;
            logWrapper.mapWorkOrderServiceAppointment = wrapper.mapWorkOrderServiceAppointment;
            if(String.isNotBlank(this.autoscheduleWrapper.originPartner)) {
                logWrapper.originPartner = this.autoscheduleWrapper.originPartner;
            }
            logWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
            logWrapper.errorMessage = Label.XC_CL_MassiveAssignmentWorkOrderErrorSkill;
            insertErrorLog(logWrapper);
            return false;
        }
        return true;
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description finish
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Finish XC_SC012_AutoScheduleToPartner!');
        if(!this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician.isEmpty()) {
            XC_SC012_AutoScheduleToTechnician.AutoScheduleTechWrapper autoScheduleTechWrapper = new XC_SC012_AutoScheduleToTechnician.AutoScheduleTechWrapper();
            if(String.isNotBlank(this.autoscheduleWrapper.originPartner)) {
                autoScheduleTechWrapper.originPartner = this.autoscheduleWrapper.originPartner;
            }
            autoScheduleTechWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
            autoScheduleTechWrapper.updateDueDate = this.autoscheduleWrapper.updateDueDate;
            autoScheduleTechWrapper.outOfDate = this.autoscheduleWrapper.outOfDate;
            autoScheduleTechWrapper.listIdWorkOrderAssignToTechnician = this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician;
            autoScheduleTechWrapper.comments = this.autoscheduleWrapper.comments;
            Id batchId = Database.executeBatch(new XC_SC012_AutoScheduleToTechnician(autoScheduleTechWrapper), 1);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC012_AutoScheduleToTechnician ID ' + batchId); 
        }
    }    

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 14/05/2019
     * @description Method to update Service Appointment 
     * @param listServiceAppointmentByWorkOrderToUpdate - List<ServiceAppointment>
     * @param updateDueDate - Boolean
     * @param outOfDate - Boolean
    */
    public static void updateServiceAppointmentDueDate(List<ServiceAppointment> listServiceAppointmentByWorkOrderToUpdate, Boolean updateDueDate, Boolean outOfDate) {
        List<ServiceAppointment> listServiceAppointmentToUpdateForDueDate = new List<ServiceAppointment>();
        List<WorkOrder> listWoDueDateToUpdate = new List<WorkOrder>();
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        XC_CM_ServiceAppointment_Default_Value__mdt saCM  = [SELECT XC_DaysForUpdateDueDate__c FROM XC_CM_ServiceAppointment_Default_Value__mdt LIMIT 1];
        for(ServiceAppointment sa : listServiceAppointmentByWorkOrderToUpdate) {
            ServiceAppointment saToUpdate = new ServiceAppointment();
            saToUpdate.Id = sa.Id;
            //if(updateDueDate && outOfDate) {
                saToUpdate.DueDate = Datetime.Now().addDays(Integer.valueOf(saCM.XC_DaysForUpdateDueDate__c));
            //}
            saToUpdate.FSL__Pinned__c = false;
            listServiceAppointmentToUpdateForDueDate.add(saToUpdate);
            listWoDueDateToUpdate.add(new WorkOrder(
                Id = sa.ParentRecordId,
                DueDate__c = saToUpdate.DueDate, 
                XC_DueDate__c = saToUpdate.DueDate
            ));
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
        for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC012_AutoScheduleToPartner';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Update Due Date';
                bel.XC_RecordId__c = wr.errorObjectId;
                errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog);
    }
 
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 15/05/2019
     * @description Method to schedule service appointment
     * @param workOrderIds - List<Id>
     * @param mapWorkOrderServiceAppointment - Map<String, ServiceAppointment>
     * @param listCapacityBasedResource - List<ServiceResource>
    */
    private void scheduleServiceAppointment(List<String> workOrderIds, Map<String, ServiceAppointment> mapWorkOrderServiceAppointment, List<ServiceResource> listCapacityBasedResource) {
        //List<ServiceAppointment> listServiceAppointmentToUpdate = new List<ServiceAppointment>();
        List<AssignedResource> listAssignResourceToUpdate = new List<AssignedResource>();
        List<AssignedResource> listAssignResourceToInsert = new List<AssignedResource>();
        Map<String, String> mapIdServiceAppointmentWorkOrder = new Map<String, String>();
        for(String workOrderId : workOrderIds) {
            mapIdServiceAppointmentWorkOrder.put(mapWorkOrderServiceAppointment.get(workOrderId).Id, workOrderId);
        }

        List<String> listServiceAppointmentIds = XC_UTIL_Sobject.getIds(mapWorkOrderServiceAppointment.values());
 
        Map<Id, AssignedResource> mapAssignResource = new Map<Id, AssignedResource>([
            SELECT Id, ServiceAppointmentId 
            FROM AssignedResource 
            WHERE ServiceAppointmentId IN :listServiceAppointmentIds
        ]);
        List<String> listServiceAppointmentIdsWithAssignedResource = XC_UTIL_Sobject.getListFieldValues(mapAssignResource.values(), 'ServiceAppointmentId');

        for(AssignedResource ar : mapAssignResource.values()) {
            ar.ServiceResourceId = listCapacityBasedResource[0].Id;
            listAssignResourceToUpdate.add(ar);
        } 

        for(String saId : listServiceAppointmentIds) {
            if(!listServiceAppointmentIdsWithAssignedResource.contains(saId)) {
                AssignedResource ar = new AssignedResource(
                    ServiceResourceId = listCapacityBasedResource[0].Id,
                    ServiceAppointmentId = saId
                );
                listAssignResourceToInsert.add(ar);
            }
        }

        /*if(listAssignResourceToUpdate.isEmpty()) {
            XC_SC012_AutoSchedule_U.LogWrapper logWrapper = new XC_SC012_AutoSchedule_U.LogWrapper();
            logWrapper.workOrderIds = workOrderIds;
            logWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
            logWrapper.originPartner = this.autoscheduleWrapper.originPartner;
            logWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
            logWrapper.errorMessage = Label.XC_CL_MassiveAssignmentWorkErrorResource;
            logWrapper.comments = this.autoscheduleWrapper.comments;
            insertErrorLogs(logWrapper);
            return;
        }*/

        List<XC_UTIL_Sobject.WrapperResult> wrapperResultListAssignedResourceToUpdate = XC_UTIL_Sobject.updateListRecords(listAssignResourceToUpdate);
        for(XC_UTIL_Sobject.WrapperResult wr : wrapperResultListAssignedResourceToUpdate) {
            XC_UTIL_Debug.debug(true, '@@@ Wrapper Result Update Assigned Resource ---> ' + wr.errorMessage);
            XC_SC012_AutoSchedule_U.LogWrapper logWrapper = new XC_SC012_AutoSchedule_U.LogWrapper();
            logWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
            if(String.isNotBlank(this.autoscheduleWrapper.originPartner)) {
                logWrapper.originPartner = this.autoscheduleWrapper.originPartner;
            }
            logWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
            logWrapper.comments = this.autoscheduleWrapper.comments;
            if(wr.success) { 
                AssignedResource ar = mapAssignResource.get(wr.recordId);
                logWrapper.workOrderId = mapIdServiceAppointmentWorkOrder.get(ar.ServiceAppointmentId);
                insertSuccessLog(logWrapper);
            }
            else {
                AssignedResource ar = mapAssignResource.get(wr.errorObjectId);
                logWrapper.workOrderId = mapIdServiceAppointmentWorkOrder.get(ar.ServiceAppointmentId);
                logWrapper.errorMessage = wr.errorMessage;
                insertErrorLog(logWrapper);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultListAssignedResourceToInsert = XC_UTIL_Sobject.insertListRecords(listAssignResourceToInsert);
        Boolean checkDmlInsert = XC_UTIL_Sobject.checkDMLResults(wrapperResultListAssignedResourceToInsert);
        for(AssignedResource ar : listAssignResourceToInsert) {
            XC_SC012_AutoSchedule_U.LogWrapper logWrapper = new XC_SC012_AutoSchedule_U.LogWrapper();
            logWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
            if(String.isNotBlank(this.autoscheduleWrapper.originPartner)) {
                logWrapper.originPartner = this.autoscheduleWrapper.originPartner;
            }
            logWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
            logWrapper.comments = this.autoscheduleWrapper.comments;
            if(checkDmlInsert) { 
                logWrapper.workOrderId = mapIdServiceAppointmentWorkOrder.get(ar.ServiceAppointmentId);
                insertSuccessLog(logWrapper);
            }
            else {
                logWrapper.workOrderId = mapIdServiceAppointmentWorkOrder.get(ar.ServiceAppointmentId);
                logWrapper.errorMessage = wrapperResultListAssignedResourceToInsert[0].errorMessage;
                insertErrorLog(logWrapper);
            }
        }

        /*for(Id workOrderId : workOrderIds) {
            ServiceAppointment serviceAppointmentToUpdate = new ServiceAppointment();
            AssignedResource assigneResourceToInsert = new AssignedResource();
            serviceAppointmentToUpdate.Status = 'None';
            serviceAppointmentToUpdate.SchedStartTime = mapWorkOrderServiceAppointment.get(workOrderId).SchedStartTime;
            serviceAppointmentToUpdate.SchedEndTime = mapWorkOrderServiceAppointment.get(workOrderId).SchedEndTime;
            assigneResourceToInsert.ServiceAppointmentId = mapWorkOrderServiceAppointment.get(workOrderId).Id;
            assigneResourceToInsert.ServiceResourceId = listCapacityBasedResource[0].Id;
            listServiceAppointmentToUpdate.add(serviceAppointmentToUpdate);
            listAssignResourceToInsert.add(assigneResourceToInsert);
            mapIdServiceAppointmentWorkOrder.put(mapWorkOrderServiceAppointment.get(workOrderId).Id, workOrderId);
        }
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultListServiceAppointmentToUpdate = XC_UTIL_Sobject.updateListRecords(listServiceAppointmentToUpdate);
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultListAssignResourceToInsert = XC_UTIL_Sobject.insertListRecords(listAssignResourceToInsert);
 
        for(XC_UTIL_Sobject.WrapperResult wr : wrapperResultListAssignResourceToInsert) {
            XC_UTIL_Debug.debug(true, '@@@ Wrapper Result Update Assigned Resource ---> ' + wr.errorMessage);
            if(wr.success) {
                insertSuccessLog(mapIdServiceAppointmentWorkOrder.get(wr.recordId), mapWorkOrderServiceAppointment);
            }
            else {
                insertErrorLog(wr.errorMessage, mapIdServiceAppointmentWorkOrder.get(wr.recordId), mapWorkOrderServiceAppointment);
            } 
        }*/
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 15/05/2019
     * @description Method to insert error logs
     * @param logWrapper - LogWrapper
    */
    public void insertErrorLogs(XC_SC012_AutoSchedule_U.LogWrapper logWrapper) {
        if(!logWrapper.workOrderIds.isEmpty()) { 
            List<XC_MassiveAssignmentWorkOrderLog__c> listMassiveAssignmentLog = new List<XC_MassiveAssignmentWorkOrderLog__c>();
            Set<String> setWorkOrderIds = new Set<String>();
            setWorkOrderIds.addAll(logWrapper.workOrderIds);
            for(String workOrderId : setWorkOrderIds) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error for Massive Assignment Work Order. Insert to Log (Work Order \'' + workOrderId + '\')'); 
                XC_MassiveAssignmentWorkOrderLog__c massiveAssignmentLog = new XC_MassiveAssignmentWorkOrderLog__c();
                if(String.isNotBlank(logWrapper.originPartner)) {
                    massiveAssignmentLog.XC_OriginPartner__c = logWrapper.originPartner;
                }
                massiveAssignmentLog.XC_DestinationPartner__c = logWrapper.destinationPartner;
                massiveAssignmentLog.XC_ServiceAppointment__c = logWrapper.mapWorkOrderServiceAppointment.get(workOrderId).Id;
                massiveAssignmentLog.XC_WorkOrder__c = workOrderId;
                massiveAssignmentLog.XC_AssignmentMessage__c = logWrapper.errorMessage;
                massiveAssignmentLog.XC_AssignmentSuccess__c = false;
                massiveAssignmentLog.XC_Reason__c = logWrapper.comments;
                listMassiveAssignmentLog.add(massiveAssignmentLog);
            }
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultListMassiveAssignmentLog = XC_UTIL_Sobject.insertListRecords(listMassiveAssignmentLog);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrapperResultListMassiveAssignmentLog ---> ' + wrapperResultListMassiveAssignmentLog);
        }
    }

    /** 
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 15/05/2019
     * @description Method to insert error log
     * @param logWrapper - LogWrapper
    */
    public void insertErrorLog(XC_SC012_AutoSchedule_U.LogWrapper logWrapper) {
        logWrapper.workOrderIds = new List<String>{logWrapper.workOrderId};
        insertErrorLogs(logWrapper);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 15/05/2019
     * @description Method to insert success logs
     * @param logWrapper - LogWrapper 
    */
    public void insertSuccessLogs(XC_SC012_AutoSchedule_U.LogWrapper logWrapper) {
        if(!logWrapper.workOrderIds.isEmpty()) {
            List<XC_MassiveAssignmentWorkOrderLog__c> listMassiveAssignmentLog = new List<XC_MassiveAssignmentWorkOrderLog__c>();
            Set<String> setWorkOrderIds = new Set<String>();
            setWorkOrderIds.addAll(logWrapper.workOrderIds);
            for(Id workOrderId : setWorkOrderIds) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Success for Massive Assignment Work Order. Insert to Log (Work Order \'' + workOrderId + '\')'); 
                XC_MassiveAssignmentWorkOrderLog__c massiveAssignmentLog = new XC_MassiveAssignmentWorkOrderLog__c();
                if(String.isNotBlank(logWrapper.originPartner)) {
                    massiveAssignmentLog.XC_OriginPartner__c = logWrapper.originPartner;
                }
                massiveAssignmentLog.XC_DestinationPartner__c = logWrapper.destinationPartner;
                massiveAssignmentLog.XC_ServiceAppointment__c = (logWrapper.mapWorkOrderServiceAppointment.containsKey(workOrderId)) ? logWrapper.mapWorkOrderServiceAppointment.get(workOrderId).Id : null;
                massiveAssignmentLog.XC_WorkOrder__c = workOrderId;
                massiveAssignmentLog.XC_AssignmentSuccess__c = true;
                massiveAssignmentLog.XC_Reason__c = logWrapper.comments;
                listMassiveAssignmentLog.add(massiveAssignmentLog);
            }
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultListMassiveAssignmentLog = XC_UTIL_Sobject.insertListRecords(listMassiveAssignmentLog);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrapperResultListMassiveAssignmentLog ---> ' + wrapperResultListMassiveAssignmentLog);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 15/05/2019
     * @description Method to insert success log
     * @param logWrapper - LogWrapper
    */
    public void insertSuccessLog(XC_SC012_AutoSchedule_U.LogWrapper logWrapper) {
        logWrapper.workOrderIds = new List<String>{logWrapper.workOrderId};
        insertSuccessLogs(logWrapper);
    }

}