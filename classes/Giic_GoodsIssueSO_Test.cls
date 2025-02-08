/**
* @author Glovia Team
* @date Creation 07/08/2019
* @date Modification 10/09/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description Giic_GoodsIssueSO_Test – Test Class for Giic_GoodsIssueSO
*/  

@isTest
public class Giic_GoodsIssueSO_Test {
    
    @TestSetup
    static void onSetup() {
      giic_GloviaLogisticSetting__c settings = giic_GloviaLogisticSetting__c.getOrgDefaults();
      settings.giic_DisableVRTestClasses__c = true;
      upsert settings custSettings__c.Id;
    }

    @isTest 
    // To cover new WO non serial product part
    static void createGoodsIssueTest(){
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
      
      List<Account> lstAccount = [SELECT Id FROM Account];
      List<product2> lstProduct = [SELECT Id FROM product2];
      gii__Product2Add__c objProdRef= [SELECT Id,gii__ProductCode__c FROM gii__Product2Add__c WHERE gii__ProductReference__c =: lstProduct[0].Id LIMIT 1];
      objProdRef.gii__ProductCode__c='Test';
      objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
      //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
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
      List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineListForWOLI = new  List<Giic_GoodsIssueSO.SalesOrderLine>();
      soCreateObj.salesOrderLineListForWOLI = salesOrderLineListForWOLI;
      soCreateObj.FSLWorkOrder = 'TestWO-1';
      soCreateObj.FSLWorkOrderLineItem = 'TestWO-1';
      soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
      soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
      // No serial
      Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
      newSOL.ProductRequiredID = 'PREQ-7';
      newSOL.OrderQuantity = 2;
      newSOL.ConsumedQuantity = 3;
      newSOL.Product = objProdRef.Id;
      solListToCreate.add(newSOL);
      System.assertEquals(true, solListToCreate.size()>0);
      soCreateObj.SalesOrderLineList = solListToCreate;
      soWrapList.add(soCreateObj);
      Test.startTest();
      Giic_UtilityClass_Test.purchaseOrderCreation();
      Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
      Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
      Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
      Giic_UtilityClass_Test.objPO.gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.id;
      upsert Giic_UtilityClass_Test.objPO; 
      Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
      Giic_UtilityClass_Test.pOReceipt();
      Giic_UtilityClass_Test.pOReceiptLine();
      gii__ProductInventory__c prodInvntryobj= [SELECT  gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                                                FROM gii__ProductInventory__c
                                                ];
      Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
      Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
      Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
      Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.objTO.giic_SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.Id;
        update Giic_UtilityClass_Test.objTO;
      Giic_GoodsIssueSO.cancelRelatedObjects(Giic_UtilityClass_Test.objSalesOrder.Id);
      Test.stopTest();
    }
      
    @isTest
    // To cover new WO serial product part    
    static void createGoodsIssueTest1(){
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
      
      List<Account> lstAccount = [SELECT Id FROM Account];
      List<product2> lstProduct = [SELECT Id FROM product2];
      gii__Product2Add__c objProdRef= [SELECT Id,gii__ProductCode__c FROM gii__Product2Add__c WHERE gii__ProductReference__c =:lstProduct[0].Id LIMIT 1];
      objProdRef.gii__ProductCode__c='Test';
      objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
      //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
      objProdRef.gii__SerialControlled__c = true;
      objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
      update objProdRef;
      Giic_UtilityClass_Test.salesOrderCreation();
      Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
      Giic_UtilityClass_Test.productSerailCreation(objProdRef);
      Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
      update Giic_UtilityClass_Test.lstWh;
      List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
      List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
      List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
      
      Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
      soCreateObj.FSLWorkOrder = 'TestWO-12';
      soCreateObj.FSLWorkOrderLineItem = 'TestWO-12';
      soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
      soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
      // No serial
      Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
      newSOL.ProductRequiredID = 'PREQ-8';
      newSOL.OrderQuantity = 2;
      newSOL.ConsumedQuantity = 3;
      newSOL.Product = objProdRef.Id;
      List<Giic_GoodsIssueSO.AssignedSerial> serialList = new List<Giic_GoodsIssueSO.AssignedSerial>();
      Giic_GoodsIssueSO.AssignedSerial assignedSerial = new Giic_GoodsIssueSO.AssignedSerial();
      assignedSerial.SerialNumber = 'TUBE1234';
      createSerial('TUBE1234');
      serialList.add(assignedSerial);
      newSOL.assignedSerials = serialList;
      solListToCreate.add(newSOL);
      System.assertEquals(true, solListToCreate.size()>0);
      soCreateObj.SalesOrderLineList = solListToCreate;
      soWrapList.add(soCreateObj);
      Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
    }
    
    @isTest
    static void createGoodsIssueSerial0Test(){
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
      
      List<Account> lstAccount = [SELECT Id from Account];
      List<product2> lstProduct = [SELECT Id from product2];
      gii__Product2Add__c objProdRef= [SELECT Id,gii__ProductCode__c FROM gii__Product2Add__c WHERE gii__ProductReference__c =:lstProduct[0].Id LIMIT 1];
      objProdRef.gii__ProductCode__c='Test';
      objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
      //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
      objProdRef.gii__SerialControlled__c = true;
      objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
      update objProdRef;
      Giic_UtilityClass_Test.salesOrderCreation();
      Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-13';
      Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-13';
      update Giic_UtilityClass_Test.objSalesOrder;
      
      gii__SalesOrderLine__c objSalesOrderLine1 = new gii__SalesOrderLine__c(
        gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.id,
        gii__Product__c=objProdRef.id,
        gii__OrderQuantity__c =2
      );        
      //Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
      objSalesOrderLine1.giic_ProductRequiredId__c = 'PREQ-9';
      insert objSalesOrderLine1;
      Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
      update Giic_UtilityClass_Test.lstWh;
      Giic_UtilityClass_Test.productSerailCreation(objProdRef);
      
      List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
      List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
      List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
      Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
      soCreateObj.FSLWorkOrder = 'TestWO-13';
      soCreateObj.FSLWorkOrderLineItem = 'TestWO-13';
      soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
      soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
      // No serial
      Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
      newSOL.ProductRequiredID = 'PREQ-9';
      newSOL.OrderQuantity = 2;
      newSOL.ConsumedQuantity = 2;
      newSOL.Product = objProdRef.Id;
      newSOL.isSerialControlled = true;
      List<Giic_GoodsIssueSO.AssignedSerial> serialList = new List<Giic_GoodsIssueSO.AssignedSerial>();
      Giic_GoodsIssueSO.AssignedSerial assignedSerial = new Giic_GoodsIssueSO.AssignedSerial();
      assignedSerial.SerialNumber = null;
      createSerial('TUBE12345');
      serialList.add(assignedSerial);
      newSOL.assignedSerials = serialList;
      solListToCreate.add(newSOL);
      System.assertEquals(true, solListToCreate.size()>0);
      soCreateObj.SalesOrderLineList = solListToCreate;
      soWrapList.add(soCreateObj);
      Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
      Giic_GoodsIssueSO.GoodIssueParamsWrapper paramsGIPW = new Giic_GoodsIssueSO.GoodIssueParamsWrapper();
      paramsGIPW.salesOrderLineListForWOLI = new List<gii__SalesOrderLine__c>{objSalesOrderLine1};
      Giic_GoodsIssueSO.GoodIssueParamsWrapper wrRes = Giic_GoodsIssueSO.processSOLWithWOLI(paramsGIPW);
    }
    
    @isTest
    // To cover existing WO serial product part    
    static void createGoodsIssueSerial1Test(){
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
      
      List<Account> lstAccount = [SELECT Id from Account];
      List<product2> lstProduct = [SELECT Id from product2];
      gii__Product2Add__c objProdRef= [SELECT Id,gii__ProductCode__c FROM gii__Product2Add__c WHERE gii__ProductReference__c =:lstProduct[0].Id LIMIT 1];
      objProdRef.gii__ProductCode__c='Test';
      objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
      //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
      objProdRef.gii__SerialControlled__c = true;
      objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
      update objProdRef;
      Giic_UtilityClass_Test.salesOrderCreation();
      Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-13';
      Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-13';
      update Giic_UtilityClass_Test.objSalesOrder;
      
      gii__SalesOrderLine__c objSalesOrderLine1 = new gii__SalesOrderLine__c(
        gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.id,
        gii__Product__c=objProdRef.id,
        gii__OrderQuantity__c =2
      );
      //Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
      objSalesOrderLine1.giic_ProductRequiredId__c = 'PREQ-9';
      insert objSalesOrderLine1;
      Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
      update Giic_UtilityClass_Test.lstWh;
      Giic_UtilityClass_Test.productSerailCreation(objProdRef);
      
      List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
      List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
      List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
      Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
      soCreateObj.FSLWorkOrder = 'TestWO-13';
      soCreateObj.FSLWorkOrderLineItem = 'TestWO-13';
      soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
      soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
      // No serial
      Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
      newSOL.ProductRequiredID = 'PREQ-9';
      newSOL.OrderQuantity = 2;
      newSOL.ConsumedQuantity = 2;
      newSOL.Product = objProdRef.Id;
      List<Giic_GoodsIssueSO.AssignedSerial> serialList = new List<Giic_GoodsIssueSO.AssignedSerial>();
      Giic_GoodsIssueSO.AssignedSerial assignedSerial = new Giic_GoodsIssueSO.AssignedSerial();
      assignedSerial.SerialNumber = 'TUBE12345';
      createSerial('TUBE12345');
      serialList.add(assignedSerial);
      newSOL.assignedSerials = serialList;
      solListToCreate.add(newSOL);
      System.assertEquals(true, solListToCreate.size()>0);
      soCreateObj.SalesOrderLineList = solListToCreate;
      soWrapList.add(soCreateObj);
      Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
    }
    
    @isTest 
    // To cover existing WO serial product part   
    static void createGoodsIssueSerial2Test(){
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
      //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
      update  Giic_UtilityClass_Test.lstWh[0];        
      List<Account> lstAccount = [SELECT Id FROM Account];
      List<product2> lstProduct = [SELECT Id FROM product2];
      gii__Product2Add__c objProdRef= [SELECT Id,gii__ProductCode__c FROM gii__Product2Add__c WHERE gii__ProductReference__c =:lstProduct[0].Id LIMIT 1];
      objProdRef.gii__ProductCode__c='Test';
      objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
      //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
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
      // No serial
      Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
      newSOL.ProductRequiredID = 'PREQ-10';
      newSOL.ConsumedQuantity = 2;
      newSOL.Product = objProdRef.Id;
      List<Giic_GoodsIssueSO.AssignedSerial> serialList = new List<Giic_GoodsIssueSO.AssignedSerial>();
      Giic_GoodsIssueSO.AssignedSerial assignedSerial = new Giic_GoodsIssueSO.AssignedSerial();
      assignedSerial.SerialNumber = 'TUB1234';
      createSerial('TUB1234');
      Giic_GoodsIssueSO.AssignedSerial assignedSerial2 = new Giic_GoodsIssueSO.AssignedSerial();
      assignedSerial2.SerialNumber = 'TUB1235';
      createSerial('TUB1235');
      serialList.add(assignedSerial);
      serialList.add(assignedSerial2);
      newSOL.assignedSerials = serialList;
      solListToCreate.add(newSOL);
      System.assertEquals(true, solListToCreate.size()>0);
      soCreateObj.SalesOrderLineList = solListToCreate;
      soWrapList.add(soCreateObj);
      Test.startTest();
      Giic_UtilityClass_Test.purchaseOrderCreation();
      Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
      Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
      //Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
      upsert Giic_UtilityClass_Test.objPO; 
      Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
      Giic_UtilityClass_Test.pOReceipt();
      Giic_UtilityClass_Test.pOReceiptLine();
      gii__ProductInventory__c prodInvntryobj= [SELECT  gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                                                FROM gii__ProductInventory__c
                                                ];
      
      System.debug('prodInvntryobj+++++'+prodInvntryobj);
      Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
      Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
      Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
      Test.stopTest();
    }
    
    @isTest 
    // To cover existing WO serial product part    
    static void createGoodsIssueSerial3Test(){
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
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
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
        
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-11';
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
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-11';
        newSOL.OrderQuantity =10;
        newSOL.ConsumedQuantity = 11;
        newSOL.Product = objProdRef.Id;
        List<Giic_GoodsIssueSO.AssignedSerial> serialList = new List<Giic_GoodsIssueSO.AssignedSerial>();
        Giic_GoodsIssueSO.AssignedSerial assignedSerial = new Giic_GoodsIssueSO.AssignedSerial();
        assignedSerial.SerialNumber = 'TUBE12347';
        createSerial('TUBE12347');
        serialList.add(assignedSerial);
        newSOL.assignedSerials = serialList;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        Test.stopTest();
    }

    // To cover existing WO non serial product part 1
    @isTest
    static void createGoodsIssueTest2(){
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
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
        //lstWh[0].giic_ZipCodes__c = '00120';
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        //objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-14';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-14';
        update Giic_UtilityClass_Test.objSalesOrder;
        gii__SalesOrderLine__c objSalesOrderLine1 = new gii__SalesOrderLine__c(gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.id,gii__Product__c=objProdRef.id,gii__OrderQuantity__c =2);
        
        //Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        objSalesOrderLine1.giic_ProductRequiredId__c = 'PREQ-17';
        insert objSalesOrderLine1;
        //Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-14';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-14';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-17';
        newSOL.OrderQuantity = 2;
        newSOL.ConsumedQuantity = 3;
        newSOL.Product = objProdRef.Id;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        //  try{
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        // }catch(Exception ex){
        //     System.debug('Exception------'+ex);
        //  }
        Test.stopTest();
    }
    
     @isTest
     static void createGoodsIssueTest5(){
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
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
        //lstWh[0].giic_ZipCodes__c = '00120';
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        //objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-14';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-14';
        update Giic_UtilityClass_Test.objSalesOrder;
        gii__SalesOrderLine__c objSalesOrderLine1 = new gii__SalesOrderLine__c(gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.id,gii__Product__c=objProdRef.id,gii__OrderQuantity__c =2);
        
        //Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        objSalesOrderLine1.giic_ProductRequiredId__c = 'PREQ-18';
        insert objSalesOrderLine1;
        //Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-14';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-14';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.fromComponent = true;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-18';
        newSOL.OrderQuantity = 2;
        newSOL.ConsumedQuantity = 2;
        newSOL.Product = objProdRef.Id;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        //  try{
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        // }catch(Exception ex){
        //     System.debug('Exception------'+ex);
        //  }
        Test.stopTest();
    }
    
     @isTest
     static void createGoodsIssueTest51(){
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
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
        //lstWh[0].giic_ZipCodes__c = '00120';
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        //objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        Giic_UtilityClass_Test.workTypeCreation();
        Giic_UtilityClass_Test.workOrderCreation();
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-14';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-14';
        Giic_UtilityClass_Test.workOrderLineItemCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_workOrder__c = Giic_UtilityClass_Test.objWorkOrder.Id;
        Giic_UtilityClass_Test.objSalesOrder.giic_workOrderLineItem__c = Giic_UtilityClass_Test.objWorkOrderLineItem.Id;
            
        update Giic_UtilityClass_Test.objSalesOrder;
        gii__SalesOrderLine__c objSalesOrderLine1 = new gii__SalesOrderLine__c(gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.id,gii__Product__c=objProdRef.id,gii__OrderQuantity__c =2);
        
        //Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        objSalesOrderLine1.giic_ProductRequiredId__c = 'PREQ-18';
        insert objSalesOrderLine1;
         
        //Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-14';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-14';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.fromComponent = false;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-18';
        newSOL.OrderQuantity = 2;
        newSOL.ConsumedQuantity = 3;
        newSOL.Product = objProdRef.Id;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        //  try{
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        // }catch(Exception ex){
        //     System.debug('Exception------'+ex);
        //  }
        Test.stopTest();
    }
    
    // To cover existing WO non serial product part 2
    @isTest
    static void createGoodsIssueTest3(){
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
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        //objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-1';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-1';
        update Giic_UtilityClass_Test.objSalesOrder;
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-7';
        update Giic_UtilityClass_Test.objSalesOrderLine; 
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
        newSOL.ProductRequiredID = 'PREQ-7';
        newSOL.OrderQuantity = 10;
        newSOL.ConsumedQuantity = 11;
        newSOL.Product = objProdRef.Id;
        solListToCreate.add(newSOL);
		    System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        soWrapList.add(soCreateObj);
        map<Id,Id> salesOrderIdToWorkOrderId = new map<Id,Id>();
        salesOrderIdToWorkOrderId.put(Giic_UtilityClass_Test.objSalesOrder.Id , Giic_UtilityClass_Test.objSalesOrder.Id );
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        Giic_TR_SalesOrder_UTIL.populateSalesOrderWrapper(salesOrderIdToWorkOrderId);
        Test.stopTest();
    }
    
    // To cover existing WO non serial product part 3
    @isTest
    static void createGoodsIssueTest4(){
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
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        //objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-1';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-1';
        update Giic_UtilityClass_Test.objSalesOrder;
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        //Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-1';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-1';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(2, 'Commercial Visit');      
        insert woList;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = woList[0].id;
        insert woli;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        ProductRequired preq = new ProductRequired();
        preq.ParentRecordId = woList[0].id;
        preq.Product2Id = lstProduct[0].Id;
        preq.QuantityRequired = 1;
        insert preq;
        newSOL.ProductRequiredID = preq.Id;
        newSOL.OrderQuantity = 10;
        newSOL.ConsumedQuantity = 8;
        newSOL.Product = objProdRef.Id;
        solListToCreate.add(newSOL);
        
        
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        soWrapList.add(soCreateObj);
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = preq.Id;
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        List<giic_ErrorLog__c> lstErrors = new List<giic_ErrorLog__c>();
        Giic_ErrorLogsUtility.insertErrorLogs(lstErrors);
        CalloutException e = new CalloutException();
        e.setMessage('This is a constructed exception!');
        Giic_ErrorLogsUtility.insertGloviaErrorLog('Giic_GoodsIssueSO_Test',e,'test');
        Test.stopTest();
    }
     
    @isTest
    static void createGoodsIsueForMultipleWO(){
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
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        //objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-1';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-1';
        update Giic_UtilityClass_Test.objSalesOrder;
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-6';
        update Giic_UtilityClass_Test.objSalesOrderLine; 
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        //Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        gii__SalesOrder__c objSalesOrder = new gii__SalesOrder__c(gii__Account__c = lstAccount[0].id,giic_FSLWorkOrder__c='TestWO-1', gii__OrderType__c='Standard',CurrencyIsoCode ='EUR',gii__Warehouse__c=Giic_UtilityClass_Test.lstWh[0].id);
        insert objSalesOrder;
        gii__SalesOrderLine__c objSalesOrderLine = new gii__SalesOrderLine__c(gii__SalesOrder__c = objSalesOrder.id,gii__Product__c=objProdRef.id,gii__OrderQuantity__c =10);
        insert objSalesOrderLine;
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
        newSOL.ProductRequiredID = 'PREQ-6';
        newSOL.OrderQuantity = 10;
        newSOL.ConsumedQuantity = 8;
        newSOL.Product = objProdRef.Id;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        soWrapList.add(soCreateObj);
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
    }
    
     @isTest 
     static void callGoodIssueSOApiWOLITest(){
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
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
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
 
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(2,'Commercial Visit');      
        insert woList;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= woList[0].id;
        insert woli;
        soCreateObj.FSLWorkOrderLineItem = woli.Id;
        soWrapList.add(soCreateObj); 
        //Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c = null;
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrderLineItem__c = woli.Id;
        update   Giic_UtilityClass_Test.objSalesOrder; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        Test.stopTest();
    }
    
      @isTest 
      static void callGoodIssueSOApiWOLILastGoodIssue(){
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
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
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
 
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO;    
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(2,'Commercial Visit');      
        insert woList;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= woList[0].id;
        insert woli;
        soCreateObj.FSLWorkOrderLineItem = woli.Id;
        soWrapList.add(soCreateObj); 
        //Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c = null;
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrderLineItem__c = woli.Id;
        Giic_UtilityClass_Test.objSalesOrder.giic_LastGoodIssueDone__c = true;
        update   Giic_UtilityClass_Test.objSalesOrder; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        Test.stopTest();
    }
    
    @isTest 
    static void callGoodIssueSOApiWOCancelled(){
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
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
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
        newSOL.ConsumedQuantity = 2;
        newSOL.Product = objProdRef.Id;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
 
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
         
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(2,'Commercial Visit');      
		    woList[0].Status = 'Canceled';
        insert woList;
        soWrapList.add(soCreateObj); 
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c = woList[0].id;
        Giic_UtilityClass_Test.objSalesOrder.giic_LastGoodIssueDone__c = false;
        update   Giic_UtilityClass_Test.objSalesOrder; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        Test.stopTest();
    }
    
     @isTest 
     static void callGoodIssueSOApiWOLITest2(){
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
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
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
        soCreateObj.lastGoodIssue = false;
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
         
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(2,'Commercial Visit');      

        insert woList;
   
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= woList[0].id;
        
        insert woli;
        soCreateObj.FSLWorkOrderLineItem = woli.Id;
        soWrapList.add(soCreateObj); 
        //Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c = null;
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrderLineItem__c = woli.Id;
        update   Giic_UtilityClass_Test.objSalesOrder; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        Test.stopTest();
    }

     @isTest 
     static void callGoodIssueSOApiWOLITest3(){
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
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
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
        soCreateObj.fromComponent = true;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'ENEL-P-7';
        newSOL.OrderQuantity = 2;
        newSOL.ConsumedQuantity = 3;
        newSOL.Product = objProdRef.Id;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soCreateObj.lastGoodIssue = false;
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
         
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(2,'Commercial Visit');      
        insert woList;
        soCreateObj.FSLWorkOrder = woList[0].Id;
        soWrapList.add(soCreateObj); 
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c = woList[0].Id;
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = woList[0].Id;
        update   Giic_UtilityClass_Test.objSalesOrder; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        Giic_GoodsIssueSO.callGoodIssueSOApi(JSON.serialize(soCreateObj) , Giic_UtilityClass_Test.objSalesOrder.Id);
        Test.stopTest();
    }
    
     @isTest 
     static void createGoodsIssueLottizedTest(){
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
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__LotControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-11';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        // Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-11';
        newSOL.OrderQuantity =10;
        newSOL.ConsumedQuantity = 11;
        newSOL.Product = objProdRef.Id;
        List<Giic_GoodsIssueSO.ProductLot> lstAssignedLot = new List<Giic_GoodsIssueSO.ProductLot>();
        Giic_GoodsIssueSO.ProductLot assignedLot = new Giic_GoodsIssueSO.ProductLot();
        Id lotId = createLot('LOT1234' , objProdRef.Id);
        assignedLot.LotNumber = 'LOT1234';
        assignedLot.lotQty = 1;
        lstAssignedLot.add(assignedLot);
        newSOL.lstAssignedLot = lstAssignedLot;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        Giic_UtilityClass_Test.creationPILocationDetailForLot(prodInvntryobj,objProdRef,lotId);
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
         
        Giic_CommonWrapper.MediaMobileWrapper mmw = new Giic_CommonWrapper.MediaMobileWrapper();
        List<Giic_CommonWrapper.MediaMobileWrapper> mmwList = new List<Giic_CommonWrapper.MediaMobileWrapper>();
        mmw.productCode = objProdRef.gii__ProductCode__c;
        mmw.price = 7;
        mmw.inCurrency = 'USD';
        mmwList.add(mmw);
        Giic_ProductReference_UTIL.updateAveragePrice(mmwList);
        Test.stopTest();
    }
   
     @isTest 
     static void createGoodsIssueLottizedErrTest(){
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
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__LotControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-2';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-2';
        update Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-11';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        // Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-11';
        newSOL.OrderQuantity =10;
        newSOL.ConsumedQuantity = 11;
        newSOL.Product = objProdRef.Id;
        List<Giic_GoodsIssueSO.ProductLot> lstAssignedLot = new List<Giic_GoodsIssueSO.ProductLot>();
        Giic_GoodsIssueSO.ProductLot assignedLot = new Giic_GoodsIssueSO.ProductLot();
        Id lotId = createLot('TUBE1234', objProdRef.Id);
        assignedLot.LotNumber = null;
        assignedLot.lotQty = 1;
        lstAssignedLot.add(assignedLot);
        newSOL.lstAssignedLot = lstAssignedLot;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetailForLot(prodInvntryobj,objProdRef, lotId);
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        Giic_CommonWrapper.MediaMobileWrapper mmw = new Giic_CommonWrapper.MediaMobileWrapper();
        List<Giic_CommonWrapper.MediaMobileWrapper> mmwList = new List<Giic_CommonWrapper.MediaMobileWrapper>();
        mmw.productCode = objProdRef.gii__ProductCode__c;
        mmw.price = 7;
        mmw.inCurrency = 'USD';
        mmwList.add(mmw);
        Giic_ProductReference_UTIL.updateAveragePrice(mmwList);
        Test.stopTest();
    }
    
    @isTest 
    static void processIncomingWrapperTest(){
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
        //Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objWhLocal.Id;
      
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update  Giic_UtilityClass_Test.lstWh[0];
        
        system.debug('Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c>>>>>'+Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c);
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
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
        
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-11';
        update Giic_UtilityClass_Test.objSalesOrderLine;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        Giic_GoodsIssueSO.ParamsWrapper params = new Giic_GoodsIssueSO.ParamsWrapper();
        soCreateObj.FSLWorkOrder = 'TestWO-2';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-2';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        soCreateObj.lastGoodIssue = false;
        params.woSetSO.add('TestWO-2');
        List<String> serialList = new List<String>{'1111111','222222'};
        params.mapWOvsSerials.put('TestWO-2', serialList);
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-11';
        newSOL.OrderQuantity =10;
        newSOL.ConsumedQuantity = 11;
        newSOL.Product = objProdRef.Id;
        List<Giic_GoodsIssueSO.ProductLot> lstAssignedLot = new List<Giic_GoodsIssueSO.ProductLot>();
        Giic_GoodsIssueSO.ProductLot assignedLot = new Giic_GoodsIssueSO.ProductLot();
        //createLot('TUBE1234',objProdRef.Id);
        assignedLot.LotNumber = 'TUBE1234';
        assignedLot.lotQty = 1;
        lstAssignedLot.add(assignedLot);
        newSOL.lstAssignedLot = lstAssignedLot;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        soWrapList.add(soCreateObj);
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj = [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                 ];
        
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
       
        params.soWrapList = soWrapList;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        params.piqdList = [SELECT Id, gii__Product__c,gii__Warehouse__c, gii__Location__c, gii__ProductSerial__c,
                           gii__Product__r.gii__SerialControlled__c, gii__Available__c, gii__ProductSerial__r.name
                           FROM gii__ProductInventoryQuantityDetail__c];
        Map<String,List<gii__ProductInventoryQuantityDetail__c>> mapOfPdtWhLocvsPIQD = new map<String,List<gii__ProductInventoryQuantityDetail__c>>();
        Map<String,Integer> mapOfPdtWhLocvsRndmNbr = new Map<String,Integer>();
        String key = Giic_UtilityClass_Test.objPID.gii__Product__c+'-'+Giic_UtilityClass_Test.objPID.gii__Warehouse__c+'-'+Giic_UtilityClass_Test.objPID.gii__Location__c;
        mapOfPdtWhLocvsPIQD.put(key, params.piqdList);
        mapOfPdtWhLocvsRndmNbr.put(key,1);
        params.mapOfPdtWhLocvsRndmNbr = mapOfPdtWhLocvsRndmNbr;
        Giic_GoodsIssueSO.processIncomingWrapper(params);
        Giic_GoodsIssueSO.unreservePIQD(params, mapOfPdtWhLocvsPIQD);
        Giic_GoodsIssueSO.fetchSOAndSoLineData(Giic_UtilityClass_Test.objSalesOrder.Id);
        Test.stopTest();
    }
    
    @isTest
    static void createGoodsIssueTestLot5(){
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
      List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
      //lstWh[0].giic_ZipCodes__c = '00120';
      lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
      update lstWh;
      List<Account> lstAccount = [SELECT id FROM Account];
      List<product2> lstProduct = [SELECT id FROM product2];
      gii__Product2Add__c objProdRef= [SELECT id,gii__ProductCode__c FROM gii__Product2Add__c WHERE gii__ProductReference__c =:lstProduct[0].Id LIMIT 1];
      objProdRef.gii__ProductCode__c='Test';
      objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
      //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
      objProdRef.gii__lotControlled__c = true;
      objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
      update objProdRef;
      
      Giic_UtilityClass_Test.salesOrderCreation();
      Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-14';
      Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-14';
      update Giic_UtilityClass_Test.objSalesOrder;
      gii__SalesOrderLine__c objSalesOrderLine1 = new gii__SalesOrderLine__c(gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.id,gii__Product__c=objProdRef.id,gii__OrderQuantity__c =2);
      
      //Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
      objSalesOrderLine1.giic_ProductRequiredId__c = 'PREQ-18';
      insert objSalesOrderLine1;
      //Giic_UtilityClass_Test.productSerailCreation(objProdRef);
      Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
      update Giic_UtilityClass_Test.lstWh;
      List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
      List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
      List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
      
      Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
      soCreateObj.FSLWorkOrder = 'TestWO-14';
      soCreateObj.FSLWorkOrderLineItem = 'TestWO-14';
      soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
      soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
      soCreateObj.fromComponent = true;
      // non serial
      Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
      newSOL.ProductRequiredID = 'PREQ-18';
      newSOL.OrderQuantity = 2;
      newSOL.isLotControlled = true;
      newSOL.ConsumedQuantity = 2;
      newSOL.Product = objProdRef.Id;
        List<Giic_GoodsIssueSO.ProductLot> lstAssignedLot = new List<Giic_GoodsIssueSO.ProductLot>();
      Giic_GoodsIssueSO.ProductLot assignedLot = new Giic_GoodsIssueSO.ProductLot();
      Id lotId = createLot('LOT1234',objProdRef.Id);
      assignedLot.LotNumber = null;
      assignedLot.lotQty = 1;
      lstAssignedLot.add(assignedLot);
      newSOL.lstAssignedLot = lstAssignedLot;
      solListToCreate.add(newSOL);
      System.assertEquals(true, solListToCreate.size()>0);
      soCreateObj.SalesOrderLineList = solListToCreate;
      soWrapList.add(soCreateObj);
      Test.startTest();
      Giic_UtilityClass_Test.purchaseOrderCreation();
      Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
      Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
      Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
      upsert Giic_UtilityClass_Test.objPO; 
      Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
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
      Giic_UtilityClass_Test.creationPILocationDetailForLot(prodInvntryobj,objProdRef, lotId);
      //  try{
      Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
      // }catch(Exception ex){
      //     System.debug('Exception------'+ex);
      //  }
      Test.stopTest();
    }
    
    @isTest
    static void onCallGoodIssueApiUtil() {
      Giic_UtilityClass_Test.systemPolicyCreation();
      Giic_UtilityClass_Test.gloviaSystemSettingCreation();
      Giic_UtilityClass_Test.accountCreation();
      Giic_UtilityClass_Test.wareHouseGroupCreation();
      Giic_UtilityClass_Test.warehouseCreation();
      Giic_UtilityClass_Test.salesOrderCreation();
      Giic_GoodsIssueSO.GoodIssueParamsWrapper goWr = new Giic_GoodsIssueSO.GoodIssueParamsWrapper();
      goWr.lastGoodIssue = true;
      goWr.odrResponse = new Giic_GoodsIssueSO.OrderGoodsIssuedResponse();
      goWr.fslWO = new List<String>();
      goWr.fslWOL = new List<String>();
      goWr.errlist = new List<Giic_GoodsIssueSO.ErrorList>();
      goWr.lstErrorLogs=new list<giic_ErrorLog__c>();
      goWr.lstErrorsTmp= new List<String>();
      goWr.salesOrderLineList = new List<gii__SalesOrderLine__c>();
      goWr.salesOrderLineListForWOLI = new List<gii__SalesOrderLine__c>();
      goWr.mapOfSolIdVsSo = new Map<Id,gii__SalesOrderLine__c>();
      goWr.mapOfWOVsListSOId = new Map<String,Set<String>>();
      goWr.mapOfSoIdVsSOLList = new Map<String,List<gii__SalesOrderLine__c>>();
      goWr.soId = Giic_UtilityClass_Test.objSalesOrder.Id;
      goWr.soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
      goWr.mapOfWOvsPdtReqList = new Map<String,List<String>>();
      goWr.solSet = new Set<String>();
      Giic_GoodsIssueSO.SalesOrder soWr = new Giic_GoodsIssueSO.SalesOrder();
      Test.startTest();
      Giic_GoodsIssueSO.callGoodIssueSOApi(JSON.serialize(soWr), Giic_UtilityClass_Test.objSalesOrder.Id);
      Giic_GoodsIssueSO.GoodIssueParamsWrapper resltGowr = Giic_GoodsIssueSO.processSOLWithWOLI(goWr);
      Giic_GoodsIssueSO.OrderGoodsIssuedResponse ogir = Giic_GoodsIssueSO.responseProcessing(new List<Giic_GoodsIssueSO.SalesOrder>(), new Set<String>(), new Giic_GoodsIssueSO.ParamsWrapper(), false);
      Test.stopTest();
    }

    @isTest 
    static void createGoodsIssueWithNoProductsTest(){
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
      
      List<Account> lstAccount = [SELECT Id FROM Account];
      List<product2> lstProduct = [SELECT Id FROM product2];
      gii__Product2Add__c objProdRef= [SELECT Id,gii__ProductCode__c FROM gii__Product2Add__c WHERE gii__ProductReference__c =: lstProduct[0].Id LIMIT 1];
      objProdRef.gii__ProductCode__c='Test';
      objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
      //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
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
      List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineListForWOLI = new  List<Giic_GoodsIssueSO.SalesOrderLine>();
      soCreateObj.salesOrderLineListForWOLI = salesOrderLineListForWOLI;
      soCreateObj.FSLWorkOrder = 'TestWO-1';
      soCreateObj.FSLWorkOrderLineItem = 'TestWO-1';
      soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
      soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
      // No serial
      Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
      newSOL.ProductRequiredID = 'PREQ-7';
      newSOL.OrderQuantity = 2;
      newSOL.ConsumedQuantity = 300;
      newSOL.Product = objProdRef.Id;
      solListToCreate.add(newSOL);
      soCreateObj.SalesOrderLineList = solListToCreate;
      soWrapList.add(soCreateObj);
      Test.startTest();
      Giic_UtilityClass_Test.purchaseOrderCreation();
      Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
      Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
      Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
      upsert Giic_UtilityClass_Test.objPO; 
      Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
      Giic_UtilityClass_Test.pOReceipt();
      Giic_UtilityClass_Test.pOReceiptLine();
      gii__ProductInventory__c prodInvntryobj= [SELECT  gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                                                FROM gii__ProductInventory__c
                                                ];
      Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
      Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
      Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
      Giic_UtilityClass_Test.transferOrderCreation();
      Giic_GoodsIssueSO.cancelRelatedObjects(Giic_UtilityClass_Test.objSalesOrder.Id);
      Test.stopTest();
    }
    
    
    private static Id createSerial(String serialName){
      gii__productserial__c ps = new gii__productserial__c(Name=serialName);
      insert ps;
      return ps.Id;
    }
    
    private static Id createLot(String lotName, Id productAssociated){
      gii__productlot__c pl = new gii__productlot__c(Name=lotName,gii__Product__c= productAssociated);
      insert pl;
      gii__lotDetail__c ld = new gii__lotDetail__c(gii__ProductLot__c  = pl.Id, gii__Quantity__c=1);
      insert ld;
      return pl.Id;
    }

@isTest 
    static void createGoodsIssueWithNoProductsTest2(){
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
      
      List<Account> lstAccount = [SELECT Id FROM Account];
      List<product2> lstProduct = [SELECT Id FROM product2];
      gii__Product2Add__c objProdRef= [SELECT Id,gii__ProductCode__c FROM gii__Product2Add__c WHERE gii__ProductReference__c =: lstProduct[0].Id LIMIT 1];
      objProdRef.gii__ProductCode__c='Test';
      objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
      //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
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
        /**/
      Giic_GoodsIssueSO.SalesOrderLine newSOL1 = new Giic_GoodsIssueSO.SalesOrderLine();
      newSOL1.ProductRequiredID = 'PREQ-6';
      newSOL1.OrderQuantity = 2;
      newSOL1.ConsumedQuantity = 200;
      newSOL1.Product = objProdRef.Id;
      newSOL1.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
      List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineListForWOLI = new  List<Giic_GoodsIssueSO.SalesOrderLine>();
      salesOrderLineListForWOLI.add(newSOL1);
            //**/
      soCreateObj.salesOrderLineListForWOLI = salesOrderLineListForWOLI;
      soCreateObj.FSLWorkOrder = 'TestWO-1';
      soCreateObj.FSLWorkOrderLineItem = 'TestWO-1';
      soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
      soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
      soCreateObj.lastGoodIssue = false;
      // No serial
      Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
      newSOL.ProductRequiredID = 'PREQ-7';
      newSOL.OrderQuantity = 2;
      newSOL.ConsumedQuantity = 200;
      newSOL.Product = objProdRef.Id;
      newSOL.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;//new
      solListToCreate.add(newSOL);
      soCreateObj.SalesOrderLineList = solListToCreate;
      soWrapList.add(soCreateObj);
      Test.startTest();
      Giic_UtilityClass_Test.purchaseOrderCreation();
      Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
      Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
      Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
      upsert Giic_UtilityClass_Test.objPO;
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(2,'Commercial Visit');      

        insert woList;
   
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= woList[0].id;
        
        insert woli;
        soCreateObj.FSLWorkOrderLineItem = woli.Id;
        soWrapList.add(soCreateObj); 
        //Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c = null;
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrderLineItem__c = woli.Id;
        update   Giic_UtilityClass_Test.objSalesOrder; 
        
      Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
      Giic_UtilityClass_Test.pOReceipt();
      Giic_UtilityClass_Test.pOReceiptLine();
      gii__ProductInventory__c prodInvntryobj= [SELECT  gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                                                FROM gii__ProductInventory__c
                                                ];
      Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef);
      Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.objPID.giic_Reserved__c = 0;
        Giic_UtilityClass_Test.objPID.gii__OnHandQuantity__c = 0;
        update Giic_UtilityClass_Test.objPID;
      Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
      Giic_UtilityClass_Test.transferOrderCreation();
      Giic_GoodsIssueSO.cancelRelatedObjects(Giic_UtilityClass_Test.objSalesOrder.Id);
      Test.stopTest();
    }
    
    @isTest
    static void createGoodsIssueTest6(){
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
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        //objProdRef.gii__SerialControlled__c = true;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        gii__Product2Add__c objProdRef2= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[1].Id Limit 1];
        objProdRef2.gii__ProductCode__c='Test2';
        objProdRef2.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef2.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef2;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-1';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-1';
        update Giic_UtilityClass_Test.objSalesOrder;
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-7';
        update Giic_UtilityClass_Test.objSalesOrderLine; 
        //Giic_UtilityClass_Test.productSerailCreation(objProdRef);
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        /**/
      Giic_GoodsIssueSO.SalesOrderLine newSOL1 = new Giic_GoodsIssueSO.SalesOrderLine();
      newSOL1.ProductRequiredID = 'PREQ-6';
      newSOL1.OrderQuantity = 2;
      newSOL1.ConsumedQuantity = 3;//new
      newSOL1.Product = objProdRef.Id;
      newSOL1.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
      List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineListForWOLI = new  List<Giic_GoodsIssueSO.SalesOrderLine>();
      salesOrderLineListForWOLI.add(newSOL1);
         
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-1';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-1';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-7';
        newSOL.OrderQuantity = 10;
        newSOL.ConsumedQuantity = 11;
        newSOL.Product = objProdRef.Id;
        solListToCreate.add(newSOL);
        Giic_GoodsIssueSO.SalesOrderLine newSOL2 = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL2.ProductRequiredID = 'PREQ-7';
        newSOL2.OrderQuantity = 10;
        newSOL2.ConsumedQuantity = 11;
        newSOL2.Product = objProdRef2.Id;
		    System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        Test.startTest();
        /*Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        upsert Giic_UtilityClass_Test.objPO;*/
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(2,'Commercial Visit');      

        insert woList;
   
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= woList[0].id;
        
        insert woli;
        soCreateObj.FSLWorkOrderLineItem = woli.Id;
        soWrapList.add(soCreateObj); 
        //Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c = null;
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrderLineItem__c = woli.Id;
        update   Giic_UtilityClass_Test.objSalesOrder; 
        
        /*Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();*/
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
        Giic_UtilityClass_Test.objPID.giic_Reserved__c = 0;
        Giic_UtilityClass_Test.objPID.gii__OnHandQuantity__c = 0;
        update Giic_UtilityClass_Test.objPID;
        soWrapList.add(soCreateObj);
        map<Id,Id> salesOrderIdToWorkOrderId = new map<Id,Id>();
        salesOrderIdToWorkOrderId.put(Giic_UtilityClass_Test.objSalesOrder.Id , Giic_UtilityClass_Test.objSalesOrder.Id );
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        Giic_TR_SalesOrder_UTIL.populateSalesOrderWrapper(salesOrderIdToWorkOrderId);
        Test.stopTest();
    }
    
    @isTest
    static void createGoodsIssueTest7(){
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
        
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];
        
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
        objProdRef.gii__ProductCode__c='Test';
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        update objProdRef;
        
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-1';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-1';
        update Giic_UtilityClass_Test.objSalesOrder;
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objSalesOrderLine.giic_ProductRequiredId__c = 'PREQ-7';
        update Giic_UtilityClass_Test.objSalesOrderLine; 
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Giic_GoodsIssueSO.SalesOrderLine> solListToCreate = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        List<Giic_GoodsIssueSO.AssignedSerial> assignedSerialsList = new  List<Giic_GoodsIssueSO.AssignedSerial>();
        
      Giic_GoodsIssueSO.SalesOrderLine newSOL1 = new Giic_GoodsIssueSO.SalesOrderLine();
      newSOL1.ProductRequiredID = 'PREQ-6';
      newSOL1.OrderQuantity = 2;
      newSOL1.ConsumedQuantity = 3;
      newSOL1.Product = objProdRef.Id;
      newSOL1.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
      List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineListForWOLI = new  List<Giic_GoodsIssueSO.SalesOrderLine>();
      salesOrderLineListForWOLI.add(newSOL1);
         
        Giic_GoodsIssueSO.SalesOrder soCreateObj = new Giic_GoodsIssueSO.SalesOrder();
        soCreateObj.FSLWorkOrder = 'TestWO-1';
        soCreateObj.FSLWorkOrderLineItem = 'TestWO-1';
        soCreateObj.account = Giic_UtilityClass_Test.objAccountCentral.Id;
        soCreateObj.warehouse = Giic_UtilityClass_Test.lstWh[0].Id;
        // non serial
        Giic_GoodsIssueSO.SalesOrderLine newSOL = new Giic_GoodsIssueSO.SalesOrderLine();
        newSOL.ProductRequiredID = 'PREQ-7';
        newSOL.OrderQuantity = 10;
        newSOL.ConsumedQuantity = 11;
        newSOL.Product = objProdRef.Id;
        solListToCreate.add(newSOL);
        System.assertEquals(true, solListToCreate.size()>0);
        soCreateObj.SalesOrderLineList = solListToCreate;
        Test.startTest();
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(2,'Commercial Visit');      

        insert woList;
   
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= woList[0].id;
        woli.XC_ReCalculateSalesOrder__c = true;
        
        insert woli;
        soCreateObj.FSLWorkOrderLineItem = woli.Id;
        soWrapList.add(soCreateObj);
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrderLineItem__c = woli.Id;
        update   Giic_UtilityClass_Test.objSalesOrder; 
        
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
        Giic_UtilityClass_Test.objPID.giic_Reserved__c = 0;
        Giic_UtilityClass_Test.objPID.gii__OnHandQuantity__c = 0;
        update Giic_UtilityClass_Test.objPID;
        soWrapList.add(soCreateObj);
        map<Id,Id> salesOrderIdToWorkOrderId = new map<Id,Id>();
        salesOrderIdToWorkOrderId.put(Giic_UtilityClass_Test.objSalesOrder.Id , Giic_UtilityClass_Test.objSalesOrder.Id );
        Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        Giic_TR_SalesOrder_UTIL.populateSalesOrderWrapper(salesOrderIdToWorkOrderId);
        Test.stopTest();
    }
 
}