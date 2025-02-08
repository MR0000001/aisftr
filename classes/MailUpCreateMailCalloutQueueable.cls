/**
 * Created by SNEKKANTI00 on 17/03/2021.
 */

public with sharing class MailUpCreateMailCalloutQueueable implements Queueable, Database.AllowsCallouts {

    private MailUpMailWrapper mailUpMailWrapper = new MailUpMailWrapper();

    public MailUpCreateMailCalloutQueueable(Case theCase, String caseId, String listId, String groupId, String templateSubject, String templateBody, String queueName, String queueEmail, Boolean pecValue, String amaRiciclaCasaQueue, String amaRiciclaCasaEmail, String emailExternalSystem, String pecExternalSystem, Boolean isForRecipient, String recipientMail) {
        this.mailUpMailWrapper.singleCase = theCase;
        this.mailUpMailWrapper.caseId = theCase.id;
        this.mailUpMailWrapper.listId = listId;
        this.mailUpMailWrapper.groupId = groupId;
        this.mailUpMailWrapper.templateSubject = templateSubject;
        this.mailUpMailWrapper.templateBody = templateBody;
        this.mailUpMailWrapper.queueName = queueName;
        this.mailUpMailWrapper.queueEmail = queueEmail;
        this.mailUpMailWrapper.amaRiciclaCasaQueue = amaRiciclaCasaQueue;
        this.mailUpMailWrapper.pecValue = pecValue;
        this.mailUpMailWrapper.amaRiciclaCasaEmail = amaRiciclaCasaEmail;
        this.mailUpMailWrapper.emailExternalSystem = emailExternalSystem;
        this.mailUpMailWrapper.pecExternalSystem = pecExternalSystem;
        this.mailUpMailWrapper.isForRecipient = isForRecipient;
        this.mailUpMailWrapper.recipientMail = recipientMail;
    }

    public void execute(QueueableContext qc) {
        Boolean isFailed = MailUpCreateMailCallout.mailUpCreateMailCallout(this.mailUpMailWrapper);

        try {
            if(isFailed) {
                ActivityCaseErrorService.insertActivityCaseErrors(mailUpMailWrapper, false);
            } else {
                EmailMessageService.insertEmailMessages(mailUpMailWrapper.emailMessages, false);
                if(!mailUpMailWrapper.isForRecipient) CaseService.updateCasesForEmailExternal(new List<String>{mailUpMailWrapper.caseId}, false);
            }
            system.debug('mailUpMailWrapper.calloutLoggers -> '+ mailUpMailWrapper.calloutLoggers);
            CalloutLoggerService.insertCalloutLoggers(mailUpMailWrapper.calloutLoggers, false);
            ErrorLogEventHandler.publishEventsDMLSafe(mailUpMailWrapper.errorLogEvents);
        } catch(Exception e) {
            System.debug('Exception at MailUpCreateMailCalloutQueueable.execute ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
}