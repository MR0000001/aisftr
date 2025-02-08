/**
 * Created by SNEKKANTI00 on 15/04/2021.
 */

public with sharing class SMSWrapper {
    public String caseId;
    public String serviceRequestId;
    public String serviceAppointmentId;
    public String idList;
    public String smsType;
    public String phoneNumber;
    public String prefixPhoneNumber;
    public String contentLength;
    public String smsSubject;
    public String smsBody;
    public String error;
    public Boolean isForRecipient;
    public List<SMS__c> smsList = new List<SMS__c>();
    public List<Callout_logger__c> calloutLoggers = new List<Callout_logger__c>();
    public List<Error_Log_Event__e> errorLogEvents = new List<Error_Log_Event__e>();
}