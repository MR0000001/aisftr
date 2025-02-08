@isTest
public with sharing class TA_LCC212_OrderSummary_Test {
    @testSetup
    static void setup() {
        NE__Order__c order = new NE__Order__c();
        insert order;

        NE__OrderItem__c orderItem = new NE__OrderItem__c();
        orderItem.NE__OrderId__c = order.Id;
        orderItem.NE__Qty__c = 1;
        insert orderItem;

        WorkOrder workOrder = new WorkOrder();
        workOrder.XC_Configuration__c = order.Id;
        insert workOrder;
    }

    @isTest
    static void initialize_Test() {
        WorkOrder workOrder = [SELECT Id, XC_Configuration__c FROM WorkOrder][0];
        String customSet = '{"NE__Order__c":[{"apiName":"Name","label":"Sell Order Number"},{"apiName":"NE__One_Time_Fee_Total__c","label":"Total Order"},{"apiName":"XC_BillingModel__c","label":"Billing Model"}],"NE__OrderItem__c":[{"apiName":"XC_TranslatedProductName__c","label":"Name"},{"apiName":"NE__Qty__c","label":"Quantity"},{"apiName":"XC_Product_Type__c","label":"Sell Order Number"},{"apiName":"XC_Product_Subtype__c","label":"Sell Order Number"}]}';
        Test.startTest();
        TA_LCC212_OrderSummary.initialize(workOrder, customSet);
        Test.stopTest();
    }

    @isTest
    static void initialize_Test2() {
        WorkOrder workOrder = new WorkOrder();        
        insert workOrder;
        String customSet = '{"NE__Order__c":[{"apiName":"Name","label":"Sell Order Number"},{"apiName":"NE__One_Time_Fee_Total__c","label":"Total Order"},{"apiName":"XC_BillingModel__c","label":"Billing Model"}],"NE__OrderItem__c":[{"apiName":"XC_TranslatedProductName__c","label":"Name"},{"apiName":"NE__Qty__c","label":"Quantity"},{"apiName":"XC_Product_Type__c","label":"Sell Order Number"},{"apiName":"XC_Product_Subtype__c","label":"Sell Order Number"}]}';
        Test.startTest();
        TA_LCC212_OrderSummary.initialize(workOrder, customSet);
        Test.stopTest();
    }

    @isTest
    static void initialize_Test3() {        
        List<Asset> assList = XC_DF_Asset.createAssets(1);     
        Asset assetTest = assList[0];   
        assetTest.Name = 'assetName';
        assetTest.SerialNumber = '12345';         
        insert assetTest;
        WorkOrder workOrder = new WorkOrder();              
        workOrder.AssetId = assetTest.id;
        insert workorder;

        String customSet = '{"NE__Order__c":[{"apiName":"Name","label":"Sell Order Number"},{"apiName":"NE__One_Time_Fee_Total__c","label":"Total Order"},{"apiName":"XC_BillingModel__c","label":"Billing Model"}],"NE__OrderItem__c":[{"apiName":"XC_TranslatedProductName__c","label":"Name"},{"apiName":"NE__Qty__c","label":"Quantity"},{"apiName":"XC_Product_Type__c","label":"Sell Order Number"},{"apiName":"XC_Product_Subtype__c","label":"Sell Order Number"}]}';
        Test.startTest();
        TA_LCC212_OrderSummary.initialize(workOrder, customSet);
        Test.stopTest();
    }
}