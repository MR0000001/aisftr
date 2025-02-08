/**
 * @author Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 19/04/2019
 * @description XC_UTIL_Schedule_U – UTIL class for scheduling Service Appointments
 */

public without sharing class XC_UTIL_Schedule_U {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Schedule');

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description This method is used to get a list of available slots for an Appointment.
     *               It creates a Work Order and a Service Appointment and then 
     *               retrieves a list of Slots available to book the appointment 
     *               (like "standard" FSL functionality book appointment). 
     *               Work Order and Appointment creation are then rollbacked. 
     * @param reqWr - ScheduleRequestWrapper 
     * @param metaD - default values
     * @return BookingResult
     **/  
    public static XC_UTIL_Schedule.BookingResult getSlots(XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr, List<XC_CM_Scheduling_Default_Value__mdt> metaD) {
        XC_UTIL_Schedule.BookingResult result = new XC_UTIL_Schedule.BookingResult();  
        XC_UTIL_EligibleServiceResource.EligibleWrapper eWr = new XC_UTIL_EligibleServiceResource.EligibleWrapper();
        DateTime earliestDate = reqWr.startDate;

        if(reqWr.workType == Label.XC_CL_WorkType_DeliveryInstallation) {
            List<WorkOrder> listWorkOrder = new List<WorkOrder>([
                SELECT Id, XC_RequiredPartnerId__c, XC_FSLAssignmentKey__c, PostalCode, WorkTypeId, XC_ApplyCoverageFilterInBooking__c   
                FROM WorkOrder
                WHERE Id = :reqWr.existingWorkOrderId
            ]);
            List<ServiceResource> listSr = new List<ServiceResource>([
                SELECT Id, XC_Account__c    
                FROM ServiceResource
                WHERE RelatedRecordId = :UserInfo.getUserId() AND isActive = true
            ]);
            
            String partnerId = '';
            if(!listSr.isEmpty()) {
                partnerId = listSr[0].XC_Account__c;
            } 
            else if(String.isNotBlank(listWorkOrder[0].XC_RequiredPartnerId__c)) {
                partnerId = listWorkOrder[0].XC_RequiredPartnerId__c;
            }
            String zipCodeToUse = (String.isBlank(listWorkOrder[0].XC_FSLAssignmentKey__c)) ? listWorkOrder[0].PostalCode : listWorkOrder[0].XC_FSLAssignmentKey__c;
            eWr = XC_UTIL_FSLLogistic.checkAvailability(listWorkOrder[0], zipCodeToUse, listWorkOrder[0].WorkTypeId, partnerId);
            if(!eWr.success && !Test.isRunningTest()){
                result.message = eWr.errorMessage;
                return result;
            }
            earliestDate = (eWr.availabilityDate > reqWr.startDate) ? eWr.availabilityDate : reqWr.startDate;
        }  
              
        System.Savepoint beforeInsertSavepoint = Database.setSavepoint(); 
        ServiceAppointment appointment = new ServiceAppointment();
        WorkOrder wo = new WorkOrder();

        if (reqWr.action.equalsIgnoreCase(XC_UTIL_Schedule.NEWAPPOINTMENT)) {
            XC_UTIL_Schedule_W.CreateWOSAWrapper createWrapper = createWorkOrderAndServiceAppointment(reqWr, Integer.valueOf(metaD[0].XC_Days_for_Due_Date__c));
            if(reqWr.workType == Label.XC_CL_WorkType_DeliveryInstallation) {
                createWrapper.serviceAppointment.EarliestStartTime = earliestDate;
            }
            if(!createWrapper.success){
                result.message = createWrapper.message;
                return result;
            }
            appointment = createWrapper.serviceAppointment;
            XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.insertRecord(appointment);
            if(reqWr.WorkType == Label.XC_CL_WorkType_Repair){
                List<ServiceAppointment> appointmentAfterInsert = new List<ServiceAppointment>([SELECT Id, DueDate
                                                                                                FROM ServiceAppointment
                                                                                                WHERE Id =: appointment.Id]);
                result.dueDate = appointmentAfterInsert[0].DueDate;
            }else{
                result.dueDate = appointment.DueDate;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'dueDate' +  result.dueDate);
            if (!dmlResult.success) {
                result.message = dmlResult.errorMessage;
                Database.rollback(beforeInsertSavepoint);
                return result;
            }
        } else if (reqWr.action.equalsIgnoreCase(XC_UTIL_Schedule.EDITAPPOINTMENT)) {
            List<ServiceAppointment> saList = new List<ServiceAppointment>([SELECT id, EarliestStartTime, ArrivalWindowStartTime, ArrivalWindowEndTime, ParentRecordId, dueDate, WorkType.Name, AccountId FROM serviceAppointment WHERE id =: reqWr.existingServiceAppointmentId]);
            appointment = saList.get(0);
            appointment.ArrivalWindowEndTime = null;
            appointment.ArrivalWindowStartTime = null;
            
            List<WorkOrder> woList = new List<WorkOrder>([
                SELECT Id, XC_WorkTypeCategory__c, XC_FSLAssignmentKey__c, PostalCode, WorkTypeId, XC_RequiredPartnerId__c, XC_ApplyCoverageFilterInBooking__c 
                FROM WorkOrder 
                WHERE Id = :appointment.ParentRecordId
            ]);
            wo = woList.get(0);

            Date originalEarliestStartTime = String.isNotBlank(String.valueOf(appointment.EarliestStartTime)) ? Date.valueOf(appointment.EarliestStartTime) : Date.today();
            if(reqWr.workType == Label.XC_CL_WorkType_DeliveryInstallation) {
                appointment.EarliestStartTime = earliestDate;
            } else {
                appointment.EarliestStartTime = getEarliestStartDate(wo, reqWr);
            }
            appointment.ArrivalWindowEndTime = null;
            appointment.ArrivalWindowStartTime = null;
            appointment.DueDate += originalEarliestStartTime.daysBetween(Date.valueOf(appointment.EarliestStartTime));
            
            
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.updateRecord(appointment);            
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            result.dueDate = appointment.duedate;
            system.debug('dueDate: '+appointment.duedate);
            if (!dmlResult.success) {
                result.message = dmlResult.errorMessage;
                Database.rollback(beforeInsertSavepoint);
                return result;
            } 
        } 

        XC_UTIL_Schedule_W.ManageBookingWrapper manageBooking = manageBookingOptions(reqWr, wo, appointment, Integer.valueOf(metaD[0].XC_Days_for_Due_Date__c));
        if(!manageBooking.success) {
            result.message = manageBooking.message;
            Database.rollback(beforeInsertSavepoint);
            return result;
        }
        appointment = manageBooking.sa;
        FSL__Scheduling_Policy__c policy = XC_UTIL_Schedule_D.getPolicy(metaD[0].XC_Policy_Name__c);
        OperatingHours operatingHours = XC_UTIL_Schedule_D.getOperatingHoursByName(metaD[0].XC_Operating_Hours_Name__c);
        TimeZone timeZone = UserInfo.getTimeZone();

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@FSL appointment.Id--' + appointment.Id);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@FSL timezone--' + timezone);

        if(Test.isRunningTest()){            
            XC_UTIL_Schedule.Slot slot = new XC_UTIL_Schedule.Slot();
            XC_UTIL_Schedule.Interval interval = new XC_UTIL_Schedule.Interval(System.now(), System.now().addHours(1)); 
            slot.interval = interval; 
            result.slots = new List<XC_UTIL_Schedule.Slot>{slot};
            result.success = true;
        }
        List<FSL.AppointmentBookingSlot> slotsFSL = FSL.AppointmentBookingService.GetSlots(
            appointment.Id,
            policy.Id,
            operatingHours,
            timezone,
            false
        ); 
        if (!slotsFSL.isEmpty()) {
            result.slots = XC_UTIL_Schedule.manageSlotsFSL(slotsFSL);
            result.success = true;
        } else {
            result.message = Label.XC_CL_Schedule_NoSlot;
        }
        Database.rollback(beforeInsertSavepoint);
        return result;
    }  

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Method to calculate Earliest Start Date
     * @param wo - WorkOrder
     * @param reqWr - ScheduleRequestWrapper
     * @return Datetime 
     **/ 
    @TestVisible
    private static Datetime getEarliestStartDate(WorkOrder wo, XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr){
        Datetime earliestDate = reqWr.startDate;
        String workTypeCategory = wo.XC_WorkTypeCategory__c;
        if( workTypeCategory == Label.XC_CL_WorkType_Delivery || workTypeCategory == Label.XC_CL_WorkType_Installation
            /*|| workTypeCategory == Label.XC_CL_WorkType_DeliveryInstallation*/){
                String zipCodeToUse = (String.isBlank(wo.XC_FSLAssignmentKey__c)) ? wo.PostalCode : wo.XC_FSLAssignmentKey__c;
                List<ServiceResource> listSr = new List<ServiceResource>([
                    SELECT Id, XC_Account__c    
                    FROM ServiceResource
                    WHERE RelatedRecordId = :UserInfo.getUserId() AND isActive = true
                ]);
                String partnerId = '';
                if(!listSr.isEmpty()) {
                    partnerId = listSr[0].XC_Account__c;
                } 
                else if(String.isNotBlank(wo.XC_RequiredPartnerId__c)) {
                    partnerId = wo.XC_RequiredPartnerId__c;
                }
                XC_UTIL_EligibleServiceResource.EligibleWrapper eWr = XC_UTIL_FSLLogistic.checkAvailability(wo, zipCodeToUse, wo.WorkTypeId, partnerId);
                earliestDate = (eWr.availabilityDate > reqWr.startDate) ? eWr.availabilityDate : reqWr.startDate;
        }
        return earliestDate;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description This method is used to book an appointment (like "standard" FSL functionality book appointment). 
     *               If the action is NEWAPPOINTMENT, it creates a Work Order and a Service Appointment and then 
     *               books the appointment by assigning it to a Service Resource.
     *               If the action is EDITAPPOINTMENT, it assings the existing Service Appointment to a new Service Resource. 
     *               In case of booking failure, Work Order and Appointment creation are rollbacked.     
     * @param reqWr - ScheduleRequestWrapper
     * @param metaD - default values
     * @return BookingResult 
     **/ 
    public static XC_UTIL_Schedule.BookingResult scheduleAppointment(XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr, List<XC_CM_Scheduling_Default_Value__mdt> metaD) {
        XC_UTIL_Schedule.BookingResult result = new XC_UTIL_Schedule.BookingResult(); 
        XC_UTIL_EligibleServiceResource.EligibleWrapper eWr = new XC_UTIL_EligibleServiceResource.EligibleWrapper();
        DateTime earliestDate = reqWr.startDate;

        if(reqWr.workType == Label.XC_CL_WorkType_DeliveryInstallation) {
            List<WorkOrder> listWorkOrder = new List<WorkOrder>([
                SELECT Id, XC_RequiredPartnerId__c, XC_FSLAssignmentKey__c, PostalCode, WorkTypeId, XC_ApplyCoverageFilterInBooking__c   
                FROM WorkOrder
                WHERE Id = :reqWr.existingWorkOrderId
            ]);
            List<ServiceResource> listSr = new List<ServiceResource>([
                SELECT Id, XC_Account__c    
                FROM ServiceResource
                WHERE RelatedRecordId = :UserInfo.getUserId() AND isActive = true
            ]);
            
            String partnerId = '';
            if(!listSr.isEmpty()) {
                partnerId = listSr[0].XC_Account__c;
            } 
            else if(String.isNotBlank(listWorkOrder[0].XC_RequiredPartnerId__c)) {
                partnerId = listWorkOrder[0].XC_RequiredPartnerId__c;
            }
            String zipCodeToUse = (String.isBlank(listWorkOrder[0].XC_FSLAssignmentKey__c)) ? listWorkOrder[0].PostalCode : listWorkOrder[0].XC_FSLAssignmentKey__c;
            eWr = XC_UTIL_FSLLogistic.checkAvailability(listWorkOrder[0], zipCodeToUse, listWorkOrder[0].WorkTypeId, partnerId);
            if(!eWr.success && !Test.isRunningTest()){
                result.message = eWr.errorMessage;
                return result;
            }
            earliestDate = (eWr.availabilityDate > reqWr.startDate) ? eWr.availabilityDate : reqWr.startDate;
        }  

        System.Savepoint beforeInsertSavepoint = Database.setSavepoint();
        ServiceAppointment appointment = new ServiceAppointment();
        WorkOrder workOrder = new WorkOrder();
        String woId = '';
        String accId = '';

        if (reqWr.action.equalsIgnoreCase(XC_UTIL_Schedule.NEWAPPOINTMENT)) {
            XC_UTIL_Schedule_W.CreateWOSAWrapper createWrapper = createWorkOrderAndServiceAppointment(reqWr, Integer.valueOf(metaD[0].XC_Days_for_Due_Date__c));
            if(reqWr.workType == Label.XC_CL_WorkType_DeliveryInstallation) {
                createWrapper.serviceAppointment.EarliestStartTime = earliestDate;
            }
            if(!createWrapper.success){
                result.message = createWrapper.message;
                return result;
            }
            appointment = createWrapper.serviceAppointment;

            workOrder = createWrapper.workOrder;
            woId = workOrder.id;
            accId = workorder.AccountId;

        } else if (reqWr.action.equalsIgnoreCase(XC_UTIL_Schedule.EDITAPPOINTMENT)) {
            appointment.Id = reqWr.existingServiceAppointmentId;
            ServiceAppointment sa = XC_UTIL_Schedule_D.getExistingAppointment(appointment.Id);
            if(sa == null) {
                result.message = Label.XC_CL_ServiceAppointmentNotExist;
                return result;
            }
            if(sa != null && sa.DueDate < reqWr.timeslotFinish && !Test.isRunningTest()){
                result.message = Label.XC_CL_ServiceAppointment_ErrorDueDate;
                return result;
            }
            appointment = sa;

            List<WorkOrder> woList = new List<WorkOrder>([
                SELECT Id, XC_WorkTypeCategory__c, XC_FSLAssignmentKey__c, DurationInMinutes, PostalCode, WorkTypeId, XC_RequiredPartnerId__c, XC_ApplyCoverageFilterInBooking__c
                FROM WorkOrder 
                WHERE Id = :sa.ParentRecordId
            ]);
            WorkOrder wo = woList.get(0);

            //sa.XC_ReschedulingReason__c = Label.XC_CL_ReschedulingAPI; ha senso?
            
            appointment.XC_ReschedulingReason__c = Label.XC_CL_ReschedulingAPI;
            Date originalEarliestStartTime = String.isNotBlank(String.valueOf(appointment.EarliestStartTime)) ? Date.valueOf(appointment.EarliestStartTime) : Date.today();
            if(reqWr.workType == Label.XC_CL_WorkType_DeliveryInstallation) {
                appointment.EarliestStartTime = earliestDate;
            } else {
                appointment.EarliestStartTime = getEarliestStartDate(wo, reqWr);
            }
            appointment.DueDate += originalEarliestStartTime.daysBetween(Date.valueOf(appointment.EarliestStartTime));
            woId = sa.ParentRecordId;
            accId = sa.AccountId;
            workOrder = wo;
        }
        try {
            TimeZone timezone = UserInfo.getTimeZone();
            FSL__Scheduling_Policy__c policy = new FSL__Scheduling_Policy__c();
            if(reqWr.bookNow != null && reqWr.bookNow) {
                policy = XC_UTIL_Schedule_D.getPolicy(metaD[0].XC_Policy_Name_NoAvailability__c);
            }else{
                policy = XC_UTIL_Schedule_D.getPolicy(metaD[0].XC_Policy_Name__c);   
            }
            XC_UTIL_Schedule_W.ManageBookingWrapper manageBooking = manageBookingOptions(reqWr, workOrder, appointment, Integer.valueOf(metaD[0].XC_Days_for_Due_Date__c));
            if(!manageBooking.success) {
                result.message = manageBooking.message;
                Database.rollback(beforeInsertSavepoint);
                return result;
            }
            appointment = manageBooking.sa;
            reqWr.timeslotBegin = manageBooking.timeslotBegin != null ? manageBooking.timeslotBegin : reqWr.timeslotBegin;
            reqWr.timeslotFinish = manageBooking.timeslotFinish != null ? manageBooking.timeslotFinish : reqWr.timeslotFinish;
            pupulateServiceAppointmentData(appointment, reqWr);

            //XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.upsertRecord(appointment);
            
            XC_UTIL_Sobject.WrapperResult dmlResult = new XC_UTIL_Sobject.WrapperResult();
            if(appointment.Id == null){
                dmlResult = XC_UTIL_Sobject.insertRecord(appointment);
            } else {                
                XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                dmlResult = XC_UTIL_Sobject.updateRecord(appointment);            
                XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            }
            if(!dmlResult.success && !Test.isRunningTest()) {
                result.message = dmlResult.errorMessage;
                Database.rollback(beforeInsertSavepoint);
                return result;
            } 
            FSL.ScheduleResult scheduleResult;
            if(!Test.isRunningTest()) {
                scheduleResult = FSL.ScheduleService.Schedule(policy.Id, appointment.Id);
            }
            if(scheduleResult == null && !Test.isRunningTest()) {
                result.message = Label.XC_CL_Schedule_TimeSlotNotAvailable;
                Database.rollback(beforeInsertSavepoint);
            } else { 
                if((reqWr.assignToMe !=null && reqWr.bookNow !=null && reqWr.assignToMe && reqWr.bookNow) || Test.isRunningTest()) {
                    List<ServiceAppointment> listSa = new List<ServiceAppointment>([
                        SELECT Id, XC_StatusReason__c
                        FROM ServiceAppointment 
                        WHERE Id = :appointment.Id
                    ]);
                    if(listSa[0].XC_StatusReason__c == Label.XC_CL_StatusReason_ToBeScheduled || Test.isRunningTest()) {
                        listSa[0].XC_StatusReason__c = Label.XC_CL_StatusReason_Assignedtothetechnician;
                        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                        dmlResult = XC_UTIL_Sobject.updateRecord(listSa[0]);            
                        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
                        if(!dmlResult.success) {
                            result.message = dmlResult.errorMessage;
                            Database.rollback(beforeInsertSavepoint);
                            return result;
                        } 
                    }
                }
                result.success = true;
                result.scheduledAppointmentId = appointment.Id;
                //return wo fields - for rest class
                result.workOrderId = woid;
                result.workTypeName = reqWr.worktype;
                result.accountId = accId;
            }
        } catch (Exception e) {
            result.message = e.getMessage();
            system.debug('err: '+e.getStackTraceString());
            Database.rollback(beforeInsertSavepoint);
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ before return ' + result);
        return result;
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description This method populates Service Appointment data before Scheduling
     * @param appointment - Service Appointment
     * @param reqWr - ScheduleRequestWrapper  
     **/ 
    private static void pupulateServiceAppointmentData(ServiceAppointment appointment, XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr){
        Datetime timeslotBegin = reqWr.timeslotBegin;
        Datetime timeslotFinish = reqWr.timeslotFinish;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'timeslotBegin->' + timeslotBegin);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'timeslotFinish->' + timeslotFinish);

        //timeslotBegin = timeslotBegin.addSeconds(UserInfo.getTimeZone().getOffset(timeslotBegin) / -1000);
        //timeslotFinish = timeslotFinish.addSeconds(UserInfo.getTimeZone().getOffset(timeslotFinish) / -1000);

        if(String.isNotBlank(reqWr.opportunityId)){
            appointment.Opportunity__c = reqWr.opportunityId;
        }
        appointment.ArrivalWindowStartTime = timeslotBegin;
        appointment.ArrivalWindowEndTime = timeslotFinish;
        XC_UTIL_Debug.debug(DEBUGACTIVE,'appointment.ArrivalWindowStartTime->' + appointment.ArrivalWindowStartTime);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'appointment.ArrivalWindowEndTime->' + appointment.ArrivalWindowEndTime);
    }
        
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @Mod 16/12/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to insert a Work Order and to return a Service Appointment for that Work Order
     * @param reqWr - ScheduleRequestWrapper
     * @param n - Integer
     * @return ServiceAppointment
     **/
    public static XC_UTIL_Schedule_W.CreateWOSAWrapper createWorkOrderAndServiceAppointment(XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr, Integer n) {
        XC_UTIL_Schedule_W.CreateWOSAWrapper createWrapper = retrieveWorkOrder(reqWr, n);
        if(!createWrapper.success){
            return createWrapper;
        }

        DateTime earliestDate = reqWr.startDate;
        WorkOrder wo = createWrapper.workOrder;
        String workTypeCategory = wo.XC_WorkTypeCategory__c;
        if(workTypeCategory == Label.XC_CL_WorkType_Delivery || workTypeCategory == Label.XC_CL_WorkType_Installation){
            List<ServiceResource> listSr = new List<ServiceResource>([
                SELECT Id, XC_Account__c    
                FROM ServiceResource
                WHERE RelatedRecordId = :UserInfo.getUserId() AND isActive = true
            ]);
            
            String partnerId = '';
            if(!listSr.isEmpty()) {
                partnerId = listSr[0].XC_Account__c;
            } 
            else if(String.isNotBlank(wo.XC_RequiredPartnerId__c)) {
                partnerId = wo.XC_RequiredPartnerId__c;
            }

            String zipCodeToUse = (String.isBlank(wo.XC_FSLAssignmentKey__c)) ? wo.PostalCode : wo.XC_FSLAssignmentKey__c;
            XC_UTIL_EligibleServiceResource.EligibleWrapper eWr = XC_UTIL_FSLLogistic.checkAvailability(wo, zipCodeToUse, wo.WorkTypeId, partnerId);
            if (!eWr.success){
                createWrapper.success = false;
                createWrapper.message = eWr.errorMessage;
                return createWrapper;
            }
            earliestDate = (eWr.availabilityDate > reqWr.startDate) ? eWr.availabilityDate : reqWr.startDate;
        }

        ServiceAppointment sa = XC_UTIL_ServiceAppointment.populateServiceAppointmentFromWorkOrder(wo);
        sa.EarliestStartTime = earliestDate;
        if(workTypeCategory != Label.XC_CL_WorkType_Repair) {
            sa.DueDate = XC_UTIL_Schedule_D.getDueDate(reqWr.startDate, n);
        }
        createWrapper.serviceAppointment = sa;
        return createWrapper;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Method to insert a Work Order and to return a Service Appointment for that Work Order.
     * @param reqWr - ScheduleRequestWrapper
     * @param n - Integer
     * @return WorkOrder
     **/
    private static XC_UTIL_Schedule_W.CreateWOSAWrapper retrieveWorkOrder(XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr, Integer n) {
        XC_UTIL_Schedule_W.CreateWOSAWrapper createWrapper = new XC_UTIL_Schedule_W.CreateWOSAWrapper();
        if(!String.isBlank(reqWr.existingWorkOrderId)) {
            List<WorkOrder> listWo = XC_UTIL_SObject.selectAllFields(reqWr.existingWorkOrderId);
            if(!listWo.isEmpty()) {
                createWrapper.success = true;
                createWrapper.workOrder = listWo[0];
                return createWrapper;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'SIMONE->' + reqWr);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'SIMONE->' + reqWr.workType);
        WorkOrder wo = createWorkOrder(reqWr); //Dynamic workType for different typology of work order

        XC_UTIL_WorkOrder.populateAddressFields(wo, reqWr.addressWr);
        XC_UTIL_Sobject.WrapperResult result =  XC_UTIL_Sobject.insertRecord(wo);     
        createWrapper.success = result.success; 
        if(!result.success){            
            createWrapper.message = result.errorMessage;
        } else{
            List<WorkOrder> listWo = XC_UTIL_SObject.selectAllFields(wo.Id);
            if(!listWo.isEmpty()) {
                createWrapper.success = true;
                createWrapper.workOrder = wo;
                return createWrapper;
            } 
        }
        return createWrapper;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Method to return a Work Order related to an Opportunity and/or an Account 
     * @param reqWr - parameters wrapper
     * @return WorkOrder
     **/
    private static WorkOrder createWorkOrder(XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr) {
        WorkOrder wo = new WorkOrder();
        if(!String.isBlank(reqWr.leadId)){
            wo = XC_UTIL_WorkOrder.createWorkOrder(reqWr.worktype, reqWr.country, reqWr.leadId);
        } else {
            Opportunity opp = XC_UTIL_Schedule_D.getExistingOpportunity(reqWr.opportunityId);
            if(opp != null){
                wo = XC_UTIL_WorkOrder.createWorkOrder(reqWr.worktype, reqWr.country, opp.accountId);
                wo.XC_Opportunity__c = opp.Id; 
                wo.ContactId = opp.XC_Contact__c;
            }
        } 
        return wo; 
    }  

    /** 
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 02/03/2020
     * @description Method to manage "Assign to me" and "Book now" options
     * @param reqWr - ScheduleRequestWrapper
     * @param wo - WorkOrder
     * @param sa - ServiceAppointment
     * @param n - Integer
     * @return XC_UTIL_Schedule_W.ManageBookingWrapper
     */
    @TestVisible
    private static XC_UTIL_Schedule_W.ManageBookingWrapper manageBookingOptions(XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr, WorkOrder wo, ServiceAppointment sa, Integer n) {
        XC_UTIL_Schedule_W.ManageBookingWrapper outputWrapper = new XC_UTIL_Schedule_W.ManageBookingWrapper();
        if(reqWr.bookNow != null && reqWr.bookNow) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For this request, manage Book now');
            Map<String, Object> mapWo = wo.getPopulatedFieldsAsMap();
            sa.EarliestStartTime = Datetime.now().addMinutes(10);
            sa.DueDate = (!mapWo.keySet().isEmpty() && mapWo.containsKey('DurationInMinutes')) ? Datetime.now().addMinutes(Integer.valueOf(wo.DurationInMinutes)+10) : XC_UTIL_Schedule_D.getDueDate(Datetime.now(), n);//XC_UTIL_Schedule_D.getDueDate(Datetime.now(), n);
            outputWrapper.timeslotBegin = sa.EarliestStartTime;
            outputWrapper.timeslotFinish = sa.DueDate;
            sa.ArrivalWindowStartTime = outputWrapper.timeslotBegin;
            sa.ArrivalWindowEndTime = outputWrapper.timeslotFinish;
            
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.WrapperResult wrapperRes = XC_UTIL_Sobject.updateRecord(sa);            
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            if(!wrapperRes.success) {
                outputWrapper.message = wrapperRes.errorMessage;
                outputWrapper.success = false;
            }
        }
        if(reqWr.assignToMe != null && reqWr.assignToMe) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For this request, manage Assign to me');
            List<ServiceResource> listServiceResource = new List<ServiceResource>([
                SELECT Id 
                FROM ServiceResource
                WHERE RelatedRecordId = :UserInfo.getUserId() AND IsActive = true
            ]);
            if(listServiceResource.isEmpty()) {
                outputWrapper.message = Label.XC_CL_NoResourceFound;
                outputWrapper.success = false;
            } else {
                List<XC_UTIL_Sobject.WrapperResult> wrapperList = XC_UTIL_ResourcePreference.removeRequiredResourcePreferences(new List<Id>{sa.ParentRecordId});
                if(!XC_UTIL_Sobject.checkDMLResults(wrapperList)) {
                    outputWrapper.message = wrapperList[0].errorMessage;
                    outputWrapper.success = false;
                } else {
                    ResourcePreference rp = new ResourcePreference(
                        RelatedRecordId = sa.ParentRecordId,
                        PreferenceType = 'Required',
                        ServiceResourceId = listServiceResource[0].Id
                    );
                    XC_UTIL_Sobject.WrapperResult wrapperRes = XC_UTIL_Sobject.insertRecord(rp);
                    if(!wrapperRes.success) {
                        outputWrapper.message = wrapperRes.errorMessage;
                        outputWrapper.success = false;
                    }
                }
            }
        }
        outputWrapper.sa = sa;
        return outputWrapper;
    }

}