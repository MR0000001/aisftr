/**
 * Created by SNEKKANTI00 on 12/03/2021.
 */

public with sharing class MailUpCreateSMSCalloutQueueable implements Queueable, Database.AllowsCallouts {
    private SMSWrapper smsWrapper = new SMSWrapper();

    public MailUpCreateSMSCalloutQueueable(String serviceAppointmentId, String caseId, String serviceRequestId, String idList, String type, String phoneNumber, String prefixPhoneNumber, String smsSubject, String smsBody) {
        this.smsWrapper.serviceAppointmentId = serviceAppointmentId;
        this.smsWrapper.caseId = caseId;
        this.smsWrapper.serviceRequestId = serviceRequestId;
        this.smsWrapper.idList = idList;
        this.smsWrapper.smsType = type;
        this.smsWrapper.phoneNumber = phoneNumber;
        this.smsWrapper.prefixPhoneNumber = prefixPhoneNumber;
        this.smsWrapper.smsSubject = smsSubject;
        this.smsWrapper.smsBody = smsBody;
        this.smsWrapper.isForRecipient = (smsWrapper.serviceAppointmentId == null) ? true : false;
    }

    public void execute(QueueableContext qc) {
        Boolean isFailed = MailUpCreateSMSCallout.mailUpCreateSMSCallout(this.smsWrapper);

        try {
            if(isFailed) {
                ActivityCaseErrorService.insertActivityCaseErrors(this.smsWrapper, false);
            } else {
                SMSService.insertSMSs(this.smsWrapper.smsList, false);
            }
            //ActivityCaseErrorService.deleteActivityCaseErrorsFromServiceAppointmentIds(new List<String>{this.smsWrapper.serviceAppointmentId}, false);
            CalloutLoggerService.insertCalloutLoggers(smsWrapper.calloutLoggers, false);
            ErrorLogEventHandler.publishEventsDMLSafe(smsWrapper.errorLogEvents);
        } catch(Exception e) {
            System.debug('Exception at MailUpCreateSMSCalloutQueueable.execute ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
}