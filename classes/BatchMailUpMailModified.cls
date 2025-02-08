/**
 * Created by SNEKKANTI00 on 15/04/2021.
 */

global with sharing class BatchMailUpMailModified implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts {
    private static OrgManagement__c orgSetting = OrgManagement__c.getOrgDefaults();
    private static Email__c emailSetting = Email__c.getOrgDefaults();
    private static MailUpBatch_Settings__c setting = MailUpBatch_Settings__c.getValues('BatchMailUp');
    private static List<MailUpGroup__c> groupSettings = MailUpGroup__c.getall().values();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('START at BatchMailUpMailModified');
        try {
            DateTime nowTime = datetime.now();
            DateTime lowestTime = nowTime.addHours(-Integer.valueOf(setting.Lowest_Time_Hours__c));

            String query = 'SELECT Last_Batch_Date_Time__c, Email_Subject__c, Case__c, Case__r.Status, Case__r.Sub_Status__c, Case__r.SendEmail__c, Case__r.OwnerId, Case__r.Owner.Name, Case__r.Owner.type, Email_Template__c, PEC_External_System__c, Email_External_System__c, AMA_Ricicla_Casa_Email__c, AMA_Ricicla_Casa_Queue__c, Id_Group__c, Id_List__c, Send_to_Recipient__c, Message_Type__c, PEC_Value__c, Queue_Email__c, Queue_Name__c, Status__c, Case__r.ContactEmail, Case__r.SuppliedEmail ' +
                    'FROM Activity_Case_Error__c ' +
                    'WHERE LastModifiedDate <: nowTime AND (Last_Batch_Date_Time__c >: lowestTime OR Last_Batch_Date_Time__c = null) AND Message_Type__c = \'Email\' AND Status__c = \'Not Sent\'';

            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Exception at BatchMailUpMailModified.start ' + e.getMessage());
            ErrorLogEventHandler.standardExceptionLog(e);

            return Database.getQueryLocator('SELECT id FROM Activity_Case_Error__c LIMIT 0');
        }
    }

    global void execute(Database.BatchableContext BC, List<Activity_Case_Error__c> scope) {
        System.debug('EXECUTE at BatchMailUpMailModified');
        System.debug('scope.size() ' + scope.size());

        if(scope != null && !scope.isEmpty()) {
            try {
                Boolean makeCallout = false;
                String ownerName;
                MailUpGroup__c mailUpGroup;
                Boolean isFailed = true;
                Boolean toUpdate = false;
                Set<String> caseIds = new Set<String>();
                Set<String> groupIds = new Set<String>();
                List<String> groupDevNames = new List<String>();
                List<String> activityCaseErrorIds = new List<String>();
                List<Activity_Case_Error__c> activityCaseErrors = new List<Activity_Case_Error__c>();
                Map<String, MailUpGroup__c> mailUpGroupMap = new Map<String, MailUpGroup__c>();
                Map<String, String> groupEmails = new Map<String, String>();
                MailUpMailWrapper mailUpMailWrapper = new MailUpMailWrapper();

                for(Activity_Case_Error__c ace : scope) groupIds.add(ace.Case__r.OwnerId);

                List<Group> groups = GroupsSelector.getGroupsByIds(groupIds);

                for(Group g : groups) {
                    if(!groupDevNames.contains(g.DeveloperName)) {
                        groupDevNames.add(g.DeveloperName);
                        groupEmails.put(g.DeveloperName, g.Email);
                    }
                }

                if(Test.isRunningTest()) {
                    groupDevNames.add('TestGroupMail');
                    groupEmails.put('TestGroupMail', 'test@test.com');
                }

                for(MailUpGroup__c mg : groupSettings) mailUpGroupMap.put(mg.DeveloperNameQueue__c, mg);

                for(Activity_Case_Error__c ace : scope) {
                    mailUpMailWrapper.caseId = ace.Case__c;
                    mailUpMailWrapper.templateBody = ace.Email_Template__c;
                    mailUpMailWrapper.templateSubject = ace.Email_Subject__c;
                    mailUpMailWrapper.pecExternalSystem = emailSetting.PEC_External_System__c;
                    mailUpMailWrapper.emailExternalSystem = (ace.Send_to_Recipient__c) ? emailSetting.WorkingCase__c : emailSetting.EmailExternalSystem__c;
                    mailUpMailWrapper.amaRiciclaCasaEmail = orgSetting.AMARiciclaCasaEmail__c;
                    mailUpMailWrapper.amaRiciclaCasaQueue = orgSetting.AMARiciclaCasaQueue__c;


                    if(Test.isRunningTest() || (!ace.Send_to_Recipient__c && ace.Case__r?.Owner?.type?.equalsIgnoreCase('Queue'))) {
                        ownerName = (!Test.isRunningTest()) ? ace.Case__r.Owner.Name.replace(' ', '_') + '_External' : 'TestGroupMail';
                        mailUpGroup = mailUpGroupMap.get(ownerName);
                    }

                    if(mailUpGroup != null && !ace.Send_to_Recipient__c) {
                        System.debug('groupDevNames ' + groupDevNames);
                        mailUpMailWrapper.pecValue = mailUpGroup.PEC__c;
                        mailUpMailWrapper.listId = mailUpGroup.Id_List__c;
                        mailUpMailWrapper.queueName = groupDevNames.get(groupDevNames.indexOf(ownerName));
                        mailUpMailWrapper.queueEmail = groupEmails.get(mailUpMailWrapper.queueName);

                        mailUpMailWrapper.groupId = mailUpGroup.Name;
                        mailUpMailWrapper.isForRecipient = ace.Send_to_Recipient__c;
                        makeCallout = true;
                    } else if(ace.Send_to_Recipient__c) {
                        mailUpMailWrapper.listId = orgSetting.Id_List_MailUp_Email__c;
                        mailUpMailWrapper.pecValue = false;
                        mailUpMailWrapper.isForRecipient = ace.Send_to_Recipient__c;
                        mailUpMailWrapper.recipientMail = (String.isNotBlank(ace.Case__r.ContactEmail)) ? ace.Case__r.ContactEmail : ace.Case__r.SuppliedEmail;
                        makeCallout = true;
                    }

                    if(makeCallout) {
                        isFailed = MailUpCreateMailCallout.mailUpCreateMailCallout(mailUpMailWrapper);
                    } else {
                        ErrorLogEventHandler.createEvent('No Callout Made from BatchMailUpMailModified');
                    }

                    if(!isFailed) {
                        activityCaseErrorIds.add(ace.Id);
                        if(!mailUpMailWrapper.isForRecipient) caseIds.add(ace.Case__c);
                    } else if(isFailed && ace.Last_Batch_Date_Time__c == null) {
                        ace.Last_Batch_Date_Time__c = Datetime.now();
                        activityCaseErrors.add(ace);
                        toUpdate = true;
                    }
                }

                CaseService.updateCasesForEmailExternal(new List<String>(caseIds), false);
                EmailMessageService.insertEmailMessages(mailUpMailWrapper.emailMessages, false);
                ActivityCaseErrorService.deleteActivityCaseErrors(activityCaseErrorIds, false);
                if(toUpdate) ActivityCaseErrorService.updateActivityCaseErrors(activityCaseErrors, false);
                CalloutLoggerService.insertCalloutLoggers(mailUpMailWrapper.calloutLoggers, false);
                ErrorLogEventHandler.publishEventsDMLSafe(mailUpMailWrapper.errorLogEvents);
            } catch(Exception e) {
                System.debug('Exception at BatchMailUpMailModified execute: ' + e.getMessage());
                Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

                ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('FINISH at BatchMailUpMailModified');
    }

    global static void execute(SchedulableContext ctx) {
        try {
            Database.executeBatch(new BatchMailUpMailModified(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            System.debug('Exception at BatchMailUpMailModified execute scheduled: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
}