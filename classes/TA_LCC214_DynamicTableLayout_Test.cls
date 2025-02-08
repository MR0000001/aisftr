/*
@CreatedBy      - Federico Ruggeri (federico.ruggeri@webresults.it), 2020/10/20
@Description    - Class test for TA_LCC214_DynamicTableLayout
*/
@isTest
public with sharing class TA_LCC214_DynamicTableLayout_Test {
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

        workOrderTest.AccountId = accountToInsert.Id;
        assetTest.AccountId = accountToInsert.Id;

        update workOrderTest;
        update assetTest;

        String jsonTest = '[{"details":{"objectName":"Asset","objectLookup":"Id","whereCondition":"AccountId=:AccountId","indexShowField":"2","typeOfTabel":"Details","totalCountLabel":"","apiFieldCount":"","detailDescription":"","onlyModal":"false"},"fields":[{	"apiName":"Name","mode":"view","showLabel":"true"},{"apiName":"Status","mode":"view","showLabel":"true"},{"apiName":"XC_ActivationDate__c","mode":"view","showLabel":"true"}]}]';

        test.startTest();
        TA_LCC214_DynamicTableLayout.getObjWrapper(String.valueOf(workOrderTest.Id),jsonTest, String.valueOf(accountToInsert.Id), String.valueOf(orderTest.Id));
        test.stopTest();
    }
}