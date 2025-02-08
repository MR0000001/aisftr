@isTest
public with sharing class TA_LCC201_DynamicLayoutContainer_Test {
    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
        TA_CNS201_DynamicLayoutContainer instance = new TA_CNS201_DynamicLayoutContainer();
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

        XC_Address__c address = new XC_Address__c();
        address.XC_Address__c = 'Via test';
        address.XC_City__c = 'Madrid';
        address.XC_AddressCountry__c = 'Spain';
        address.XC_PostalCode__c = '28080';
        address.XC_AddressProvince__c = 'Madrid';
        address.XC_StreetNumber__c = '1';
        address.XC_StreetType__c = 'Street'; 
        address.XC_Municipality__c   = 'Test';
        address.XC_Stair__c = '7';
        address.XC_Floor__c = 'B';
        insert address;

        workOrderTest.XC_Address__c = address.Id;
        update workOrderTest;

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

        newCapability = new TA_Capability_Configuration__c();
        newCapability.TA_Configuration_Set__c = confSet;
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkType_Category__c = 'Delivery & Installation';
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_DeveloperName__c = TA_CNS201_DynamicLayoutContainer.CB_CARTCONTAINER;
        newCapability.TA_Type__c = 'Layout';
        newCapability.TA_External_Id__c = 'test7';
        newCapabilityList.add(newCapability);

        newCapability = new TA_Capability_Configuration__c();
        newCapability.TA_Configuration_Set__c = confSet;
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkType_Category__c = 'Delivery & Installation';
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_DeveloperName__c = TA_CNS201_DynamicLayoutContainer.CB_REQUIREDDOCUMENT;
        newCapability.TA_Type__c = 'Layout';
        newCapability.TA_External_Id__c = 'test8';
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

    @isTest
    static void getGeneralInfoGetException() {
        try {
            Map<String, Map<String, String>> result = TA_LCC201_DynamicLayoutContainer.getGeneralInfo(null, null);
        } catch(Exception e) {
            System.assertEquals(true, e.getMessage() != null);
        }
        
    }
}