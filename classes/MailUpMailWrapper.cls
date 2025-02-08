/**
 * Created by SNEKKANTI00 on 17/03/2021.
 */

public with sharing class MailUpMailWrapper {
    public Boolean isForRecipient;
    public Case singleCase;
    public String caseId;
    public String listId;
    public String groupId;
    public String templateSubject;
    public String templateBody;
    public String queueName;
    public String queueEmail;
    public Boolean pecValue;
    public String amaRiciclaCasaQueue;
    public String amaRiciclaCasaEmail;
    public String emailExternalSystem;
    public String pecExternalSystem;
    public String error;
    public String recipientMail;
    public List<EmailMessage> emailMessages = new List<EmailMessage>();
    public List<Callout_logger__c> calloutLoggers = new List<Callout_logger__c>();
    public List<Error_Log_Event__e> errorLogEvents = new List<Error_Log_Event__e>();
    public String orgCaseQueue;
    public String queueEmailAma;
}