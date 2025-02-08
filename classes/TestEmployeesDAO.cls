/**
 * Created by SNEKKANTI00 on 27/04/2021.
 */

@isTest
public with sharing class TestEmployeesDAO {

    @TestSetup
    public static void setup() {
        TestDataFactory.listEmployee();
    }

    @isTest
    public static void getEmployeesBySerialNumber() {
        List<Employee__c> employees = [SELECT SerialNumber__c FROM Employee__c];

        Test.startTest();
        EmployeesDAO.getEmployeesBySerialNumber(employees[0].SerialNumber__c);
        Test.stopTest();
    }

    @isTest
    public static void getEmployeesModifiedInTheLastHoursByWSO2() {
        Test.startTest();
        EmployeesDAO.getEmployeesModifiedInTheLastHoursByWSO2();
        Test.stopTest();
    }

    @isTest
    public static void deleteEmployees() {
        List<Employee__c> employees = [SELECT id FROM Employee__c];

        Test.startTest();
        EmployeesDAO.deleteEmployees(employees, false);
        Test.stopTest();
    }

    @isTest
    public static void updateEmployees() {
        Employee__c employee = new Employee__c();

        List<Employee__c> employees = [SELECT id FROM Employee__c];

        Test.startTest();
        EmployeesDAO.updateEmployees(employees, true);
        employees.add(employee);
        EmployeesDAO.updateEmployees(employees, true);
        Test.stopTest();
    }
}