/**
 * @author Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 19/04/2019
 * @description XC_UTIL_Schedule_W – Wrappers class for scheduling Service Appointments
 */

public without sharing class XC_UTIL_Schedule_W {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Schedule_W');
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Wrapper classes to manage input createWorkOrderAndServiceAppointment methods 
     **/
    public class CreateWOSAWrapper{
        public Boolean success = false;
        public String message = ''; 
        public ServiceAppointment serviceAppointment = new ServiceAppointment(); 
        public WorkOrder workOrder = new WorkOrder();
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Wrapper classes to manage input of getSlot and scheduleAppointment methods 
     **/
    public class ScheduleRequestWrapper {
        public String action = '';                                  // Type action
        public String operation = '';                               // Source action
        public String leadId = '';                                  // Id of the Lead to which the Work Order is related
        public String opportunityId = '';                           // Id of the Opportunity to which the Work Order is related
        public String existingWorkOrderId = '';                     // Id of the Work Order for Scheduling a new Appointment
        public String existingWorkOrderNumber = '';                 // Number of the Work Order for Scheduling a new Appointment - just for output of the rest method
        public String workType = '';                                // Work Type for the work order
        public String country = '';                                 // Country to retrieve custom metadata value
        public AddressWrapper addressWr = new AddressWrapper();     // Address for the Service Appointment
        public DateTime startDate;                                  // EarliestStartTime for the Service Appointment
        public Datetime timeslotBegin;                              // ArrivalWindowStartTime for the Service Appointment
        public Datetime timeslotFinish;                             // ArrivalWindowEndTime for the Service Appointment
        public String existingServiceAppointmentId = '';            // Id of the Service Appointment for reScheduling
        public Boolean bookNow = false;                             // Manage Book Appointment for Now
        public Boolean assignToMe = false;                          // Manage Book Appointment for current resource
        //public String accassignId = '';                           // Id of the Account to which the Work Order is related
    } 
    
    /** @description AddressWrapper class wrapper **/
    public class AddressWrapper {
        public String addressId = '';
        public String city = '';
        public String country = '';
        public String postalCode = '';
        public String street = '';
        public String state = '';
        
        /** @description Address Wrapper class constructor **/
        public AddressWrapper(){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ AdressWrapper Costructor');
        }
    }

    /** @description ManageBookingWrapper */
    public class ManageBookingWrapper {
        public Boolean success = true;
        public String message = '';
        public ServiceAppointment sa;
        public Datetime timeslotBegin = null; 
        public Datetime timeslotFinish = null;
    }

}