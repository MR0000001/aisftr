/**
 * @description       : Test Class for TA_LCC254_DynamicHomepage
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 28-05-2021
 * @last modified by  : benjamin.geronimo
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   28-05-2021   benjamin.geronimo   Initial Version
**/
@isTest
public with sharing class TA_LCC254_DynamicHomepage_Test {


    @isTest
    private static void test_getCustomLabels() {
        // Test data setup

        // Actual test
        Test.startTest();
        TA_LCC254_DynamicHomepage.getCustomLabels(new List<String>{'TA_HomepageTab_CheckAppointment'});
        TA_LCC254_DynamicHomepage.getCustomLabels(null);
        Test.stopTest();

        // Asserts
    }

}