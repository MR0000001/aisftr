/**
* @author Andrea Di Cicco
* @date Creation 19/03/2020
* @description Class of future methods for asynchronous calls about Goods Receipt
*/
@isTest
public class XC_REST_GoodReceipt_TEST {
    
    @testSetup static void setup() {
         Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        
        
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        /*
        gii__PurchaseOrder__c purchaseOrder = [Select id, giic_POCode__c from gii__PurchaseOrder__c limit 1];
        purchaseOrder.giic_POCode__c = 'TEST';
        update purchaseOrder;
        
        
        Product2 prod2 = new Product2();
        prod2.Name ='Prod 2';
        prod2.ProductCode ='TUBE1234';
        insert prod2;
        Product2 prod3 = new Product2();
        prod3.Name ='TUBE1234';
        prod3.ProductCode ='TUBE1234';
        insert prod3;
*/
        Giic_UtilityClass_Test.pOReceiptSC();
        List<gii__Product2Add__c> productList =  [Select gii__NonStock__c From gii__Product2Add__c LIMIT 2];
      

        productList[0].gii__SerialControlled__c = true;
        productList[1].gii__SerialControlled__c = true;
        update productList;

        Giic_UtilityClass_Test.purchaseOrderLineCreationLSTForCS(productList);
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productSerialCreation( String.valueOf(productList[0].id) );

        Giic_UtilityClass_Test.pOReceiptLineCS();
       // Giic_UtilityClass_Test.pOReceiptSC();
    }
    
    
    @isTest static void sendCreateGoodReceiptSAP(){
       
        XC_CS001_InterfaceConfiguration__c interfaceConfig = new XC_CS001_InterfaceConfiguration__c (Name = 'CreateGoodReceipt', XC_interfaceName__c = 'CreateGoodReceipt', XC_activeInterface__c = true, XC_URL_Required__c = 'test//v1/purchase-order');
        insert interfaceConfig;  
        Test.startTest();
        contract objContract = [select id, name, XC_IDSYSSAP__c from contract limit 1];
        objContract.XC_IDSYSSAP__c = 'S4P';
        update objContract;
        gii__PurchaseOrderReceipt__c objPOreceiptCS =  [SELECT Id,gii__PurchaseOrder__r.giic_POCode__c FROM gii__PurchaseOrderReceipt__c limit 1];
        gii__PurchaseOrder__c purchaseOrder = [Select id, giic_POCode__c from gii__PurchaseOrder__c limit 1];
        purchaseOrder.giic_POCode__c = 'TEST';
        purchaseOrder.giic_Contract__c = objContract.id;
        update purchaseOrder;
		System.debug('gii__PurchaseOrder__r.giic_POCode__c = '+(objPOreceiptCS).gii__PurchaseOrder__r.giic_POCode__c);
        try{
            XC_REST_GoodReceipt.sendCreateGoodReceiptSAP(objPOreceiptCS.id);
        }catch( Exception e ){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Too') ? true : false;
		    System.AssertEquals(expectedExceptionThrown, false);
        }
        
        Test.stopTest();
    }
    
    
    @isTest static  void sendUpdateGoodReceiptSAP(){
        
        contract objContract = [select id, name, XC_IDSYSSAP__c from contract limit 1];
        objContract.XC_IDSYSSAP__c = 'S4P';
        update objContract;

        gii__PurchaseOrder__c objPurchaseOrder = [select id, name, giic_Contract__c from gii__PurchaseOrder__c limit 1];
        objPurchaseOrder.giic_Contract__c = objContract.id;
        update objPurchaseOrder;

        XC_CS001_InterfaceConfiguration__c interfaceConfig = new XC_CS001_InterfaceConfiguration__c (Name = 'UpdateGoodReceipt', XC_interfaceName__c = 'UpdateGoodReceipt', XC_activeInterface__c = true, XC_URL_Required__c = 'test//v1/purchase-order');
        insert interfaceConfig;  
        gii__PurchaseOrderReceiptStaging__c porStaging = new gii__PurchaseOrderReceiptStaging__c();
        porStaging.giic_ReceiptDate__c =System.today();
        porStaging.giic_PurchaseOrder__c = objPurchaseOrder.id;
        insert porStaging;
        
        Test.startTest();
        XC_REST_GoodReceipt.sendUpdateGoodReceiptSAP(porStaging.id);
        Test.stopTest();
        
        
    }
    
    
    @isTest static void sendCreateGoodReceiptSAP2(){
       

        Test.startTest();
        contract objContract = [select id, name, XC_IDSYSSAP__c from contract limit 1];
        objContract.XC_IDSYSSAP__c = 'S4P';
        update objContract;
        gii__PurchaseOrderReceipt__c objPOreceiptCS =  [SELECT Id,gii__PurchaseOrder__r.giic_POCode__c FROM gii__PurchaseOrderReceipt__c limit 1];
        gii__PurchaseOrder__c purchaseOrder = [Select id, giic_POCode__c from gii__PurchaseOrder__c limit 1];
        purchaseOrder.giic_POCode__c = 'TEST';
        purchaseOrder.giic_Contract__c=objContract.id;
        update purchaseOrder;
		System.debug('gii__PurchaseOrder__r.giic_POCode__c = '+(objPOreceiptCS).gii__PurchaseOrder__r.giic_POCode__c);
        try{
            XC_REST_GoodReceipt.sendCreateGoodReceiptSAP(objPOreceiptCS.id);
        }catch( Exception e ){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Too') ? true : false;
		    System.AssertEquals(expectedExceptionThrown, false);
        }
        
        Test.stopTest();
    }
    
    @isTest static void sendCreateGoodReceipt3PL(){
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = 'CreateGoodReceipt';
        csInt.XC_interfaceName__c = 'CreateGoodReceipt';
        csInt.XC_URL_Required__c = 'test//v1/purchase-order';
        csInt.XC_activeInterface__c = true;
        insert csInt;
        
        Test.startTest();
        List<Account> lstAccount = [Select id from Account];
        gii__Product2Add__c objProdRef= [Select id, name, gii__ProductCode__c,gii__SerialControlled__c,giic_PartnerGRGI__c from gii__Product2Add__c Limit 1];
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
		objProdRef.gii__SerialControlled__c = true;
		objProdRef.giic_PartnerGRGI__c = true;
        update objProdRef;
        
        
        gii__Warehouse__c WH= [Select id, giic_WarehouseType__c, gii__DefaultReceivingLocation__c from gii__Warehouse__c Limit 1];
		WH.giic_WarehouseType__c = 'Local';
		update WH;
        
        gii__PriceBook__c pB = [select id from gii__PriceBook__c limit 1];
            
        gii__PurchaseOrder__c po = new gii__PurchaseOrder__c(gii__Supplier__c = lstAccount[0].Id, 
                                          gii__ShipTo__c = WH.id,
                                          gii__Approved__c=true,
                                          giic_Status__c='Draft',
                                          giic_PurchasingOrganization__c = 'ED02',
                                          giic_PriceBookId__c = pB.Id);
        insert po;
        
        gii__PurchaseOrderLine__C pol = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=po.id,gii__Product__c=objProdRef.id,gii__OrderQuantity__c=100.00,gii__UnitPrice__c=10.00,gii__Calc_LineGrossAmount__c=100, Giic_PartnerGRGI__c = true);
        insert pol;
		Giic_UtilityClass_Test.objProductSerial= new gii__ProductSerial__c(Name = 'TUBE1234',gii__Product__c=objProdRef.id,gii__TransactionType__c='Shipment', giic_FirstInstallationDate__c  = date.today());
        insert Giic_UtilityClass_Test.objProductSerial;
		
        gii__PurchaseOrderReceipt__c poReceipt = new gii__PurchaseOrderReceipt__c(gii__PurchaseOrder__c = po.id, gii__ReceiptDate__c = system.today());
        insert poReceipt;
        
        gii__PurchaseOrderReceiptLine__c poReceiptLine = new gii__PurchaseOrderReceiptLine__c(gii__PurchaseOrderReceipt__c = poReceipt.Id, gii__PurchaseOrderLine__c = pol.id,gii__PurchaseOrder__c= po.id,gii__Location__c=WH.gii__DefaultReceivingLocation__c,gii__ReceivedQuantity__c = 10.00, gii__ProductSerial__c = Giic_UtilityClass_Test.objProductSerial.Id);
        insert poReceiptLine;
        
        try{
            XC_REST_GoodReceipt.sendCreateGoodReceipt3PL(poReceipt.id);
        }catch( Exception e ){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Too') ? true : false;
		    System.AssertEquals(expectedExceptionThrown, false);
        }
        
        Test.stopTest();
    }
    
    @isTest static void sendCreateGoodReceipt3PLTO(){
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = 'CreateGoodReceipt';
        csInt.XC_interfaceName__c = 'CreateGoodReceipt';
        csInt.XC_URL_Required__c = 'test//v1/purchase-order';
        csInt.XC_activeInterface__c = true;
        insert csInt;
        
        test.startTest();
		List<Account> lstAccount = [Select id from Account];
        gii__Product2Add__c objProdRef= [Select id, name, gii__ProductCode__c,gii__SerialControlled__c,giic_PartnerGRGI__c from gii__Product2Add__c Limit 1];
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
		objProdRef.gii__SerialControlled__c = true;
		objProdRef.giic_PartnerGRGI__c = true;
        update objProdRef;   
        Giic_UtilityClass_Test.objProductSerial = new gii__ProductSerial__c(Name = 'TUBE1234',gii__Product__c=objProdRef.id,gii__TransactionType__c='Shipment', giic_FirstInstallationDate__c  = date.today());
        insert Giic_UtilityClass_Test.objProductSerial;
        gii__WarehouseGroup__c wG = [select id from gii__WarehouseGroup__c limit 1];
        gii__Warehouse__c WH= [Select id, giic_WarehouseType__c, gii__DefaultReceivingLocation__r.name, giic_WarehouseCode__c from gii__Warehouse__c limit 1];
        WH.giic_WarehouseType__c = 'Local';
        update WH;
		gii__Warehouse__c wh2 = new gii__Warehouse__c(Name = 'Local',
                                           giic_WarehouseType__c='Local',
                                           giic_StorageCapacity__c=50000,
                                           gii__Account__c = lstAccount[0].Id,
                                           gii__WarehouseGroup__c = wG.Id,
                                           giic_WarehouseCode__c = 'LW2',
                                           giic_warehousecountryPick__c = 'Spain',
                                           gii__WareHouseCountry__c = 'Spain',
                                           giic_LegalEntity__c = 'EndesaX',
                                           giic_ServerSystem__c ='Sirkus');
    	insert wh2;
        Gii__TransferOrder__c to = new gii__transferOrder__c(gii__Account__c=lstAccount[0].Id,gii__OrderDate__c=system.today(),
                                          gii__RequiredDate__c=system.today(),gii__FromWarehouse__c=wh2.Id,
                                          gii__TransferToWarehouse__c=WH.Id);
        insert to;
		
        gii__TransferOrderLine__c tol = new gii__TransferOrderLine__c(gii__TransferOrder__c=to.id,gii__Product__c=objProdRef.Id, gii__Quantity__c=1.00,gii__UnitCost__c=10,giic_PartnerGRGI__c = true);
        insert tol;
        gii__Receipt__c rc = new gii__receipt__c(gii__TransferOrder__c = to.id, gii__TransferOrderLine__c = tol.Id, gii__ProductSerial__c = Giic_UtilityClass_Test.objProductSerial.id, gii__Warehouse__c = WH.Id, gii__ShippedDate__c = system.today(), gii__ReceiptDate__c = system.today());
        insert rc;
        try{
            XC_REST_GoodReceipt.sendCreateGoodReceipt3PLTO(rc.id);
        }catch( Exception e ){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Too') ? true : false;
		    System.AssertEquals(expectedExceptionThrown, false);
        }
        test.stopTest();
    }
}