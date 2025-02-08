/**
 * Created by LCONATO00 on 06/05/2020.
 */

global without sharing class RoleLogicalDeleteBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{

    private List<Role__c> rolesToDelete = new List<Role__c>();
    private static LogicalDeleteBatch_Setting__c setting = LogicalDeleteBatch_Setting__c.getValues('RoleLogicalDeleteBatch');

    global static void execute(SchedulableContext ctx) {

        try {
            //CHECK
            Datetime tenMinutesAgo = Datetime.now().addMinutes(Integer.valueOf(setting.minutes__c));
            Boolean readyToStart = true;
            List<Role__c> roleRecentlyUpdated = RoleDAO.getRolesModifiedInTheLastHoursByWSO2();

            if(!roleRecentlyUpdated.isEmpty() && !(roleRecentlyUpdated[0].LastModifiedWSO2__c <= tenMinutesAgo)){
                readyToStart = false;
            }

            //SCHEDULE IN THE FUTURE
            if(!readyToStart){
                Datetime tempTime = Datetime.now().addMinutes(Integer.valueOf(setting.schedule_minutes__c));
                String scheduleTime = getScheduleString(tempTime);

                System.schedule('RoleLogicalDeleteBatch ' + datetime.now(), scheduleTime, new RoleLogicalDeleteBatch());
            }else{
                Database.executeBatch(new RoleLogicalDeleteBatch(), Integer.valueOf(setting.Batch_Size__c));
            }
        } catch(Exception e) {
            System.debug('Exception at RoleLogicalDeleteBatch schedule execute: ' + e.getMessage());
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            Datetime refDatetime = Datetime.now().addHours(Integer.valueOf(setting.hours__c));
            String query = 'SELECT Id, LastModifiedWSO2__c, IsDeleted__c, Name ' +
                    'FROM Role__c ' +
                    'WHERE LastModifiedWSO2__c <: refDatetime AND IsDeleted__c = FALSE ';

            return Database.getQueryLocator(query);
        } catch (Exception e) {throw ErrorLogEventHandler.standardExceptionLog(e);}
    }

    global void execute(Database.BatchableContext BC, List<Role__c> scope) {
        try {
            if(scope != null && !scope.isEmpty()) {
                for(Role__c role:scope){
                    role.IsDeleted__c = true;
                    role.Logical_Delete_Time__c = Datetime.now();
                }
                this.rolesToDelete = scope;
                RoleService.updateRoles(scope, false);
            }
        } catch(Exception e) {
            System.debug('Exception at RoleLogicalDeleteBatch execute: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    global void finish(Database.BatchableContext BC) {
        try{

            sendRecapMail(this.rolesToDelete);

        }catch (Exception e) {throw ErrorLogEventHandler.standardExceptionLog(e);}
    }

    private void sendRecapMail(List<Role__c> listRoles) {
        system.debug('@@@ listRoles '+listRoles);
        User adminUser = UserSelector.getAdminUser();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[]{
                adminUser.Email
        };
        message.subject = setting.subject__c + ' ' + String.valueOf(Datetime.now());
        String bodyHtml;
        if (listRoles != null && !listRoles.isEmpty()) {
            bodyHtml = setting.bodyHtml__c;
            for (Role__c role : listRoles) {
                bodyHtml += ('- ' + role.Name + '<br />');
            }
            message.setHtmlBody(bodyHtml);
        } else {
            message.setHtmlBody(setting.bodyHtmlAlternative__c);
        }
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
                message
        };
        system.debug('@@@ sendEmail '+messages);
        Messaging.sendEmail(messages);
    }

    @TestVisible
    private static String getScheduleString(Datetime tempTime){
        return '00 ' + String.valueOf(tempTime.minute()) + ' ' + String.valueOf(tempTime.hour()) + ' '
                + String.valueOf(tempTime.day()) + ' ' + String.valueOf(tempTime.month()) + ' ? ' + String.valueOf(tempTime.year());
    }
}