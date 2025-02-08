/**
* @author FirstName : Milko Fatiga
* @date Creation 12/05/2021
* @date Modification dd/mm/yyyy
* @description Giic_BA011_CheckAvailabilityQty_TEST – for Giic_BA011_CheckAvailabilityQty_TEST class
*/
@isTest(SeeAllData=false)
public class Giic_BA011_CheckAvailabilityQty_TEST {
    
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
                                                                                                           B2WExtCat__External_Catalog_Item__c = catItem.Id, XC_Quantity__c = 1  );
        insert extCat;
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObjList[0]);
        
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh,prodRefObjList);
        Giic_UtilityClass_Test.lstProductInventory[0].giic_AvgTransferTime__c = 0;
        update   Giic_UtilityClass_Test.lstProductInventory[0];
        Giic_UtilityClass_Test.creationPILocation(Giic_UtilityClass_Test.lstProductInventory[0],prodRefObjList[0]);
        Giic_UtilityClass_Test.objPILocation.giic_SalesOnHand__c = 3;
        update Giic_UtilityClass_Test.objPILocation;
        
        Giic_BA011_CheckAvailabilityQty batchobj = new Giic_BA011_CheckAvailabilityQty();
        Id batchId=DataBase.executeBatch(batchobj); 
        
        Test.stopTest();
    }
}