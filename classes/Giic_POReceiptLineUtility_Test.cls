/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/08/2019
* @date Modification dd/mm/yyyy
* @description Giic_POReceiptLineUtility_Test – Test Class for Giic_POReceiptLineUtility.
*/
@isTest
public class Giic_POReceiptLineUtility_Test {
    
    @TestSetup
    static void onSetup() {
      giic_GloviaLogisticSetting__c settings = giic_GloviaLogisticSetting__c.getOrgDefaults();
      settings.giic_DisableVRTestClasses__c = true;
      upsert settings custSettings__c.Id;
    }    
    
/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/08/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for pOReceiptLine.
*/    
    @isTest
    static  void pOReceiptLineTest(){
        //create warehouse data
        /*gii__Warehouse__c objWarehouse = new gii__Warehouse__c(Name='WarehouseForSystemPolicy', 
                                                               gii__WareHouseStreet__c='111 Seedsman St',
                                                               gii__WareHouseCity__c='Chicago',
                                                               gii__WareHouseStateProvince__c='IL',
                                                               gii__WareHouseZipPostalCode__c='50001',
                                                               gii__WareHouseCountry__c='USA',
                                                               giic_WarehouseCode__c = 'CWH'); 
        insert objWarehouse;
        gii__SystemPolicy__c objSystemPolicy = new gii__SystemPolicy__c(Name='GII',gii__Description__c='Glovia Policies',gii__PriceBookName__c='Standard',
                                                                        gii__StockUM__c='Each',gii__ServiceTicketPricingOverriddenReason__c='Service Ticket',
                                                                        gii__AutoReleaseOrder__c=true,gii__AllowZeroUnitPrice__c=true ,
                                                                        gii__OppConversionPricingOverriddenReason__c='Opportunity Conversion' ,
                                                                        gii__SQConversionPricingOverriddenReason__c='Sales Quote Conversion',
                                                                        gii__AutoApprovePurchaseOrders__c=true, gii__Warehouse__c=objWarehouse.Id  );
        insert objSystemPolicy;*/
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        giic_UtilityClass_Test.accountCreation();
        List<Account> lstAcc =[select id, name, RecordTypeId, RecordType.Name from Account ];
        giic_UtilityClass_Test.wareHouseGroupCreation();
        giic_UtilityClass_Test.warehouseCreation();
        giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
        system.debug('prodRefObj: ' + prodRefObj);
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Test.startTest();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_LegalEntity__c= 'EndesaX';
        Giic_UtilityClass_Test.objPO.giic_Status__c= System.Label.giic_PODraftStatus;
        upsert Giic_UtilityClass_Test.objPO; 
        gii__Product2Add__c pref=new gii__Product2Add__c(); 
        pref=[Select Id from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id Limit 1];
        giic_UtilityClass_Test.purchaseOrderLineCreation(pref);
        Date receiptDate = system.today().addMonths(1);
        string receiptDateString = receiptDate.year()+'-'+receiptDate.month()+'-'+receiptDate.day();
        gii__PurchaseOrderReceipt__c objPOreceiptCS = new gii__PurchaseOrderReceipt__c(gii__ReceiptDate__c =Date.valueOf(receiptDateString), 
                                                                                       gii__PurchaseOrder__c =giic_UtilityClass_Test.objPO.id ,
                                                                                       gii__Supplier__c = giic_UtilityClass_Test.objAccountCentral.id,
                                                                                       gii__ShipTo__c=giic_UtilityClass_Test.objWh.id,
                                                                                       giic_LegalEntity__c = 'EndesaX');
        insert objPOreceiptCS;
        //giic_UtilityClass_Test.pOReceipt();
        //giic_UtilityClass_Test.pOReceiptLine();
        gii__PurchaseOrderReceiptLine__c objPoRecLine = new gii__PurchaseOrderReceiptLine__c(gii__PurchaseOrderReceipt__c=objPOreceiptCS.id,
                                                                                             gii__PurchaseOrderLine__c=giic_UtilityClass_Test.objPOLine.id,
                                                                                             gii__PurchaseOrder__c=giic_UtilityClass_Test.objPO.id,
                                                                                             gii__Location__c=giic_UtilityClass_Test.objLocationCentral.id,
                                                                                             gii__ReceivedQuantity__c = 100.00);
        insert objPoRecLine;
        List<gii__PurchaseOrderReceiptLine__c> porl=[Select Id,gii__UnitPrice__c,CurrencyIsoCode,gii__ReceivedQuantity__c,gii__Product__c,gii__PurchaseOrderReceipt__c,gii__PurchaseOrderLine__c,gii__PurchaseOrder__c,gii__Location__c from gii__PurchaseOrderReceiptLine__c];
        System.assertEquals(true, porl.size()>0); 
        try{ 
            porl[0].gii__RoundAmountstoZeroDecimal__c = true;
        	update porl;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('My Error Message') ? true : false;
            
            System.AssertEquals(expectedExceptionThrown, false);
        }
        giic_POReceiptLineUtility.calcAvgPrice(porl);
        Test.stopTest();
    }
/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/08/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for pOReceiptLine.
*/      
     @isTest
    static  void pOReceiptLine1(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c objProdRef = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountLocal.Id;
        update objProdRef;
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_LegalEntity__c= 'EndesaX';
        upsert Giic_UtilityClass_Test.objPO;
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__BackOrderQuantity__c, gii__SalesOrderQuantity__c,
                                                  giic_BackOrderNew__c FROM gii__ProductInventory__c
                                                 ];
        
        
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef); 
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
         List<gii__PurchaseOrderReceipt__c> porRec = [SELECT id  FROM  gii__PurchaseOrderReceipt__c 
                                                            ];
        List<gii__PurchaseOrderReceiptLine__c> porLineRec = [SELECT id, gii__ReceivedQuantity__c,gii__ShipTo__c, gii__ShipTo__r.gii__DefaultReceivingLocation__c,CurrencyIsoCode,
                                                             gii__Product__c,gii__ProductInventory__r.giic_BackOrderNew__c FROM  gii__PurchaseOrderReceiptLine__c 
                                                            ];
        System.assertEquals(true, porLineRec.size()>0);       
        giic_POReceiptLineUtility.clearBackOrderQtyOnPI(porLineRec);
         Test.stopTest();
       
    }
    
    
    
       @isTest
    static  void pOReceiptLine2(){
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
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        List<gii__Product2Add__c> prodRefList = new List<gii__Product2Add__c>();
        prodRefList.add(prodRefObj);
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh, prodRefList);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_LegalEntity__c= 'EndesaX';
        upsert Giic_UtilityClass_Test.objPO;
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        Gii__ProductInventory__c pi = [SELECT Id,giic_Reserved__c,gii__Warehouse__c,giic_BackOrderNew__c FROM Gii__ProductInventory__c LIMIT 1 ];
        Giic_UtilityClass_Test.creationPILocation(pi,prodRefObj);
        Giic_UtilityClass_Test.creationPILocationDetail(pi,prodRefObj);
        
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.createPOReceiptLineWithPIQD(pi, Giic_UtilityClass_Test.objPID);
        
        Giic_UtilityClass_Test.objPOreceipt.giic_DeliveryDate__c = system.today();
        Giic_UtilityClass_Test.objPOreceipt.giic_DeliveryDocumentID__c = '353535';
    	Giic_UtilityClass_Test.objPOreceipt.giic_ReasonOfCancellation__c = 'Wrong Quantity'; 
        update Giic_UtilityClass_Test.objPOreceipt;
        
        Test.startTest();
         List<gii__PurchaseOrderReceipt__c> porRec = [SELECT id  FROM  gii__PurchaseOrderReceipt__c ];
       
	     List <Id> idsReceipt = XC_UTIL_SObject.getIds(porRec);
        
         gii.PurchaseOrderReceipt.reverse(idsReceipt);
         Test.stopTest();
    }
    
    
    
     @isTest
    static  void clearBackOrderQtyOnPITest(){
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
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.giic_LegalEntity__c= 'EndesaX';
        upsert Giic_UtilityClass_Test.objPO;
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        giic_enable_NR2246__c cs = new giic_enable_NR2246__c();
        cs.Name = 'test';
        cs.LegalEntity__c = 'EndesaX';
        insert cs;
        Giic_UtilityClass_Test.pOReceipt();
        
        Giic_UtilityClass_Test.objPOreceipt.giic_DeliveryDate__c = system.today();
        Giic_UtilityClass_Test.objPOreceipt.giic_DeliveryDocumentID__c = '353535';
    	Giic_UtilityClass_Test.objPOreceipt.giic_ReasonOfCancellation__c = 'Wrong Quantity'; 
        list<gii__Product2Add__c> lstProdRef = NEW list<gii__Product2Add__c>();
        lstProdRef.add(prodRefObj);
        Gii__ProductInventory__c pi = [SELECT Id from Gii__ProductInventory__c LIMIT 1 ];
        pi.giic_BackOrderNew__c = 2;
        update  pi;
        Giic_UtilityClass_Test.createPOReceiptLineWithPI(pi);
            
        Test.startTest();
        
        List<gii__PurchaseOrderReceiptLine__c> porRecLineList = [SELECT id  FROM  gii__PurchaseOrderReceiptLine__c  ];
        Giic_POReceiptLineUtility.clearBackOrderQtyOnPI(porRecLineList);
        Test.stopTest();
        
    }
    
     @isTest
    static  void pOReceiptLine3(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
		
		List<product2> lstProduct = [select id from product2];
		
        gii__Product2Add__c objProdRef = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountLocal.Id;
        update objProdRef;
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef);
        Giic_UtilityClass_Test.workTypeCreation();
        Giic_UtilityClass_Test.workOrderCreation();
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c = 'TestWO-14';
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrderLineItem__c = 'TestWO-14';
        Giic_UtilityClass_Test.workOrderLineItemCreation();
        Giic_UtilityClass_Test.objSalesOrder.giic_workOrder__c = Giic_UtilityClass_Test.objWorkOrder.Id;
        Giic_UtilityClass_Test.objSalesOrder.giic_workOrderLineItem__c = Giic_UtilityClass_Test.objWorkOrderLineItem.Id;
		
        ProductRequired preq = new ProductRequired();
        preq.ParentRecordId = Giic_UtilityClass_Test.objWorkOrderLineItem.Id;
        preq.Product2Id = lstProduct[0].Id;
        preq.QuantityRequired = 1;
        insert preq;
        preq =  [select Id,ProductRequiredNumber,ParentRecordId,Product2Id,QuantityRequired  from ProductRequired where id = : preq.id];
        
        update Giic_UtilityClass_Test.objSalesOrder;
        gii__SalesOrderLine__c objSalesOrderLine1 = new gii__SalesOrderLine__c(gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.id,gii__Product__c=objProdRef.id,gii__OrderQuantity__c =2,giic_ProdRequired__c = preq.Id,giic_ProductRequiredId__c = preq.ProductRequiredNumber);
        upsert objSalesOrderLine1;
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_LegalEntity__c= 'EndesaX';
		Giic_UtilityClass_Test.objPO.gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.Id;
        upsert Giic_UtilityClass_Test.objPO;
        Test.startTest();
		Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPOLine.gii__SalesOrderLine__c = objSalesOrderLine1.Id;
        upsert Giic_UtilityClass_Test.objPOLine;
        //Test.startTest();
        
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();

         Test.stopTest();
       
    }

}