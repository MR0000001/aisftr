/**
 * Created by LCONATO00 on 07/05/2020.
 */

global without sharing class EmployeeFisicalDeleteBatch implements Database.Batchable<sObject>, Database.Stateful{
    private List<Employee__c> employeesDeleted = new List<Employee__c>();
    private FisicalDeleteBatch_Setting__c setting = FisicalDeleteBatch_Setting__c.getValues('EmployeeFisicalDeleteBatch');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            Datetime refDatetime = Datetime.now().addDays(Integer.valueOf(setting.days__c));
            String query = 'SELECT Id, LastModifiedWSO2__c, IsDeleted__c, Name ' +
                    'FROM Employee__c ' +
                    'WHERE Logical_Delete_Time__c <: refDatetime AND IsDeleted__c = TRUE';

            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Exception at EmployeeFisicalDeleteBatch start: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        return null;
    }

    global void execute(Database.BatchableContext BC, List<Employee__c> scope) {
        try {
            this.employeesDeleted = scope;
            EmployeeService.deleteEmployees(scope, false);
        } catch(Exception e) {
            System.debug('Exception at EmployeeFisicalDeleteBatch execute: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }

    }

    global void finish(Database.BatchableContext BC) {
        try{
            system.debug('@@@ this.employeesDeleted '+this.employeesDeleted);
            sendRecapMail(this.employeesDeleted);

        }catch (Exception e) {
            System.debug('Exception at EmployeeFisicalDeleteBatch finish: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);

            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
    private void sendRecapMail(List<Employee__c> listEmployees) {
        system.debug('@@@ listEmployees '+listEmployees);
        User adminUser = UserSelector.getAdminUser();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[]{
                adminUser.Email
        };
        message.subject = setting.subject__c + ' ' + String.valueOf(Datetime.now());
        String bodyHtml;
        if (listEmployees != null && !listEmployees.isEmpty()) {
            system.debug('@@@ listEmployees2 '+listEmployees);
            bodyHtml = setting.bodyHtml__c;
            for (Employee__c employee : listEmployees) {
                bodyHtml += ('- ' + employee.Name + '<br />');
            }
            system.debug('@@@ bodyHtmlemploy '+bodyHtml);
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