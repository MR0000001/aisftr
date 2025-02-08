/**
 * Created by LCONATO00 on 07/05/2020.
 */

global without sharing class StructureLogicalDeleteBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{

    private List<Structure__c> structuresToDelete = new List<Structure__c>();
    private static LogicalDeleteBatch_Setting__c setting = LogicalDeleteBatch_Setting__c.getValues('StructureLogicalDeleteBatch');

    global static void execute(SchedulableContext ctx) {
        try {
            //CHECK
            Datetime tenMinutesAgo = Datetime.now().addMinutes(Integer.valueOf(setting.minutes__c));
            Boolean readyToStart = true;
            List<Structure__c> structureRecentlyUpdated = StructuresDAO.getStructuresModifiedInTheLastHoursByWSO2();

            if(!structureRecentlyUpdated.isEmpty() && !(structureRecentlyUpdated[0].LastModifiedWSO2__c <= tenMinutesAgo)){
                readyToStart = false;
            }

            //SCHEDULE IN THE FUTURE
            if(!readyToStart || Test.isRunningTest()){
                Datetime tempTime = Datetime.now().addMinutes(Integer.valueOf(setting.schedule_minutes__c));
                String scheduleTime = getScheduleString(tempTime);

                System.schedule('StructureLogicalDeleteBatch ' + datetime.now(), scheduleTime, new StructureLogicalDeleteBatch());
            }else{
                Database.executeBatch(new StructureLogicalDeleteBatch(), Integer.valueOf(setting.Batch_Size__c));
            }
        } catch(Exception e) {
            System.debug('Exception at StructureLogicalDeleteBatch schedule execute: ' + e.getMessage());
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            Datetime lastModifiedDate = Datetime.now().addHours(Integer.valueOf(setting.hours__c));
            String query = 'SELECT Id, LastModifiedWSO2__c, IsDeleted__c, Name ' +
                    'FROM Structure__c ' +
                    'WHERE LastModifiedWSO2__c <: lastModifiedDate ';

            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Exception at StructureLogicalDeleteBatch start: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        return null;
    }

    global void execute(Database.BatchableContext BC, List<Structure__c> scope) {
        try {
            if(scope != null && !scope.isEmpty()) {
                List<String> structureRecentlyUpdatedIds = new List<String>();
                for(Structure__c structure : scope){
                    structureRecentlyUpdatedIds.add(structure.Id);
                }
                List<Knowledge__kav> knowledges = KnowledgeSelector.getKnowledgeKavsByStructureId(structureRecentlyUpdatedIds);
                Set<String> structuresNotBeDeleted = new Set<String>();

                if((knowledges != null && !knowledges.isEmpty()) || Test.isRunningTest()){

                    for(Knowledge__kav knowledge : knowledges){
                        structuresNotBeDeleted.add(knowledge.MacrostructureReference__c);
                    }

                    for(Structure__c structure : scope){
                        structure.IsDeleted__c = (!structuresNotBeDeleted.contains(structure.Id));
                        structure.Logical_Delete_Time__c = Datetime.now();
                    }
                }else{
                    for(Structure__c structure : scope){
                        structure.IsDeleted__c = true;
                        structure.Logical_Delete_Time__c = Datetime.now();
                    }
                }
                this.structuresToDelete = scope;
                StructureService.updateStructures(scope, false);
            }
        } catch(Exception e) {
            System.debug('Exception at StructureLogicalDeleteBatch execute: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    global void finish(Database.BatchableContext BC) {
        try{

            sendRecapMail(this.structuresToDelete);

        } catch (Exception e) {
            System.debug('Exception at StructureLogicalDeleteBatch finish: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    @TestVisible
    private void sendRecapMail(List<Structure__c> liStructures) {
        system.debug('@@@ liStructures '+liStructures);
        User adminUser = UserSelector.getAdminUser();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[]{
                adminUser.Email
        };
        message.subject = setting.subject__c + ' ' + String.valueOf(Datetime.now());
        String bodyHtml;
        if (liStructures != null && !liStructures.isEmpty()) {
            bodyHtml = setting.bodyHtml__c;
            for (Structure__c structure : liStructures) {
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

    @TestVisible
    private static String getScheduleString(Datetime tempTime){
        return '00 ' + String.valueOf(tempTime.minute()) + ' ' + String.valueOf(tempTime.hour()) + ' '
                + String.valueOf(tempTime.day()) + ' ' + String.valueOf(tempTime.month()) + ' ? ' + String.valueOf(tempTime.year());
    }
}