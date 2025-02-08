/**
 * Created by SNEKKANTI00 on 10/03/2021.
 */

public with sharing class MailUpSMSInvocable {

    @InvocableMethod
    public static void mailUpSMS(List<FlowInput> flowInputs) {
        for(FlowInput flow : flowInputs) {
            String jobID = System.enqueueJob(new MailUpCreateSMSCalloutQueueable(flow.serviceAppointmentId, flow.caseId, flow.serviceRequestId, flow.idList, flow.type, flow.phoneNumber, flow.prefixPhoneNumber, flow.smsSubject, flow.smsBody));
            System.debug('mailUpSMS jobID ' + jobID);
        }
    }

    public class FlowInput {

        @InvocableVariable
        public String serviceAppointmentId;

        @InvocableVariable
        public String serviceRequestId;

        @InvocableVariable
        public String caseId;

        @InvocableVariable
        public String idList;

        @InvocableVariable
        public String type;

        @InvocableVariable
        public String phoneNumber;

        @InvocableVariable
        public String prefixPhoneNumber;

        @InvocableVariable
        public String smsSubject;

        @InvocableVariable
        public String smsBody;
    }
}