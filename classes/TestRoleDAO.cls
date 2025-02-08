/**
 * Created by SNEKKANTI00 on 27/04/2021.
 */

@isTest
public with sharing class TestRoleDAO {

    @TestSetup
    public static void setup() {
        TestDataFactory.listRole();
    }

    @isTest
    public static void getRolesByEmployeeSerialNumberAndStructureId() {
        List<Employee__c> employees = [SELECT SerialNumber__c FROM Employee__c];

        Test.startTest();
        RoleDAO.getRolesByEmployeeSerialNumberAndStructureId(employees[0].SerialNumber__c);
        Test.stopTest();
    }

    @isTest
    public static void getRolesModifiedInTheLastHoursByWSO2() {
        Test.startTest();
        RoleDAO.getRolesModifiedInTheLastHoursByWSO2();
        Test.stopTest();
    }

    @isTest
    public static void deleteRoles() {
        List<Role__c> roles = [SELECT id FROM Role__c];

        Test.startTest();
        RoleDAO.deleteRoles(roles, false);
        Test.stopTest();
    }

    @isTest
    public static void updateEmployees() {
        Role__c role = new Role__c();

        List<Role__c> roles = [SELECT id FROM Role__c];

        Test.startTest();
        RoleDAO.updateRoles(roles, false);
        roles.add(role);
        RoleDAO.updateRoles(roles, true);
        Test.stopTest();
    }
}