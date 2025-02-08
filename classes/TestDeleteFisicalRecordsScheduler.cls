/**
 * Created by LCONATO00 on 08/10/2020.
 */
@isTest
public with sharing class TestDeleteFisicalRecordsScheduler {
    @testSetup static void setup() {
        List<FisicalDeleteBatch_Setting__c> batchCustomSettingList = TestDataFactory.createFisicalDeleteBatchSettings();
        List<Structure__c> structures = TestDataFactory.listMacroStructures();
        List<Employee__c> employees = TestDataFactory.listEmployee();
        List<Role__c> roles = TestDataFactory.listRoles(structures,employees);
    }

    @isTest
    private static void executeEveryDayTest() {
        User u = TestDataFactory.createUser();

        Test.startTest();
        system.runAs(u) {
            String sch0 = '0 00 * * * ?';
            System.schedule('DeleteFisicalRecordsScheduler ' + ' hh:10', sch0, new DeleteFisicalRecordsScheduler());
        }
        Test.stopTest();
    }

    @isTest
    private static void executeEveryDayTestEmpty() {
        User u = TestDataFactory.createUser();

        Test.startTest();
        system.runAs(u) {
            String sch0 = '0 00 * * * ?';
            try {
                DELETE [SELECT Id FROM Employee__c];
                DELETE [SELECT Id FROM Role__c];
                DELETE [SELECT Id FROM Structure__c];
            } catch(Exception e) {
                System.debug('Exception at TestDeleteFisicalRecordsScheduler.executeEveryDayTestEmpty ' + e.getMessage());
            }
            System.schedule('DeleteFisicalRecordsScheduler ' + ' hh:11', sch0, new DeleteFisicalRecordsScheduler());
        }
        Test.stopTest();
    }
}