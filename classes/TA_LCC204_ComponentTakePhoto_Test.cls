@IsTest
public with sharing class TA_LCC204_ComponentTakePhoto_Test {
    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
    }

    @isTest
    static void getSetup() {
        WorkOrder workOrderTest = new WorkOrder(TA_Phase__c = 'checkIn', XC_WorkTypeCategory__c = 'Delivery & Installation');
        insert workOrderTest;

        TA_Phase_Configuration__c newPhase =new  TA_Phase_Configuration__c();
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

        TA_Doxee_Url_Management__c taDoxee1 = new TA_Doxee_Url_Management__c (
            TA_Work_Order__c = workOrderTest.Id
        );

        TA_Doxee_Url_Management__c taDoxee2 = new TA_Doxee_Url_Management__c (
            TA_Work_Order__c = workOrderTest.Id
        );

        TA_LCC204_ComponentTakePhoto cd = new TA_LCC204_ComponentTakePhoto();

        insert taDoxee1;
        insert taDoxee2;
    }

    @IsTest
    public static void getFile_Test() {
        getSetup();
        WorkOrder workTest = [SELECT Id FROM WorkOrder LIMIT 1];
        String customConfig = '{"minQtyImages":2,"fileName":"site_photo","fileCategory":"SF_GENERIC_DOCUMENT"}';
        test.startTest();
        TA_LCC204_ComponentTakePhoto.getFile(workTest, customConfig);
        test.stopTest();
    }

    @IsTest
    public static void deleteFile_Test() {
        getSetup();
        TA_Doxee_Url_Management__c urlTest = [SELECT Id FROM TA_Doxee_Url_Management__c LIMIT 1];
        test.startTest();
        TA_LCC204_ComponentTakePhoto.deleteFile(urlTest.Id);
        test.stopTest();
    }

    @IsTest
    public static void deleteFile_TestException() {
        getSetup();
        TA_Doxee_Url_Management__c urlTest = [SELECT Id FROM TA_Doxee_Url_Management__c LIMIT 1];
        test.startTest();
        TA_LCC204_ComponentTakePhoto.deleteFile(null);
        test.stopTest();
    }

    @IsTest
    public static void callDoxee_test1() {
        getSetup();
        TA_Doxee_Url_Management__c urlTest = [SELECT Id, TA_Type__c FROM TA_Doxee_Url_Management__c LIMIT 1];

        XC_REST_DoxeeFileSend_U.FileWrapper fwp = new XC_REST_DoxeeFileSend_U.FileWrapper();

        fwp.FileSize = 30;
        fwp.FileName = 'test';
        fwp.FileDescription = 'test';
        fwp.FileCreationDate = '30-Oct-2020';
        fwp.FileCategory = 'test';
        fwp.FileBase64 = 'test';
        fwp.ObjectType = 'test';
        fwp.ObjectID = urlTest.Id;
        fwp.Company = 'test';
        fwp.Country = 'Italy';
        fwp.Id = 'test';
        fwp.Purl = 'test';
        fwp.Version = 'test';

        test.startTest();
        TA_LCC204_ComponentTakePhoto.uploadFile(JSON.serialize(fwp), true, true);
        test.stopTest();
    }

    @IsTest
    public static void updateWasteDisposal_Test() {
        getSetup();
        WorkOrder wo = [SELECT Id FROM WorkOrder][0];
        test.startTest();
        TA_LCC204_ComponentTakePhoto.updateWasteDisposal(JSON.serialize(wo));
        TA_LCC204_ComponentTakePhoto.updateWasteDisposal(null);
        test.stopTest();
    }
}