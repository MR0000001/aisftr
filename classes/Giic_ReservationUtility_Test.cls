/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 26/07/2019
* @description Giic_ReservationUtility_Test – Test Class for Giic_ReservationUtility.
*/

@isTest
public class Giic_ReservationUtility_Test {

    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 26/07/2019
    * @description – Test Method for getReservationWrapper
    */
    @isTest
    private static void getReservationWrapperTest() {
     Giic_UtilityClass_Test.systemPolicyCreation();
     Giic_UtilityClass_Test.gloviaSystemSettingCreation();
     Giic_UtilityClass_Test.accountCreation();
     Giic_UtilityClass_Test.wareHouseGroupCreation();
     Giic_UtilityClass_Test.warehouseCreation();
     Giic_UtilityClass_Test.locationCreation();
     Giic_UtilityClass_Test.productCreation(); 
     String whId;
     String productId;
     integer qtyReserved;
     String locId;
     Test.startTest();    
     whId=Giic_UtilityClass_Test.objWhLocal.Id;
     List<gii__Product2Add__c> objProdRef= new List<gii__Product2Add__c>();
     objProdRef = [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
     System.assertEquals(true, objProdRef.size()>0);
     productId=objProdRef[0].Id;
     qtyReserved=1;
     locId=Giic_UtilityClass_Test.objLocationCentral.Id;
     Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef ); 
     Giic_ReservationUtility.getReservationWrapper(whId,productId,qtyReserved,locId);
     //objWhLocal.
     Test.stopTest();    
    }

    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 26/07/2019
    * @description – Test Method for getreserveQuantities
    */    
    @isTest
    private static  void getreserveQuantitiesTest() {       
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation(); 
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.giic_ProcurementType__c = 'Transfer';
        objProdRef.gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        update objProdRef;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef);
        Test.startTest();
        /*Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        update Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();*/
        List<gii__Product2Add__c> lstProdRef = new List<gii__Product2Add__c>();
        lstProdRef.add(objProdRef);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,lstProdRef ); 
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
          gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
          gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
          gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
          gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
          gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
          gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
        ];
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap= new List<giic_ReservationUtility.ReservationWrapper>();
        giic_ReservationUtility.ReservationWrapper objReserve=new giic_ReservationUtility.ReservationWrapper();
        objReserve.warehouseId=Giic_UtilityClass_Test.lstWh[0].Id;
        objReserve.product =objProdRef.Id;
        objReserve.qty =2; 
        objReserve.location=Giic_UtilityClass_Test.objLocationCentral.Id;
        reserveWrap.add(objReserve);
        System.assertEquals(true, reserveWrap.size()>0);
        Giic_ReservationUtility.reserveQuantities(reserveWrap);
         Test.stopTest();
    } 
    
    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date Creation 26/07/2019
    * @date Modification dd/mm/yyyy
    * @description – Test Method for changePIQDReserveStatus.
    */    
    @isTest
    private static void changePIQDReserveStatusTest() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();   
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.gii__SerialControlled__c=true;
        objProdRef.giic_ProcurementType__c = 'Transfer';
        objProdRef.gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        update objProdRef;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef);
      /*  Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        system.debug('getQueries()>>>>>1111'+Limits.getQueries());
         
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();   */
              Test.startTest();    
        list<gii__Product2Add__c> lstProdRef = new list<gii__Product2Add__c>();
        lstProdRef.add(objProdRef);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,lstProdRef ); 
         gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                              gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                              gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                              gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                              gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                              gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                              gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                              ];
        System.debug('prodInvntryobj+++++'+prodInvntryobj); 
        system.debug('getQueries()>>>>>22222'+Limits.getQueries());
        // gii__ProductInventory__c prodInvntryobj=new gii__ProductInventory__c(gii__Product__c=objProdRef, gii__Warehouse__c=);    
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        //Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        Giic_UtilityClass_Test.objProductSerial= new gii__ProductSerial__c(Name = 'TUBE1234',gii__Product__c=objProdRef.id,gii__ProductInventory__c=prodInvntryobj.Id,	
                                                                           gii__Warehouse__c=Giic_UtilityClass_Test.lstWh[0].Id,gii__Location__c=Giic_UtilityClass_Test.objLocationCentral.Id);
        insert Giic_UtilityClass_Test.objProductSerial;
        Giic_UtilityClass_Test.objPID.gii__ProductSerial__c = Giic_UtilityClass_Test.objProductSerial.Id;
        Giic_UtilityClass_Test.objPID.gii__Location__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objPID;
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c ='FSL92001';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c ='FSL92091';
        update Giic_UtilityClass_Test.objSalesOrder; 
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c ='TEST12345';
        update Giic_UtilityClass_Test.objSalesOrderLine; 
        
        system.debug('Giic_UtilityClass_Test.objPID>>>>>>'+Giic_UtilityClass_Test.objPID.gii__Location__c);
        
        List<giic_CommonWrapper.SalesOrderHeader> soList= new List<giic_CommonWrapper.SalesOrderHeader>();
        giic_CommonWrapper.SalesOrderHeader soHderObj=new giic_CommonWrapper.SalesOrderHeader();
        soHderObj.AccountId=giic_UtilityClass_Test.objAccountCentral.Id;
        soHderObj.DirectPurchaseOrder=true;
        soHderObj.fSLWorkOrder='FSL92001';
        soHderObj.fSLWorkOrderLineItem='FSL92091';
        soHderObj.warehouseId=Giic_UtilityClass_Test.lstWh[0].Id;
        soHderObj.SalesOrderLineList= new List<giic_CommonWrapper.SalesOrderLine>();
        giic_CommonWrapper.SalesOrderLine soLObj=new giic_CommonWrapper.SalesOrderLine();
        soLObj.OrderQuantity=10.0;
        soLObj.ProductId=objProdRef.Id;
        soLObj.UnitPrice=10;
        soLObj.OwnedByEnelX = false;
        soLObj.productRequiredID='TEST12345';
        soLObj.batchNumber= Giic_UtilityClass_Test.objProductSerial.Id;
        soHderObj.SalesOrderLineList.add(soLObj);
        soList.add(soHderObj);
        System.assertEquals(true, soList.size()>0);
        Giic_ReservationUtility.changePIQDReserveStatus(soList);       
        Test.stopTest();
    }
   
    @isTest
    private static void soDirectReserveAndShipTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        Test.startTest();    
        List<gii__InventoryReserve__c> listInventoryReserve = new List<gii__InventoryReserve__c>();
        gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
        ir.gii__SalesOrderLine__c = Giic_UtilityClass_Test.objSalesOrderLine.id;
      //  ir.gii__ProductInventoryQuantityDetail__c = Giic_UtilityClass_Test.objPID.Id;
        ir.gii__ReserveQuantity__c = 1.0;  
        // add reservation record to the list
        listInventoryReserve.add(ir);
		System.assertEquals(true, listInventoryReserve.size()>0);
       // Giic_GoodsIssueSO.OrderGoodsIssuedResponse odrResponse = new Giic_GoodsIssueSO.OrderGoodsIssuedResponse();
        Giic_ReservationUtility.soDirectReserveAndShip(listInventoryReserve);
        Test.stopTest();   
    }

   @isTest
    private static void clearBackOrderQtyTest(){
         Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation(); 
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.giic_ProcurementType__c = 'Transfer';
        objProdRef.gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        update objProdRef;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef);
          Test.startTest();
      /*  Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        update Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
       
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();   */

        list<gii__Product2Add__c> lstProdRef = new list<gii__Product2Add__c>();
        lstProdRef.add(objProdRef);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,lstProdRef ); 
        map<Id,gii__ProductInventory__c> mapProductInventory = new   map<Id,gii__ProductInventory__c> ([SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                              gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                              gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                              gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                              gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                              gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                              gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                              ]);
        gii__ProductInventory__c prodInvntryobj=mapProductInventory.values()[0];
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap= new List<giic_ReservationUtility.ReservationWrapper>();
        giic_ReservationUtility.ReservationWrapper objReserve=new giic_ReservationUtility.ReservationWrapper();
        objReserve.warehouseId=Giic_UtilityClass_Test.lstWh[0].Id;
        objReserve.product =objProdRef.Id;
        objReserve.qty =2; 
        objReserve.location=Giic_UtilityClass_Test.objLocationCentral.Id;
        reserveWrap.add(objReserve);
        System.assertEquals(true, reserveWrap.size()>0);
        Giic_ReservationUtility.clearBackOrderQty(reserveWrap, mapProductInventory);
         Test.stopTest();
    }
    
   @isTest
    private static void clearBackOrderQtyPOTest(){
         Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation(); 
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.giic_ProcurementType__c = 'Transfer';
        objProdRef.gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        update objProdRef;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef);
          Test.startTest();
      /*  Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        update Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
       
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();   */
        
        list<gii__Product2Add__c> lstProdRef = new list<gii__Product2Add__c>();
        lstProdRef.add(objProdRef);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,lstProdRef ); 
        map<Id,gii__ProductInventory__c> mapProductInventory = new   map<Id,gii__ProductInventory__c> ([SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                              gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                              gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                              gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                              gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                              gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                              gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                              ]);
        gii__ProductInventory__c prodInvntryobj=mapProductInventory.values()[0];
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap= new List<giic_ReservationUtility.ReservationWrapper>();
        giic_ReservationUtility.ReservationWrapper objReserve=new giic_ReservationUtility.ReservationWrapper();
        objReserve.warehouseId=Giic_UtilityClass_Test.lstWh[0].Id;
        objReserve.product =objProdRef.Id;
        objReserve.qty =2; 
        objReserve.location=Giic_UtilityClass_Test.objLocationCentral.Id;
        reserveWrap.add(objReserve);
        System.assertEquals(true, reserveWrap.size()>0);
        Giic_ReservationUtility.clearBackOrderQtyPO(reserveWrap, mapProductInventory);
         Test.stopTest();
    }
      
   @isTest
    private static void doInventoryAdjustmentsTest(){
         Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation(); 
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.giic_ProcurementType__c = 'Transfer';
        objProdRef.gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        update objProdRef;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef);
          Test.startTest();
   /*     Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        update Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
       
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();   */
        
        list<gii__Product2Add__c> lstProdRef = new list<gii__Product2Add__c>();
        lstProdRef.add(objProdRef);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,lstProdRef ); 
        map<Id,gii__ProductInventory__c> mapProductInventory = new   map<Id,gii__ProductInventory__c> ([SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                              gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                              gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                              gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                              gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                              gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                              gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                              ]);
        gii__ProductInventory__c prodInvntryobj=mapProductInventory.values()[0];
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap= new List<giic_ReservationUtility.ReservationWrapper>();
        giic_ReservationUtility.ReservationWrapper objReserve=new giic_ReservationUtility.ReservationWrapper();
        objReserve.warehouseId=Giic_UtilityClass_Test.lstWh[0].Id;
        objReserve.product =objProdRef.Id;
        objReserve.qty =2; 
        objReserve.location=Giic_UtilityClass_Test.objLocationCentral.Id;
        reserveWrap.add(objReserve);
        System.assertEquals(true, reserveWrap.size()>0);
        List<gii__ProductInventoryQuantityDetail__c> listPIQD = new List<gii__ProductInventoryQuantityDetail__c>();
        listPIQD.add(Giic_UtilityClass_Test.objPID);
        Giic_ReservationUtility.doInventoryAdjustments(listPIQD);
         Test.stopTest();
    }
}