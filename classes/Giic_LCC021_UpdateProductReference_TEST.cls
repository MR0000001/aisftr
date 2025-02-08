/**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description Giic_LCC021_UpdateProductReference_TEST
*/

@isTest
private class Giic_LCC021_UpdateProductReference_TEST {
    
    @isTest
    static void rmaInsertTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation(); 
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            XC_Country__c = 'Spain',
            XC_ProductSubType__c = 'Enel Spare Part'
        );
        insert p2;
        
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        
          NE__Product__c prod = new NE__Product__c(
            Name = 'Test',
            XC_LIC_Product_Name__c = 'Test',
            NE__Engine_Code__c = 'enginecode'
        );
        insert prod;
        NE__Product__c prodPromo = new NE__Product__c(
            Name = 'Test',
            NE__IsPromo__c = true,
            XC_LIC_Product_Name__c = 'Test',
            NE__Engine_Code__c = 'enginecode'
        );
        insert prodPromo;
        NE__Catalog__c cat = new NE__Catalog__c();
        insert cat;
        NE__Catalog_Item__c catItem = new NE__Catalog_Item__c(
            NE__ProductId__c = prod.Id,
            NE__Min_Qty__c = 1,
            NE__Catalog_Id__c = cat.Id
        );
        insert catItem;
        NE__Promotion__c prom = new NE__Promotion__c(
            NE__Min_Qty__c = 1,
            NE__Start_Date__c = Datetime.now(),
            NE__Catalog_Id__c = cat.Id,
            NE__Commercial_Product__c = prodPromo.Id,
            NE__Prodotto__c = p2.Id
        );
        insert prom;
        NE__Promotion_Item__c promItem = new NE__Promotion_Item__c(
            NE__Catalog_Item__c = catItem.Id,
            NE__Promotion_Id__c = prom.Id
        );
        insert promItem;
        B2WExtCat__External_Catalog__c cec = new B2WExtCat__External_Catalog__c(
            B2WExtCat__External_Catalog_Name__c = 'Test',
            B2WExtCat__Start_Date__c = Datetime.now()
        );
        insert cec;
        B2WExtCat__External_Catalog_Item__c ceci = new B2WExtCat__External_Catalog_Item__c(
            B2WExtCat__External_Catalog_Item_Name__c = 'Test',
            B2WExtCat__Start_Date__c = Datetime.now(),
            B2WExtCat__Type__c = 'Item',
            B2WExtCat__External_Catalog__c = cec.Id
        );
        insert ceci;
        B2WExtCat__External_Catalog_Association__c ceca = new B2WExtCat__External_Catalog_Association__c(
            XC_TechnicalProduct__c = p2.Id,
            XC_Quantity__c = 1, 
            B2WExtCat__External_Catalog_Item__c = ceci.Id,
            B2WExtCat__Commercial_Catalog_Item__c = catItem.Id
        );
        insert ceca;
        
        Product2 p22 = new Product2(
            isActive = true,
            Name = 'Test2',
            ProductCode = 'Test22',
            XC_Country__c = 'Spain',
            XC_ProductSubType__c = 'Enel Spare Part'
        );
        insert p22;
        
        gii__Product2Add__c prodRefObj2 = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c where  Name = 'Test2' limit 1];
        
        Test.startTest();
        Giic_LCC021_UpdateProductReference.updateProdReference(prodRefObj2.ID);
        Giic_LCC021_UpdateProductReference.updateProdReference(prodRefObj.ID);
        Test.stopTest();
    }

}