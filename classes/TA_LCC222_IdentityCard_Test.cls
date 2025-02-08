/*
@CreatedBy - Federico Ruggeri (federico.ruggeri@webresults.it), 2020/11/02
@Description - Test class for TA_LCC222_IdentityCard
*/

@IsTest
public with sharing class TA_LCC222_IdentityCard_Test {
    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
    }

    @isTest
    static void getSetup() {
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');     
        WorkOrder workOrderTest = new WorkOrder(TA_Phase__c = 'checkIn', XC_WorkTypeCategory__c = 'Delivery & Installation', XC_Configuration__c =  order.id);
        insert workOrderTest;

        TA_Phase_Configuration__c newPhase =new  TA_Phase_Configuration__c();
        newPhase.TA_DeveloperName__c = 'checkIn';
        newPhase.TA_Hidden__c = false;
        newPhase.TA_External_Id__c = 'test';
        insert newPhase;

        TA_Action_Configuration__c actionConf = new TA_Action_Configuration__c();
        actionConf.TA_Type__c = 'Closing';
        actionConf.TA_DeveloperName__c = 'CloseService';
        actionConf.TA_External_Id__c = 'Test';
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

        TA_Doxee_Url_Management__c taDoxeeFront = new TA_Doxee_Url_Management__c (
            TA_ObjectId__c = order.Id,
            TA_Type__c = 'SF_DSN_FRONT'
        );

        TA_Doxee_Url_Management__c taDoxeeRetro = new TA_Doxee_Url_Management__c (
            TA_ObjectId__c = order.Id,
            TA_Type__c = 'SF_DSN_REAR'
        );

        TA_LCC222_IdentityCard cd = new TA_LCC222_IdentityCard();

        insert taDoxeeFront;
        insert taDoxeeRetro;
    }

    @IsTest
    public static void getDoxeeUrlManagements_test1() {
        getSetup();
        WorkOrder workTest = [SELECT Id FROM WorkOrder LIMIT 1];
        test.startTest();
        TA_LCC222_IdentityCard.getDoxeeUrlManagements(workTest.Id,'CONFIGURATION', 'SF_DSN_FRONT', 'SF_DSN_REAR');
        test.stopTest();
    }

    @IsTest
    public static void deleteDoxeeDocs_test1() {
        getSetup();
        TA_Doxee_Url_Management__c urlTest = [SELECT Id FROM TA_Doxee_Url_Management__c LIMIT 1];
        test.startTest();
        TA_LCC222_IdentityCard.deleteDoxeeDocs(urlTest.Id);
        test.stopTest();
    }

    @IsTest
    public static void deleteDoxeeDocs_Excep() {
        getSetup();
        TA_Doxee_Url_Management__c urlTest = [SELECT Id FROM TA_Doxee_Url_Management__c LIMIT 1];
        test.startTest();
        TA_LCC222_IdentityCard.deleteDoxeeDocs(null);
        test.stopTest();
    }

    @IsTest
    public static void deleteDoxeeDocs_Excep2() {        
        test.startTest();
        TA_LCC222_IdentityCard.deleteDoxeeDocs('test');
        test.stopTest();
    }

    @IsTest
    public static void callDoxee_test1() {
        getSetup();
        TA_Doxee_Url_Management__c urlTest = [SELECT Id, TA_Type__c FROM TA_Doxee_Url_Management__c LIMIT 1];

        XC_REST_DoxeeFileSend_U.FileWrapper fwp = new XC_REST_DoxeeFileSend_U.FileWrapper();
        List<WorkOrder> woList = [SELECT ID FROM WorkOrder limit 1];

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
        TA_LCC222_IdentityCard.callDoxee(JSON.serialize(fwp), urlTest.TA_Type__c, woList[0].id, true, true);
        test.stopTest();
    }

    @IsTest
    public static void callDoxee_test2() {
        getSetup();      
        NE__Order__c order = [SELECT id FROM NE__Order__c LIMIT 1];
        XC_REST_DoxeeFileSend_U.FileWrapper fwp = new XC_REST_DoxeeFileSend_U.FileWrapper();
        List<WorkOrder> woList = [SELECT ID FROM WorkOrder limit 1];

        fwp.FileSize = 30;
        fwp.FileName = 'test';
        fwp.FileDescription = 'test';
        fwp.FileCreationDate = '30-Oct-2020';
        fwp.FileCategory = 'test';
        fwp.FileBase64 = 'test';
        fwp.ObjectType = 'test';
        fwp.ObjectID = order.Id;
        fwp.Company = 'test';
        fwp.Country = 'Italy';
        fwp.Id = 'test';
        fwp.Purl = 'test';
        fwp.Version = 'test';

        test.startTest();
        TA_LCC222_IdentityCard.callDoxee(JSON.serialize(fwp), 'SF_DSN_FRONT', woList[0].id, true, true);
        test.stopTest();
    }
}