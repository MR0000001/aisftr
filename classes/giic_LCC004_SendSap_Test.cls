@isTest
private class giic_LCC004_SendSap_Test {
    
    @isTest static void retrivePoInfoTest() {
         Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
         Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.salesOrderCreation();  
         Giic_UtilityClass_Test.shipmentCreation();
         Giic_UtilityClass_Test.contractCreation();
          Giic_UtilityClass_Test.objContract.XC_CompanyCode__c = 'ES21'; 
        update  Giic_UtilityClass_Test.objContract;
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
       
       
        Test.startTest();
        
        giic_LCC004_SendSap.retrivePoInfo( Giic_UtilityClass_Test.objPO.Id);
        Test.stopTest();
    }
    
    @isTest static void retrivePoLInformationTest() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
         Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
        Giic_UtilityClass_Test.salesOrderCreation();  
        Giic_UtilityClass_Test.shipmentCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.objContract.XC_CompanyCode__c = 'ES21'; 
        update  Giic_UtilityClass_Test.objContract;
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();  
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        Test.startTest();
        
        giic_LCC004_SendSap.retrivePoLInformation( Giic_UtilityClass_Test.objPO.Id);
        Test.stopTest();
        
    }
    
    
    
    
      @isTest static void savePurchaseGroupTest() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
         Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.salesOrderCreation();  
         Giic_UtilityClass_Test.shipmentCreation();
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Test.startTest();
       
        giic_LCC004_SendSap.savePurchaseGroup( Giic_UtilityClass_Test.objPO.Id, 'COD');
          giic_LCC004_SendSap.savePurchaseOrganization( Giic_UtilityClass_Test.objPO.Id, 'COD');
        Test.stopTest();
    }
    
    
      @isTest static void updatePOLineTest() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
         Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.salesOrderCreation();  
         Giic_UtilityClass_Test.shipmentCreation();
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        Map<String,String> optionsMap = new   Map<String,String> ();
        optionsMap.put('polId',Giic_UtilityClass_Test.objPOLine.Id);
        optionsMap.put('category', 'K');
        optionsMap.put('applicantUnit', 'K');
        optionsMap.put('division', 'K');
          
              
         optionsMap.put('purchaseOrderId',Giic_UtilityClass_Test.objPO.Id);
        String polData = JSON.serialize(optionsMap);
        Test.startTest();
       
        giic_LCC004_SendSap.updatePOLine(polData);  
        Test.stopTest();
    }
    
    
         
         
    
    
    

}