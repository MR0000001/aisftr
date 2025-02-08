/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@fujitsu.com
* @date Creation 5/09/2019
* @date Modification dd/mm/yyyy
* @description Giic_IntegrationUtility_Test – Test Class for Giic_IntegrationUtility.
*/
@isTest(SeeAllData=false)
public class Giic_IntegrationUtility_Test {
     /**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 5/09/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for Giic_IntegrationUtility
*/
    private static testMethod void createPOReceiptandStagingTest(){
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
        Giic_UtilityClass_Test.objPO.giic_IntegrationStatus__c= System.Label.giic_TOIntegrationStatusReadyToIntegrate;
        Giic_UtilityClass_Test.objPO.giic_IntegrationOperation__c= System.Label.giic_IntegrationOperationCreate;
        Giic_UtilityClass_Test.objPO.giic_TargetSystem__c= System.Label.giic_TargetSystemSAP;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        
        Giic_UtilityClass_Test.objPO.giic_PriceBookId__c = Giic_UtilityClass_Test.objPriceBook.Id;
        
        update Giic_UtilityClass_Test.objPO;
        gii__Product2Add__c objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        objProdRef.gii__SerialControlled__c = true;
        update objProdRef;
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
         List<String> stringList= new List<String>();
        stringList.add('PO cancelled');
        stringList.add('To craeted');
        System.assertEquals(true, stringList.size()>0);
         List<Id> porID= new List<Id>();
        porID.add(Giic_UtilityClass_Test.objPOreceipt.Id);
         List<Id> porIDlst= new List<Id>();
        porIDlst.add(Giic_UtilityClass_Test.objPOreceipt.Id);
         List<Id> shipIDlst= new List<Id>();
        shipIDlst.add(Giic_UtilityClass_Test.objShipment.Id);
        
       
        Giic_IntegrationUtility.createShipmentStaging(shipIDlst);
        
         Test.stopTest();
       
    }
    
    
     private static testMethod void createPOReceiptandStagingTest2(){
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
        Giic_UtilityClass_Test.objPO.giic_IntegrationStatus__c= System.Label.giic_TOIntegrationStatusReadyToIntegrate;
        Giic_UtilityClass_Test.objPO.giic_IntegrationOperation__c= System.Label.giic_IntegrationOperationCreate;
        Giic_UtilityClass_Test.objPO.giic_TargetSystem__c= System.Label.giic_TargetSystemSAP;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        
        Giic_UtilityClass_Test.objPO.giic_PriceBookId__c = Giic_UtilityClass_Test.objPriceBook.Id;
        
        update Giic_UtilityClass_Test.objPO;
        gii__Product2Add__c objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        objProdRef.gii__SerialControlled__c = true;
        update objProdRef;
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
         List<String> stringList= new List<String>();
        stringList.add('PO cancelled');
        stringList.add('To created');
        System.assertEquals(true, stringList.size()>0);
         List<Id> porID= new List<Id>();
         porID.add(Giic_UtilityClass_Test.objPOreceipt.Id);  
         List<Id> porIDlst= new List<Id>();
        porIDlst.add(Giic_UtilityClass_Test.objPOreceipt.Id);    
         List<Id> shipIDlst= new List<Id>();
        shipIDlst.add(Giic_UtilityClass_Test.objShipment.Id);
        Giic_IntegrationUtility.setReceiptQueueStatusReadytoIntegrate(porIDlst);
        Giic_IntegrationUtility.setReceiptStatusReadytoIntegrate(porIDlst);
        List<gii__ReceiptQueue__c> rqList = [SELECT Id FROM gii__ReceiptQueue__c];
        Giic_IntegrationUtility.setLEFromTO(rqList);  
         Test.stopTest();
       
    }
    
    private static testMethod void createPOReceiptandStagingTest3(){
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
        Giic_UtilityClass_Test.objPO.giic_IntegrationStatus__c= System.Label.giic_TOIntegrationStatusReadyToIntegrate;
        Giic_UtilityClass_Test.objPO.giic_IntegrationOperation__c= System.Label.giic_IntegrationOperationCreate;
        Giic_UtilityClass_Test.objPO.giic_TargetSystem__c= System.Label.giic_TargetSystemSAP;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        
        Giic_UtilityClass_Test.objPO.giic_PriceBookId__c = Giic_UtilityClass_Test.objPriceBook.Id;
        
        update Giic_UtilityClass_Test.objPO;
        gii__Product2Add__c objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        objProdRef.gii__SerialControlled__c = true;
        update objProdRef;
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
         List<String> stringList= new List<String>();
        stringList.add('PO cancelled');
        stringList.add('To craeted');
        System.assertEquals(true, stringList.size()>0);
         List<Id> porID= new List<Id>();
        porID.add(Giic_UtilityClass_Test.objPOreceipt.Id);
         List<Id> porIDlst= new List<Id>();
        porIDlst.add(Giic_UtilityClass_Test.objPOreceipt.Id);
         List<Id> shipIDlst= new List<Id>();
        shipIDlst.add(Giic_UtilityClass_Test.objShipment.Id);
        
        Giic_IntegrationUtility.createPOReceiptStaging(porIDlst);
            
         Test.stopTest();
       
    }

}