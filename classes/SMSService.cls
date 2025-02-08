/**
 * Created by SNEKKANTI00 on 20/04/2021.
 */

public with sharing class SMSService {

    public static void createSMSs(SMSWrapper smsWrapper) {
        SMS__c sms = new SMS__c();

        sms.CaseId__c = smsWrapper.caseId;
        sms.ServiceRequestId__c = smsWrapper.serviceRequestId;
        sms.Phone__c = smsWrapper.phoneNumber;
        sms.SMS_Template__c = String.isNotBlank(smsWrapper.smsBody) ? Util.abbreviateTo10k(smsWrapper.smsBody) : '';

        smsWrapper.smsList.add(sms);
    }

    public static void insertSMSs(List<SMS__c> smsList, Boolean allOrNone) {
        if(smsList != null && !smsList.isEmpty()) SMSSelector.insertSMSs(smsList, allOrNone);
    }
}