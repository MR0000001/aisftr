/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 25/08/2021
* @description Giic_BA013_ReprocessSalesOrder_TEST – Test Class for Giic_BA013_ReprocessSalesOrder
*/

@isTest
private class Giic_BA013_ReprocessSalesOrder_TEST {

    @isTest
    static void onExecuteBatch() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [SELECT Id FROM Account];
        List<product2> lstProduct = [SELECT Id FROM product2];
        gii__Product2Add__c objProdRef= [SELECT Id, gii__ProductCode__c FROM gii__Product2Add__c WHERE gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        List<gii__SalesOrder__c> listSalesOrder = new List<gii__SalesOrder__c>([SELECT Id FROM gii__SalesOrder__c]);
        listSalesOrder[0].giic_OrderStatus__c = 'Error';
        update listSalesOrder;

        Test.startTest();
        Database.executeBatch(new Giic_BA013_ReprocessSalesOrder(), 1);
        Test.stopTest();
    }
}