/**
 * @author Sara Miozza - sara.miozza@nttdata.com
 * @date Creation 30/01/2020
 * @date Modification dd/mm/yyyy
 * @description giic_TR_CheckAvailability test class
 */

@isTest
private class Giic_TR_CheckAvailability_Test {
    
    
    @isTest static void methodTest1(){ 
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
		List<gii__PriceBookEntry__c> pbeList = [SELECT id from gii__PriceBookEntry__c LIMIT 1];
        pbeList[0].giic_WBSElement__c = '123456';
        update pbeList;
        Map<Id,gii__PriceBookEntry__c> mapOld = new Map<Id,gii__PriceBookEntry__c>();
        mapOld.put(pbeList[0].id,pbeList[0]);
        Map<Id,gii__PriceBookEntry__c> mapNew =  new Map<Id,gii__PriceBookEntry__c>();
        mapNew.put(pbeList[0].id,pbeList[0]);
        
       
        giic_TR_CheckAvailabilityForSupplierProd.checkAvailabilityForSupplierProduct(pbeList);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh,prodRefObjList);
         
        Giic_UtilityClass_Test.creationPILocation(Giic_UtilityClass_Test.lstProductInventory[0],prodRefObjList[0]);
        Giic_UtilityClass_Test.objPILocation.giic_SalesOnHand__c = 3;
        update Giic_UtilityClass_Test.objPILocation;
        giic_TR_CheckAvailability.Giic_AvailabilityWrapper avabWrapp = new giic_TR_CheckAvailability.Giic_AvailabilityWrapper();
       
        System.assertEquals(true, prodRefObjList.size()>0);       
        Test.stopTest();
    }
    
    
      @isTest static void methodTest2(){ 
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
		List<gii__PriceBookEntry__c> pbeList = [SELECT id from gii__PriceBookEntry__c LIMIT 1];
        Map<Id,gii__PriceBookEntry__c> mapOld = new Map<Id,gii__PriceBookEntry__c>();
        mapOld.put(pbeList[0].id,pbeList[0]);
        Map<Id,gii__PriceBookEntry__c> mapNew =  new Map<Id,gii__PriceBookEntry__c>();
        mapNew.put(pbeList[0].id,pbeList[0]);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh,prodRefObjList);
          Giic_UtilityClass_Test.lstProductInventory[0].giic_AvgTransferTime__c = 0;
          update   Giic_UtilityClass_Test.lstProductInventory[0];
        Giic_UtilityClass_Test.creationPILocation(Giic_UtilityClass_Test.lstProductInventory[0],prodRefObjList[0]);
        Giic_UtilityClass_Test.objPILocation.giic_SalesOnHand__c = 3;
        update Giic_UtilityClass_Test.objPILocation;
        giic_TR_CheckAvailability.checkAvailability(Giic_UtilityClass_Test.lstProductInventory);
       
      
        Test.stopTest();
    }
    
    
}