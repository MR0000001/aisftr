/**
 * Created by LCONATO00 on 07/05/2020.
 */

global without sharing class StructureFisicalDeleteBatch implements Database.Batchable<sObject>, Database.Stateful{
    private List<Structure__c> structuresDeleted = new List<Structure__c>();
    private FisicalDeleteBatch_Setting__c setting = FisicalDeleteBatch_Setting__c.getValues('StructureFisicalDeleteBatch');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            Datetime refDatetime = Datetime.now().addDays(Integer.valueOf(setting.days__c));
            String query = 'SELECT Id, LastModifiedWSO2__c, IsDeleted__c, Name ' +
                    'FROM Structure__c ' +
                    'WHERE Logical_Delete_Time__c <: refDatetime AND IsDeleted__c = TRUE';

            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Exception at StructureFisicalDeleteBatch start: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        return null;
    }

    global void execute(Database.BatchableContext BC, List<Structure__c> scope) {
        try {
            this.structuresDeleted = scope;
            StructureService.deleteStructures(scope, false);
        } catch(Exception e) {
            System.debug('Exception at StructureFisicalDeleteBatch execute: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    global void finish(Database.BatchableContext BC) {
        try {
            system.debug('@@@ this.structuresDeleted '+this.structuresDeleted);
            sendRecapMail(this.structuresDeleted);

        } catch (Exception e) {
            System.debug('Exception at StructureFisicalDeleteBatch finish: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
    private void sendRecapMail(List<Structure__c> listStructures) {
        system.debug('@@@ listStructures '+listStructures);
        User adminUser = UserSelector.getAdminUser();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[]{
                adminUser.Email
        };
        message.subject = setting.subject__c + ' ' + String.valueOf(Datetime.now());
        String bodyHtml;
        if (listStructures != null && !listStructures.isEmpty()) {
            bodyHtml = setting.bodyHtml__c;
            for (Structure__c structure : listStructures) {
                bodyHtml += ('- ' + structure.Name + '<br />');
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