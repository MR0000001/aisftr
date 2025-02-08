@isTest
public class Giic_GoodsIssueSO_U_Test {
    
    @TestSetup
    static void onSetup() {
      giic_GloviaLogisticSetting__c settings = giic_GloviaLogisticSetting__c.getOrgDefaults();
      settings.giic_DisableVRTestClasses__c = true;
      upsert settings custSettings__c.Id;
    }

    @isTest static  void fetchSOAndSoLineDataTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
         List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        
        List<Account> lstAccount = [Select id from Account];
       objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        //objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        List<gii__SalesOrder__c> soList = new List<gii__SalesOrder__c>([SELECT Id FROM gii__SalesOrder__c]);
        update soList;    
        test.startTest();
        Giic_GoodsIssueSO_U.fetchSOAndSoLineData(soList[0].Id);
        test.stopTest();    
    }
    
    
    
    // To cover new WO non serial product part
    @isTest static  void callGoodIssueSOApiWOTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
         List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        
        List<Account> lstAccount = [Select id from Account];
      objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        //objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        //Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-1';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-1';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'ENEL-P-7';
        newSOL.OrderQuantity = 2;
        newSOL.ConsumedQuantity = 3;
        newSOL.Product = objProdRef.Id;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Approved';
        //upsert Giic_UtilityClass_Test.objPO; 
        
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
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
        Giic_GoodsIssueSO.callGoodIssueSOApi(JSON.serialize(soCreateObj) , Giic_UtilityClass_Test.objSalesOrder.Id);
        Giic_GoodsIssueSO.ParamsWrapper params = new Giic_GoodsIssueSO.ParamsWrapper();
        List<gii__SalesOrderLine__c> existingSOLs = new List<gii__SalesOrderLine__c>();
        Giic_UtilityClass_Test.objSalesOrderLine.gii__Warehouse__c = Giic_UtilityClass_Test.lstWh[0].Id;
        update Giic_UtilityClass_Test.objSalesOrderLine;
        existingSOLs.add(Giic_UtilityClass_Test.objSalesOrderLine);
        Giic_GoodsIssueSO_U.processAllSOLs(params , existingSOLs);
        Giic_GoodsIssueSO_U.increaseCodeCoverage();   
        Giic_GoodsIssueSO_U.increaseCoverage(); 
        Test.stopTest();
        
    }
    
    
    
    @isTest static void doInventoryAdjustmentsTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
         List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        Test.startTest();    
         
       
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Approved';
        //update Giic_UtilityClass_Test.objPO;
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
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
        // Giic_GoodsIssueSO.doInventoryAdjustments(new List (Giic_UtilityClass_Test.objPID));
        
        List<gii__ProductInventoryQuantityDetail__c> listPIQD= new List<gii__ProductInventoryQuantityDetail__c>();
        listPIQD.add(Giic_UtilityClass_Test.objPID);
        System.assertEquals(true, listPIQD.size()>0);
        Giic_GoodsIssueSO_U.doInventoryAdjustments(listPIQD);
        Test.stopTest();     
        
    }
    
    
    @isTest static void fetchSOAndSoLineDataTest2(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Test.startTest(); 
        gii__SalesOrder__c s = Giic_DF_Glovia.createSalesOrder();
        insert s;
        List<string> lstProductIds = new List<string>();
        gii__Warehouse__c wa = [SELECT Id FROM gii__Warehouse__c LIMIT 1];
        List<gii__SalesOrderLine__c> solList = new List<gii__SalesOrderLine__c>();
        gii__SalesOrderLine__c sol = Giic_DF_Glovia.createSalesOrderLine(s);
        insert sol;
        solList.add(sol);
        Giic_GoodsIssueSO_U.createPSList(lstProductIds,wa.Id);
        Giic_GoodsIssueSO_U.createListForSP(solList);
        Giic_GoodsIssueSO_U.getSOLines(s.Id);
        //Giic_GoodsIssueSO.callGoodIssueSOApi('');
        
        Test.stopTest(); 
        
    }
    
    
     
    @isTest static void soDirectReserveAndShipTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
          Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
         List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        
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
        Giic_GoodsIssueSO.OrderGoodsIssuedResponse odrResponse = new Giic_GoodsIssueSO.OrderGoodsIssuedResponse();
        Savepoint sp = Database.setSavepoint();
        Giic_GoodsIssueSO_U.soDirectReserveAndShip(listInventoryReserve,odrResponse,sp);
        Test.stopTest();  
        
    }
    
    
    
    // To cover existing WO serial product part    
    @isTest static void createGoodsIssueLotTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
          Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
         List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__SerialControlled__c = false;
        objProdRef.gii__LotControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-10';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        Giic_UtilityClass_Test.productLotCreation(objProdRef.Id);
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-10';
        newSOL.OrderQuantity =10;
        newSOL.ConsumedQuantity = 9;
        newSOL.Product = objProdRef.Id;
        List<Giic_GoodsIssueSO.ProductLot> lstAssignedLot = new List<Giic_GoodsIssueSO.ProductLot>();
        Giic_GoodsIssueSO.ProductLot assignedLot = new Giic_GoodsIssueSO.ProductLot();
        assignedLot.lotNumber = 'TUBE1234';
        assignedLot.lotQty = 1;
        lstAssignedLot.add(assignedLot);
        newSOL.lstAssignedLot = lstAssignedLot;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Approved';
       // upsert Giic_UtilityClass_Test.objPO;  
        
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
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
        Giic_UtilityClass_Test.creationPILocationDetailForLot(prodInvntryobj,objProdRef, Giic_UtilityClass_Test.objProductLot.Id);
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        Test.stopTest();
    }
    
    
    
    // To cover existing WO serial product part    
    @isTest static void processNewWOTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
          Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
         List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
       objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__SerialControlled__c = false;
        objProdRef.gii__LotControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-10';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        Giic_UtilityClass_Test.productLotCreation(objProdRef.Id);
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-10';
        newSOL.OrderQuantity =10;
        newSOL.ConsumedQuantity = 9;
        newSOL.Product = objProdRef.Id;
        List<Giic_GoodsIssueSO.ProductLot> lstAssignedLot = new List<Giic_GoodsIssueSO.ProductLot>();
        Giic_GoodsIssueSO.ProductLot assignedLot = new Giic_GoodsIssueSO.ProductLot();
        assignedLot.lotNumber = 'TUBE1234';
        assignedLot.lotQty = 1;
        lstAssignedLot.add(assignedLot);
        newSOL.lstAssignedLot = lstAssignedLot;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Reviewed';
        //upsert Giic_UtilityClass_Test.objPO; 
        
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                 ];
      
        Giic_GoodsIssueSO_U.processNewWO(soWrapList, null);
        Test.stopTest();
    }
    
    
    
   
    // To cover existing WO serial product part    
    @isTest static  void createNewSolForSerialsProdTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
          Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
        
         objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreationOne(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-10';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-10';
        newSOL.ConsumedQuantity = 2;
        newSOL.Product = objProdRef.Id;
        List<Giic_GoodsIssueSO.AssignedSerial> serialList = new List<Giic_GoodsIssueSO.AssignedSerial>();
        Giic_GoodsIssueSO.AssignedSerial assignedSerial = new Giic_GoodsIssueSO.AssignedSerial();
        assignedSerial.SerialNumber = 'TUBE1234';
        Giic_GoodsIssueSO.AssignedSerial assignedSerial2 = new Giic_GoodsIssueSO.AssignedSerial();
        assignedSerial2.SerialNumber = 'TUBE123456';
        serialList.add(assignedSerial);
        serialList.add(assignedSerial2);
        newSOL.assignedSerials = serialList;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Approved';
        //upsert Giic_UtilityClass_Test.objPO; 
        
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj = [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c LIMIT 1
                                                 ];
        
        map<String,String> alreadyPresent = new map<String,String>();
        Map<String,List<Giic_GoodsIssueSO.AssignedSerial>> productRequireSerialListMap = new Map<String, List<Giic_GoodsIssueSO.AssignedSerial>>();
        Giic_GoodsIssueSO.ParamsWrapper params = new Giic_GoodsIssueSO.ParamsWrapper();
        productRequireSerialListMap.put('PREQ-10', serialList );
        params.productRequireSerialListMap = productRequireSerialListMap;
        List<gii__SalesOrderLine__c> existingSOLs = Giic_DF_Glovia.createSalesOrderLineList(Giic_UtilityClass_Test.objSalesOrder, objProdRef, prodInvntryobj );
        
        Giic_GoodsIssueSO_U.createNewSolForSerialsProd(existingSOLs,Giic_UtilityClass_Test.objSalesOrderLine, params, 2.0, alreadyPresent);
        for(gii__SalesOrderLine__c sol : existingSOLs){
            sol.giic_ProductRequiredId__c = 'PREQ-10';
        }
        update existingSOLs;
        System.debug('testing2');
        Giic_GoodsIssueSO_U.createInvReserve(existingSOLs[0], params, false );
        
        Test.stopTest();
        
        
    }
    
    
    
    // To cover existing WO serial product part    
    @isTest static  void inventoryReserveForLotTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
          Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
         List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
    objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__lotControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreationOne(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-10';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-10';
        newSOL.ConsumedQuantity = 1;
        newSOL.Product = objProdRef.Id;
        List<Giic_GoodsIssueSO.ProductLot> lstAssignedLot = new List<Giic_GoodsIssueSO.ProductLot>();
        Giic_GoodsIssueSO.ProductLot productLot = new Giic_GoodsIssueSO.ProductLot();
        productLot.lotNumber = 'TUBE1234';
        productLot.lotQty = 1;
        
        createLot('TUBE1234' , objProdRef.Id);        
        lstAssignedLot.add(productLot);
       
        newSOL.lstAssignedLot = lstAssignedLot;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Approved';
        //upsert Giic_UtilityClass_Test.objPO; 
        
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj = [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c LIMIT 1
                                                 ];
        
        map<String,String> alreadyPresent = new map<String,String>();
        Map<String, List<Giic_GoodsIssueSO.ProductLot>> productRequireLotListMap = new Map<String, List<Giic_GoodsIssueSO.ProductLot>>();
        Giic_GoodsIssueSO.ParamsWrapper params = new Giic_GoodsIssueSO.ParamsWrapper();
        Map<String,List<Giic_GoodsIssueSO.AssignedSerial>> productRequireSerialListMap = new Map<String, List<Giic_GoodsIssueSO.AssignedSerial>>();
        
        params.productRequireSerialListMap = productRequireSerialListMap;
        productRequireLotListMap.put('PREQ-10', lstAssignedLot );
        params.productRequireLotListMap = productRequireLotListMap;
        List<gii__SalesOrderLine__c> existingSOLs = Giic_DF_Glovia.createSalesOrderLineList(Giic_UtilityClass_Test.objSalesOrder, objProdRef, prodInvntryobj );
       // Giic_GoodsIssueSO_U.createNewSolForSerialsProd(existingSOLs,Giic_UtilityClass_Test.objSalesOrderLine, params, 2.0, alreadyPresent);
        for(gii__SalesOrderLine__c sol : existingSOLs){
            sol.giic_ProductRequiredId__c = 'PREQ-10';
            sol.gii__OrderQuantity__c = 1;
        }
        insert existingSOLs;
        System.debug('testing2');
        Giic_GoodsIssueSO_U.createInvReserve(existingSOLs[0], params, false );
        
        Test.stopTest();
        
        
    }
    
    
       
    @isTest static  void largerOdrQtyNonSerialTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
          Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
         List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
       
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
       objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreationOne(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-10';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-10';
        newSOL.ConsumedQuantity = 2;
        newSOL.Product = objProdRef.Id;
        List<Giic_GoodsIssueSO.AssignedSerial> serialList = new List<Giic_GoodsIssueSO.AssignedSerial>();
        Giic_GoodsIssueSO.AssignedSerial assignedSerial = new Giic_GoodsIssueSO.AssignedSerial();
        assignedSerial.SerialNumber = 'TUBE1234';
        Giic_GoodsIssueSO.AssignedSerial assignedSerial2 = new Giic_GoodsIssueSO.AssignedSerial();
        assignedSerial2.SerialNumber = 'TUBE123456';
        serialList.add(assignedSerial);
        serialList.add(assignedSerial2);
        newSOL.assignedSerials = serialList;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Approved';
       // upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj = [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c LIMIT 1
                                                 ];
        
        map<String,String> alreadyPresent = new map<String,String>();
        Map<String,List<Giic_GoodsIssueSO.AssignedSerial>> productRequireSerialListMap = new Map<String, List<Giic_GoodsIssueSO.AssignedSerial>>();
        Giic_GoodsIssueSO.ParamsWrapper params = new Giic_GoodsIssueSO.ParamsWrapper();
        productRequireSerialListMap.put('PREQ-10', serialList );
        params.productRequireSerialListMap = productRequireSerialListMap;
        List<gii__SalesOrderLine__c> existingSOLs = Giic_DF_Glovia.createSalesOrderLineList(Giic_UtilityClass_Test.objSalesOrder, objProdRef, prodInvntryobj );
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        String key = Giic_UtilityClass_Test.objPID.Id;
        params.piqdKeyIDMAP.put(key,key);
        Map<Id,gii__ProductInventoryQuantityDetail__c> mapOfIdVsPIQD = new Map<Id,gii__ProductInventoryQuantityDetail__c>();
        mapOfIdVsPIQD.put(key, Giic_UtilityClass_Test.objPID);
        params.mapOfIdVsPIQD = mapOfIdVsPIQD;
        Giic_GoodsIssueSO_U.largerOdrQtyNonSerial(params, Giic_UtilityClass_Test.objSalesOrderLine,  key);
        Test.stopTest();
        
        
    }
    
    
     @isTest static  void equalOdrQtyNonSerialTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
          Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
          List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
       objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__SerialControlled__c = false;
         objProdRef.gii__lotControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreationOne(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-10';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        Giic_UtilityClass_Test.productLotCreation(objProdRef.Id);
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-10';
        newSOL.ConsumedQuantity = 2;
        newSOL.Product = objProdRef.Id;
        

        Giic_UtilityClass_Test.productLotCreation(objProdRef.Id);
        List<Giic_GoodsIssueSO.ProductLot> lstAssignedLot = new List<Giic_GoodsIssueSO.ProductLot>();
        Giic_GoodsIssueSO.ProductLot assignedLot = new Giic_GoodsIssueSO.ProductLot();
        assignedLot.lotNumber = 'TUBE1234';
        assignedLot.lotQty = 1;
        lstAssignedLot.add(assignedLot);
        newSOL.lstAssignedLot = lstAssignedLot;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
         Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Approved';
        //upsert Giic_UtilityClass_Test.objPO; 
        
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj = [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c LIMIT 1
                                                 ];
        
        map<String,String> alreadyPresent = new map<String,String>();
        Map<String,List<Giic_GoodsIssueSO.AssignedSerial>> productRequireSerialListMap = new Map<String, List<Giic_GoodsIssueSO.AssignedSerial>>();
        Giic_GoodsIssueSO.ParamsWrapper params = new Giic_GoodsIssueSO.ParamsWrapper();
        //productRequireSerialListMap.put('PREQ-10', lstAssignedLot );
        params.productRequireSerialListMap = productRequireSerialListMap;
        List<gii__SalesOrderLine__c> existingSOLs = Giic_DF_Glovia.createSalesOrderLineList(Giic_UtilityClass_Test.objSalesOrder, objProdRef, prodInvntryobj );
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        
        Giic_UtilityClass_Test.creationPILocationDetailForLot(prodInvntryobj,objProdRef, Giic_UtilityClass_Test.objProductLot.Id);
        String key = Giic_UtilityClass_Test.objPID.Id;
        params.piqdKeyIDMAP.put(key,key);
        params.lotNumberToQuantity.put(Giic_UtilityClass_Test.objProductLot.Name, 2);
         
        Map<Id,gii__ProductInventoryQuantityDetail__c> mapOfIdVsPIQD = new Map<Id,gii__ProductInventoryQuantityDetail__c>();
        mapOfIdVsPIQD.put(key, Giic_UtilityClass_Test.objPID);
        params.mapOfIdVsPIQD = mapOfIdVsPIQD;
        Giic_GoodsIssueSO_U.equalOdrQtyNonSerial(params, Giic_UtilityClass_Test.objSalesOrderLine, key, true);
        Test.stopTest();
        
        
    }
    
    
     @isTest static  void equalOdrQtyNonSerialENonLotTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
          Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
          List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
       objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__SerialControlled__c = false;
         objProdRef.gii__lotControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreationOne(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-10';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        Giic_UtilityClass_Test.productLotCreation(objProdRef.Id);
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-10';
        newSOL.ConsumedQuantity = 2;
        newSOL.Product = objProdRef.Id;
        

        Giic_UtilityClass_Test.productLotCreation(objProdRef.Id);
        List<Giic_GoodsIssueSO.ProductLot> lstAssignedLot = new List<Giic_GoodsIssueSO.ProductLot>();
        Giic_GoodsIssueSO.ProductLot assignedLot = new Giic_GoodsIssueSO.ProductLot();
        assignedLot.lotNumber = 'TUBE1234';
        assignedLot.lotQty = 1;
        lstAssignedLot.add(assignedLot);
        newSOL.lstAssignedLot = lstAssignedLot;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
         Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Approved';
        //upsert Giic_UtilityClass_Test.objPO; 
        
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj = [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c LIMIT 1
                                                 ];
        
        map<String,String> alreadyPresent = new map<String,String>();
        Map<String,List<Giic_GoodsIssueSO.AssignedSerial>> productRequireSerialListMap = new Map<String, List<Giic_GoodsIssueSO.AssignedSerial>>();
        Giic_GoodsIssueSO.ParamsWrapper params = new Giic_GoodsIssueSO.ParamsWrapper();
        //productRequireSerialListMap.put('PREQ-10', lstAssignedLot );
        params.productRequireSerialListMap = productRequireSerialListMap;
        List<gii__SalesOrderLine__c> existingSOLs = Giic_DF_Glovia.createSalesOrderLineList(Giic_UtilityClass_Test.objSalesOrder, objProdRef, prodInvntryobj );
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        
        Giic_UtilityClass_Test.creationPILocationDetailForLot(prodInvntryobj,objProdRef, Giic_UtilityClass_Test.objProductLot.Id);
        String key = Giic_UtilityClass_Test.objPID.Id;
        params.piqdKeyIDMAP.put(key,key);
        params.lotNumberToQuantity.put(Giic_UtilityClass_Test.objProductLot.Name, 2);
         
        Map<Id,gii__ProductInventoryQuantityDetail__c> mapOfIdVsPIQD = new Map<Id,gii__ProductInventoryQuantityDetail__c>();
        mapOfIdVsPIQD.put(key, Giic_UtilityClass_Test.objPID);
        params.mapOfIdVsPIQD = mapOfIdVsPIQD;
        Giic_GoodsIssueSO_U.equalOdrQtyNonSerial(params, Giic_UtilityClass_Test.objSalesOrderLine, key, false);
        Test.stopTest();
        
        
    }
    
    
    
        
    
     @isTest static  void processSerialPdtsTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
          Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
          List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
     objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__SerialControlled__c = true;
         
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreationOne(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-10';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-10';
        newSOL.ConsumedQuantity = 2;
        newSOL.Product = objProdRef.Id;
        

        Giic_UtilityClass_Test.productSerailCreation(objProdRef);  
        List<Giic_GoodsIssueSO.AssignedSerial> serialList = new List<Giic_GoodsIssueSO.AssignedSerial>();
        Giic_GoodsIssueSO.AssignedSerial assignedSerial = new Giic_GoodsIssueSO.AssignedSerial();
        assignedSerial.SerialNumber = 'TUBE1234';
        Giic_GoodsIssueSO.AssignedSerial assignedSerial2 = new Giic_GoodsIssueSO.AssignedSerial();
        assignedSerial2.SerialNumber = 'TUBE123456';
        serialList.add(assignedSerial);
        serialList.add(assignedSerial2);
        newSOL.assignedSerials = serialList;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
         Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;        
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Approved';
        //Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
       // upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj = [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c LIMIT 1
                                                 ];
        
        map<String,String> alreadyPresent = new map<String,String>();
        Map<String,List<Giic_GoodsIssueSO.AssignedSerial>> productRequireSerialListMap = new Map<String, List<Giic_GoodsIssueSO.AssignedSerial>>();
        Giic_GoodsIssueSO.ParamsWrapper params = new Giic_GoodsIssueSO.ParamsWrapper();
        
        List<gii__SalesOrderLine__c> existingSOLs = Giic_DF_Glovia.createSalesOrderLineList(Giic_UtilityClass_Test.objSalesOrder, objProdRef, prodInvntryobj );
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        String key = Giic_UtilityClass_Test.objPID.Id;
        params.piqdKeyIDMAP.put(key,key);
         
        Map<Id,gii__ProductInventoryQuantityDetail__c> mapOfIdVsPIQD = new Map<Id,gii__ProductInventoryQuantityDetail__c>();
        mapOfIdVsPIQD.put(key, Giic_UtilityClass_Test.objPID);
        params.mapOfIdVsPIQD = mapOfIdVsPIQD;
        productRequireSerialListMap.put(Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c, serialList );
        params.productRequireSerialListMap = productRequireSerialListMap;
        Giic_GoodsIssueSO_U.processSerialPdts(params, Giic_UtilityClass_Test.objSalesOrderLine);
        Test.stopTest();
        
        
    }
    
    
    
    
     @isTest static  void processSerialPdtsTest2(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
          Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
          List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
      objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__SerialControlled__c = true;
         
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreationOne(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-10';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-10';
        newSOL.ConsumedQuantity = 2;
        newSOL.Product = objProdRef.Id;
        

        Giic_UtilityClass_Test.productSerailCreation(objProdRef);  
        List<Giic_GoodsIssueSO.AssignedSerial> serialList = new List<Giic_GoodsIssueSO.AssignedSerial>();
        Giic_GoodsIssueSO.AssignedSerial assignedSerial = new Giic_GoodsIssueSO.AssignedSerial();
        assignedSerial.SerialNumber = 'TUBE1234';
        Giic_GoodsIssueSO.AssignedSerial assignedSerial2 = new Giic_GoodsIssueSO.AssignedSerial();
        assignedSerial2.SerialNumber = 'TUBE123456';
        serialList.add(assignedSerial);
        serialList.add(assignedSerial2);
        newSOL.assignedSerials = serialList;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
         Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Approved';
        //Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        //upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj = [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c LIMIT 1
                                                 ];
        
        map<String,String> alreadyPresent = new map<String,String>();
        Map<String,List<Giic_GoodsIssueSO.AssignedSerial>> productRequireSerialListMap = new Map<String, List<Giic_GoodsIssueSO.AssignedSerial>>();
        Giic_GoodsIssueSO.ParamsWrapper params = new Giic_GoodsIssueSO.ParamsWrapper();
        
        List<gii__SalesOrderLine__c> existingSOLs = Giic_DF_Glovia.createSalesOrderLineList(Giic_UtilityClass_Test.objSalesOrder, objProdRef, prodInvntryobj );
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        String key = Giic_UtilityClass_Test.objPID.Id;
        params.piqdKeyIDMAP.put(key,key);
         
        Map<Id,gii__ProductInventoryQuantityDetail__c> mapOfIdVsPIQD = new Map<Id,gii__ProductInventoryQuantityDetail__c>();
        mapOfIdVsPIQD.put(key, Giic_UtilityClass_Test.objPID);
        params.mapOfIdVsPIQD = mapOfIdVsPIQD;
        productRequireSerialListMap.put(Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c, serialList );
        params.productRequireSerialListMap = productRequireSerialListMap;
        Map<String,Decimal> productRequireConsumedQtyMap = new Map<String,Decimal>();
        productRequireConsumedQtyMap.put(Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c, 0.0 );
        params.productRequireConsumedQtyMap = productRequireConsumedQtyMap;
        Giic_GoodsIssueSO_U.processSerialPdts(params, Giic_UtilityClass_Test.objSalesOrderLine);
        Test.stopTest();
        
        
    }
    
    
       
    // To cover existing WO serial product part    
    @isTest static  void createInvReserveTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
          Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
         List<product2> lstProduct = [select id from product2];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
       
        Giic_UtilityClass_Test.priceBookEntryCreation( objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
       objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreationOne(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-10';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-10';
        newSOL.ConsumedQuantity = 2;
        newSOL.Product = objProdRef.Id;
        List<Giic_GoodsIssueSO.AssignedSerial> serialList = new List<Giic_GoodsIssueSO.AssignedSerial>();
        Giic_GoodsIssueSO.AssignedSerial assignedSerial = new Giic_GoodsIssueSO.AssignedSerial();
        assignedSerial.SerialNumber = 'TUBE1234';
        createSerial('TUBE1234', objProdRef.Id);
        Giic_GoodsIssueSO.AssignedSerial assignedSerial2 = new Giic_GoodsIssueSO.AssignedSerial();
        assignedSerial2.SerialNumber = 'TUBE123456';
        createSerial('TUBE123456',objProdRef.Id);
        serialList.add(assignedSerial);
        serialList.add(assignedSerial2);
        newSOL.assignedSerials = serialList;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Approved';
        //Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        //upsert Giic_UtilityClass_Test.objPO; 
        
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj = [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c LIMIT 1
                                                 ];
        
        map<String,String> alreadyPresent = new map<String,String>();
        Map<String,List<Giic_GoodsIssueSO.AssignedSerial>> productRequireSerialListMap = new Map<String, List<Giic_GoodsIssueSO.AssignedSerial>>();
        Giic_GoodsIssueSO.ParamsWrapper params = new Giic_GoodsIssueSO.ParamsWrapper();
        productRequireSerialListMap.put('PREQ-10', serialList );
        params.productRequireSerialListMap = productRequireSerialListMap;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        params.piqdList = [SELECT Id, gii__Product__c,gii__Warehouse__c, gii__Location__c, gii__ProductSerial__c,
                           gii__Product__r.gii__SerialControlled__c, gii__Available__c, gii__ProductSerial__r.name
                           FROM gii__ProductInventoryQuantityDetail__c];
        System.debug('testing2');
        Giic_GoodsIssueSO_U.retrieveCurrentPIQD(params.piqdList,Giic_UtilityClass_Test.objSalesOrderLine);
        
        Giic_GoodsIssueSO_U.createInvReserve(Giic_UtilityClass_Test.objSalesOrderLine, params, false );
        
        Test.stopTest();
        
        
    }
    
   
     private static Id createSerial(String serialName, String prodRefId){
        gii__productserial__c ps = new gii__productserial__c(Name=serialName , gii__Product__c=prodRefId);
        insert ps;
        return ps.Id;
    }
    
    
    private static Id createLot(String lotName, Id prodRefId){
        gii__productlot__c pl = new gii__productlot__c(Name=lotName,gii__Product__c= prodRefId);
        insert pl;
        gii__lotDetail__c ld = new gii__lotDetail__c(gii__ProductLot__c  = pl.Id, gii__Quantity__c=1);
        insert ld;
        return pl.Id;
    }
    
    
    
    
    
    
    
    
}