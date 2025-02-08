@isTest
public with sharing class TA_LCC215_DynamicMultyQueryLayout_Test {
    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
    }

    @isTest
    static void testMethod1() {
        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        Asset assetTest = XC_DF_Asset.createAssets(1)[0];
        insert assetTest;

        NE__Order__c orderTest = XC_DF_Order.createOrders(1, 'InOrder')[0];
        insert orderTest;

        NE__Product__c product = XC_DF_Product.createProducts(1)[0];
        insert product;

        NE__DocumentationCharacterist__c docChar = new NE__DocumentationCharacterist__c(
            LicName__c = 'Power',
            LicValue__c = 'test0000',
            NE__Product__c = product.Id
        );
        insert docChar;

        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.AssetId = assetTest.Id;

        assetTest.AccountId = accountToInsert.Id;
        update workOrderTest;
        update assetTest;

        String jsonTest = '[{"details":{"objectName":"Asset","show":"false","afterObjectLookup":"NE__ProdId__c","whereCondition": " id =: AssetId","byPassClassicInformation": "true"}, "fields": [{"apiName": "Name","required": "false","mode": "none","editableField":"false"},{"apiName": "SerialNumber","required": "false","mode": "view","editableField":"true"},{"apiName": "XC_Product_Subtype__c","required": "false","mode": "view","editableField":"false"},{"apiName": "NE__ProdId__c","required": "false","mode": "none","editableField":"false"},{"apiName": "XC_ActivationDate__c","required": "false","mode": "view","editableField":"false"},{"apiName": "PurchaseDate","required": "false","mode": "view","editableField":"false"},{"apiName": "XC_Warranty_End_Date__c","required": "false","mode": "view","editableField":"false"}]},{"details":{"objectName":"NE__DocumentationCharacterist__c","show":"false","afterObjectLookup":"","whereCondition": " NE__Product__c =: conditionId AND (LicName__c = \'Brand\' OR LicName__c = \'Power\' OR LicName__c = \'Model\')","byPassClassicInformation": "true"}, "fields": [{"apiName": "LicName__c","usedFor": "label","required": "false","mode": "view","editableField":"false"},{"apiName": "LicValue__c","usedFor":"value","required": "false","mode": "view","editableField":"false"}]}]';

        test.startTest();
        TA_LCC215_DynamicMultyQueryLayout.getObjWrapper(String.valueOf(workOrderTest.Id), jsonTest, String.valueOf(assetTest.Id));
        test.stopTest();
    }

    @isTest
    static void testMethod2() {
        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        Asset assetTest = XC_DF_Asset.createAssets(1)[0];
        insert assetTest;

        NE__Order__c orderTest = XC_DF_Order.createOrders(1, 'InOrder')[0];
        insert orderTest;

        NE__Product__c product = XC_DF_Product.createProducts(1)[0];
        insert product;

        NE__DocumentationCharacterist__c docChar = new NE__DocumentationCharacterist__c(
            LicName__c = 'Power',
            LicValue__c = 'test0000',
            NE__Product__c = product.Id
        );
        insert docChar;

        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.AssetId = assetTest.Id;
        assetTest.AccountId = accountToInsert.Id;

        update workOrderTest;
        update assetTest;

        String jsonTest = '[{"details":{"objectName":"WorkOrder","show":"false","afterObjectLookup":"Asset.NE__ProdId__c","whereCondition": " AssetId =: AssetId AND Id =: WorkOrderId","byPassClassicInformation": "false"}, "fields": [{"apiName": "Asset.Name","required": "false","mode": "none","editableField":"false"},{"apiName": "Asset.SerialNumber","required": "false","mode": "view","editableField":"true"},{"apiName": "Asset.XC_Product_Subtype__c","required": "false","mode": "view","editableField":"false"},{"apiName": "Asset.NE__ProdId__c","required": "false","mode": "none","editableField":"false"},{"apiName": "Asset.XC_ActivationDate__c","required": "false","mode": "view","editableField":"false"},{"apiName": "Asset.PurchaseDate","required": "false","mode": "view","editableField":"false"},{"apiName": "Asset.XC_Warranty_End_Date__c","required": "false","mode": "view","editableField":"false"}]},{"details":{"objectName":"NE__DocumentationCharacterist__c","show":"false","afterObjectLookup":"","whereCondition": " NE__Product__c =: conditionId AND (LicName__c = \'Brand\' OR LicName__c = \'Power\' OR LicName__c = \'Model\')","byPassClassicInformation": "true"}, "fields": [{"apiName": "LicName__c","usedFor": "label","required": "false","mode": "view","editableField":"false"},{"apiName": "LicValue__c","usedFor":"value","required": "false","mode": "view","editableField":"false"}]}]';

        test.startTest();
        TA_LCC215_DynamicMultyQueryLayout.getObjWrapper(String.valueOf(workOrderTest.Id), jsonTest, String.valueOf(assetTest.Id));
        test.stopTest();
    }
}