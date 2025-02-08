/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 16/05/2019
* @description XC_SC013_GenerateWBE_TEST – Test class for XC_SC013_GenerateWBE
*/ 

@isTest
private class XC_SC013_GenerateWBE_TEST {
    static testMethod void extecuteBatch() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        catalogItem.XC_ProductLine__c = 'Test';
        catalogItem.XC_ProductServiceType__c = 'Tst';
        catalogItem.XC_ProfitCenter__c = 'Test';
        catalogItem.XC_CostCenter__c = 'Test';
        insert catalogItem;
        System.assert(catalogItem != null);
        
        Test.startTest(); 
        XC_SC013_GenerateWBE myClass = new XC_SC013_GenerateWBE();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        Test.stopTest();        
    }
}