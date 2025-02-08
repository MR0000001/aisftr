/**
 * Created by LCONATO00 on 07/05/2020.
 */
@isTest
public with sharing class TestDeleteLogicalRecordsScheduler {
    @testSetup static void setup() {
        List<LogicalDeleteBatch_Setting__c> batchCustomSettingList = TestDataFactory.createLogicalDeleteBatchSettings();
        List<Structure__c> structures = TestDataFactory.listMacroStructures();
        List<Employee__c> employees = TestDataFactory.listEmployee();
        List<Role__c> roles = TestDataFactory.listRoles(structures,employees);
        List<Knowledge__kav> listKnowlKavs = TestDataFactory.createKnowledgeNewsFromStructures(structures);
    }

    @isTest
    private static void executeEveryDayTest() {
        Test.startTest();
        StructureLogicalDeleteBatch.getScheduleString(Datetime.now());
        DeleteLogicalRecordsScheduler.executeEveryDay();
        System.schedule('TestRoleLogicalDeleteBatch', '0 17 * ? * * *', new RoleLogicalDeleteBatch());
        System.schedule('TestStructureLogicalDeleteBatch', '0 17 * ? * * *', new StructureLogicalDeleteBatch());
        System.schedule('TestEmployeeLogicalDeleteBatch', '0 17 * ? * * *', new EmployeeLogicalDeleteBatch());
        EmployeeLogicalDeleteBatch.getScheduleString(Datetime.now());
        RoleLogicalDeleteBatch.getScheduleString(Datetime.now());
        Test.stopTest();
    }

    @isTest
    private static void executeEveryDayTestEmpty() {
        Test.startTest();
        try {
            DELETE [SELECT Id FROM Structure__c];
            StructureLogicalDeleteBatch structureLogicalDeleteBatch = new StructureLogicalDeleteBatch();
            structureLogicalDeleteBatch.sendRecapMail([SELECT id, Name FROM Structure__c]);
        } catch(Exception e) {
            System.debug('Exception at TestDeleteLogicalRecordsScheduler.executeEveryDayTestEmpty ' + e.getMessage());
        }
        System.schedule('TestStructureLogicalDeleteBatch', '0 17 * ? * * *', new StructureLogicalDeleteBatch());
        Test.stopTest();
    }
}