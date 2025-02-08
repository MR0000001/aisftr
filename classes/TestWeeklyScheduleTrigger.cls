/**
 * Created by snekkanti002 on 02/11/2022.
 */

@IsTest
public without sharing class TestWeeklyScheduleTrigger {

    @TestSetup
    public static void setup() {
        TestDataFactory.createAnotherUserWithRoleLeaderCC();
    }

    @IsTest
    public static void weeklyScheduleTest() {
        TestDataFactory.listStructures();

        Test.startTest();
        Structure__c structure = [SELECT Id FROM Structure__c LIMIT 1];
        Weekly_Schedule__c w = new Weekly_Schedule__c(All_Morning_Closed__c=true, All_Afternoon_Closed__c=true, Structure_Reference__c = structure.Id);
        try {
            insert w;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }

        try {
            update w;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }

        try {
            delete w;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void weeklyScheduleTestAsUser() {
        User u = [SELECT Id FROM User WHERE Email = 'test2@test.com'];

        Test.startTest();
        System.runAs(u) {
            List<Structure__c> structures = TestDataFactory.listStructures();
            TestDataFactory.listEmployeeSingle();
            Weekly_Schedule__c w = new Weekly_Schedule__c(All_Morning_Closed__c=true, All_Afternoon_Closed__c=true, Structure_Reference__c = structures[0].Id);
            try {
                insert w;
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }

            try {
                update w;
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }

            try {
                delete w;
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
        }
        Test.stopTest();
    }
}