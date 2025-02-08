public without sharing class TA_LCC200_AppointmentCalendar {
    public TA_LCC200_AppointmentCalendar() {}

    @AuraEnabled
    public static String initialize() {
        String infoBag = TA_UTIL_Appointment.getInfoBag(null);
        return infoBag;
    }
}