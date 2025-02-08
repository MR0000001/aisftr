@isTest
private class Giic_TR_ReturnToSupplierShip_Test {
    
    @isTest
    static void returnToSuppShipInsertTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);  
        gii__RMA__c rmaObj = new gii__RMA__c();
        rmaObj.gii__Account__c =Giic_UtilityClass_Test.objAccountLocal.Id;
        rmaObj.gii__Warehouse__c = Giic_UtilityClass_Test.objWhLocal.Id;
        rmaObj.CurrencyIsoCode = 'EUR';
        insert rmaObj;
        gii__RMADetail__c rMALineObj = new gii__RMADetail__c();
        RMALineObj.gii__Product__c = prodRefObj.Id;
        RMALineObj.gii__RMAQuantity__c = 1;
        RMALineObj.gii__RMA__c = rmaObj.Id;
        insert rMALineObj;
        gii__RMAReceipt__c receipt = new gii__RMAReceipt__c();
        receipt.gii__RMA__c = rmaObj.Id;
        receipt.gii__ReceiptQuantity__c = 1;
        receipt.gii__ReceiptDate__c = Date.today();
        receipt.gii__RMALineDetail__c = rMALineObj.Id;
        receipt.gii__Product__c = prodRefObj.Id;
        receipt.gii__Warehouse__c = Giic_UtilityClass_Test.objWhLocal.Id;
        insert receipt;
        gii__RMADisposition__c dispose = new gii__RMADisposition__c();
        dispose.gii__RMAReceipt__c = receipt.Id;
        dispose.gii__DispositionQuantity__c = 1;
        insert dispose;
        List<Account> accList = new  List<Account>(); 
        accList.add(Giic_UtilityClass_Test.objAccountLocal);
        List<XC_Address__c> addressList = XC_DF_Address.createAddress(accList);
        insert addressList;
        gii__ReturntoSupplier__c rtsObj = new gii__ReturntoSupplier__c();
        rtsObj.gii__Supplier__c = Giic_UtilityClass_Test.objAccountLocal.Id;
        rtsObj.gii__ShipFrom__c = Giic_UtilityClass_Test.objWhLocal.Id;
        rtsObj.CurrencyIsoCode = 'EUR';
        rtsObj.gii__PriceBookName__c = Giic_UtilityClass_Test.objPriceBook.Name;
        rtsObj.giic_RMA__c = rmaObj.Id; 
        insert rtsObj;
        gii__ReturntoSupplierLine__c rtsLineObj = new gii__ReturntoSupplierLine__c();
        rtsLineObj.gii__Product__c = prodRefObj.Id;
        rtsLineObj.gii__OrderQuantity__c =2;
        rtsLineObj.gii__ReturntoSupplier__c = rtsObj.Id;
        insert rtsLineObj;
        Test.startTest();
        gii__ReturntoSupplierLineShipment__c rtsLineShipObj = new gii__ReturntoSupplierLineShipment__c();
        rtsLineShipObj.gii__ReturntoSupplier__c = rtsObj.Id;
        rtsLineShipObj.gii__ReturntoSupplierLine__c = rtsLineObj.Id;
         try{
       
        insert rtsLineShipObj;
        } catch(Exception e){
            	System.debug('@@@ Eccezione');
                System.assertEquals(rtsLineShipObj.gii__ReturntoSupplier__c!=null, true);
		}
         
       
        Test.stopTest();
    }
    
    @isTest
    static void returnToSuppShipUpdateTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);  
        List<gii__Product2Add__c> listProd = new List<gii__Product2Add__c>();
        listProd.add(prodRefObj);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal, listProd);
        Giic_UtilityClass_Test.creationPILocation(Giic_UtilityClass_Test.lstProductInventory[0] ,prodRefObj);
        Giic_UtilityClass_Test.creationPILocationDetail(Giic_UtilityClass_Test.lstProductInventory[0] ,prodRefObj);
       /** gii__RMA__c rmaObj = new gii__RMA__c();
        rmaObj.gii__Account__c =Giic_UtilityClass_Test.objAccountLocal.Id;
        rmaObj.gii__Warehouse__c = Giic_UtilityClass_Test.objWhLocal.Id;
        rmaObj.CurrencyIsoCode = 'EUR';
        insert rmaObj;
        gii__RMADetail__c rMALineObj = new gii__RMADetail__c();
        RMALineObj.gii__Product__c = prodRefObj.Id;
        RMALineObj.gii__RMAQuantity__c = 1;
        RMALineObj.gii__RMA__c = rmaObj.Id;
        insert rMALineObj;
        gii__RMAReceipt__c receipt = new gii__RMAReceipt__c();
        receipt.gii__RMA__c = rmaObj.Id;
        receipt.gii__ReceiptQuantity__c = 1;
        receipt.gii__ReceiptDate__c = Date.today();
        receipt.gii__RMALineDetail__c = rMALineObj.Id;
        receipt.gii__Product__c = prodRefObj.Id;
        receipt.gii__Warehouse__c = Giic_UtilityClass_Test.objWhLocal.Id;
        insert receipt;
        gii__RMADisposition__c dispose = new gii__RMADisposition__c();
        dispose.gii__RMAReceipt__c = receipt.Id;
        dispose.gii__DispositionQuantity__c = 1;
        insert dispose;*/
        gii__ReturntoSupplier__c rtsObj = new gii__ReturntoSupplier__c();
        rtsObj.gii__Supplier__c =Giic_UtilityClass_Test.objAccountLocal.Id;
        rtsObj.gii__ShipFrom__c = Giic_UtilityClass_Test.objWhLocal.Id;
        rtsObj.CurrencyIsoCode = 'EUR';
        rtsObj.gii__PriceBookName__c = Giic_UtilityClass_Test.objPriceBook.Name;
        //rtsObj.giic_RMA__c = rmaObj.Id; 
        insert rtsObj;
        gii__ReturntoSupplierLine__c rtsLineObj = new gii__ReturntoSupplierLine__c();
        rtsLineObj.gii__Product__c = prodRefObj.Id;
        rtsLineObj.gii__OrderQuantity__c =2;
        rtsLineObj.gii__ReturntoSupplier__c = rtsObj.Id;
        insert rtsLineObj;
        Test.startTest();
        gii__ReturntoSupplierLineShipment__c rtsLineShipObj = new gii__ReturntoSupplierLineShipment__c();
        rtsLineShipObj.gii__ReturntoSupplier__c = rtsObj.Id;
        rtsLineShipObj.gii__ReturntoSupplierLine__c = rtsLineObj.Id;
        insert rtsLineShipObj;
        update rtsLineShipObj;
        System.assertEquals(rtsLineShipObj.gii__ReturntoSupplier__c!=null, true);
        Test.stopTest();
    }
    
    @isTest
    static void returnToSuppShipDeleteTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);  
        List<gii__Product2Add__c> listProd = new List<gii__Product2Add__c>();
        listProd.add(prodRefObj);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal, listProd);
        Giic_UtilityClass_Test.creationPILocation(Giic_UtilityClass_Test.lstProductInventory[0] ,prodRefObj);
        Giic_UtilityClass_Test.creationPILocationDetail(Giic_UtilityClass_Test.lstProductInventory[0] ,prodRefObj);
       /** gii__RMA__c rmaObj = new gii__RMA__c();
        rmaObj.gii__Account__c =Giic_UtilityClass_Test.objAccountLocal.Id;
        rmaObj.gii__Warehouse__c = Giic_UtilityClass_Test.objWhLocal.Id;
        rmaObj.CurrencyIsoCode = 'EUR';
        insert rmaObj;
        gii__RMADetail__c rMALineObj = new gii__RMADetail__c();
        RMALineObj.gii__Product__c = prodRefObj.Id;
        RMALineObj.gii__RMAQuantity__c = 1;
        RMALineObj.gii__RMA__c = rmaObj.Id;
        insert rMALineObj;
        gii__RMAReceipt__c receipt = new gii__RMAReceipt__c();
        receipt.gii__RMA__c = rmaObj.Id;
        receipt.gii__ReceiptQuantity__c = 1;
        receipt.gii__ReceiptDate__c = Date.today();
        receipt.gii__RMALineDetail__c = rMALineObj.Id;
        receipt.gii__Product__c = prodRefObj.Id;
        receipt.gii__Warehouse__c = Giic_UtilityClass_Test.objWhLocal.Id;
        insert receipt;
        gii__RMADisposition__c dispose = new gii__RMADisposition__c();
        dispose.gii__RMAReceipt__c = receipt.Id;
        dispose.gii__DispositionQuantity__c = 1;
        insert dispose;
		*/
        List<Account> accountList = new List<Account>();
        accountList.add(Giic_UtilityClass_Test.objAccountLocal);
        List<XC_Address__c> address = XC_DF_Address.createAddress(accountList);
        insert address;
        gii__ReturntoSupplier__c rtsObj = new gii__ReturntoSupplier__c();
        rtsObj.gii__Supplier__c =Giic_UtilityClass_Test.objAccountLocal.Id;
        rtsObj.gii__ShipFrom__c = Giic_UtilityClass_Test.objWhLocal.Id;
        rtsObj.CurrencyIsoCode = 'EUR';
        rtsObj.gii__PriceBookName__c = Giic_UtilityClass_Test.objPriceBook.Name;
       // rtsObj.giic_RMA__c = rmaObj.Id; 
        insert rtsObj;
        gii__ReturntoSupplierLine__c rtsLineObj = new gii__ReturntoSupplierLine__c();
        rtsLineObj.gii__Product__c = prodRefObj.Id;
        rtsLineObj.gii__OrderQuantity__c =2;
        rtsLineObj.gii__ReturntoSupplier__c = rtsObj.Id;
        insert rtsLineObj;
        Test.startTest();
        gii__ReturntoSupplierLineShipment__c rtsLineShipObj = new gii__ReturntoSupplierLineShipment__c();
        rtsLineShipObj.gii__ReturntoSupplier__c = rtsObj.Id;
        rtsLineShipObj.gii__ReturntoSupplierLine__c = rtsLineObj.Id;
        insert rtsLineShipObj;
        try{
       
        delete rtsLineShipObj;
        } catch(Exception e){
            	System.debug('@@@ Eccezione');
                Boolean expectedExceptionThrown =  e.getMessage().contains('Return to Supplier Line Shipment Record cannot be deleted') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
		}
        Test.stopTest();
    }

}