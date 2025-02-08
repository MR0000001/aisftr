/**
 * Created by SNEKKANTI00 on 02/02/2021.
 */
@isTest
public with sharing class TestEmployeeService {

    @isTest
    public static void testEmployeeService() {
        List<Employee__c> employees = TestDataFactory.listEmployee();
        List<User> users = TestDataFactory.createWSOUsers();
        User qUser = [SELECT Id, Profile.Name FROM User WHERE Id =: users[0].Id];
        System.runAs(users[0]) {
            Test.startTest();
            EmployeeService.TriggerHandlerPopolateBeforeInsertBeforeUpdate(employees);
            Test.stopTest();
        }
    }
}