/**
 * @author Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 02/10/2018
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_Schedule – Util class for scheduling Service Appointments
 */

public without sharing class XC_UTIL_Schedule {  
 
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Schedule');

    public static final String NEWAPPOINTMENT = 'New'; 
    public static final String EDITAPPOINTMENT = 'Edit';
    public static final String GETSLOTS = 'getSlots';
    public static final String SCHEDULEAPPOINTMENT = 'scheduleAppointment'; 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Wrapper classes to manage output of getSlot and scheduleAppointment methods 
     **/

    public class BookingResult { 
        public Boolean success = false;
        public String message = ''; 
        public String IntegrationError = ''; //used by rest class logging
        public XC_UTIL_Schedule_W.AddressWrapper Address; //used by rest class logging 
        public String workOrderNumber;
        public String workOrderId;
        public String workTypeName;
        public String accountId;
        public List < Slot > slots = new List < Slot > ();
        public Id scheduledAppointmentId = null;
        public ServiceResource assignedResource = new ServiceResource();
        public DateTime dueDate; //used by rest class
    }

    /**
     * @description Slot Wrapper class 
     **/

    public class Slot {
        public Decimal grade;
        public Interval interval;
    }

    /**
     * @description Interval Wrapper class 
     **/

    public class Interval {
        public Datetime start;
        public Datetime finish;
        /**
        * @description Interval Wrapper class constructor
        * @param start - Datetime
        * @param finish - Datetime
        **/ 
        public Interval(Datetime start, Datetime finish) {
            this.start = start;
            this.finish = finish;
        }
    } 

    /** 
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description This method is used to get a list of available slots for an Appointment.
     *               If the action is NEWAPPOINTMENT then all required parameters are in input.
     *               If the action is EDITAPPOINTMENT then all required parameters are retrieved 
     *               from existing appointment.  
     * @param reqWr - ScheduleRequestWrapper
     * @return result - BookingResult
     **/
    public static BookingResult getSlots(XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr) {
        BookingResult result = new BookingResult();
        result = getSlotsFromWrapper(reqWr); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'slots->' + result);
        return result;
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description This method is used to book an appointment (like "standard" FSL functionality book appointment).         
     * @param reqWr - ScheduleRequestWrapper
     * @return result - BookingResult
     **/
    public static BookingResult scheduleAppointment(XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr) {
        BookingResult result = new BookingResult();
        result = scheduleAppointmentFromWrapper(reqWr);
        return result;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description This method is used to get a list of available slots for an Appointment.
     *               It creates a Work Order and a Service Appointment and then 
     *               retrieves a list of Slots available to book the appointment 
     *               (like "standard" FSL functionality book appointment). 
     *               Work Order and Appointment creation are then rollbacked. 
     * @param reqWr - ScheduleRequestWrapper
     * @return BookingResult
     **/

    private static BookingResult getSlotsFromWrapper(XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr) {
        BookingResult result = new BookingResult();
        List<XC_CM_Scheduling_Default_Value__mdt> metaD = XC_UTIL_Schedule_D.getMetadata(reqWr.country);
        if (metaD.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, metaD);
            result.message = Label.XC_CL_Schedule_NoConfiguration;
            return result;
        } 
        return XC_UTIL_Schedule_U.getSlots(reqWr, metaD);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description This method is used to book an appointment (like "standard" FSL functionality book appointment). 
     *               If the action is NEWAPPOINTMENT, it creates a Work Order and a Service Appointment and then 
     *               books the appointment by assigning it to a Service Resource.
     *               If the action is EDITAPPOINTMENT, it assings the existing Service Appointment to a new Service Resource. 
     *               In case of booking failure, Work Order and Appointment creation are rollbacked.     
     * @param reqWr - ScheduleRequestWrapper
     * @return BookingResult  
     **/ 

    private static BookingResult scheduleAppointmentFromWrapper(XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr) {
        BookingResult result = new BookingResult();
        List<XC_CM_Scheduling_Default_Value__mdt> metaD = XC_UTIL_Schedule_D.getMetadata(reqWr.country);
        if (metaD.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, metaD);
            result.message = Label.XC_CL_Schedule_NoConfiguration;
            return result; 
        } 
        return XC_UTIL_Schedule_U.scheduleAppointment(reqWr, metaD);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Converts FSL Slots to our Wrapper Slot 
     * @param slotList - FSL.AppointmentBookingSlot
     * @return List<Slot>
     **/

    public static List<Slot> manageSlotsFSL(List<FSL.AppointmentBookingSlot> slotList) {
        List<Slot> slots = new List <Slot> ();
        for (FSL.AppointmentBookingSlot slot: slotList) {
            Slot s = new Slot();
            s.grade = slot.Grade.setScale(4, RoundingMode.HALF_UP);
            s.interval = new Interval(slot.Interval.Start, slot.Interval.Finish);
            slots.add(s);
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'slotsFSL->' + slots); 
        return slots;
    } 
}