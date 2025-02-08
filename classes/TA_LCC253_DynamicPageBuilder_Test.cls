/**
 * @description       : Test class for TA_LCC253_DynamicPageBuilder
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 28-05-2021
 * @last modified by  : benjamin.geronimo
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   28-05-2021   benjamin.geronimo   Initial Version
**/
@IsTest
public with sharing class TA_LCC253_DynamicPageBuilder_Test {

    @isTest
    private static void test_getPageConfigurations() {
        // Test data setup
        TA_Phase_Configuration__c newPhaseHome = new TA_Phase_Configuration__c (Name = 'TA_Phase_HomePage', TA_DeveloperName__c = 'HomePage', TA_Hidden__c = false, TA_External_Id__c = 'TA_Phase_000000');
        insert newPhaseHome;

        TA_Capability_Configuration__c cc = new TA_Capability_Configuration__c(
            TA_Active__c  = true,
            TA_Configuration_Set__c = 'B2C_Italy_Set',
            TA_DeveloperName__c = 'TA_LCP256_DynamicAppointmentPreview',
            TA_JSON_Param__c = '',
            TA_Index__c  = 2,
            TA_Phase__c = newPhaseHome.Id,
            TA_Type__c = 'Layout',
            TA_Value__c = 'Homepage',
            TA_External_Id__c = 'TA_Capability_000281'
        );

        insert cc;


        // Actual test
        Test.startTest();
        TA_LCC253_DynamicPageBuilder.getPageConfigurations('Home');
        TA_LCC253_DynamicPageBuilder.getPageConfigurations('Custom Calendar');
        TA_LCC253_DynamicPageBuilder.getPageConfigurations(null);
        Test.stopTest();

        // Asserts
    }

}