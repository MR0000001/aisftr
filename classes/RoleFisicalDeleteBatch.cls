/**
 * Created by LCONATO00 on 06/05/2020.
 */

global without sharing class RoleFisicalDeleteBatch implements Database.Batchable<sObject>, Database.Stateful{
    private List<Role__c> rolesDeleted = new List<Role__c>();
    private FisicalDeleteBatch_Setting__c setting = FisicalDeleteBatch_Setting__c.getValues('RoleFisicalDeleteBatch');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            Datetime refDatetime = Datetime.now().addDays(Integer.valueOf(setting.days__c));
            String query = 'SELECT Id, LastModifiedWSO2__c, IsDeleted__c, Name ' +
                    'FROM Role__c ' +
                    'WHERE Logical_Delete_Time__c <: refDatetime AND IsDeleted__c = TRUE';

            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Exception at RoleFisicalDeleteBatch start: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        return null;
    }

    global void execute(Database.BatchableContext BC, List<Role__c> scope) {
        try {
            this.rolesDeleted = scope;
            RoleService.deleteRoles(scope, false);
        } catch(Exception e) {
            System.debug('Exception at RoleFisicalDeleteBatch execute: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }

    }

    global void finish(Database.BatchableContext BC) {
        try{
            system.debug('@@@ this.rolesDeleted '+this.rolesDeleted);
            sendRecapMail(this.rolesDeleted);

        }catch (Exception e) {
            System.debug('Exception at RoleFisicalDeleteBatch finish: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
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
}