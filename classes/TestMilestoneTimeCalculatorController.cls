/**
 * Created by FMARCHEGIA00 on 15/06/2021.
 */

@IsTest
private class TestMilestoneTimeCalculatorController {

    @TestSetup
    public static void setup() {
        TestDataFactory.createHolidays();
        TestDataFactory.createOrgManagementSettings();
        TestDataFactory.createSingleCasesWithoutCities();
    }

    @IsTest
    public static void testMilestoneTimeCalculator() {
        Test.startTest();
        List<Case> cases = [SELECT Id FROM Case];
        Integer res = MilestoneTimeCalculatorController.calculateMilestoneTriggerTime(cases[0].Id, null);
        system.assert(res > 0);
        Test.stopTest();
    }
}