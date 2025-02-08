@isTest
public with sharing class TA_LCC201_DynamicLayoutController_Test {
    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
    }

    @isTest
    static void testMethod1() {
        String confSet = 'Italy_Set';
        WorkOrder workOrderTest = new WorkOrder(TA_Phase__c = 'PreService_Lock', XC_WorkTypeCategory__c = 'Delivery & Installation');
        insert workOrderTest;

        TA_Phase_Configuration__c newPhase = new  TA_Phase_Configuration__c();
        newPhase.TA_External_Id__c = 'test';
        newPhase.TA_DeveloperName__c = 'PreService_Lock';
        insert newPhase;

        ServiceAppointment newAddress = new ServiceAppointment();
        newAddress.ParentRecordId = workOrderTest.Id;
        //insert newAddress;

        List<TA_Capability_Configuration__c> newCapabilityList = new List<TA_Capability_Configuration__c>();

        TA_Capability_Configuration__c newCapability = new TA_Capability_Configuration__c();
        newCapability.TA_Configuration_Set__c = confSet;
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkType_Category__c = 'Delivery & Installation';
        newCapability.TA_DeveloperName__c = 'TA_LCP215_DynamicMultyQueryLayout';
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_Type__c = 'Layout';
        newCapability.TA_External_Id__c = 'test';
        newCapabilityList.add(newCapability);

        newCapability = new TA_Capability_Configuration__c();
        newCapability.TA_Configuration_Set__c = confSet;
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkType_Category__c = 'Delivery & Installation';
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_DeveloperName__c = 'TA_LCP214_DynamicTableLayout';
        newCapability.TA_Type__c = 'Layout';
        newCapability.TA_External_Id__c = 'test2';
        newCapabilityList.add(newCapability);

        newCapability = new TA_Capability_Configuration__c();
        newCapability.TA_Configuration_Set__c = confSet;
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkType_Category__c = 'Delivery & Installation';
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_DeveloperName__c = 'TA_LCP203_CapabilityMaps';
        newCapability.TA_Type__c = 'Layout';
        newCapability.TA_External_Id__c = 'test3';
        newCapabilityList.add(newCapability);

        newCapability = new TA_Capability_Configuration__c();
        newCapability.TA_Configuration_Set__c = confSet;
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkType_Category__c = 'Delivery & Installation';
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_DeveloperName__c = 'TA_LCP211_SecondaryContact';
        newCapability.TA_Type__c = 'Layout';
        newCapability.TA_External_Id__c = 'test4';
        newCapabilityList.add(newCapability);

        newCapability = new TA_Capability_Configuration__c();
        newCapability.TA_Configuration_Set__c = confSet;
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkType_Category__c = 'Delivery & Installation';
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_DeveloperName__c = 'TA_LCP218_DynamicRemind';
        newCapability.TA_Type__c = 'Layout';
        newCapability.TA_External_Id__c = 'test5';
        newCapabilityList.add(newCapability);

        newCapability = new TA_Capability_Configuration__c();
        newCapability.TA_Configuration_Set__c = confSet;
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkType_Category__c = 'Delivery & Installation';
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_DeveloperName__c = 'TA_LCP212_Measurement';
        newCapability.TA_Type__c = 'Layout';
        newCapability.TA_External_Id__c = 'test6';
        newCapabilityList.add(newCapability);
        insert newCapabilityList;

        TA_LCC201_DynamicLayoutContainer.GeneralInfoWrapper infoWrp = new TA_LCC201_DynamicLayoutContainer.GeneralInfoWrapper('TA_Phase__c', 'test');

        List<TA_LCC201_DynamicLayoutContainer.SectionWrapper> SectionWrapper = new List<TA_LCC201_DynamicLayoutContainer.SectionWrapper>();

        test.startTest();
        User u = new User(id = UserInfo.getUserId());
        System.runAs(u) {
            TA_LCC201_DynamicLayoutContainer.getConfigurations(workOrderTest.Id);
        }
        test.stopTest();
    }

    @isTest
    static void testMethod2() {
        PermissionSetAssignment permSet = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Label = 'Italy Set' LIMIT 1];

        User u = new User(id = permSet.AssigneeId);

        test.startTest();
        System.runAs(u) {
            TA_LCC201_DynamicLayoutContainer.getConfigurations(null);
        }
        test.stopTest();
    }
}