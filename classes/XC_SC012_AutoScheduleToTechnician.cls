/**
* @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 11/04/2019
* @description XC_SC012_AutoScheduleToTechnician – Batch used to automatically schedule Service Appointment to Partners (capacity based service resources)
*/

public with sharing class XC_SC012_AutoScheduleToTechnician implements Database.Batchable<sObject>, Database.Stateful {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC106_MassiveAssignmentWorkOrder'); 
    private AutoScheduleTechWrapper autoscheduleWrapper = new AutoScheduleTechWrapper();

    /** @description AutoScheduleTechWrapper */
    public class AutoScheduleTechWrapper {
        public String originPartner = '';
        public String destinationPartner = '';
        public Boolean updateDueDate = false;
        public Boolean outOfDate = false;
        public List<String> listIdWorkOrderAssignToTechnician = new List<String>();
        public String comments = 'No comments';
    }

    /** @description CheckSuccessWrapper */
    public class CheckSuccessWrapper{
        public Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
        public XC_UTIL_AutoSchedule.AutoScheduleInputWrapper inputWr;
        public Map<String, String> mapIdServiceAppointmentWorkOrder = new Map<String, String>();
        public ServiceAppointment sa = new ServiceAppointment();
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Costructor
     * @param autoscheduleWrapper - AutoScheduleTechWrapper
    */
    public XC_SC012_AutoScheduleToTechnician(AutoScheduleTechWrapper autoscheduleWrapper){
        this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician = autoscheduleWrapper.listIdWorkOrderAssignToTechnician;
        this.autoscheduleWrapper.originPartner = autoscheduleWrapper.originPartner;
        this.autoscheduleWrapper.destinationPartner = autoscheduleWrapper.destinationPartner;
        this.autoscheduleWrapper.outOfDate = autoscheduleWrapper.outOfDate;
        this.autoscheduleWrapper.updateDueDate = autoscheduleWrapper.updateDueDate;
        this.autoscheduleWrapper.comments = autoscheduleWrapper.comments;
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description start
     * @param bc - BatchableContext 
     * @return Database.getQueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!Schema.sObjectType.ServiceAppointment.isAccessible()) {
            return null;
        }
        List<String> listIdWorkOrderAssignToTechnician = this.autoscheduleWrapper.listIdWorkOrderAssignToTechnician;
        return Database.getQueryLocator('SELECT Id, ParentRecordId, ArrivalWindowEndTime, ArrivalWindowStartTime, XC_Country__c, OwnerId, XC_AssignedResource__c, SchedStartTime, SchedEndTime, Status ' +
                                        'FROM ServiceAppointment ' +
                                        'WHERE ParentRecordId IN :listIdWorkOrderAssignToTechnician ' +
                                        /*'AND (Status = :labelScheduled OR ' +
                                            'Status = :labelDispatched OR ' +
                                            'Status = :labelOnHold) ' +*/
                                        'ORDER BY ParentRecordId, DueDate'); 
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description execute
     * @param bc - BatchableContext
     * @param scope - List<ServiceAppointment> 
    */
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ [In XC_SC012_AutoScheduleToTechnician] For List of WorkOrder to assign to Technician');
        if(!scope.isEmpty()) {
            XC_SC012_AutoSchedule_U scAU = new XC_SC012_AutoSchedule_U();
            XC_SC012_AutoSchedule_U.SplitListWrapper splitWrapper = scAU.splitScope(scope);
            List<ServiceAppointment> listServiceAppointmentErrorStatus = splitWrapper.listServiceAppointmentErrorStatus;
            List<ServiceAppointment> listServiceAppointmentFiltred = splitWrapper.listServiceAppointmentFiltred;         

            // Creazione lista workOrderId e mappa key->workOrderId, value->serviceAppointment
            Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
            Map<String, String> mapIdServiceAppointmentWorkOrder = new Map<String, String>();
            for(ServiceAppointment sa : listServiceAppointmentFiltred) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Service Appointment --> ' + sa.Id); 
                mapWorkOrderServiceAppointment.put(sa.ParentRecordId, sa);
                mapIdServiceAppointmentWorkOrder.put(sa.Id, sa.ParentRecordId);
            } 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapWorkOrderServiceAppointment --> ' + mapWorkOrderServiceAppointment); 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapIdServiceAppointmentWorkOrder --> ' + mapIdServiceAppointmentWorkOrder); 
            
            // Aggiornamento Service Appointment prima della rischedulazione:
            XC_SC012_AutoScheduleToPartner.updateServiceAppointmentDueDate(listServiceAppointmentFiltred, this.autoscheduleWrapper.updateDueDate, this.autoscheduleWrapper.outOfDate);
            
            // Rischedulazione Service Appointment 
            for(ServiceAppointment sa : listServiceAppointmentFiltred) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Service Appointment --> ' + sa.Id); 
                CheckSuccessWrapper checkWrapper = new CheckSuccessWrapper();
                checkWrapper.inputWr = populateInputWrapper(sa);
                checkWrapper.sa = sa;
                checkWrapper.mapIdServiceAppointmentWorkOrder = mapIdServiceAppointmentWorkOrder;
                checkWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkWrapper --> ' + checkWrapper); 
                if(!Test.isRunningTest()) {
                    checkSuccess(checkWrapper);
                } else {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Run in Testing mode'); 
                } 
            }

            scAU.insertNoMathStatusLogError(listServiceAppointmentErrorStatus, this.autoscheduleWrapper.originPartner, this.autoscheduleWrapper.destinationPartner);
        }
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description finish
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC012_AutoScheduleToTechnician'); 
    }    

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Populate AutoScheduleInputWrapper
     * @param sa - Service Appointment
     * @return XC_UTIL_AutoSchedule.AutoScheduleInputWrapper  
    */
    private XC_UTIL_AutoSchedule.AutoScheduleInputWrapper populateInputWrapper(ServiceAppointment sa) {
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
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ inputWr --> ' + inputWr); 
        return inputWr;
    }   

    /**  
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Check Success
     * @param checkWrapper 
    */ 
    private void checkSuccess(CheckSuccessWrapper checkWrapper) {
        XC_UTIL_AutoSchedule.AutoSchedulingResult res = XC_UTIL_AutoSchedule.autoScheduleAppointmentToFixedSlot(checkWrapper.inputWr); 
        insertLog(res, checkWrapper);
    }   
    
    @TestVisible
    private void insertLog(XC_UTIL_AutoSchedule.AutoSchedulingResult res, CheckSuccessWrapper checkWrapper){
        XC_SC012_AutoScheduleToPartner scAP = new XC_SC012_AutoScheduleToPartner();
        XC_SC012_AutoSchedule_U.LogWrapper logWrapper = new XC_SC012_AutoSchedule_U.LogWrapper();
        logWrapper.workOrderId = checkWrapper.mapIdServiceAppointmentWorkOrder.get(checkWrapper.sa.Id);
        logWrapper.mapWorkOrderServiceAppointment = checkWrapper.mapWorkOrderServiceAppointment;
        logWrapper.originPartner = this.autoscheduleWrapper.originPartner;
        logWrapper.destinationPartner = this.autoscheduleWrapper.destinationPartner;
        logWrapper.comments = this.autoscheduleWrapper.comments;
        if(res.success) {
            scAP.insertSuccessLog(logWrapper);
        } else {
            logWrapper.errorMessage = Label.XC_CL_MassiveAssignmentWorkErrorAssignmentTech;
            scAP.insertErrorLog(logWrapper);
        }
    }
}