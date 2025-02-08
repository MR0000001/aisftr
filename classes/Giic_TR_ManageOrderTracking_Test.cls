/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description giic_LCC010_InventoryMovement_Test
*/  
@isTest
public class Giic_TR_ManageOrderTracking_Test {
    
   /*
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test getRecordTypeIdByName
*/
    @isTest static void rebaltTrackingTest() {
	    Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
         Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
    Test.startTest();
        gii__Product2Add__c p = Giic_DF_Glovia.createProductReference();
        gii__ProductInventory__c pi = Giic_DF_Glovia.createProductInventory(Giic_UtilityClass_Test.objWh.Id ,p.Id);
        insert pi;
        List<gii__PurchaseOrder__c> poList = new List<gii__PurchaseOrder__c>();
        poList.add(Giic_UtilityClass_Test.objPO);
        Giic_UtilityClass_Test.purchaseOrderLineCreation(p);
        System.debug('PI = '+pi.Id);     
    	Giic_TR_ManageOrderTracking.rebaltTracking(poList);
        Giic_UtilityClass_Test.objPOLine.giic_CarrierName__c = 'ddd';
        update Giic_UtilityClass_Test.objPOLine;
     
    Test.stopTest();
   }
    
     /*
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test getRecordTypeIdByName
*/
    @isTest static void foundWorstDateTest() {
	    Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
         Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
    Test.startTest();
        gii__Product2Add__c p = Giic_DF_Glovia.createProductReference();
        gii__ProductInventory__c pi = Giic_DF_Glovia.createProductInventory(Giic_UtilityClass_Test.objWh.Id ,p.Id);
        insert pi;
        List<gii__PurchaseOrder__c> poList = new List<gii__PurchaseOrder__c>();
        poList.add(Giic_UtilityClass_Test.objPO);
        gii__SalesOrder__c s = Giic_DF_Glovia.createSalesOrder();
        insert s;
        poList[0].gii__SalesOrder__c = s.Id;
    
        update poList;
        Giic_UtilityClass_Test.purchaseOrderLineCreation(p);
        map<Id,gii__PurchaseOrderLine__c> idPOtoPoLine = new map<Id,gii__PurchaseOrderLine__c>();
        idPOtoPoLine.put(Giic_UtilityClass_Test.objPOLine.gii__PurchaseOrder__c ,  Giic_UtilityClass_Test.objPOLine );
    	Giic_TR_ManageOrderTracking.foundWorstDate(idPOtoPoLine);
        
     
    Test.stopTest();
   }
    
    
     /*
    @isTest static void fillFieldsOrderTrackingTest() {
	    Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        
    Test.startTest();
        
        gii__PurchaseOrder__c po = Giic_DF_Glovia.createPurchaseOrder();
        insert po;
        gii__PurchaseOrderLine__c pol = Giic_DF_Glovia.createPurchaseOrderLine(po);   
        insert pol;
        pol.giic_CarrierName__c = 'aaaaaaa';
        update pol;
        delete pol;
    Test.stopTest();
   }

*/

    @isTest static void fillFieldsOrderTrackingTest2() {
	    Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
           Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
         Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.transferOrderCreation();
        gii__Product2Add__c p = Giic_DF_Glovia.createProductReference();
        gii__Product2Add__c p2 = Giic_DF_Glovia.createProductReference2();    
        List<gii__Product2Add__c> pList = new List<gii__Product2Add__c>();
        pList.add(p);
        pList.add(p2);
         Giic_UtilityClass_Test.tOLineCreationSC(pList);
         Test.startTest();
        Giic_UtilityClass_Test.objTO.giic_CarrierName__c = 'aaaaaaa';
        Giic_UtilityClass_Test.objTO.giic_Approved__c = true;
        Giic_UtilityClass_Test.objTO.giic_status__c = 'Open';
        update  Giic_UtilityClass_Test.objTO;
            Test.stopTest();
        
        
        
    }
    @isTest static void foundWorstDateTest2() {
	    Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
           Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
         Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.transferOrderCreation();
        gii__Product2Add__c p = Giic_DF_Glovia.createProductReference();
        gii__Product2Add__c p2 = Giic_DF_Glovia.createProductReference2();    
        List<gii__Product2Add__c> pList = new List<gii__Product2Add__c>();
        pList.add(p);
        pList.add(p2);
        Giic_UtilityClass_Test.tOLineCreationSC(pList);
        Test.startTest();
        map<Id,gii__TransferOrderLine__c> idTOtoToLine = new map<Id,gii__TransferOrderLine__c>();
        for(gii__TransferOrderLine__c t : Giic_UtilityClass_Test.lstTOLSC){
            idTOtoToLine.put(t.Id,t);
        }
        Giic_TR_ManageOrderTracking.foundWorstDate(idTOtoToLine);
        delete Giic_UtilityClass_Test.lstTOLSC;
         Test.stopTest();
        
    }
    
    
    

}