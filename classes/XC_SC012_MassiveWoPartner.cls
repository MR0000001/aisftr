/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 24/11/2020
* @description XC_SC012_MassiveWoPartner – Batch used to schedule Service Appointment to Partners (capacity based service resources) automatically 
* @                                      - For Massive Assignment WorkOrder
*/

public without sharing class XC_SC012_MassiveWoPartner implements Database.Batchable<sObject>, Database.Stateful {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC012_MassiveWoPartner');
    private AutoSchedulePartnerWrapper autoscheduleWrapper = new AutoSchedulePartnerWrapper();

    //***************************************************************************************************************************** WRAPPER 

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 03/12/2020
    * @description CheckSkillWrapper - Wrapper with information about Partner's skill
    */ 
    private class CheckSkillWrapper {
        List<ServiceResourceSkill> listSkillsPartner = new List<ServiceResourceSkill>();
        Map<Id, List<SkillRequirement>> mapWorkOrderSkills = new Map<Id, List<SkillRequirement>>();
        String workOrderId = '';
        Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
        public Map<String, String> mapWorkOrderOriginPartner = new Map<String, String>();
        public Boolean checkSuccessSkill = false;
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
        public List<String> listSaCreated = new List<String>();
    } 

    //************************************************************************************************************************************* 

    //***************************************************************************************************************************** COSTRUCTOR 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Costructor with params
     * @param wrapper - AutoSchedulePartnerWrapper
    */
    public XC_SC012_MassiveWoPartner(AutoSchedulePartnerWrapper wrapper){
        this.autoscheduleWrapper.listIdWorkOrderAssignToPartner = wrapper.listIdWorkOrderAssignToPartner;
        this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician = wrapper.listIdWorkOrderAssignToTechnician;
        this.autoscheduleWrapper.originPartner = wrapper.originPartner;
        this.autoscheduleWrapper.destinationPartner = wrapper.destinationPartner;
        this.autoscheduleWrapper.updateDueDate = wrapper.updateDueDate;
        this.autoscheduleWrapper.outOfDate = wrapper.outOfDate;
        this.autoscheduleWrapper.comments = wrapper.comments;
        this.autoscheduleWrapper.skipCheckCoverage = wrapper.skipCheckCoverage;
        this.autoscheduleWrapper.listSaCreated = wrapper.listSaCreated;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Costructor without params 
    */
    public XC_SC012_MassiveWoPartner(){
        this.autoscheduleWrapper.listIdWorkOrderAssignToPartner = new List<String>();
        this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician = new List<String>();
        this.autoscheduleWrapper.originPartner = '';
        this.autoscheduleWrapper.destinationPartner = '';
        this.autoscheduleWrapper.updateDueDate = false;
        this.autoscheduleWrapper.outOfDate = false;
        this.autoscheduleWrapper.skipCheckCoverage = false;
        this.autoscheduleWrapper.listSaCreated = new List<String>();
    }

    //************************************************************************************************************************************* 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method start for batch
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
                                        'WHERE ParentRecordId IN :listIdWorkOrderAssignToPartner AND XC_Check_Final_Status__c = false ' +
                                        'ORDER BY ParentRecordId, DueDate');
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description execute
     * @param bc - BatchableContext 
     * @param scope - List<ServiceAppointment> 
    */
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {
        if(!scope.isEmpty()) {
            List<XC_MassiveAssignmentWorkOrderLog__c> listErrorLogs = new List<XC_MassiveAssignmentWorkOrderLog__c>();
            List<XC_MassiveAssignmentWorkOrderLog__c> listSuccessLogs = new List<XC_MassiveAssignmentWorkOrderLog__c>();
            XC_SC012_UTIL_MassiveWo UtilClass = new XC_SC012_UTIL_MassiveWo();

            // Split Service Appointment for Status
            XC_SC012_UTIL_MassiveWo.SplitListWrapper splitWrapper = UtilClass.splitScope(scope);
            List<ServiceAppointment> listServiceAppointmentErrorStatus = splitWrapper.listServiceAppointmentErrorStatus;
            List<ServiceAppointment> listServiceAppointmentFiltred = splitWrapper.listServiceAppointmentFiltred;            
            
            // Create util maps:
            List<String> workOrderIds = XC_UTIL_Sobject.getListFieldValues(listServiceAppointmentFiltred, 'ParentRecordId');
            Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
            for(ServiceAppointment sa : listServiceAppointmentFiltred) {
                mapWorkOrderServiceAppointment.put(sa.ParentRecordId, sa);
            }
            XC_SC012_UTIL_MassiveWo.UtilMapsWrapper utilMapWrapper = UtilClass.getUtilMap(workOrderIds);

            // Check if Partner has Manager:
            List<ServiceResource> listCapacityBasedResource = [
                SELECT Id, 
                    (SELECT SkillLevel, Skill.MasterLabel, SkillId, EffectiveStartDate, EffectiveEndDate 
                    FROM ServiceResourceSkills)
                FROM ServiceResource
                WHERE XC_Account__r.Id = :this.autoscheduleWrapper.destinationPartner AND XC_IsManager__c = true];
            if(listCapacityBasedResource.isEmpty()) {
                XC_SC012_UTIL_MassiveWo.LogWrapper logWrapper = new XC_SC012_UTIL_MassiveWo.LogWrapper();
                logWrapper.workOrderIds = workOrderIds;
                logWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
                logWrapper.originPartner = this.autoscheduleWrapper.originPartner;
                logWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
                logWrapper.errorMessage = Label.XC_CL_MassiveAssignmentWorkOrderImpossibleAssign;
                logWrapper.mapWorkOrderOriginPartner = utilMapWrapper.mapWorkOrderPartner;
                logWrapper.comments = this.autoscheduleWrapper.comments;
                UtilClass.insertErrorLogs(logWrapper);
                return;
            }
            
            // Controllo Skills and Coverages:
            // -- Data Preparation:
            List<ServiceResourceSkill> listSkillsPartner = new List<ServiceResourceSkill>();
            for(ServiceResource sr : listCapacityBasedResource) {
                listSkillsPartner.addAll(sr.ServiceResourceSkills);
            }
            Map<Id, WorkOrder> mapWorkOrdersWithSkill = utilMapWrapper.mapWorkOrdersWithSkill;
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
            // -- Check:
            for(String workOrderId : workOrderIds) {
                CheckSkillWrapper checkSkillWrapper = new CheckSkillWrapper();
                checkSkillWrapper.listSkillsPartner = listSkillsPartner;
                checkSkillWrapper.mapWorkOrderSkills = mapWorkOrderSkills;
                checkSkillWrapper.workOrderId = workOrderId;
                checkSkillWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
                checkSkillWrapper.mapWorkOrderOriginPartner = utilMapWrapper.mapWorkOrderPartner;
                checkSkill(checkSkillWrapper, listErrorLogs);
                Boolean checkedSkill = checkSkillWrapper.checkSuccessSkill;
                Boolean checkedCoverage = this.autoscheduleWrapper.skipCheckCoverage;
                if(!checkedCoverage) {
                    checkedCoverage = checkCoverage(listPcCoverage, mapWorkOrdersWithSkill.get(workOrderId), this.autoscheduleWrapper.destinationPartner);
                }
                if(checkedSkill && checkedCoverage) {
                    listWorkOrderWithSkill.add(workOrderId);
                    listSaToManage.add(mapWorkOrderServiceAppointment.get(workOrderId));
                } else {
                    listWorkOrderWithoutSkill.add(workOrderId);
                }
            }
            if(!listWorkOrderWithoutSkill.isEmpty()) {
                XC_SC012_UTIL_MassiveWo.LogWrapper logWrapper = new XC_SC012_UTIL_MassiveWo.LogWrapper();
                logWrapper.workOrderIds = listWorkOrderWithoutSkill;
                logWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
                logWrapper.originPartner = this.autoscheduleWrapper.originPartner;
                logWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
                logWrapper.errorMessage = Label.XC_CL_MassAssWoMissingSkill;
                logWrapper.mapWorkOrderOriginPartner = utilMapWrapper.mapWorkOrderPartner;
                logWrapper.comments = this.autoscheduleWrapper.comments;
                listErrorLogs.addAll(UtilClass.populateErrorLogs(logWrapper));
            }

            // Reschedule appointment:
            if(!listWorkOrderWithSkill.isEmpty()) {
                // -- Update dates Service Appointment:
                XC_SC012_UTIL_MassiveWo.UpdateDueDateWrapper uddWrapper = UtilClass.updateServiceAppointmentDueDate(listServiceAppointmentFiltred, this.autoscheduleWrapper.updateDueDate);
                Boolean updateSuccess = uddWrapper.firstUpdateSuccess;
                
                // -- Schedule Service Appointment:
                if(updateSuccess) {
                    UtilClass.scheduleServiceAppointment(this.autoscheduleWrapper.updateDueDate, uddWrapper.mapAppointmentIdOldDueDate, utilMapWrapper.mapWorkOrderPartner, listWorkOrderWithSkill, mapWorkOrderServiceAppointment, listCapacityBasedResource, listErrorLogs, listSuccessLogs, this.autoscheduleWrapper.originPartner, this.autoscheduleWrapper.destinationPartner, this.autoscheduleWrapper.comments);
                }
            }            

            // Insert Error/Success logs:
            listErrorLogs.addAll(UtilClass.insertNoMathStatusLogError(listServiceAppointmentErrorStatus, this.autoscheduleWrapper.originPartner, this.autoscheduleWrapper.destinationPartner, this.autoscheduleWrapper.comments));
            listErrorLogs.addAll(listSuccessLogs);
            XC_UTIL_Sobject.insertListRecords(listErrorLogs);
            // Rollback for Error SA:
            List<ServiceAppointment> listSaToDelete = new List<ServiceAppointment>();
            for(ServiceAppointment sa : listServiceAppointmentErrorStatus) {
                if(autoscheduleWrapper.listSaCreated.contains(sa.Id)) {
                    listSaToDelete.add(new ServiceAppointment(Id = sa.Id));
                }
            }
            XC_UTIL_Sobject.deleteListRecords(listSaToDelete);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 24/11/2020
     * @description Finish method for Batch
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        if(!this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician.isEmpty()) {
            XC_SC012_MassiveWoTech.AutoScheduleTechWrapper autoScheduleTechWrapper = new XC_SC012_MassiveWoTech.AutoScheduleTechWrapper();
            autoScheduleTechWrapper.originPartner = this.autoscheduleWrapper.originPartner;
            autoScheduleTechWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
            autoScheduleTechWrapper.updateDueDate = this.autoscheduleWrapper.updateDueDate;
            autoScheduleTechWrapper.outOfDate = this.autoscheduleWrapper.outOfDate;
            autoScheduleTechWrapper.listIdWorkOrderAssignToTechnician = this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician;
            autoScheduleTechWrapper.comments = this.autoscheduleWrapper.comments;
            autoScheduleTechWrapper.listSaCreated = this.autoscheduleWrapper.listSaCreated;
            autoScheduleTechWrapper.skipCheckCoverage = this.autoscheduleWrapper.skipCheckCoverage;
            Database.executeBatch(new XC_SC012_MassiveWoTech(autoScheduleTechWrapper), 1);
        }
    }    

    //***************************************************************************************************************************** UTIL:
    
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
    * @param listErrorLog - List<XC_MassiveAssignmentWorkOrderLog__c>
    */
    private void checkSkill(CheckSkillWrapper wrapper, List<XC_MassiveAssignmentWorkOrderLog__c> listErrorLog) {
        if(wrapper.workOrderId != null && !wrapper.mapWorkOrderSkills.containsKey(wrapper.workOrderId)) {
            wrapper.checkSuccessSkill = true;
            return;
        }
        Boolean found = XC_UTIL_Skill.checkSkills(wrapper.mapWorkOrderSkills.get(wrapper.workOrderId), wrapper.listSkillsPartner);
        if(!found) {
            XC_SC012_UTIL_MassiveWo.LogWrapper logWrapper = new XC_SC012_UTIL_MassiveWo.LogWrapper();
            logWrapper.workOrderIds = new List<String>{wrapper.workOrderId}; 
            logWrapper.mapWorkOrderServiceAppointment = wrapper.mapWorkOrderServiceAppointment;
            logWrapper.originPartner = this.autoscheduleWrapper.originPartner;
            logWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
            logWrapper.errorMessage = Label.XC_CL_MassiveAssignmentWorkOrderErrorSkill;
            logWrapper.mapWorkOrderOriginPartner = wrapper.mapWorkOrderOriginPartner;
            logWrapper.comments = this.autoscheduleWrapper.comments;
            XC_SC012_UTIL_MassiveWo UtilClass = new XC_SC012_UTIL_MassiveWo();
            listErrorLog.addAll(UtilClass.populateErrorLogs(logWrapper));
            wrapper.checkSuccessSkill = false;
            return;
        }
        wrapper.checkSuccessSkill = true;
        return;
    }

}