/**
* @author FirstName : Roberta Porrega
* @date Creation 29/07/2019
* @date Modification dd/mm/yyyy
* @description XC_REST_PurchaseOrder_TEST – for XC_REST_PurchaseOrder test class.
*/
@isTest
private class  XC_REST_PurchaseOrder_TEST {
	@isTest
        private static  void createCaseFromPOTest(){ 
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        List<gii__Product2Add__c> prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj[0]);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation( prodRefObj[0]);
            Test.startTest();
            
        	XC_REST_PurchaseOrder.callSendCreatePurchaseOrder(Giic_UtilityClass_Test.objPO.Id);
            XC_REST_PurchaseOrder.callSendUpdatePurchaseOrder(Giic_UtilityClass_Test.objPO.Id);
            XC_REST_PurchaseOrder.callSendUpdatePurchaseOrder3PL(Giic_UtilityClass_Test.objPO.Id);
            System.assertEquals(prodRefObj.size() >0, true);
            Test.stopTest();    
         
     }
    
    @isTest
        private static  void createCaseFromPOTest2(){ 
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        List<gii__Product2Add__c> prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj[0]);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation( prodRefObj[0]);
            Test.startTest();
            gii__PurchaseOrder__c po = [SELECT id, giic_POCode__c FROM gii__PurchaseOrder__c LIMIT 1];
            po.giic_POCode__c = 'test';
            update po;
        	XC_REST_PurchaseOrder.callSendCreatePurchaseOrder(Giic_UtilityClass_Test.objPO.Id);
            XC_REST_PurchaseOrder.callSendUpdatePurchaseOrder(Giic_UtilityClass_Test.objPO.Id);
            XC_REST_PurchaseOrder.callSendUpdatePurchaseOrder3PL(Giic_UtilityClass_Test.objPO.Id);
            System.assertEquals(prodRefObj.size() >0, true);
            Test.stopTest();    
         
     }
}