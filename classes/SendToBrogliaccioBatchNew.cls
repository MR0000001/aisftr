/**
 * Created by snekkanti002 on 27/09/2021.
 */

global without sharing class SendToBrogliaccioBatchNew implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    private static BrogliaccioBatch_Setting__c setting = BrogliaccioBatch_Setting__c.getValues('SendToBrogliaccioBatch');

    global Database.QueryLocator start(Database.BatchableContext bc) {
        DebugService.printLimits('SendToBrogliaccioBatchNew', 'start', 'beginning');
        try {
            DateTime nowTime = datetime.now();
            DateTime lowestTime = nowTime.addHours(-Integer.valueOf(setting.Lowest_Time_Hours__c));
            DateTime upperTime = nowTime.addMinutes(-Integer.valueOf(setting.Upper_Time_Minutes__c));
            System.debug('lowestTime ' + lowestTime);
            System.debug('upperTime ' + upperTime);
            String groupName = setting.Group_Name__c;

            String query = 'SELECT Id, Last_Batch_Date_Time__c, Status, CreatedDate, Case_Specification__c, ExternalSystemId_Brogliaccio__c, Street_Address__c, Number_Address__c, Account.Name, ContactMobile, To_be_sent_Brogliaccio__c, All_Content_Versions_Integrated__c, Geolocation__Latitude__s, Sent_to_External__c, Geolocation__Longitude__s, Subject, Current_Queue__c, Comment_User__c, Brogliaccio_DescriptioError__c, Brogliaccio_N_Attachment__c '
                    + 'FROM Case WHERE Brogliaccio_Reject__c  = false AND (Status != \'In Creazione\' AND Estimated_Queue__c =: groupName AND LastModifiedDate <: upperTime AND (Last_Batch_Date_Time__c >: lowestTime OR Last_Batch_Date_Time__c = null) AND ((Sent_to_External__c = \'Sync\' AND All_Content_Versions_Integrated__c = false) OR (Sent_to_External__c = \'Not Sync\' AND Status != \'Closed\') OR (Sent_to_External__c = \'To Be Sync\' AND Status != \'Closed\')))';
            DebugService.printLimits('SendToBrogliaccioBatchNew', 'start', 'return');

            return Database.getQueryLocator(query);
        } catch (Exception e) {
            DebugService.printException('SendToBrogliaccioBatchNew', 'start', e);
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        DebugService.printLimits('SendToBrogliaccioBatchNew', 'start', 'end');
        return Database.getQueryLocator('SELECT Id FROM CASE LIMIT 0');
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        DebugService.printLimits('SendToBrogliaccioBatchNew', 'execute', 'start');
        System.debug('@@@ scope '+ scope.size());
        System.debug('scope '+ scope);

        try {
            BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapper = new BrogliaccioCaseListWrapperNew(false, scope);

        	System.debug('brogliaccioCaseListWrapper '+ brogliaccioCaseListWrapper);
            List<Case> cases = BrogliaccioCaseCalloutNew.brogliaccioCaseCallout(brogliaccioCaseListWrapper);
        	System.debug('cases '+ cases);

            DebugService.printList('SendToBrogliaccioBatchNew', 'execute', 'cases', cases);
            CaseService.updateCases(cases, false);
            System.debug('Finished updating cases');
        } catch(Exception e) {
            DebugService.printException('SendToBrogliaccioBatchNew', 'execute', e);
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        DebugService.printLimits('SendToBrogliaccioBatchNew', 'execute', 'end');
    }

    global void finish(Database.BatchableContext bc) {
        DebugService.printLimits('SendToBrogliaccioBatchNew', 'finish', 'start');
        DebugService.printLimits('SendToBrogliaccioBatchNew', 'finish', 'end');
    }

    global static void execute(SchedulableContext sc) {
        try {
            Database.executeBatch(new SendToBrogliaccioBatchNew(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            DebugService.printException('SendToBrogliaccioBatchNew', 'schedulable execute', e);
            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }
}