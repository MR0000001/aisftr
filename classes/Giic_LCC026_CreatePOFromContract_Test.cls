@isTest
public class Giic_LCC026_CreatePOFromContract_Test {
    
    
     @isTest
    static void retrieveInitialInfoTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        gii__PurchaseOrder__c po = Giic_UtilityClass_Test.objPO;
        gii__PurchaseOrderLine__c pol = Giic_UtilityClass_Test.objPOLine;
        
        Giic_UtilityClass_Test.objContract.XC_Type__c = 'ZCC';
        update Giic_UtilityClass_Test.objContract;
        Test.startTest();
        Giic_LCC026_CreatePOFromContract.retrieveInitialInfo(Giic_UtilityClass_Test.objContract.Id);
        Test.stopTest();
        
    }
    
     @isTest
    static void retrieveInitialInfoTestFail(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        gii__PurchaseOrder__c po = Giic_UtilityClass_Test.objPO;
        gii__PurchaseOrderLine__c pol = Giic_UtilityClass_Test.objPOLine;
        
        Test.startTest();
        Giic_LCC026_CreatePOFromContract.retrieveInitialInfo(Giic_UtilityClass_Test.objContract.Id);
        Test.stopTest();
        
    }
    @isTest
    static void validatePurchaseOrderTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        gii__PurchaseOrder__c po = Giic_UtilityClass_Test.objPO;
        gii__PurchaseOrderLine__c pol = Giic_UtilityClass_Test.objPOLine;
        
        Test.startTest();
        Giic_LCC026_CreatePOFromContract.validatePurchaseOrder(JSON.serialize(Giic_UtilityClass_Test.objContract), Giic_UtilityClass_Test.objWh.Id, Giic_UtilityClass_Test.objPriceBook.Id );
        Test.stopTest();
        
    }
    
    
    
      @isTest
    static void createPurchaseOrderTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        gii__PurchaseOrder__c po = Giic_UtilityClass_Test.objPO;
        gii__PurchaseOrderLine__c pol = Giic_UtilityClass_Test.objPOLine;
        
        Test.startTest();
        Giic_LCC026_CreatePOFromContract.createPurchaseOrder(JSON.serialize(Giic_UtilityClass_Test.objContract), Giic_UtilityClass_Test.objWh.Id, Giic_UtilityClass_Test.objPriceBook.Id );
        Test.stopTest();
        
    }
    
    


}