/*
@CreatedBy      - Federico Ruggeri (federico.ruggeri@webresults.it), 2020/11/02
@Description    - Test class for TA_LCC208_Modal
*/
@isTest
public without sharing class TA_LCC208_Modal_Test {
    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
    }

    @isTest
    static void testMethod1() {
        User u = new User(id = UserInfo.getUserId());

        WorkOrder workOrderTest = new WorkOrder(TA_Phase__c = 'checkIn', XC_WorkTypeCategory__c = 'Delivery & Installation');
        insert workOrderTest;

        TA_Phase_Configuration__c newPhase = new  TA_Phase_Configuration__c();
        newPhase.TA_DeveloperName__c = 'checkIn';
        newPhase.TA_Hidden__c = false;
        newPhase.TA_External_Id__c = 'test';
        insert newPhase;

        TA_Action_Configuration__c actionConf = new TA_Action_Configuration__c();
        actionConf.TA_Type__c = 'Closing';
        actionConf.TA_DeveloperName__c = 'CloseService';
        actionConf.TA_External_Id__c = 'test';
        insert actionConf;

        TA_Layout_Matrix_Configuration__c newCapability = new TA_Layout_Matrix_Configuration__c();
        newCapability.TA_ConfigurationSet__c = 'Italy_Set';
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkTypeCategory__c = 'Delivery & Installation';
        newCapability.TA_Action__c = actionConf.Id;
        newCapability.TA_IndexAction__c = 1;
        newCapability.TA_IndexPhase__c = 2;
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_External_Id__c = 'test';
        insert newCapability;

        TA_LCC208_Modal.ActionWrapper actionWrp1 = new TA_LCC208_Modal.ActionWrapper();
        TA_LCC208_Modal.ActionWrapper actionWrp2 = new TA_LCC208_Modal.ActionWrapper(actionConf.Id, 'test', actionConf.TA_DeveloperName__c, actionConf.TA_Type__c);
        TA_LCC208_Modal.MatrixWrapper MatrixWrp1 = new TA_LCC208_Modal.MatrixWrapper();
        TA_LCC208_Modal.MatrixWrapper MatrixWrp2 = new TA_LCC208_Modal.MatrixWrapper(newCapability.Id, newCapability.TA_IndexAction__c, 'checkIn', newCapability.TA_Active__c, 'test', false, actionWrp2);

        List<String> actions = new List<String>{'CloseService'};

        test.startTest();
        System.runAs(u) {
            TA_LCC208_Modal.initialize('checkIn', actions, newCapability.TA_WorkTypeCategory__c, newCapability.TA_ConfigurationSet__c);
        }
        test.stopTest();
    }
}