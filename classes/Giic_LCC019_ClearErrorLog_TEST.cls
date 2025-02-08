/**
* @author FirstName : Roberta Porrega
* @date Creation 29/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_LCC019_ClearErrorLog_TEST – for Giic_LCC019_ClearErrorLog test class.
*/
@isTest
private class  Giic_LCC019_ClearErrorLog_TEST {
    @isTest
    private static  void errorLogTest(){ 
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
        giic_ErrorLog__c    errorLog = new giic_ErrorLog__c();
        errorLog.Name = 'Integration';
        errorLog.giic_PurchaseOrder__c = Giic_UtilityClass_Test.objPO.Id;
        errorLog.giic_Process__c = 'Integration SAP';
        insert errorLog;
        giic_ErrorLog__c    errorLog1 = new giic_ErrorLog__c();
        errorLog1.Name = 'Integration';
        errorLog1.giic_PurchaseOrder__c = Giic_UtilityClass_Test.objPO.Id;
        errorLog1.giic_Process__c = 'Integration 3PL';
        insert errorLog1;
        Test.startTest();
        Giic_UtilityClass_Test.pOReceiptSC();
        giic_ErrorLog__c    errorLog2 = new giic_ErrorLog__c();
        errorLog2.Name = 'Integration';
        errorLog2.giic_PurchaseOrderReceipt__c = Giic_UtilityClass_Test.objPOreceiptCS.Id;
        errorLog2.giic_Process__c = 'Purchase Order Receipt';
        insert errorLog2;
        Giic_LCC019_ClearErrorLog.retrieveErrorLog(Giic_UtilityClass_Test.objPO.Id);
        Giic_LCC019_ClearErrorLog.deleteErrorLog(Giic_UtilityClass_Test.objPO.Id, true, true);
        Giic_LCC019_ClearErrorLog.deleteErrorLog(Giic_UtilityClass_Test.objPOreceiptCS.Id, true, true);
        System.assertEquals(prodRefObj.size() >0, true);
        Test.stopTest(); 
        
    }
}