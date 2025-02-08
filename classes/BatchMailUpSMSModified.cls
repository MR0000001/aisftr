/**
 * @author            : Sree Vamsi Nekkanti
 * @created date      : 15-04-2021
 * @description       : 
 * @testClasses       : TestBatchMailUpSMSModified
 * @last modified by  : Daniel Perrella
 * @last modified on  : 06-03-2023
**/

global with sharing class BatchMailUpSMSModified implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts {

    private static MailUpBatch_Settings__c setting = MailUpBatch_Settings__c.getValues('BatchMailUp');

    private static OrgManagement__c orgSetting = OrgManagement__c.getOrgDefaults();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('START at BatchMailUpSMSV2');
        try {
            DateTime nowTime = datetime.now();
            DateTime lowestTime = nowTime.addHours(-Integer.valueOf(setting.Lowest_Time_Hours__c));

            // String query = 'SELECT Last_Batch_Date_Time__c, SMS_Subject__c, SMS_Template__c, Prefix_Phone_Number__c, Phone_Number__c, Id_Group__c, Id_List__c, SMS_Type__c, Message_Type__c, Status__c, Case__c, ServiceRequest__c, Service_Appointment__c ' +
            String query = 'SELECT Last_Batch_Date_Time__c, SMS_Subject__c, SMS_Template__c, Prefix_Phone_Number__c, Phone_Number__c, Id_Group__c, Id_List__c, SMS_Type__c, Message_Type__c, Status__c, Case__c, ServiceRequest__c ' +
                    'FROM Activity_Case_Error__c WHERE LastModifiedDate <=: nowTime AND (Last_Batch_Date_Time__c >: lowestTime OR Last_Batch_Date_Time__c = null) AND Message_Type__c = \'SMS\' AND Status__c = \'Not Sent\' ';
            // System.debug('BatchMailUpSMSModified.start - query: '+query);
            // System.debug('BatchMailUpSMSModified.start - nowTime: '+nowTime);
            // System.debug('BatchMailUpSMSModified.start - lowestTime: '+lowestTime);
            // System.debug('BatchMailUpSMSModified.start'+[SELECT LastModifiedDate, Last_Batch_Date_Time__c, SMS_Subject__c, SMS_Template__c, Prefix_Phone_Number__c, Phone_Number__c, Id_Group__c, Id_List__c, SMS_Type__c, Message_Type__c, Status__c, Case__c, ServiceRequest__c FROM Activity_Case_Error__c]);
            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Exception at BatchMailUpSMS.start ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);

            return Database.getQueryLocator('SELECT id FROM Activity_Case_Error__c LIMIT 0');
        }
    }

    global void execute(Database.BatchableContext BC, List<Activity_Case_Error__c> scope) {
        System.debug('EXECUTE at BatchMailUpSMSV2');
        System.debug('scope.size() ' + scope.size());

        if(scope != null && !scope.isEmpty()) {
            try {
                Boolean toUpdate = false;
                SMSWrapper smsWrapper = new SMSWrapper();
                List<String> activityCaseErrorIds = new List<String>();
                List<Activity_Case_Error__c> activityCaseErrors = new List<Activity_Case_Error__c>();

                for(Activity_Case_Error__c ace : scope) {
                    smsWrapper.idList = orgSetting.Id_List_MailUp__c;
                    smsWrapper.smsSubject = ace.SMS_Subject__c;
                    smsWrapper.smsBody = ace.SMS_Template__c;
                    smsWrapper.contentLength = String.valueOf(ace.SMS_Template__c.length());
                    smsWrapper.phoneNumber = ace.Phone_Number__c;
                    smsWrapper.prefixPhoneNumber = ace.Prefix_Phone_Number__c;
                    smsWrapper.caseId = ace.Case__c;
                    smsWrapper.serviceRequestId = ace.ServiceRequest__c;

                    // if(ace.Service_Appointment__c == null) {
                        // smsWrapper.caseId = ace.Case__c;
                    // } else if(ace.Service_Appointment__c != null) {
                        // smsWrapper.serviceAppointmentId = ace.Service_Appointment__c;
                        // smsWrapper.smsType = ace.SMS_Type__c;
                    // }

                    Boolean isFailed = MailUpCreateSMSCallout.mailUpCreateSMSCallout(smsWrapper);

                    if(!isFailed) {
                        activityCaseErrorIds.add(ace.Id);
                    } else if(isFailed && ace.Last_Batch_Date_Time__c == null) {
                        ace.Last_Batch_Date_Time__c = Datetime.now();
                        activityCaseErrors.add(ace);
                        toUpdate = true;
                    }
                }

                SMSService.insertSMSs(smsWrapper.smsList, false);
                ActivityCaseErrorService.deleteActivityCaseErrors(activityCaseErrorIds, false);
                if(toUpdate) ActivityCaseErrorService.updateActivityCaseErrors(activityCaseErrors, false);
                CalloutLoggerService.insertCalloutLoggers(smsWrapper.calloutLoggers, false);
                ErrorLogEventHandler.publishEventsDMLSafe(smsWrapper.errorLogEvents);
            } catch(Exception e) {
                System.debug('Exception at BatchMailUpSMSModified execute: ' + e.getMessage());
                Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
                ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('FINISH at BatchMailUpSMSV2');
    }

    global static void execute(SchedulableContext ctx) {
        try {
            Database.executeBatch(new BatchMailUpSMSModified(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            System.debug('Exception at BatchMailUpSMSModified execute scheduled: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
}