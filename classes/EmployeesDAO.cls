/**
 * Created by LCONATO00 on 16/06/2020.
 */

public with sharing class EmployeesDAO {
    public static List<Employee__c> getEmployeesBySerialNumber(String serialNumber){
        List<Employee__c> employees = new List<Employee__c>();
        employees = [SELECT Id FROM Employee__c WHERE SerialNumber__c =: serialNumber];
        return employees;
    }
    public static List<Employee__c> getEmployeesModifiedInTheLastHoursByWSO2(){
        List<Employee__c> employeesModified = new List<Employee__c>();
        Datetime forHoursAgo = datetime.now().addHours(-24);
        employeesModified = [SELECT Id, LastModifiedWSO2__c, IsDeleted__c FROM Employee__c WHERE LastModifiedWSO2__c <:forHoursAgo ORDER BY LastModifiedDate DESC LIMIT 1];
        return employeesModified;
    }

    public static void deleteEmployees(List<Employee__c> employees, Boolean allOrNone) {
        try {
            Database.DeleteResult[] results = Database.delete(employees, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at EmployeesDAO.deleteEmployees: ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }

    public static void updateEmployees(List<Employee__c> employees, Boolean allOrNone) {
        try {
            Database.SaveResult[] results = Database.update(employees, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at EmployeesDAO.updateEmployees: ' + e.getMessage());

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
}