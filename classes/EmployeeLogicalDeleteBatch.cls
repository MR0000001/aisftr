/**
 * Created by LCONATO00 on 07/05/2020.
 */

global without sharing class EmployeeLogicalDeleteBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    private List<Employee__c> employeesToDelete = new List<Employee__c>();
    private static LogicalDeleteBatch_Setting__c setting = LogicalDeleteBatch_Setting__c.getValues('EmployeeLogicalDeleteBatch');

    global static void execute(SchedulableContext ctx) {

        try {
            //CHECK
            Datetime tenMinutesAgo = Datetime.now().addMinutes(Integer.valueOf(setting.minutes__c));
            Boolean readyToStart = true;
            List<Employee__c> employeeRecentlyUpdated = EmployeesDAO.getEmployeesModifiedInTheLastHoursByWSO2();
            system.debug('@@@execute 1');

            if(!employeeRecentlyUpdated.isEmpty() && !(employeeRecentlyUpdated[0].LastModifiedWSO2__c <= tenMinutesAgo)){
                readyToStart = false;
            }

            //SCHEDULE IN THE FUTURE
            if(!readyToStart){
                Datetime tempTime = Datetime.now().addMinutes(Integer.valueOf(setting.schedule_minutes__c));
                String scheduleTime = getScheduleString(tempTime);

                System.schedule('EmployeeLogicalDeleteBatch ' + datetime.now(), scheduleTime, new EmployeeLogicalDeleteBatch());
            }else{
                Database.executeBatch(new EmployeeLogicalDeleteBatch(), Integer.valueOf(setting.Batch_Size__c));
            }
        } catch(Exception e) {
            System.debug('Exception at EmployeeLogicalDeleteBatch schedule execute: ' + e.getMessage());
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            system.debug('@@@ start');
            Datetime refDatetime = Datetime.now().addHours(Integer.valueOf(setting.hours__c));

            String query = 'SELECT Id, LastModifiedWSO2__c, IsDeleted__c, Name ' +
                    'FROM Employee__c ' +
                    'WHERE LastModifiedWSO2__c <: refDatetime AND IsDeleted__c = FALSE ';
            system.debug('@@@ query employee2 '+ [SELECT Id, LastModifiedWSO2__c, IsDeleted__c, Name FROM Employee__c WHERE LastModifiedWSO2__c <: refDatetime AND IsDeleted__c = FALSE ]);
            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Exception at EmployeeLogicalDeleteBatch start: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        return null;
    }

    global void execute(Database.BatchableContext BC, List<Employee__c> scope) {
        system.debug('@@@execute 2');
        try {
            if(scope != null && !scope.isEmpty()) {
                for(Employee__c employee : scope){
                    employee.IsDeleted__c = true;
                    employee.Logical_Delete_Time__c = Datetime.now();
                }
                this.employeesToDelete = scope;
                EmployeeService.updateEmployees(this.employeesToDelete, false);
            }
        } catch(Exception e) {
            System.debug('Exception at EmployeeLogicalDeleteBatch execute: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    global void finish(Database.BatchableContext BC) {
        system.debug('@@@ finish');
        try{

            sendRecapMail(this.employeesToDelete);
        }catch (Exception e) {throw ErrorLogEventHandler.standardExceptionLog(e);}
    }

    private void sendRecapMail(List<Employee__c> listEmployees) {
        User adminUser = UserSelector.getAdminUser();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[]{
                adminUser.Email
        };
        message.subject = setting.subject__c + ' ' + String.valueOf(Datetime.now());
        String bodyHtml;
        if (listEmployees != null && !listEmployees.isEmpty()) {
            bodyHtml = setting.bodyHtml__c;
            for (Employee__c employee : listEmployees) {
                bodyHtml += ('- ' + employee.Name + '<br />');
            }
            message.setHtmlBody(bodyHtml);
        } else {
            message.setHtmlBody(setting.bodyHtmlAlternative__c);
        }
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
                message
        };

        Messaging.sendEmail(messages);
    }

    @TestVisible
    private static String getScheduleString(Datetime tempTime){
        return '00 ' + String.valueOf(tempTime.minute()) + ' ' + String.valueOf(tempTime.hour()) + ' '
                + String.valueOf(tempTime.day()) + ' ' + String.valueOf(tempTime.month()) + ' ? ' + String.valueOf(tempTime.year());
    }

}