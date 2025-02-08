/*
@CreatedBy      - Fabrizio Fiorentini (Fabrizio.Fiorentini@webresults.it), 2020/10/20 
@Description    - Class test for TA_LCC198_ProcessIndicator
*/
@isTest
public with sharing class TA_LCC198_ProcessIndicator_Test {
    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
    }

    @isTest
    static void test_SetProcessOK() {
        User u = new User(id = UserInfo.getUserId());
        WorkOrder workOrderTest = new WorkOrder(TA_Phase__c = 'checkIn', XC_WorkTypeCategory__c = 'Delivery & Installation');
        insert workOrderTest;

        TA_Phase_Configuration__c newPhase = new  TA_Phase_Configuration__c();
        newPhase.TA_DeveloperName__c = 'checkIn';
        newPhase.TA_Hidden__c = false;
        newPhase.TA_External_Id__c = '123';
        insert newPhase;

        TA_Action_Configuration__c actionConf = new TA_Action_Configuration__c();
        actionConf.TA_Type__c = 'Closing';
        actionConf.TA_DeveloperName__c = 'CloseService';
        actionConf.TA_External_Id__c = '123';
        insert actionConf;

        TA_Layout_Matrix_Configuration__c newCapability = new TA_Layout_Matrix_Configuration__c();
        newCapability.TA_ConfigurationSet__c = 'Italy_Set';
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkTypeCategory__c = 'Delivery & Installation';
        newCapability.TA_Action__c = actionConf.Id;
        newCapability.TA_IndexAction__c = 1;
        newCapability.TA_IndexPhase__c = 2;
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_External_Id__c = '123';
        insert newCapability;

        test.startTest();
        System.runAs(u) {
           TA_LCC198_ProcessIndicator.setProcess(workOrderTest.Id);
            TA_LCC198_ProcessIndicator.setProcess(null);
        }
        test.stopTest();
    }
}