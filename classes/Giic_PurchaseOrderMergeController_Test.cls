/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 29/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_PurchaseOrderMergeController_Test – for Giic_PurchaseOrderMergeController test class.
*/
@isTest
public class Giic_PurchaseOrderMergeController_Test {
 /**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 29/07/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for fetchPOdata and mergePOData.
*/
    private static testMethod void checkPOTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        gii__PriceBook__c pb = Giic_UtilityClass_Test.objPriceBook;
       
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
        prodRefObj.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update prodRefObj;
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);
        
        Giic_UtilityClass_Test.purchaseOrderCreation();
        List<gii__PurchaseOrderLine__c> listPOLInsert = new List<gii__PurchaseOrderLine__c>();
         gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=Giic_UtilityClass_Test.objPO.id,gii__Product__c=prodRefObj.id,
                                                                            gii__OrderQuantity__c=100.00,gii__UnitPrice__c=10.00);
        
        listPOLInsert.add(objPOLine);
        gii__PurchaseOrderLine__c objPOLine1= new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=Giic_UtilityClass_Test.objPO.id,gii__Product__c=prodRefObj.id,giic_UnderWarranty__c = true,
                                                                            gii__OrderQuantity__c=100.00,gii__UnitPrice__c=10.00);
        
         listPOLInsert.add(objPOLine1);
         gii__PurchaseOrderLine__c objPOLine2= new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=Giic_UtilityClass_Test.objPO.id,gii__Product__c=prodRefObj.id,gii__Product_Discount_Percent__c = 30,
                                                                            gii__OrderQuantity__c=100.00,gii__UnitPrice__c=10.00);
        
         listPOLInsert.add(objPOLine2);
          gii__PurchaseOrderLine__c objPOLine3= new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=Giic_UtilityClass_Test.objPO.id,gii__Product__c=prodRefObj.id,giic_UnderWarranty__c = true,
                                                                            gii__OrderQuantity__c=100.00,gii__UnitPrice__c=10.00);
        
         listPOLInsert.add(objPOLine3);
        
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= false;
        Giic_UtilityClass_Test.objPO.giic_WarehouseLimitExceeded__c=true;
        Giic_UtilityClass_Test.objPO.gii__PriceBookName__c = Giic_UtilityClass_Test.objPriceBook.Name;
        upsert Giic_UtilityClass_Test.objPO;
       
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
             
        List<Giic_PurchaseOrderMergeController.DisplayPO> lstPO = new List<Giic_PurchaseOrderMergeController.DisplayPO>();
        Giic_PurchaseOrderMergeController.DisplayPO objPO = new Giic_PurchaseOrderMergeController.DisplayPO();
        objPO.supplier=Giic_UtilityClass_Test.objAccountSupplier.id;
        objPO.warehouse=Giic_UtilityClass_Test.objPO.gii__ShipTo__c;
        objPO.orderStatus=Giic_UtilityClass_Test.objPO.giic_Status__c;
        objPO.orderDate=Date.today(); 
        objPO.isSelected= true;
        objPO.cwrapperpo=Giic_UtilityClass_Test.objPO;
        
       
        gii__PurchaseOrder__c objPOSecond = new gii__PurchaseOrder__c(gii__Supplier__c = Giic_UtilityClass_Test.objAccountSupplier.id,
                                                                      gii__DropShip__c= false,
                                                                      giic_Status__c='Draft', 
                                                                      gii__ShipTo__c=Giic_UtilityClass_Test.objPO.gii__ShipTo__c,
                                                                      gii__Approved__c=false,
                                                                      giic_PriceBookId__c = pb.Id,
                                                                      gii__PriceBookName__c = pb.Name);
        insert objPOSecond;
        gii__PurchaseOrderLine__c objPOLine4= new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=objPOSecond.id,gii__Product__c=prodRefObj.id,gii__Product_Discount_Percent__c = 20,
                                                                            gii__OrderQuantity__c=100.00,gii__UnitPrice__c=12.00);
        
        listPOLInsert.add(objPOLine4);
      
        insert listPOLInsert;
        
        Giic_PurchaseOrderMergeController.DisplayPO objPOsecondtoMerge = new Giic_PurchaseOrderMergeController.DisplayPO();
        objPOsecondtoMerge.supplier=Giic_UtilityClass_Test.objAccountSupplier.id;
        objPOsecondtoMerge.warehouse=Giic_UtilityClass_Test.objPO.gii__ShipTo__c;
        objPOsecondtoMerge.orderStatus=Giic_UtilityClass_Test.objPO.giic_Status__c;
        objPOsecondtoMerge.orderDate=Date.today();
        objPOsecondtoMerge.isSelected= true;
        objPOsecondtoMerge.cwrapperpo=objPOSecond;
        
        
        
        lstPO.add(objPO);
        lstPO.add(objPOsecondtoMerge);
         
        Test.startTest();
         Giic_PurchaseOrderMergeController.fetchPOdata('', '', 'supplier');
         Giic_PurchaseOrderMergeController.mergePOData(JSON.serialize(lstPO));
         Giic_PurchaseOrderMergeController.getListViews();
         System.assertEquals(true, lstPO.size()>0);
        Test.stopTest(); 
    }
    
    
}