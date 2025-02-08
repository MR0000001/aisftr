public with sharing class TA_LCC213_BookAppointment {
    public TA_LCC213_BookAppointment() {}

    public class WrapperSlot {
        public Datetime startTime;
        public Datetime timeSlotStart;
        public Datetime timeSlotEnd;
        public Date eventDate;
        public String timeSlotStartDisplay;
        public String servAppId;
        public String newWorkOrderId;
        public Decimal duration;
        public String durationType;

        public WrapperSlot(Datetime startTime, Datetime timeSlotStart, Datetime timeSlotEnd, Date eventDate, String servAppId, String newWorkOrderId) {
            this.startTime = startTime;
            this.timeSlotStart = timeSlotStart;
            this.timeSlotEnd = timeSlotEnd;
            this.eventDate = eventDate;
            this.servAppId = servAppId;
            this.newWorkOrderId = newWorkOrderId;

            String minute = String.valueOf(timeSlotStart.minute());
            String hour = String.valueOf(timeSlotStart.hour());
            this.timeSlotStartDisplay = hour + ':' + (minute == '0' ? '00' : minute);
        }
    }

    @AuraEnabled
    public static Map<String, String> getAvailableAppointments(String workOrderId, String leadId, String opportunityId, Boolean reschedule){
        Map<String, String> response = new Map<String, String>();
        try {
            Map<String, String> params = new Map<String, String>();
            String appointmentSlotDate = '';

            list<WorkOrder> workOrderList = [SELECT Id, ParentWorkOrderId FROM WorkOrder WHERE Id = :workOrderId];
            if(!workOrderList.isEmpty()) {
                WorkOrder wo = workOrderList[0];
                Id servAppWOId;
                if(String.isNotBlank(wo.ParentWorkOrderId)) {
                    servAppWOId = wo.ParentWorkOrderId;
                } else {
                    servAppWOId = wo.Id;
                }

                if(reschedule) {
                    List<ServiceAppointment> serviceApps = [SELECT Id, SchedStartTime FROM ServiceAppointment WHERE ParentRecordId = :servAppWOId];
                    if(!serviceApps.isEmpty()) {
                        ServiceAppointment servApp = serviceApps[0];
                        appointmentSlotDate = String.valueOf(Date.valueOf(servApp.SchedStartTime));
                        params.put('AppointmentSlotDate', appointmentSlotDate);
                        params.put('ServiceAppointmentID', servApp.Id);
                    }
                } else {  
                    if(String.isNotBlank(leadId)) {
                        params.put('LeadID', leadId);
                    } else if (String.isNotBlank(workOrderId)) {
                        params.put('WorkOrderID', workOrderId);
                    } else if (String.isNotBlank(opportunityId)) {
                        params.put('OpportunityID', opportunityId);
                    }   
                    params.put('AppointmentSlotDate', String.valueOf(Datetime.now().addDays(3)));
                    appointmentSlotDate = String.valueOf(Date.today()).substring(0, 10);
                }           
    
                params.put('AssignToMe', 'true');
                //params.put('BookNow', String.valueOf(bookNow));
    
                System.debug('params --- ' + params);
                XC_UTIL_Schedule.BookingResult bookings = XC_REST_WorkOrder_S.ReadSlots(params);
                System.debug('bookings --- ' + bookings);
                response.put('success', String.valueOf(bookings.success));
                if(bookings.success) { 
                    XC_REST_WorkOrder_W.GetResultWrapper wrResp = new XC_REST_WorkOrder_W.GetResultWrapper(); 
                    List<XC_REST_WorkOrder_W.WrapperSlot> wrapperSlotsTmp = XC_REST_WorkOrder_W.createWrapperSlot(bookings.Slots, DateTime.valueOf(appointmentSlotDate + ' 00:00:00'), bookings.dueDate);
                    System.debug('wrapperSlotsTmp --- ' + wrapperSlotsTmp);
                    List<WrapperSlot> wrapperSlots = new List<WrapperSlot>();
                    for(XC_REST_WorkOrder_W.WrapperSlot wrapperSlot : wrapperSlotsTmp) {
                        wrapperSlots.add(new WrapperSlot(wrapperSlot.StartTime, wrapperSlot.TimeSlotStart, wrapperSlot.timeSlotEnd, Date.newInstance(wrapperSlot.TimeSlotStart.year(), wrapperSlot.TimeSlotStart.month(), wrapperSlot.TimeSlotStart.day()), reschedule ? params.get('ServiceAppointmentID') : null, !reschedule ? workOrderId : null));
                    }
                    response.put('wrapperSlots', JSON.serialize(wrapperSlots));
                } else {
                    response.put('error', bookings.message);
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            response.put('error', errorMessage);
            System.debug('[TA_LCC213_BookAppointment] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC213_BookAppointment', 'initialize', errorMessage, 0, errorMessage, null);
        }
        return response;
    }

    @AuraEnabled
    public static Map<String, String> scheduleAppointment(String wrapperSlotSelectedSerialized, Id recordId, Boolean bookNow, Boolean reschedule) {
        Map<String, String> result = new Map<String, String>();

        try {
            XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper bookAppointment = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();

            if(!bookNow) {
                WrapperSlot wrapperSlotSelected = (WrapperSlot) JSON.deserialize(wrapperSlotSelectedSerialized, WrapperSlot.class);
                bookAppointment.TimeSlotBegin = wrapperSlotSelected.timeSlotStart;
                bookAppointment.TimeSlotFinish = wrapperSlotSelected.timeSlotEnd;
                bookAppointment.StartDate = wrapperSlotSelected.eventDate;
            } else {
                bookAppointment.StartDate = Date.today();
            }
            
            bookAppointment.AssignToMe = true;
            bookAppointment.BookNow = bookNow;
            
            String sobjectType = recordId.getSObjectType().getDescribe().getName();

            if(String.isNotBlank(recordId) && sobjectType == 'WorkOrder') {
                bookAppointment.WorkOrderID = recordId;
            } else if(String.isNotBlank(recordId) && sobjectType == 'Lead') {
                bookAppointment.LeadID = recordId;
            } else if(String.isNotBlank(recordId) && sobjectType == 'ServiceAppointment') {
                bookAppointment.ServiceAppointmentID = recordId;
            }

            XC_UTIL_Schedule.BookingResult bookingResult = XC_REST_WorkOrder_S.ScheduleAppointment(bookAppointment);
            XC_REST_WorkOrder_W.Wrapper wrReq = new XC_REST_WorkOrder_W.Wrapper();
            wrReq.BookAppointment = bookAppointment;
            XC_REST_WorkOrder_W.Wrapper wrResp = manageBookingResult(bookingResult, wrReq);
            System.debug('wrResp.result.message -- ' + wrResp.result.message);
            result.put('message', wrResp.result.message);
            result.put('communityBaseUrl', Site.getBaseUrl());
            result.put('workOrderId', bookingResult.workOrderId);

            //START FIX - [20210802AL] - schedule service appointment
            //if(reschedule) {
            if(reschedule && (wrResp.result.message == 'Operation completed successfully' || Test.isRunningTest())) {
            //END FIX - [20210802AL] - schedule service appointment

                WorkOrder workOrderToUpdate = new WorkOrder(Id = bookingResult.workOrderId);
                List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder WHERE ParentWorkOrderId = :workOrderToUpdate.Id];
                if(!workOrders.isEmpty()) {
                    for(WorkOrder wo : workOrders) {
                        wo.TA_Phase__c = 'PreService';
                    }
                    List<XC_UTIL_Sobject.WrapperResult> resInsertWoList =  XC_UTIL_Sobject.updateListRecords(workOrders);
                }
                workOrderToUpdate.TA_Phase__c = 'PreService';
                
                //START FIX - [20210802AL] - schedule service appointment
                List<ServiceAppointment> servApps = [SELECT Id, XC_StatusReason__c FROM ServiceAppointment WHERE ParentRecordId =:workOrderToUpdate.Id AND Status != 'Canceled']; //FIX [20220216AL]
                if(!servApps.isEmpty()) {
                    if(servApps[0].XC_StatusReason__c == 'To be scheduled') servApps[0].XC_StatusReason__c = 'Assigned to the technician';
                    update servApps[0];
                }
                //END FIX - [20210802AL] - schedule service appointment

                XC_UTIL_Sobject.WrapperResult resInsertWO = XC_UTIL_Sobject.updaterecord(workOrderToUpdate);   
            }

        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC213_BookAppointment] EXCEPTION HANDLER: ' + errorMessage);
            result.put('message', errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC213_BookAppointment', 'scheduleAppointment', errorMessage, 0, errorMessage, null);
        }
        return result;
    }

    private static XC_REST_WorkOrder_W.Wrapper manageBookingResult(XC_UTIL_Schedule.BookingResult bookingResult,  XC_REST_WorkOrder_W.Wrapper wrReq){
        XC_REST_WorkOrder_W.Wrapper wrResp = new XC_REST_WorkOrder_W.Wrapper();
 
        if(bookingResult.success) {
            wrResp.bookAppointment = XC_REST_WorkOrder_W.getBookAppWrapper(wrReq, bookingResult); 
            wrResp.result.message = 'Operation completed successfully';
            wrResp.result.errorCode = '0';

        } else if(bookingResult.IntegrationError!='') {
            wrResp.result.message = bookingResult.IntegrationError;
            wrResp.result.errorCode = '400';

        } else {
            wrResp.result.message = 'INTERNAL ERROR: '+bookingResult.message;
            wrResp.result.errorCode = '500';
        }             
        return wrResp;
    }

    @AuraEnabled
    public static String getWorkOrderToSchedule(String workOrderId){
        if(String.isNotBlank(workOrderId)) {
            List<WorkOrder> workOrders = [SELECT Id, XC_Configuration__c, XC_Opportunity__c FROM WorkOrder WHERE Id =:workOrderId];
            System.debug('workOrders >>> ' + workOrders);
            if(!workOrders.isEmpty()) {
                WorkOrder workOrder = workOrders[0];
                List<WorkOrder> workOrdersToSchedule = [SELECT Id 
                                                        FROM WorkOrder 
                                                        WHERE XC_Configuration__c = :workOrder.XC_Configuration__c 
                                                        AND Status = 'New' AND ParentWorkOrderId = null];
                System.debug('workOrdersToSchedule >>> ' + workOrdersToSchedule);
                if(!workOrdersToSchedule.isEmpty()) {
                    return workOrdersToSchedule[0].Id;
                }
            }
        }
        return null;
    }

    @AuraEnabled
    public static void updateServiceAppointmentDurationTime(String servAppId, Decimal durationTime, String durationType) {
        try {
            ServiceAppointment servApp = new ServiceAppointment();
            servApp.Id = servAppId;
            servApp.Duration = durationTime;
            servApp.DurationType = durationType;
            update servApp;
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC213_BookAppointment] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC213_BookAppointment', 'updateServiceAppointmentDurationTime', errorMessage, 0, errorMessage, null);
        }
    }
}