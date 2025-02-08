/*
@CreatedBy      - Fabrizio Fiorentini (Fabrizio.Fiorentini@webresults.it), 2020/10/20 
@Description    - Class test for TA_LCC202_DynamicLayout
*/
@isTest
public with sharing class TA_LCC202_DynamicLayout_Test {
    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
        // TA_UTIL_Test.loadSetupB2G();     
    }

    @isTest
    static void testMethod1() {
        List<Asset> assList = XC_DF_Asset.createAssets(1);     
        Asset assetTest = assList[0];   
        assetTest.Name = 'assetName';
        assetTest.SerialNumber = '12345';       
        insert assetTest;

        WorkOrder workOrderTest = new WorkOrder(TA_Phase__c = 'checkIn', XC_WorkTypeCategory__c = 'Delivery & Installation', AssetId = assetTest.Id);
        insert workOrderTest;

        String json = '{"details":{"objectName":"WorkOrder","objectLookup":"Id","whereCondition":"","show":"false"},"fields":[{"apiName":"Status","required":"false","mode":"none"},{"apiName":"Contact.Name","required":"false","mode":"none"},{"apiName":"XC_Address__r.Name","required":"false","mode":"view"},{"apiName":"Contact.Phone","required":"false","mode":"view"},{"apiName":"Contact.Email","required":"false","mode":"view","image":"test"},{"apiName":"Contact.MobilePhone","required":"false","mode":"view","redirectTo":"test","displayValueApiName":"Contact.Name"}]}';

        TA_LCC202_DynamicLayout.ObjectWrapper SectionWrapper = new TA_LCC202_DynamicLayout.ObjectWrapper();

        test.startTest();
        SectionWrapper = TA_LCC202_DynamicLayout.getObjWrapper(workOrderTest.Id, json);
        test.stopTest();
    }

    
    @isTest
    static void testMethod2() {
        String recordtypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        List<Asset> assList = XC_DF_Asset.createAssets(2);     
        Asset assetTest = assList[0];   
        assetTest.Name = 'assetName';
        assetTest.SerialNumber = '12345'; 
        assetTest.RecordTypeId = recordtypeId;      
        insert assetTest;
       
        Asset assetTest2 = assList[1];   
        assetTest2.Name = 'assetNameParent';
        assetTest2.SerialNumber = '12345'; 
        assetTest2.RecordTypeId = recordtypeId; 
        assetTest2.ParentId = assetTest.Id;   
        insert assetTest2;      

        WorkOrder workOrderTest = new WorkOrder(TA_Phase__c = 'checkIn', XC_WorkTypeCategory__c = 'Delivery & Installation', AssetId = assetTest.Id);
        insert workOrderTest;

        String json = '{""details":{"objectName":"Asset","objectLookup":"AssetId","whereCondition":"","show":"false"},"fields":[{"apiName":"Name","required":"false","mode":"none","editableField":"false"},{"apiName":"XC_Address__r.Name","required":"false","mode":"view","editableField":"false"},{"apiName":"SerialNumber","required":"false","mode":"view","editableField":"false"},{"apiName":"TAM_AssetType__c","required":"false","mode":"view","editableField":"false"},{"apiName":"Status","required":"false","mode":"view","editableField":"false"}]}';

        TA_LCC202_DynamicLayout.ObjectWrapper SectionWrapper = new TA_LCC202_DynamicLayout.ObjectWrapper();

        test.startTest();  
        //System.runAs(userTest) {     
            SectionWrapper = TA_LCC202_DynamicLayout.getObjWrapper(workOrderTest.Id, json); 
        //}       
        test.stopTest();
    }    

    @isTest
    static void testMethod3() {
        String recordtypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        List<Asset> assList = XC_DF_Asset.createAssets(2);     
        Asset assetTest = assList[0];   
        assetTest.Name = 'assetName';
        assetTest.SerialNumber = '12345'; 
        assetTest.RecordTypeId = recordtypeId;      
        insert assetTest;
       
        Asset assetTest2 = assList[1];   
        assetTest2.Name = 'assetNameParent';
        assetTest2.SerialNumber = '12345'; 
        assetTest2.RecordTypeId = recordtypeId; 
        assetTest2.ParentId = assetTest.Id;        
        insert assetTest2;       

        WorkOrder workOrderTest = new WorkOrder(TA_Phase__c = 'checkIn', XC_WorkTypeCategory__c = 'Delivery & Installation', AssetId = assetTest.Id);
        insert workOrderTest;

        String json = '{"details":{"objectName":"Asset","objectLookup":"AssetId","whereCondition":"","show":"false"},"fields":[{"apiName":"Name","required":"false","mode":"none","editableField":"false"},{"apiName":"XC_Address__r.Name","required":"false","mode":"view","editableField":"false"},{"apiName":"SerialNumber","required":"false","mode":"view","editableField":"false"},{"apiName":"TAM_AssetType__c","required":"false","mode":"view","editableField":"false"},{"apiName":"Status","required":"false","mode":"view","editableField":"false"}]}';

        TA_LCC202_DynamicLayout.ObjectWrapper SectionWrapper = new TA_LCC202_DynamicLayout.ObjectWrapper();

        test.startTest();  
        //System.runAs(userTest) {     
            SectionWrapper = TA_LCC202_DynamicLayout.getObjWrapper(workOrderTest.Id, json); 
        //}       
        test.stopTest();
    }    
}