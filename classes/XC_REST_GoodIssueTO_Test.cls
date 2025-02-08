@isTest
private class XC_REST_GoodIssueTO_Test {

   @isTest
    static void XCRESTGoodIssueTOTest(){
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = 'CreateGoodIssue';
        csInt.XC_interfaceName__c = 'CreateGoodIssue';
        csInt.XC_URL_Required__c = 'test//v1/purchase-order';
        csInt.XC_activeInterface__c = true;
        insert csInt;
        
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
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c,gii__SerialControlled__c,giic_PartnerGRGI__c from gii__Product2Add__c Limit 1];
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
		objProdRef.gii__SerialControlled__c = true;
		objProdRef.giic_PartnerGRGI__c = true;
        update objProdRef;
        gii__Warehouse__c WH= [Select id, giic_WarehouseType__c from gii__Warehouse__c Limit 1];
		WH.giic_WarehouseType__c = 'Local';
		update WH; 
        Giic_UtilityClass_Test.salesOrderCreation();
        gii__SalesOrder__c so = Giic_UtilityClass_Test.objSalesOrder;
        
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        gii__SalesOrderLine__c sol = Giic_UtilityClass_Test.objSalesOrderLine;
        
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__SalesOrder__c= so.id; 
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPOLine.gii__SalesOrderLine__c= sol.id; 
        upsert Giic_UtilityClass_Test.objPOLine; 
		Giic_UtilityClass_Test.objProductSerial= new gii__ProductSerial__c(Name = 'TUBE1234',gii__Product__c=objProdRef.id,gii__TransactionType__c='Shipment', giic_FirstInstallationDate__c  = date.today());
         insert Giic_UtilityClass_Test.objProductSerial;
		 
        Giic_UtilityClass_Test.transferOrderCreation();
        Gii__TransferOrder__c to = Giic_UtilityClass_Test.objTO;
        to.giic_SalesOrder__c = so.Id;
        to.gii__FromWarehouse__c=WH.Id;
        update to;
        
		Giic_UtilityClass_Test.toLineCreation(objProdRef.Id);
        
		gii__TransferOrderLine__c tol= [Select id from gii__TransferOrderLine__c Limit 1];
		 
        gii__Shipment__c objShip = new gii__Shipment__c(gii__Account__c = lstAccount[0].ID,
                                                        gii__ShippedDate__c = date.today(),
                                                        giic_DeliveryDate__c = date.today(),
                                                        giic_DeliveryDocumentID__c = '0123456',
                                                        gii__TransferOrder__c = to.Id,gii__SalesOrder__c = so.Id, gii__Status__c = 'Shipped');
        insert objShip;
        gii__ShipmentDetail__c objShipDet = new gii__ShipmentDetail__c(gii__Shipment__c = objShip.id,
                                                        gii__TransferOrder__c = to.Id,
                                                                      gii__TransferOrderLine__c = tol.id,
                                                                       gii__ProductSerial__c = Giic_UtilityClass_Test.objProductSerial.id );
         insert objShipDet;
        System.assertEquals(date.today(), objShip.gii__ShippedDate__c);
        Test.stopTest();
        
    }
}