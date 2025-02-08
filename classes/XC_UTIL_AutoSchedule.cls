/**
 * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 28/02/2019
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_AutoSchedule – Util class for auto-scheduling Service Appointments
**/

public without sharing class XC_UTIL_AutoSchedule {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_AutoSchedule');

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @author Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
    * @description Wrapper classes to manage Autoschedule appointment results 
    **/
    public class AutoSchedulingResult { 
        public Boolean success = false;
        public String message = '';
        public ServiceAppointment scheduledAppointment = new ServiceAppointment();
        public ServiceResource assignedResource = new ServiceResource();
    }

    /**
     * @description Wrapper classes to manage Autoschedule appointment input 
    **/
    public class AutoScheduleInputWrapper {
        public ServiceAppointment serviceAppointment; 
        public DateTime preferredStart; 
        public DateTime preferredEnd;
        public Id operatingHoursId;
        public String preferredPartnerId = '';
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
     * @author Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
     * @description Autoschedule an appointment in a fixed slot
     * @param inputWr - AutoScheduleInputWrapper 
     * @return AutoSchedulingResult
    **/
    public static AutoSchedulingResult autoScheduleAppointmentToFixedSlot(AutoScheduleInputWrapper inputWr) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In method autoScheduleAppointmentToFixedSlot');
        ServiceAppointment serviceAppointment = inputWr.serviceAppointment;
        DateTime preferredStart = inputWr.preferredStart;
        DateTime preferredEnd = inputWr.preferredEnd;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ serviceAppointment ---> ' + serviceAppointment);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ preferredStart ---> ' + preferredStart);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ preferredEnd ---> ' + preferredEnd);
        AutoSchedulingResult result = new AutoSchedulingResult();
        System.Savepoint beforeUpdateSavepoint = Database.setSavepoint();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@FSL preferredStart->' + preferredStart);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@FSL preferredEnd->' + preferredEnd);

        if(String.isNotBlank(inputWr.preferredPartnerId)) {
            XC_UTIL_ResourcePreference.removeRequiredResourcePreferences(new List<WorkOrder>{new WorkOrder(Id = inputWr.serviceAppointment.ParentRecordId)});
            List<ServiceResource> listSr = new List<ServiceResource>([
                SELECT Id     
                FROM ServiceResource   
                WHERE AccountId = :inputWr.preferredPartnerId
            ]);
            Set<Id> setIdServiceResource = XC_UTIL_Sobject.getSetIds(listSr);
            Map<Id, Set<Id>> mapWorkOrderListServiceResources = new Map<Id, Set<Id>>{
                inputWr.serviceAppointment.ParentRecordId => setIdServiceResource
            };
            XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(mapWorkOrderListServiceResources);
        }

        if(serviceAppointment.ArrivalWindowEndTime != preferredEnd || serviceAppointment.ArrivalWindowStartTime != preferredStart){
            serviceAppointment.ArrivalWindowEndTime = preferredEnd;
            serviceAppointment.ArrivalWindowStartTime = preferredStart;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ serviceAppointment ---> ' + serviceAppointment);
            XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.updateRecord(serviceAppointment);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ dmlResult ---> ' + dmlResult);
            if (!dmlResult.success) { 
                Database.rollback(beforeUpdateSavepoint); 
            }            
        }

        List<XC_CM_Scheduling_Default_Value__mdt> metaD = XC_UTIL_Schedule_D.getMetadata(serviceAppointment.XC_Country__c);
        FSL__Scheduling_Policy__c policy = XC_UTIL_Schedule_D.getPolicy(metaD[0].XC_Policy_Name__c);
        FSL.ScheduleResult scheduleResult = FSL.ScheduleService.Schedule(policy.Id, serviceAppointment.Id);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ metaD ---> ' + metaD);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ policy ---> ' + policy);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ scheduleResult ---> ' + scheduleResult);

        if(scheduleResult == null) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In null case');
            result.message = Label.XC_CL_Schedule_FailedScheduling;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Database rollback with message ---> ' + result.message);
            Database.rollback(beforeUpdateSavepoint);
        } else {
            result.scheduledAppointment = scheduleResult.Service;
            result.assignedResource = scheduleResult.Resource;
            result.success = true;
            return result;
        }
        
        return result;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
     * @author Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
     * @description Autoschedule appointment
     * @param serviceAppointment - ServiceAppointment
     * @return AutoSchedulingResult
     **/
    public static AutoSchedulingResult autoScheduleAppointment(ServiceAppointment serviceAppointment) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start autoschedule Service Appointment');
        AutoScheduleInputWrapper inputWr = new AutoScheduleInputWrapper();
        inputWr.serviceAppointment = serviceAppointment;
        inputWr.preferredStart = null;
        inputWr.preferredEnd = null;
        inputWr.operatingHoursId = null;  
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ inputWr ---> ' + inputWr);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End autoschedule Service Appointment');
        return autoscheduleAppointment(inputWr); 
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
     * @author Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
     * @description Autoschedule appointment
     * @param inputWr - AutoScheduleInputWrapper
     * @return AutoSchedulingResult
     **/

    public static AutoSchedulingResult autoScheduleAppointment(AutoScheduleInputWrapper inputWr) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In autoschedule Service Appointment');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ inputWr ---> ' + inputWr);
        ServiceAppointment serviceAppointment = inputWr.serviceAppointment;
        DateTime preferredStart = inputWr.preferredStart;
        DateTime preferredEnd = inputWr.preferredEnd;
        Id operatingHoursId = inputWr.operatingHoursId; 

        AutoSchedulingResult result = new AutoSchedulingResult();
        System.Savepoint beforeUpdateSavepoint = Database.setSavepoint();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@FSL preferredStart->' + preferredStart);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@FSL preferredEnd->' + preferredEnd);
        if(serviceAppointment.ArrivalWindowEndTime != preferredEnd || serviceAppointment.ArrivalWindowStartTime != preferredStart){
            serviceAppointment.ArrivalWindowEndTime = preferredEnd;
            serviceAppointment.ArrivalWindowStartTime = preferredStart;
            XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.updateRecord(serviceAppointment);
            if (!dmlResult.success) {
                Database.rollback(beforeUpdateSavepoint);
            }            
        }
        List<XC_CM_Scheduling_Default_Value__mdt> metaD = XC_UTIL_Schedule_D.getMetadata(serviceAppointment.XC_Country__c);
        String policyName = 'X-Customer';
        String operatingHoursName = 'Gold Appointments Calendar';
        if(!metaD.isEmpty()){
            policyName = metaD[0].XC_Policy_Name__c;
            operatingHoursName = metaD[0].XC_Operating_Hours_Name__c;
        }
        FSL__Scheduling_Policy__c policy = XC_UTIL_Schedule_D.getPolicy(policyName);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@metaD' + metaD);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@policy' + policy);

        OperatingHours operatingHours = XC_UTIL_Schedule_D.getOperatingHours(operatingHoursId, operatingHoursName);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@operatingHours' + operatingHours);
        TimeZone timeZone = UserInfo.getTimeZone();
        List<FSL.AppointmentBookingSlot> slotsFSL = new List<FSL.AppointmentBookingSlot>();
        if(!Test.isRunningTest()) {
            slotsFSL = FSL.AppointmentBookingService.GetSlots(serviceAppointment.Id, policy.Id, operatingHours, timezone, false);
        }
        if(!slotsFSL.isEmpty() || Test.isRunningTest()) {
            Datetime timeslotBegin = System.now();
            Datetime timeslotFinish = System.now().addHours(2); 
            if(!Test.isRunningTest()) {
                timeslotBegin = slotsFSL[0].Interval.start;
                timeslotFinish = slotsFSL[0].Interval.finish;
            } 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@timeslotBegin' + timeslotBegin);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@timeslotFinish' + timeslotFinish);
            timeslotBegin = timeslotBegin.addSeconds(timezone.getOffset(timeslotBegin) / -1000);
            timeslotFinish = timeslotFinish.addSeconds(timezone.getOffset(timeslotFinish) / -1000); 
            serviceAppointment.ArrivalWindowStartTime = timeslotBegin;
            serviceAppointment.ArrivalWindowEndTime = timeslotFinish;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@serviceAppointment' + serviceAppointment);
            XC_UTIL_Sobject.WrapperResult updateResult = XC_UTIL_Sobject.updateRecord(serviceAppointment);
            if (!updateResult.success) {
                Database.rollback(beforeUpdateSavepoint);
            }

            FSL.ScheduleResult scheduleResult = FSL.ScheduleService.Schedule(policy.Id, serviceAppointment.Id);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@scheduleResult' + scheduleResult);

            if(scheduleResult == null) {
                result.message = Label.XC_CL_Schedule_FailedScheduling; 
                Database.rollback(beforeUpdateSavepoint);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@scheduleResult' + scheduleResult);
            } else {
                result.scheduledAppointment = scheduleResult.Service;
                result.assignedResource = scheduleResult.Resource;
                result.success = true;
                return result;
            }
        } else {
            result.message = Label.XC_CL_Schedule_NoSlot;
            Database.rollback(beforeUpdateSavepoint);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ End autoschedule Service Appointment');
        return result;
    }

}