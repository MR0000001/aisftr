/**    
* @author FirstName : Sara Miozza sara.miozza@nttadata.com
* @date Creation 01/04/2020
* @date Modification dd/mm/yyyy
* @description test class for Giic_LCC020_ResendSAP
*/ 

@isTest
private class Giic_LCC020_ResendSAP_Test {
    
    @isTest
    static void resendPOTest(){
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
        Set<String> values = new Set<String>();
        values.add('SAP');
        values.add('3PL');
        
        po.giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(po.giic_MultiTargetSystem__c, values);
        po.gii__Approved__c = true;
        
        Test.startTest();
        Giic_LCC020_ResendSAP.resend(po.ID,true,true);
        System.assertEquals(po.gii__Approved__c, true);
        Test.stopTest();
    }
    
     @isTest
    static void resendPOTest2(){
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
        Giic_UtilityClass_Test.pOReceipt();
        gii__PurchaseOrder__c po = Giic_UtilityClass_Test.objPO;
        gii__PurchaseOrderReceipt__c objPOreceipt = Giic_UtilityClass_Test.objPOreceipt;
        Set<String> values = new Set<String>();
        values.add('SAP');
        values.add('3PL');
        po.giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(po.giic_MultiTargetSystem__c, values);
        po.gii__Approved__c = true;
        Test.startTest();
        Giic_LCC020_ResendSAP.resend(objPOreceipt.Id,true,true);
        System.assertEquals(po.gii__Approved__c, true);
        Test.stopTest();
    }
    
    @isTest
    static void resendPOTest3(){
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
        
        Test.startTest();
        Giic_LCC020_ResendSAP.resend(po.ID,true,false);
        
        Test.stopTest();
    }
    
    @isTest
    static void resendPOTest4(){
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
        
        Test.startTest();
        Giic_LCC020_ResendSAP.resend(po.ID,false,true);    
        
        Test.stopTest();
    }
    
    @isTest
    static void resendTOTest(){
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
        Giic_UtilityClass_Test.transferOrderCreation();
        gii__PurchaseOrder__c po = Giic_UtilityClass_Test.objPO;
        
        Test.startTest();
        Giic_LCC020_ResendSAP.resend(Giic_UtilityClass_Test.objTO.Id,false,true);    
        Giic_LCC020_ResendSAP.populateErrorWrapper('Errore');
        Test.stopTest();
    }
    

}