/**
 * Created by SNEKKANTI00 on 15/04/2021.
 */

public with sharing class EmailMessageService {

    public static void insertEmailMessages(List<EmailMessage> emailMessages, Boolean allOrNone) {
        if(emailMessages != null && !emailMessages.isEmpty()) EmailMessageSelector.insertEmailMessages(emailMessages, allOrNone);
    }

    public static void createEmailMessages(MailUpMailWrapper mailUpMailWrapper) {
        if(!mailUpMailWrapper.isForRecipient && mailUpMailWrapper.queueName.equalsIgnoreCase(mailUpMailWrapper.amaRiciclaCasaQueue)) createEmailMessageAMA(mailUpMailWrapper);

        createEmailCommonMessage(mailUpMailWrapper);
    }

    private static void createEmailMessageAMA(MailUpMailWrapper mailUpMailWrapper) {
        EmailMessage message = new EmailMessage();
        message.ToAddress = mailUpMailWrapper.amaRiciclaCasaEmail;
        message.FromAddress = mailUpMailWrapper.emailExternalSystem;
        message.FromName = 'Roma Capitale';
        message.Subject = String.isNotBlank(mailUpMailWrapper.templateSubject) ? Util.abbreviateTo10k(mailUpMailWrapper.templateSubject) : '';
        message.HtmlBody = String.isNotBlank(mailUpMailWrapper.templateBody) ? Util.abbreviateTo10k(mailUpMailWrapper.templateBody) : '';
        message.Status = '3';
        message.RelatedToId = mailUpMailWrapper.caseId;

        mailUpMailWrapper.emailMessages.add(message);
    }

    private static void createEmailCommonMessage(MailUpMailWrapper mailUpMailWrapper) {

        EmailMessage message = new EmailMessage();
        message.ToAddress = (mailUpMailWrapper.isForRecipient) ? mailUpMailWrapper.recipientMail : mailUpMailWrapper.queueEmail;
        message.FromAddress = (mailUpMailWrapper.pecValue) ? mailUpMailWrapper.pecExternalSystem :  mailUpMailWrapper.emailExternalSystem;
        message.FromName = 'Roma Capitale';
        message.Subject = String.isNotBlank(mailUpMailWrapper.templateSubject) ? Util.abbreviateTo10k(mailUpMailWrapper.templateSubject) : '';
        message.HtmlBody = String.isNotBlank(mailUpMailWrapper.templateBody) ? Util.abbreviateTo10k(mailUpMailWrapper.templateBody) : '';
        message.Status = '3';
        message.RelatedToId = mailUpMailWrapper.caseId;
        message.CitizenCommunications__c = mailUpMailWrapper.isForRecipient;

        mailUpMailWrapper.emailMessages.add(message);
    }
}