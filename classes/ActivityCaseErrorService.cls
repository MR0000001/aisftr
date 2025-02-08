/**
 * @author            : Sree Vamsi Nekkanti
 * @created date      : 15-04-2021
 * @description       : 
 * @testClasses       : TestActivityCaseErrorService
 * @last modified by  : Daniel Perrella
 * @last modified on  : 06-03-2023
**/

public with sharing class ActivityCaseErrorService {
    public static void deleteActivityCaseErrors(List<String> activityCaseErrorIds, Boolean allOrNone) {
        if(!activityCaseErrorIds.isEmpty()) ActivityCaseErrorSelector.deleteActivityCaseErrors(activityCaseErrorIds, allOrNone);
    }

    // public static void deleteActivityCaseErrorsFromServiceAppointmentIds(List<String> serviceAppointmentIds, Boolean allOrNone) {
    //     List<Activity_Case_Error__c> activityCaseErrors = new List<Activity_Case_Error__c>();

    //     if(serviceAppointmentIds.isEmpty()) activityCaseErrors = ActivityCaseErrorSelector.getActivityCaseErrorsByServiceAppointmentIds(serviceAppointmentIds);

    //     if(!activityCaseErrors.isEmpty()) ActivityCaseErrorSelector.deleteActivityCaseErrors(activityCaseErrors, allOrNone);
    // }

    public static void insertActivityCaseErrors(MailUpMailWrapper mailUpMailWrapper, Boolean allOrNone) {
        List<Activity_Case_Error__c> activityCaseErrors = new List<Activity_Case_Error__c>();
        Activity_Case_Error__c ace = new Activity_Case_Error__c();

        ace.Id_List__c = mailUpMailWrapper.listId;
        ace.Case__c = mailUpMailWrapper.caseId;
        ace.Error__c = String.isNotBlank(mailUpMailWrapper.error) ? mailUpMailWrapper.error.abbreviate(Activity_Case_Error__c.Error__c.getDescribe().getLength()) : '';
        ace.Email_Subject__c = String.isNotBlank(mailUpMailWrapper.templateSubject) ? Util.abbreviateTo10k(mailUpMailWrapper.templateSubject) : '';
        ace.Email_Template__c = String.isNotBlank(mailUpMailWrapper.templateBody) ? Util.abbreviateTo10k(mailUpMailWrapper.templateBody) : '';
        ace.Status__c = 'Not Sent';
        ace.Message_Type__c = 'Email';
        ace.Id_Group__c = mailUpMailWrapper.groupId;
        ace.PEC_Value__c = (mailUpMailWrapper.pecValue == null) ? false : mailUpMailWrapper.pecValue;
        ace.Queue_Email__c = (mailUpMailWrapper.isForRecipient) ? mailUpMailWrapper.recipientMail : mailUpMailWrapper.queueEmail;
        ace.Queue_Name__c = mailUpMailWrapper.queueName;
        ace.Send_to_Recipient__c = mailUpMailWrapper.isForRecipient;
        ace.PEC_External_System__c = (ace.PEC_Value__c) ? mailUpMailWrapper.pecExternalSystem : '';
        ace.Email_External_System__c = (!ace.PEC_Value__c) ? mailUpMailWrapper.emailExternalSystem : '';
        ace.AMA_Ricicla_Casa_Email__c = (String.isNotBlank(ace.Queue_Name__c) && ace.Queue_Name__c.equalsIgnoreCase('AMA_RICICLACASA_RECLAMI_External')) ? mailUpMailWrapper.amaRiciclaCasaEmail : '';
        ace.AMA_Ricicla_Casa_Queue__c = (String.isNotBlank(ace.Queue_Name__c) && ace.Queue_Name__c.equalsIgnoreCase('AMA_RICICLACASA_RECLAMI_External')) ? mailUpMailWrapper.amaRiciclaCasaQueue : '';

        activityCaseErrors.add(ace);

        ActivityCaseErrorSelector.insertActivityCaseErrors(activityCaseErrors, allOrNone);
    }

    public static void insertActivityCaseErrors(SMSWrapper smsWrapper, Boolean allOrNone) {
        List<Activity_Case_Error__c> activityCaseErrors = new List<Activity_Case_Error__c>();
        Activity_Case_Error__c ace = new Activity_Case_Error__c();

        ace.SMS_Subject__c = smsWrapper.smsSubject;
        ace.SMS_Template__c = smsWrapper.smsBody;
        ace.SMS_Type__c = smsWrapper.smsType;
        // ace.Service_Appointment__c = smsWrapper.serviceAppointmentId;
        if ( String.isNotBlank(smsWrapper.caseId) ) {
            ace.Case__c = smsWrapper.caseId;
        } else {
            ace.ServiceRequest__c = smsWrapper.serviceRequestId;
        }
        ace.Status__c = 'Not Sent';
        ace.Message_Type__c = 'SMS';
        ace.Id_List__c = smsWrapper.idList;
        ace.Phone_Number__c = smsWrapper.phoneNumber;
        ace.Prefix_Phone_Number__c = smsWrapper.prefixPhoneNumber;
        ace.Send_to_Recipient__c = smsWrapper.isForRecipient;
        ace.Error__c = (smsWrapper.error?.length() > 255) ? smsWrapper.error.subString(0,255) : smsWrapper.error;

        activityCaseErrors.add(ace);

        ActivityCaseErrorSelector.insertActivityCaseErrors(activityCaseErrors, allOrNone);
    }

    public static void updateActivityCaseErrors(List<Activity_Case_Error__c> activityCaseErrors, Boolean allOrNone) {
        if(!activityCaseErrors.isEmpty()) {
            ActivityCaseErrorSelector.updateActivityCaseErrors(activityCaseErrors, false);
        }
    }
}