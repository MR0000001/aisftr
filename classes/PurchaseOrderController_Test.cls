@isTest
public class PurchaseOrderController_Test {
    
    
    @isTest
    static void PurchaseOrderControllerTest1(){
        
        ApexPages.StandardController controller;
        PageReference pageReference;
        
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
        controller = new ApexPages.StandardController(po);
        pageReference = new PageReference('');
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id', po.Id);
        PurchaseOrderController  PoC = new PurchaseOrderController(new ApexPages.StandardController(po));
        Test.stopTest();
        
    }
    
}