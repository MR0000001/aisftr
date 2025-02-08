public without sharing class TA_LCC206_AppointmentPreview {
    public TA_LCC206_AppointmentPreview() {}

    @AuraEnabled
    public static String initialize(Integer rowLimit) {
        String infoBag = TA_UTIL_Appointment.getInfoBag(rowLimit);
        return infoBag;
    }
}