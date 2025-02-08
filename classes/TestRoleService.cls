/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */

@isTest
public with sharing class TestRoleService {
    @isTest
    public static void roleServiceTest() {
        List<User> users = TestDataFactory.createWSOUsers();
        List<Structure__c> listStructures = TestDataFactory.listStructures();
        List<Employee__c> listEmployees = TestDataFactory.listEmployee();
        List<Role__c> listRoleSingle = TestDataFactory.listRoleSingle(listStructures, listEmployees);

        Test.startTest();
        System.runAs(users[0]) {
            RoleService.TriggerHandlerPopolateBeforeInsertBeforeUpdate(listRoleSingle);
        }
        RoleService.TriggerHandlerPopolateBeforeInsertBeforeUpdate(listRoleSingle);
        Test.stopTest();
    }
}