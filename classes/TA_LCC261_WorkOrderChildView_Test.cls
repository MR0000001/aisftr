/**
 * @description       : Test class for TA_LCC261_WorkOrderChildView
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 19-08-2021
 * @last modified by  : benjamin.geronimo
**/
@isTest
public with sharing class TA_LCC261_WorkOrderChildView_Test {

    @isTest
    static void getObjWrapper_test1() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.TA_Phase__c = 'Action';
        insert workOrderTest;

        NE__Bundle__c bundleTest = XC_DF_Bundle.createBundleRecords(1)[0];
        insert bundleTest;

        NE__Bundle_Element__c bundleElement1 = new NE__Bundle_Element__c();
        bundleElement1.NE__Bundle__c = bundleTest.Id;
        bundleElement1.NE__Max_quantity__c = 10;
        bundleElement1.NE__Min_Qty__c = 1;
        bundleElement1.NE__Sequence__c = 1;
        bundleElement1.XC_MacroCategory__c = 'Main';
        bundleElement1.NE__Type__c = 'Family';
        insert bundleElement1;

        Asset assetTest = XC_DF_Asset.createAssets(1)[0];
        assetTest.NE__Bundle_Element__c = bundleElement1.Id;
        assetTest.AccountId = accountToInsert.Id;
        insert assetTest;

        NE__Bundle_Element__c bundleElement2 = new NE__Bundle_Element__c();
        bundleElement2.NE__Bundle__c = bundleTest.Id;
        bundleElement2.NE__Max_quantity__c = 10;
        bundleElement2.NE__Min_Qty__c = 1;
        bundleElement2.NE__Sequence__c = 2;
        bundleElement2.XC_MacroCategory__c = 'Accessories';
        bundleElement2.NE__Type__c = 'Family';
        insert bundleElement2;

        Asset assetTest2 = XC_DF_Asset.createAssets(1)[0];
        assetTest2.NE__Bundle_Element__c = bundleElement2.Id;
        assetTest2.AccountId = accountToInsert.Id;
        insert assetTest2;

        WorkOrder workOrderChild = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        workOrderChild.ParentWorkOrderId = workOrderTest.Id;
        workOrderChild.AssetId = assetTest.Id;
        workOrderChild.AccountId = accountToInsert.Id;
        insert workOrderChild;

        WorkOrder workOrderChild2 = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        workOrderChild2.ParentWorkOrderId = workOrderTest.Id;
        workOrderChild2.AssetId = assetTest.Id;
        workOrderChild2.AccountId = accountToInsert.Id;
        insert workOrderChild2;
       
        String jsonTest = '{"details":{"objectName":"WorkOrder","whereCondition":"ParentWorkOrderId =: workOrderId AND AssetId != null","showSecondaryChild":"true","readOnly":"true"}}';

        test.startTest();
        TA_LCC261_WorkOrderChildView.getObjWrapper(String.valueOf(workOrderTest.Id), jsonTest);
        test.stopTest();
    }

    @isTest
    static void getObjWrapper_test2() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        insert workOrderTest;

        Asset assetTest = XC_DF_Asset.createAssets(1)[0];
        assetTest.AccountId = accountToInsert.Id;
        insert assetTest;


        WorkOrder workOrderChild = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        workOrderChild.ParentWorkOrderId = workOrderTest.Id;
        workOrderChild.AssetId = assetTest.Id;
        workOrderChild.AccountId = accountToInsert.Id;
        insert workOrderChild;

       
        String jsonTest = '{"details":{"objectName":"WorkOrder","whereCondition":"ParentWorkOrderId =: workOrderId AND AssetId != null","showSecondaryChild":"true","readOnly":"true"}}';

        test.startTest();
        TA_LCC261_WorkOrderChildView.getObjWrapper(String.valueOf(workOrderTest.Id), jsonTest);
        test.stopTest();
    }

    @isTest
    static void getObjWrapper_test3() {
    
        test.startTest();
        TA_LCC261_WorkOrderChildView.getObjWrapper(null, null);
        test.stopTest();
    }

}