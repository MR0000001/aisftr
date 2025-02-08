/**
 * Created by SNEKKANTI00 on 10/03/2021.
 */

public with sharing class MailUpMailInvocable {

    @InvocableMethod
    public static void mailUpMail(List<FlowInput> flowInputs) {
        for(FlowInput flow : flowInputs) {
            String jobID = System.enqueueJob(new MailUpCreateMailCalloutQueueable(flow.theCase, flow.theCase.Id, flow.listId, flow.groupId, flow.templateSubject, flow.templateBody, flow.queueName, flow.queueEmail, flow.pecValue, flow.amaRiciclaCasaQueue, flow.amaRiciclaCasaEmail, flow.emailExternalSystem, flow.pecExternalSystem, flow.isForRecipient, flow.recipientMail));
            System.debug('mailUpMail jobID ' + jobID);
        }
    }

    public class FlowInput {
        @InvocableVariable
        public Case theCase;

        @InvocableVariable
        public String listId;

        @InvocableVariable
        public String groupId;

        @InvocableVariable
        public String templateSubject;

        @InvocableVariable
        public String templateBody;

        @InvocableVariable
        public String queueName;

        @InvocableVariable
        public String queueEmail;

        @InvocableVariable
        public Boolean pecValue;

        @InvocableVariable
        public String amaRiciclaCasaQueue;

        @InvocableVariable
        public String amaRiciclaCasaEmail;

        @InvocableVariable
        public String emailExternalSystem;

        @InvocableVariable
        public String pecExternalSystem;

        @InvocableVariable
        public String recipientMail;

        @InvocableVariable
        public Boolean isForRecipient;
    }
}