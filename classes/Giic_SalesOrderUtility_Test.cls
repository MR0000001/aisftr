/**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 01/07/2019
* @date Modification 18/08/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description Giic_SalesOrderUtility_Test – Test class for Giic_SalesOrderUtility
*/

@isTest 
private class Giic_SalesOrderUtility_Test {

    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com 
    * @date 01/07/2019
    * @description To validate createSalesOrders method of Giic_SalesOrderUtility.
    */    
    @isTest
    static void salesorderutilityTest(){
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
        Giic_UtilityClass_Test.pOReceiptSC();
		gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        prodRefObj.giic_ProcurementType__c = 'Transfer';
        update prodRefObj;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.workTypeCreation();
        Giic_UtilityClass_Test.workOrderCreation();
        Giic_UtilityClass_Test.workOrderLineItemCreation();
        WorkOrderLineItem woliObj = [SELECT id, XC_IsMigrated__c FROM WorkOrderLineItem];
        woliObj.XC_IsMigrated__c = true;
        update woliObj;
        List<giic_CommonWrapper.SalesOrderHeader> soList= new List<giic_CommonWrapper.SalesOrderHeader>();
        giic_CommonWrapper.SalesOrderHeader soHderObj=new giic_CommonWrapper.SalesOrderHeader();
        soHderObj.AccountId=giic_UtilityClass_Test.objAccountCentral.Id;
        soHderObj.DirectPurchaseOrder=false;     
        soHderObj.fieldServiceOrder = false;
        soHderObj.scheduledDate = date.today();
        soHderObj.warehouseId = Giic_UtilityClass_Test.objWhLocal.id; 
        soHderObj.SalesOrderLineList= new List<giic_CommonWrapper.SalesOrderLine>();
        soHderObj.workOrderLineItemID = woliObj.id;
        giic_CommonWrapper.SalesOrderLine soLObj=new giic_CommonWrapper.SalesOrderLine();
        soLObj.OrderQuantity=10.0;
        soLObj.requiredDate = Date.today();
        soLObj.ProductId=prodRefObj.Id;
        soLObj.batchNumber = '1234';
        soLObj.UnitPrice=10;
        soLObj.OwnedByEnelX = false;
        soHderObj.SalesOrderLineList.add(soLObj);
        soList.add(soHderObj);
        giic_CommonWrapper.POHeader poHeader = new  giic_CommonWrapper.POHeader();
        poHeader.supplierId='65433';
        poHeader.status='status';
        poHeader.salesOrderId='76543';
        poHeader.shipTo='4677';
        poHeader.orderDate=date.today();
        poHeader.requiredDate=Date.today();
        poHeader.dropShip =true;
        System.assertEquals(true, soList.size()>0);
        Giic_SalesOrderUtility.createSalesOrders(soList); 
        List<gii__SalesOrder__c> listSalesOrder = new List<gii__SalesOrder__c>([SELECT Id FROM gii__SalesOrder__c LIMIT 1]);
        //Giic_SalesOrderUtility.reprocessOrder(listSalesOrder[0].Id);
        Giic_SalesOrderUtility.checkPermissionGlovia();
        Giic_SalesOrderUtility.coverageTestClass();
    }
 
    @isTest
    static void salesorderutilityTest2(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
		gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        prodRefObj.giic_ProcurementType__c = 'Transfer';
        update prodRefObj;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);
        Giic_UtilityClass_Test.purchaseOrderCreation(); 
        List<giic_CommonWrapper.SalesOrderHeader> soList= new List<giic_CommonWrapper.SalesOrderHeader>();
        giic_CommonWrapper.SalesOrderHeader soHderObj=new giic_CommonWrapper.SalesOrderHeader();
        soHderObj.AccountId=giic_UtilityClass_Test.objAccountCentral.Id;
        soHderObj.DirectPurchaseOrder=true;   
        soHderObj.warehouseId = Giic_UtilityClass_Test.objWhLocal.id;
        soHderObj.SalesOrderLineList= new List<giic_CommonWrapper.SalesOrderLine>();
        giic_CommonWrapper.SalesOrderLine soLObj=new giic_CommonWrapper.SalesOrderLine();
        soLObj.OrderQuantity=10.0;
        soLObj.ProductId=prodRefObj.Id;
        soLObj.UnitPrice=10;
        soLObj.OwnedByEnelX = false;
        soHderObj.SalesOrderLineList.add(soLObj);
        soList.add(soHderObj);
        System.assertEquals(true, soList.size()>0);
        Giic_SalesOrderUtility.createSalesOrders(soList); 
    }
        
    @isTest
    static void salesorderutilityTest3(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
		gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        prodRefObj.giic_ProcurementType__c = 'Purchase';
        update prodRefObj;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);
        Giic_UtilityClass_Test.purchaseOrderCreation();  
        List<giic_CommonWrapper.SalesOrderHeader> soList= new List<giic_CommonWrapper.SalesOrderHeader>();
        giic_CommonWrapper.SalesOrderHeader soHderObj=new giic_CommonWrapper.SalesOrderHeader();
        soHderObj.AccountId=giic_UtilityClass_Test.objAccountCentral.Id;
        soHderObj.DirectPurchaseOrder=false;    
        soHderObj.warehouseId = Giic_UtilityClass_Test.objWhLocal.id;  
        soHderObj.SalesOrderLineList= new List<giic_CommonWrapper.SalesOrderLine>();
        giic_CommonWrapper.SalesOrderLine soLObj=new giic_CommonWrapper.SalesOrderLine();
        soLObj.OrderQuantity=10.0;
        soLObj.ProductId=prodRefObj.Id;
        soLObj.UnitPrice=10;
        soLObj.OwnedByEnelX = false;
        soHderObj.SalesOrderLineList.add(soLObj);
        soList.add(soHderObj);
        System.assertEquals(true, soList.size()>0);
        Giic_SalesOrderUtility.createSalesOrders(soList); 
    }
	
    @isTest
     static void reprocessOrderTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
        List<Account> lstAcc =[select id, name, RecordTypeId, RecordType.Name from Account ]; 
        giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c(); 
        pref=[Select Id from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        //pref.giic_ProcurementType__c='Transfer';
        update pref;
        Giic_UtilityClass_Test.workTypeCreation();
        Giic_UtilityClass_Test.workOrderCreation();
        Giic_UtilityClass_Test.workOrderLineItemCreation();
        WorkOrderLineItem woliObj = [SELECT id, XC_IsMigrated__c FROM WorkOrderLineItem];
        woliObj.XC_IsMigrated__c = true;
        update woliObj;         
        Test.startTest();
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(pref);
        List<gii__SalesOrder__c> listId=[SELECT id, giic_WorkOrderLineItem__c from gii__SalesOrder__c Limit 1];
        ListId[0].giic_WorkOrderLineItem__c = woliObj.Id;
        update listId;
        system.debug('woliObj: ' + woliObj);
        system.debug('listId: ' + listId);
        String Id=listId[0].Id;
        Giic_SalesOrderUtility.reprocessOrder(Id);
        listId[0].giic_OrderStatus__c = 'Error';
        update listId;
        System.assertEquals(true, listId.size()>0);
        Giic_SalesOrderUtility.reprocessOrder(Id);
        Test.stopTest();
    }
    
    @isTest
    static  void reprocessOrderTest2(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
        List<Account> lstAcc =[select id, name, RecordTypeId, RecordType.Name from Account ]; 
        giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c(); 
        pref=[Select Id, giic_ProcurementType__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.giic_ProcurementType__c='Transfer';
        update pref;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);
        Giic_UtilityClass_Test.purchaseOrderCreation();      
         
        Test.startTest();
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(pref);
        List<gii__SalesOrder__c> listId=[SELECT id, giic_WorkOrderLineItem__c from gii__SalesOrder__c Limit 1];
        String Id=listId[0].Id;
        Giic_SalesOrderUtility.reprocessOrder(Id);
        listId[0].giic_OrderStatus__c = 'Error';
        update listId;
        System.assertEquals(true, listId.size()>0);
        Giic_SalesOrderUtility.reprocessOrder(Id);
        Test.stopTest();
    } 

    @isTest
    static void coverCommonWrapperTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation(); 
        giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
         List<Account> lstAcc =[select id, name, RecordTypeId, RecordType.Name from Account ];
        //giic_UtilityClass_Test.warehouseCreation();
        giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c(); 
        pref=[Select Id from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        List<giic_CommonWrapper.SalesOrderHeader> soList= new List<giic_CommonWrapper.SalesOrderHeader>();
        giic_CommonWrapper.SalesOrderHeader soHderObj=new giic_CommonWrapper.SalesOrderHeader();
        soHderObj.AccountId=giic_UtilityClass_Test.objAccountCentral.Id;
        soHderObj.DirectPurchaseOrder=false; 
        soHderObj.billingCity='Florida';
        soHderObj.billingCountry='USA'; 
        soHderObj.billingName='TESTUser';
        soHderObj.billingStateProvince='kERLA'; 
        soHderObj.billingStreet='tEST';
        soHderObj.billingZipPostalCode='201301';
        soHderObj.fieldServiceOrder=false;
        soHderObj.fSLWorkOrder='FSL000011'; 
        soHderObj.fSLWorkOrderLineItem='FSL000012';
        soHderObj.orderDate=System.today(); 
        soHderObj.requiredDate=System.today();
        soHderObj.scheduledDate=System.today();
        soHderObj.scheduledDate=System.today();
        soHderObj.SalesOrderLineList= new List<giic_CommonWrapper.SalesOrderLine>();
        giic_CommonWrapper.RmaLine rmaLine = new giic_CommonWrapper.RmaLine();
        rmaLine.shipmentDetailId = null;
        rmaLine.productId = null;
        rmaLine.rmaQuantity = 2.0;
        rmaLine.productSerialId = null;
        rmaLine.productLotId = null;
        rmaLine.sellingUnitOfMeasureId = null;
        rmaLine.underWarranty = false;
        giic_CommonWrapper.RMAHeader rmaHead = new   giic_CommonWrapper.RMAHeader();
        giic_CommonWrapper.PurchaseOrderLine polW = new  giic_CommonWrapper.PurchaseOrderLine();
        polW.purchaseOrderId = null;
        polW.productId = null;
        polW.orderQuantity=2.0;
        polW.unitPrice = 2.0;
        polW.dropShip = false;
        polW.shipTo = '';
        rmaHead.caseId='';
        rmaHead.workOrderId='';
        rmaHead.reason='';
        rmaHead.reference='';
        rmaHead.rMADate=Date.today();
        rmaHead.shipmentId ='';
        rmaHead.warehouseId ='';
        rmaHead.accountId ='';
        rmaHead.divisionCodeId='';
        rmaHead.accountName='';
        rmaHead.street='';
        rmaHead.city='';
        rmaHead.stateProvince  ='';
        rmaHead.zipPostalCode='';
        rmaHead.country='';
        rmaHead.documentText='';
        rmaHead.currencyIsoCode ='';
        giic_CommonWrapper.SalesOrderLine soLObj=new giic_CommonWrapper.SalesOrderLine();
        soLObj.OrderQuantity=10.0;
        soLObj.ProductId=pref.Id;
        soLObj.UnitPrice=10;
        soLObj.OwnedByEnelX = false;
        soLObj.batchNumber='123456';
        soLObj.requiredDate =System.today();
        //soLObj.warehouseId=objWarehouse.Id;
        soHderObj.SalesOrderLineList.add(soLObj);
        soList.add(soHderObj);
        System.assertEquals(true, soList.size()>0);
        Giic_SalesOrderUtility.createSalesOrders(soList);
     }
    
    /*@isTest
    static void validatecreateSalesOrdersTest(){
        //create warehouse data
        gii__Warehouse__c objWarehouse = new gii__Warehouse__c(Name='WarehouseForSystemPolicy', gii__WareHouseStreet__c='111 Seedsman St',gii__WareHouseCity__c='Chicago',gii__WareHouseStateProvince__c='IL',gii__WareHouseZipPostalCode__c='50001',gii__WareHouseCountry__c='USA'); 
        insert objWarehouse;
        gii__SystemPolicy__c objSystemPolicy = new gii__SystemPolicy__c(Name='GII',gii__Description__c='Glovia Policies',gii__PriceBookName__c='Standard',
                                                                        gii__StockUM__c='Each',gii__ServiceTicketPricingOverriddenReason__c='Service Ticket',
                                                                        gii__AutoReleaseOrder__c=true,gii__AllowZeroUnitPrice__c=true ,
                                                                        gii__OppConversionPricingOverriddenReason__c='Opportunity Conversion' ,
                                                                        gii__SQConversionPricingOverriddenReason__c='Sales Quote Conversion',
                                                                        gii__AutoApprovePurchaseOrders__c=true, gii__Warehouse__c=objWarehouse.Id);
        insert objSystemPolicy;
        giic_UtilityClass_Test.accountCreation();
        List<Account> lstAcc =[select id, name, RecordTypeId, RecordType.Name from Account ];
        giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c(); 
        pref=[Select Id from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update pref;
        Contract objCon=new Contract();
        objCon=[Select Id,Status,EndDate from Contract];
        objCon.Status='Active';
        objCon.ContractTerm= 12;
        update objCon;
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);  
        List<giic_CommonWrapper.SalesOrderHeader> soList= new List<giic_CommonWrapper.SalesOrderHeader>();
        giic_CommonWrapper.SalesOrderHeader soHderObj=new giic_CommonWrapper.SalesOrderHeader();
        soHderObj.AccountId=giic_UtilityClass_Test.objAccountCentral.Id;
        soHderObj.DirectPurchaseOrder=true;      
        soHderObj.SalesOrderLineList= new List<giic_CommonWrapper.SalesOrderLine>();
        giic_CommonWrapper.SalesOrderLine soLObj=new giic_CommonWrapper.SalesOrderLine();
        soLObj.OrderQuantity=10.0;
        soLObj.ProductId=pref.Id;
        soLObj.UnitPrice=10;
        soLObj.OwnedByEnelX = false;
        soHderObj.SalesOrderLineList.add(soLObj);
        soList.add(soHderObj);
        System.assertEquals(true, soList.size()>0);
        Giic_SalesOrderUtility.createSalesOrders(soList);
    } */
    
    /*static testMethod void validatecreateSalesOrderRollBackTest(){
        //create warehouse data
        gii__Warehouse__c objWarehouse = new gii__Warehouse__c(Name='WarehouseForSystemPolicy', gii__WareHouseStreet__c='111 Seedsman St',gii__WareHouseCity__c='Chicago',gii__WareHouseStateProvince__c='IL',gii__WareHouseZipPostalCode__c='50001',gii__WareHouseCountry__c='USA'); 
        insert objWarehouse;
        gii__SystemPolicy__c objSystemPolicy = new gii__SystemPolicy__c(Name='GII',gii__Description__c='Glovia Policies',gii__PriceBookName__c='Standard',
                                                                        gii__StockUM__c='Each',gii__ServiceTicketPricingOverriddenReason__c='Service Ticket',
                                                                        gii__AutoReleaseOrder__c=true,gii__AllowZeroUnitPrice__c=true ,
                                                                        gii__OppConversionPricingOverriddenReason__c='Opportunity Conversion' ,
                                                                        gii__SQConversionPricingOverriddenReason__c='Sales Quote Conversion',
                                                                        gii__AutoApprovePurchaseOrders__c=true, gii__Warehouse__c=objWarehouse.Id);
        insert objSystemPolicy;
        giic_UtilityClass_Test.accountCreation();
        List<Account> lstAcc =[select id, name, RecordTypeId, RecordType.Name from Account ];
        //giic_UtilityClass_Test.warehouseCreation();
        giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c(); 
        pref=[Select Id from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        List<giic_CommonWrapper.SalesOrderHeader> soList= new List<giic_CommonWrapper.SalesOrderHeader>();
        giic_CommonWrapper.SalesOrderHeader soHderObj=new giic_CommonWrapper.SalesOrderHeader();
        soHderObj.AccountId=giic_UtilityClass_Test.objAccountCentral.Id;
        soHderObj.DirectPurchaseOrder=true;      
        soHderObj.SalesOrderLineList= new List<giic_CommonWrapper.SalesOrderLine>();
        giic_CommonWrapper.SalesOrderLine soLObj=new giic_CommonWrapper.SalesOrderLine();
        soLObj.OrderQuantity=10.0;
        soLObj.ProductId=pref.Id;
        soLObj.UnitPrice=10;
        soLObj.OwnedByEnelX = false;
        soHderObj.SalesOrderLineList.add(soLObj);
        soList.add(soHderObj);
        System.assertEquals(true, soList.size()>0);
        Giic_SalesOrderUtility.createSalesOrders(soList);
    } */
   
    /*static testMethod void validatecreateSalesOrderRollBack1Test(){
		Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
		giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation(); 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
        List<Account> lstAcc =[select id, name, RecordTypeId, RecordType.Name from Account ]; 
        giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c(); 
        pref=[Select Id from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.giic_ProcurementType__c='Transfer';
        update pref;
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__DropShip__c= false;
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.objPO.giic_Status__c= 'Draft';
        update Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(pref);
        Test.startTest();
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
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,pref);
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,pref);
        Giic_UtilityClass_Test.objPID.gii__Location__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objPID;
        List<giic_CommonWrapper.SalesOrderHeader> soList= new List<giic_CommonWrapper.SalesOrderHeader>();
        giic_CommonWrapper.SalesOrderHeader soHderObj=new giic_CommonWrapper.SalesOrderHeader();
        soHderObj.AccountId=giic_UtilityClass_Test.objAccountCentral.Id;
        soHderObj.DirectPurchaseOrder=false;  
        soHderObj.warehouseId=Giic_UtilityClass_Test.objWhLocal.Id;//Giic_UtilityClass_Test.lstWh[0].Id;
        soHderObj.SalesOrderLineList= new List<giic_CommonWrapper.SalesOrderLine>();
        giic_CommonWrapper.SalesOrderLine soLObj=new giic_CommonWrapper.SalesOrderLine();
        soLObj.OrderQuantity=1.0;
        soLObj.ProductId=pref.Id;
        soLObj.UnitPrice=10;
        soLObj.OwnedByEnelX = false;
        soHderObj.SalesOrderLineList.add(soLObj);
        soList.add(soHderObj);
        System.assertEquals(true, soList.size()>0);
        Giic_SalesOrderUtility.createSalesOrders(soList);
		Test.stopTest();
    } */   
    
    /*static testMethod void validatecreateSalesOrderRollBack2Test(){
        //create warehouse data
        gii__Warehouse__c objWarehouse = new gii__Warehouse__c(Name='WarehouseForSystemPolicy', gii__WareHouseStreet__c='111 Seedsman St',gii__WareHouseCity__c='Chicago',gii__WareHouseStateProvince__c='IL',gii__WareHouseZipPostalCode__c='50001',gii__WareHouseCountry__c='USA'); 
        insert objWarehouse;
        gii__SystemPolicy__c objSystemPolicy = new gii__SystemPolicy__c(Name='GII',gii__Description__c='Glovia Policies',gii__PriceBookName__c='Standard',
                                                                        gii__StockUM__c='Each',gii__ServiceTicketPricingOverriddenReason__c='Service Ticket',
                                                                        gii__AutoReleaseOrder__c=true,gii__AllowZeroUnitPrice__c=true ,
                                                                        gii__OppConversionPricingOverriddenReason__c='Opportunity Conversion' ,
                                                                        gii__SQConversionPricingOverriddenReason__c='Sales Quote Conversion',
                                                                        gii__AutoApprovePurchaseOrders__c=true, gii__Warehouse__c=objWarehouse.Id);
        insert objSystemPolicy;
        giic_UtilityClass_Test.accountCreation();
        List<Account> lstAcc =[select id, name, RecordTypeId, RecordType.Name from Account ];
        //giic_UtilityClass_Test.warehouseCreation();
        giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c(); 
        pref=[Select Id from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        List<giic_CommonWrapper.SalesOrderHeader> soList= new List<giic_CommonWrapper.SalesOrderHeader>();
        giic_CommonWrapper.SalesOrderHeader soHderObj=new giic_CommonWrapper.SalesOrderHeader();
        soHderObj.AccountId=giic_UtilityClass_Test.objAccountCentral.Id;
        soHderObj.DirectPurchaseOrder=false; 
        soHderObj.billingCity='Florida';
        soHderObj.billingCountry='USA'; 
        soHderObj.billingName='TESTUser';
        soHderObj.billingStateProvince='kERLA'; 
        soHderObj.billingStreet='tEST'; 
        soHderObj.billingZipPostalCode='201301';
        //soHderObj.divisionCodeId=false; 
        //soHderObj.fieldServiceOrder=giic_UtilityClass_Test.objAccountCentral.Id;
        soHderObj.fSLWorkOrder='FSL000011'; 
        soHderObj.fSLWorkOrderLineItem='FSL000012';
        soHderObj.orderDate=System.today(); 
        soHderObj.requiredDate=System.today();
        soHderObj.SalesOrderLineList= new List<giic_CommonWrapper.SalesOrderLine>();
        giic_CommonWrapper.SalesOrderLine soLObj=new giic_CommonWrapper.SalesOrderLine();
        soLObj.OrderQuantity=10.0;
        soLObj.ProductId=pref.Id;
        soLObj.UnitPrice=10;
        soLObj.OwnedByEnelX = false;
        soHderObj.SalesOrderLineList.add(soLObj);
        soList.add(soHderObj);
        System.assertEquals(true, soList.size()>0);
        Giic_SalesOrderUtility.createSalesOrders(soList);
    }*/ 
    
    /*static testMethod void reprocessOrderTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
        List<Account> lstAcc =[select id, name, RecordTypeId, RecordType.Name from Account ]; 
        giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c(); 
        pref=[Select Id from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.giic_ProcurementType__c='Transfer';
        update pref;
        Test.startTest();
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(pref);
        List<gii__SalesOrder__c> listId=[SELECT id from gii__SalesOrder__c Limit 1];
        String id=listId[0].Id;
        System.assertEquals(true, listId.size()>0);
        Giic_SalesOrderUtility.reprocessOrder(id);
        Test.stopTest();
    } */

}