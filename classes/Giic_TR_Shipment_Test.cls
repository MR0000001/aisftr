/**
* @author FirstName :  Sara Miozza sara.miozza@nttdata.com
* @date Creation 28/01/2020
* @date Modification dd/mm/yyyy
* @description Giic_TR_Shipment_Test 
*/

@isTest
private class Giic_TR_Shipment_Test {
    
    @isTest
    static void shipmentInsertTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Account acc = Giic_UtilityClass_Test.objAccountSupplier;
        Giic_UtilityClass_Test.salesOrderCreation();
        gii__SalesOrder__c so = Giic_UtilityClass_Test.objSalesOrder;
        
        Test.startTest();
        gii__Shipment__c objShip = new gii__Shipment__c(gii__Account__c = acc.ID,
                                                        gii__ShippedDate__c = date.today(),
                                                        giic_DeliveryDate__c = date.today(),
                                                        giic_DeliveryDocumentID__c = '0123456',
                                                        gii__SalesOrder__c = so.Id);
        insert objShip;
        
        System.assertEquals(date.today(), objShip.gii__ShippedDate__c);
        Test.stopTest();
        
    }
    
    @isTest
    static void shipmentUpdateTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Account acc = Giic_UtilityClass_Test.objAccountSupplier;
        Test.startTest();
        WorkOrder workOrder = XC_DF_WorkOrder.createWorkOrders(1,'Delivery')[0];
        insert workOrder;
        Giic_UtilityClass_Test.salesOrderCreation();
        gii__SalesOrder__c so = Giic_UtilityClass_Test.objSalesOrder;
        so.giic_WorkOrder__c = workOrder.Id;
        update so;
        Giic_UtilityClass_Test.transferOrderCreation();
        Gii__TransferOrder__c to = Giic_UtilityClass_Test.objTO;
        to.giic_SalesOrder__c = so.Id;
        update to;    

        gii__Shipment__c objShip = new gii__Shipment__c(gii__Account__c = acc.ID,
                                                        gii__ShippedDate__c = date.today(),
                                                        giic_DeliveryDate__c = date.today(),
                                                        giic_DeliveryDocumentID__c = '0123456',
                                                        gii__SalesOrder__c = so.Id,
                                                        gii__TransferOrder__c = to.Id);
        insert objShip;
        objShip.giic_DeliveryDate__c = date.today()+1;
        objShip.giic_DeliveryDocumentID__c = '0123457';
        update objShip;
        System.assertEquals(date.today(), objShip.gii__ShippedDate__c);
        Test.stopTest();
        
    }
    
    @isTest
    static void shipmentDeleteTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Account acc = Giic_UtilityClass_Test.objAccountSupplier;
        Giic_UtilityClass_Test.salesOrderCreation();
        gii__SalesOrder__c so = Giic_UtilityClass_Test.objSalesOrder;
       
        Test.startTest();
         gii__Shipment__c objShip = new gii__Shipment__c(gii__Account__c = acc.ID,
                                                        gii__ShippedDate__c = date.today(),
                                                        giic_DeliveryDate__c = date.today(),
                                                        giic_DeliveryDocumentID__c = '0123456',
                                                        gii__SalesOrder__c = so.Id);
        insert objShip;
        try{
       
        delete objShip;
        } catch(Exception e){
            	System.debug('@@@ Eccezione');
                Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot delete Shipment record') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
		}
        List<gii__Shipment__c> shipList = [SELECT id FROM gii__Shipment__c WHERE giic_DeliveryDocumentID__c = '0123456'];
        System.assertEquals(true,shipList.size()>0);
        Test.stopTest();
        
    }
    
    @isTest
    static void shipmentDetailInsertTest(){
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
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
     objProdRef.gii__SerialControlled__c = true;
        update objProdRef;
        
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
        gii__Shipment__c objShip = new gii__Shipment__c(gii__Account__c = lstAccount[0].ID,
                                                        gii__ShippedDate__c = date.today(),
                                                        giic_DeliveryDate__c = date.today(),
                                                        giic_DeliveryDocumentID__c = '0123456',
                                                        gii__SalesOrder__c = so.Id);
        insert objShip;
        gii__ShipmentDetail__c objShipDet = new gii__ShipmentDetail__c(gii__Shipment__c = objShip.id,
                                                        gii__SalesOrder__c = so.Id,
                                                                      gii__SalesOrderLine__c = sol.id,
                                                                       gii__ProductSerial__c = Giic_UtilityClass_Test.objProductSerial.id );
         insert objShipDet;
        System.assertEquals(date.today(), objShip.gii__ShippedDate__c);
        Test.stopTest();
        
    }
     @isTest
    static void shipmentDetailInsertTest2(){
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
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        objProdRef.gii__PrimarySupplier__c=lstAccount[0].Id;
        objProdRef.gii__SerialControlled__c = true;
        update objProdRef;
        
        Giic_UtilityClass_Test.salesOrderCreation();
        gii__SalesOrder__c so = Giic_UtilityClass_Test.objSalesOrder;
        so.gii__DropShip__c = true;
        update so;
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        gii__SalesOrderLine__c sol = Giic_UtilityClass_Test.objSalesOrderLine;
        
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__SalesOrder__c= so.id; 
        upsert Giic_UtilityClass_Test.objPO; 
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.objPOLine.gii__SalesOrderLine__c= sol.id; 
        upsert Giic_UtilityClass_Test.objPOLine; 
		Giic_UtilityClass_Test.objProductSerial= new gii__ProductSerial__c(Name = 'TUBE1234',gii__Product__c=objProdRef.id,gii__TransactionType__c='Shipment');
         insert Giic_UtilityClass_Test.objProductSerial;
        gii__Shipment__c objShip = new gii__Shipment__c(gii__Account__c = lstAccount[0].ID,
                                                        gii__ShippedDate__c = date.today(),
                                                        giic_DeliveryDate__c = date.today(),
                                                        giic_DeliveryDocumentID__c = '0123456',
                                                        gii__SalesOrder__c = so.Id);
        insert objShip;
        gii__ShipmentDetail__c objShipDet = new gii__ShipmentDetail__c(gii__Shipment__c = objShip.id,
                                                        gii__SalesOrder__c = so.Id,
                                                                      gii__SalesOrderLine__c = sol.id,
                                                                      gii__ProductSerial__c = Giic_UtilityClass_Test.objProductSerial.id );
         insert objShipDet;
         update objShipDet; 
        System.assertEquals(date.today(), objShip.gii__ShippedDate__c);
        Test.stopTest();
        
    }

}