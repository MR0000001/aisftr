/**
* @author FirstName : Roberta  Porrega
* @date Creation 24/01/2020
* @date Modification dd/mm/yyyy
* @description Giic_BA008_CheckAvailabilityPEntry_TEST – for Giic_BA008_CheckAvailabilityPEntry_TEST class
*/
@isTest(SeeAllData=false)
public class Giic_BA008_CheckAvailabilityPEntry_TEST {
    
    @isTest static void testReceiveData(){
       Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
         Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        List<gii__Product2Add__c> prodRefObjList = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
        prodRefObjList[0].gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        update prodRefObjList;
        
        Test.startTest();
        NE__Product__c commProd = new NE__Product__c();
        insert commPrOd;
        B2WExtCat__External_Catalog__c cat = new B2WExtCat__External_Catalog__c(B2WExtCat__External_Catalog_Name__c = 'Test');
        insert cat;
        B2WExtCat__External_Catalog_Item__c catItem = new B2WExtCat__External_Catalog_Item__c(B2WExtCat__Type__c = 'Item',
                                                                                              B2WExtCat__External_Catalog_Item_Name__c = 'Test',
                                                                                              B2WExtCat__External_Catalog__c = cat.Id);
        insert catItem;
        B2WExtCat__External_Catalog_Association__c extCat = new B2WExtCat__External_Catalog_Association__c(XC_TechnicalProduct__c = Giic_UtilityClass_Test.objProductTL.Id,
                                                                                                           B2WExtCat__Commercial_Product__c = commProd.Id,
                                                                                                           B2WExtCat__External_Catalog_Item__c = catItem.Id  );
        insert extCat;
        System.debug('@@@EXTCAT ' +extCat);
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObjList[0]);
        Giic_BA008_CheckAvailabilityPEntry batchobj = new Giic_BA008_CheckAvailabilityPEntry();
        Id batchId=DataBase.executeBatch(batchobj); 
        
        Test.stopTest();
    }
}