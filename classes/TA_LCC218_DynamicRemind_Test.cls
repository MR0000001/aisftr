@isTest
public with sharing class TA_LCC218_DynamicRemind_Test {
    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
    }

    @isTest
    public static void testMethod_1() {
        List<String> masterLabels = new List<String>{'TA_ReminderLabel4', 'TA_ReminderValue3'};
        test.startTest();
        TA_LCC218_DynamicRemind.getCustomLabels('en_US', masterLabels);
        test.stopTest();
    }

    @isTest
    public static void testMethod_2() {
        test.startTest();
        TA_LCC218_DynamicRemind.getCustomLabels(null, null);
        test.stopTest();
    }
}