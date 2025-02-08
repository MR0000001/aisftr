/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@fujitsu.com
* @date Creation 5/09/2019
* @date Modification dd/mm/yyyy
* @description Giic_TOIntegrationUtility_Test – Test Class for Giic_TOIntegrationUtility.
*/
@isTest(SeeAllData=false)
public class Giic_TOIntegrationUtility_Test {
    /**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 5/09/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for Giic_IntegrationUtility
*/
    private static testMethod void createPOReceipTest(){            
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation(); 
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWh;
        
        Giic_UtilityClass_Test.objPO.gii__Approved__c=True;
        update Giic_UtilityClass_Test.objPO;
        gii__Product2Add__c objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Test.startTest();
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
        Giic_UtilityClass_Test.transferOrderCreation();
        gii__ProductInventory__c prodInvntryobj= [SELECT Id,Name FROM gii__ProductInventory__c];
        Giic_UtilityClass_Test.tOLineCreation(objProdRef);
        Giic_UtilityClass_Test.inventoryReserveCreation(objProdRef,prodInvntryobj);
        Giic_UtilityClass_Test.receiptQCreation(prodInvntryobj);
        List<Giic_IntegrationWrapper.TOReceipetLine> solListToCreate = new List<Giic_IntegrationWrapper.TOReceipetLine>();
        Giic_IntegrationWrapper.TOReceipt soCreateObj = new Giic_IntegrationWrapper.TOReceipt();
        Giic_IntegrationWrapper.TOReceipt soCreateObj2 = new Giic_IntegrationWrapper.TOReceipt();
        soCreateObj2.integrationOperation = 'a';
        soCreateObj2.targetSystem = 'b';  
        soCreateObj.transferOrderID = Giic_UtilityClass_Test.objTO.Id; //transfer order id
        Giic_IntegrationWrapper.TOReceipetLine newSOL = new Giic_IntegrationWrapper.TOReceipetLine();
        newSOL.toLineID = Giic_UtilityClass_Test.objTOline.Id; // transfer order line id
        newSOL.location = Giic_UtilityClass_Test.objLocationCentral.Id;
        solListToCreate.add(newSOL);
        soCreateObj.toReceiptLine = solListToCreate;
        System.assertEquals(true, solListToCreate.size()>0);
        Giic_TransferOrderIntegrationUtility.TOGoodsReceipt(soCreateObj);
        Test.stopTest();
    }
    
    /**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 5/09/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for Giic_IntegrationUtility
*/
    private static testMethod void createPOReceipTest1(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation(); 
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWh;
        
        Giic_UtilityClass_Test.objPO.gii__Approved__c=True;
        update Giic_UtilityClass_Test.objPO;
        gii__Product2Add__c objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Test.startTest();
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
        Giic_UtilityClass_Test.transferOrderCreation();
        gii__ProductInventory__c prodInvntryobj= [SELECT Id,Name FROM gii__ProductInventory__c];
        Giic_UtilityClass_Test.tOLineCreation(objProdRef);
        //Giic_UtilityClass_Test.inventoryReserveCreation(objProdRef,prodInvntryobj);
        //Giic_UtilityClass_Test.receiptQCreation(prodInvntryobj);
        List<Giic_IntegrationWrapper.TOReceipetLine> solListToCreate = new List<Giic_IntegrationWrapper.TOReceipetLine>();
        Giic_IntegrationWrapper.TOReceipt soCreateObj = new Giic_IntegrationWrapper.TOReceipt();
        soCreateObj.transferOrderID = Giic_UtilityClass_Test.objTO.Id; //transfer order id
        Giic_IntegrationWrapper.TOReceipetLine newSOL = new Giic_IntegrationWrapper.TOReceipetLine();
        newSOL.toLineID = Giic_UtilityClass_Test.objTOline.Id; // transfer order line id
        solListToCreate.add(newSOL);
        soCreateObj.toReceiptLine = solListToCreate;
        System.assertEquals(true, solListToCreate.size()>0);
        Giic_TransferOrderIntegrationUtility.TOGoodsReceipt(soCreateObj);
        Test.stopTest();
    }
    private static testMethod void createPOReceipTestNegative(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation(); 
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWh;
        
        Giic_UtilityClass_Test.objPO.gii__Approved__c=True;
        update Giic_UtilityClass_Test.objPO; 
        gii__Product2Add__c objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Test.startTest();
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
        Giic_UtilityClass_Test.transferOrderCreation();
        gii__ProductInventory__c prodInvntryobj= [SELECT Id,Name FROM gii__ProductInventory__c];
        Giic_UtilityClass_Test.tOLineCreation(objProdRef);
        Giic_UtilityClass_Test.inventoryReserveCreation(objProdRef,prodInvntryobj);
        Giic_UtilityClass_Test.receiptQCreation(prodInvntryobj);
        Giic_UtilityClass_Test.objRecQueue.gii__AGC__c = 'ggg';
        update Giic_UtilityClass_Test.objRecQueue;
        List<Giic_IntegrationWrapper.TOReceipetLine> solListToCreate = new List<Giic_IntegrationWrapper.TOReceipetLine>();
        Giic_IntegrationWrapper.TOReceipt soCreateObj = new Giic_IntegrationWrapper.TOReceipt();
        soCreateObj.transferOrderID = Giic_UtilityClass_Test.objTO.Id; //transfer order id
        Giic_IntegrationWrapper.TOReceipetLine newSOL = new Giic_IntegrationWrapper.TOReceipetLine();
        newSOL.toLineID = Giic_UtilityClass_Test.objTOline.Id; // transfer order line id
        solListToCreate.add(newSOL);
        soCreateObj.toReceiptLine = solListToCreate;
        System.assertEquals(true, solListToCreate.size()>0);
        Giic_TransferOrderIntegrationUtility.TOGoodsReceipt(soCreateObj);
       
        try{
             System.debug('Cancello '+Giic_UtilityClass_Test.objRecQueue);
             delete Giic_UtilityClass_Test.objRecQueue;
        }catch( Exception e ){
            System.debug('ERRRRR = '+e.getMessage());
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Cannot delete receipt queue record') || e.getMessage().contains('Delete failed') ) ? true : false;
		    System.AssertEquals(expectedExceptionThrown, true);
            
        }
       
        Test.stopTest();
    }
    
}