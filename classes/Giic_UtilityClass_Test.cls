/**
* @author FirstName :  Anil Giri- Anil .Giri@in.fujitsu.com
* @date Creation 17/06/2019
* @date Modification dd/mm/yyyy
* @description Giic_UtilityClass_Test – for all test classes
*/
@isTest
public class Giic_UtilityClass_Test {   
    /**
    * @description Product serial object
    */
    public static gii__ProductSerial__c objPS;
    
    public static gii__ProductLot__c objProductLot;
    /**
    * @description transfer order line record list
    */
    public static List<gii__TransferOrderLine__c> lstTOL;
    
    /**
    * @description transfer order line record list for serial controlled and non Controlled prodicts
    */
    public static List<gii__TransferOrderLine__c> lstTOLCS;
    
     /***** PA********
    * @description RMA receipt line 
    */
    public static gii__RMAReceipt__c objRMAReceipt;
    
     /***** PA********
    * @description RMA Disposition 
    */
    public static gii__RMADisposition__c objRMADisposition;
    
    
      
    /**
    * @description product record list
    */
    public static List<product2> lstProd;
    /**
    * @description system policy record
    */
    public static gii__SystemPolicy__c objSystemPolicy;
    /**
    * @description glovia system settings record
    */
    public static gii__GloviaSystemSetting__c objGCS;
    /**
    * @description Account record for central warehouse
    */
    public static Account objAccountCentral;
     /**
    * @description Account record for Local Warehouse
    */
    public static Account objAccountLocal;
    /**
      /**
    * @description Account record for Product Supplier
    */
    public static Account objAccountSupplier;
    /**
    * @description gii__WarehouseGroup__c record
    */
    
   public static gii__WarehouseGroup__c  wareHouseGroup;
    /**
    * @description shipment record
    */
    public static gii__Shipment__c objShipment;
    
    /**
    * @description warehouse central record
    */
    public static gii__Warehouse__c objWh;
   
    /**
    * @description warehouse local record
    */
    public static gii__Warehouse__c objWhLocal;
    /**
    * @description warehouse list
    */
    public static List<gii__Warehouse__c> lstWh;
    /**
    * @description Product 2 record
    */
    public static product2 objProductTL;
    public static product2 objProductTL2;
    /**
    * @description gii__PurchaseOrder__c record
    */
    public static gii__PurchaseOrder__c objPO;
    
    /**
    * @description List of purchase orde line record
    */
    public static List<gii__PurchaseOrderLine__c> lstPOLPS;// = new List<gii__PurchaseOrderLine__c>();    
    /**
    * @description gii__PurchaseOrder__c record
    */
    public static gii__PurchaseOrder__c objPOSupplier;

    /**
    * @description gii__TransferOrder__c record
    */
    public static gii__TransferOrder__c objTO;
    
     /**
    * @description gii__TransferOrder__c record
    */
    public static gii__TransferOrder__c objTOP;
    
    /**
    * @description gii__TransferOrder__c record
    */
    public static List<gii__TransferOrder__c> lstTO;
  
    /**
    * @description gii__TransferOrderLine__c record
    */
    public static gii__TransferOrderLine__c objTOline;
    public static gii__TransferOrderLine__c objTOline2;
    public static List<gii__TransferOrderLine__c> lstTOLSC;
    /**
    * @description gii__ReceiptQueue__c record
    */
    public static gii__ReceiptQueue__c objRecQueue;
    /**
    * @description orderDateString 
    */
    public static string orderDateString;
    /**
    * @description required date string 
    */
    public static string requiredDateString;
    /**
    * @description gii__Location__c record
    */
    public static gii__Location__c objLocationCentral;
    
    public static gii__Location__c objLocationlocal;
    
     /**
    * @description gii__Location__c record PA ******
    */
     public static gii__Location__c objLocationCentralScrap;
    
    public static gii__Location__c objLocationlocalScrap;
    
    /**
    * @description gii__Location__c record
    */
    public static List<gii__Location__c> locationList;
    /**
    * @description gii__PurchaseOrderLine__c record
    */
    public static gii__PurchaseOrderLine__c objPOLine;
     public static gii__PurchaseOrderLine__c objPOLine2;
    public static gii__PurchaseOrderLine__c objPOLineOneQty;
    /**
    * @description gii__PurchaseOrderReceipt__c record
    */
    public static gii__PurchaseOrderReceipt__c objPOreceipt;
    /**
    * @description gii__PurchaseOrderReceipt__c record
    */
    public static gii__PurchaseOrderReceipt__c objPOreceiptCS;
    /**
    * @description gii__PurchaseOrderReceiptLine__c record
    */
    public static gii__PurchaseOrderReceiptLine__c objPoRecLine;
    
    /**
    * @description gii__PurchaseOrderReceiptLine__c record
    */
    public static List<gii__PurchaseOrderReceiptLine__c> lstPoRecLine;
    
    
    /**
    * @description gii__ProductInventorybyLocation__c record
    */
    public static List<gii__TransferOrder__c> listTO ;
    public static gii__ProductInventorybyLocation__c objPILocation;
     public static List<gii__ProductInventorybyLocation__c> lstPILocation;
    /**
    * @description gii__ProductInventorybyLocation__c record
    */
    public static gii__ProductInventorybyLocation__c objPILocationNew;
    /**
    * @description gii__ProductInventoryQuantityDetail__c record
    */
    public static gii__ProductInventoryQuantityDetail__c objPID;
     public static gii__ProductInventoryQuantityDetail__c objPID2;
    
    public static list<gii__ProductInventoryQuantityDetail__c> lstPIQD;
    /**
    * @description gii__InventoryReserve__c record
    */
    public static gii__InventoryReserve__c objIR;
    /**
    * @description Work Order record
    */
    public static WorkOrder objWorkOrder;
    
    public static WorkOrderLineItem objWorkOrderLineItem;
    /**
    * @description Service Appointment record
    */
    public static ServiceAppointment objServiceAppointment;
    /**
    * @description Sales Order  record
    */
    public static gii__SalesOrder__c objSalesOrder;
    
    public static Contact objContact;
    
    /**
    * @description Sales Order Line record
    */
    public static gii__SalesOrderLine__c objSalesOrderLine;

    /**
    * @description Work Type record
    */
    public static WorkType objWorkType;
    
    /**
    * @description Product Serial Record
    */
    public static gii__ProductSerial__c objProductSerial;
    /**
    * @description Product Inventory
    */
    public static list<gii__ProductInventory__c> lstProductInventory;
    
     /**
    * @description Price Book Record
    */
    public static gii__PriceBook__c objPriceBook;
    
    /**
    * @description Price Book Entry Record
    */
    public static gii__PriceBookEntry__c objPriceBookEntry;
    
    /**
    * @description Price Book Entry Record
    */
    public static gii__PriceBook__c objPriceBookDup;
    
    
    /**
    * @description Contract Record
    */
    public static Contract objContract;
       
     /**
    * @description Contract Record
    */
    public static gii__RMA__c ObjRMA;
    
     /**
    * @description Contract Record
    */
    public static gii__RMADetail__c ObjRMALine;

    
    /**
     * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description system policy
    */
    public static void systemPolicyCreation(){
        objSystemPolicy = new gii__SystemPolicy__c(Name='GII',gii__Description__c='Glovia Policies',gii__PriceBookName__c='Standard',
                                   gii__StockUM__c='Each',gii__ServiceTicketPricingOverriddenReason__c='Service Ticket',
                                   gii__AutoReleaseOrder__c=true,gii__AllowZeroUnitPrice__c=true ,
                                   gii__OppConversionPricingOverriddenReason__c='Opportunity Conversion' ,
                                   gii__SQConversionPricingOverriddenReason__c='Sales Quote Conversion',
                                   gii__AutoApprovePurchaseOrders__c=true);
        insert objSystemPolicy;
    }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description glovia system setting
    */
     public static void gloviaSystemSettingCreation(){
        objGCS = new gii__GloviaSystemSetting__c();
        objGCS.gii__DoNotAutoReserveInventory__c = true;
        objGCS.gii__DoNotAutoReserveNonStock__c = true;
        objGCS.gii__UseGloviaPriceBook__c = true;
        insert objGCS; 
        RecordType rtacc = [SELECT Id,name,developerName FROM RecordType WHERE sObjectType = 'Account' LIMIT 1];
        Account objAccountSupplier=new account(RecordTypeId=rtacc.Id,XC_CompanyFiscalCode__c='aaa',XC_ProductCategoryOfInterest__c='Caldera',Name='Enel-X Supplier',XC_Country__c='Chile',CurrencyIsoCode='EUR',IdentityNumber__c='Enel-X-03933',Country__c='Spain',XC_DocumentCountry__c='Lebanon',IdentityType__c='Passport');
        insert objAccountSupplier;
        RecordType rt = [SELECT Id,name,developerName FROM RecordType WHERE sObjectType = 'Contract' LIMIT 1]; 
        Contract c = new Contract(RecordTypeId=rt.Id,AccountId=objAccountSupplier.Id,Status='Draft',XC_LegalEntity__c='EndesaX',XC_CompanyCode__c='7777',StartDate = Date.newInstance(1900, 1, 22),EndDate = Date.newInstance(3000, 1, 22),giic_BudgetConsumption__c=2000,giic_TotalAmount__c=100);
        insert c;
        gii__PriceBook__c standardPriceBook= new gii__PriceBook__c(Name='Standard',gii__IsActive__c=true,gii__IsStandard__c=true,giic_Contract__c=c.Id );
        insert standardPriceBook;
    }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com 
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description account creation
    */
    public static void accountCreation(){
        RecordType rt = [SELECT Id,name,developerName FROM RecordType WHERE sObjectType = 'Account' LIMIT 1];
        objAccountCentral = new account(RecordTypeId=rt.Id,XC_CompanyFiscalCode__c='aaa',XC_ProductCategoryOfInterest__c='Caldera',Name='Enel-X Central',XC_Country__c='Chile',CurrencyIsoCode='EUR',IdentityNumber__c='Enel-X-0800933',Country__c='Spain',XC_DocumentCountry__c='Spain',IdentityType__c='Passport');
        insert objAccountCentral;
        objAccountLocal=new account(RecordTypeId=rt.Id,XC_CompanyFiscalCode__c='aaa',XC_ProductCategoryOfInterest__c='Caldera',Name='Enel-X Local',XC_Country__c='Chile',CurrencyIsoCode='EUR',IdentityNumber__c='Enel-X-08783933',Country__c='Spain',XC_DocumentCountry__c='Denmark',IdentityType__c='Passport');
        insert objAccountLocal;
        objAccountSupplier=new account(RecordTypeId=rt.Id,XC_CompanyFiscalCode__c='aaa',XC_ProductCategoryOfInterest__c='Caldera',Name='Enel-X Supplier',XC_Country__c='Chile',CurrencyIsoCode='EUR',IdentityNumber__c='Enel-X-03933',Country__c='Spain',XC_DocumentCountry__c='Lebanon',IdentityType__c='Passport');
        insert objAccountSupplier;
        
    }
    
     public static void contactCreation(Id accountId){
        RecordType rt = [SELECT Id,name,developerName FROM RecordType WHERE developerName = 'XC_ESP_Contact_SFM' LIMIT 1];
        objContact = new Contact(RecordTypeId=rt.Id,FirstName='Enel',LastName='Test',accountId=accountId,CurrencyIsoCode='EUR',Country__c='Spain',Email='efgwewg@test.com');
        insert objContact;
        
        
    }
    
    
    
    
    public static void accountCreationTO(){
        RecordType rt = [SELECT Id,name,developerName FROM RecordType WHERE sObjectType = 'Account' AND developerName = 'XC_GLO_Account_Supplier'];
        objAccountCentral = new account(RecordTypeId=rt.Id,Name='Enel-X Central',XC_Country__c='Chile',CurrencyIsoCode='EUR',IdentityNumber__c='Enel-X-0800933',Country__c='Spain',XC_DocumentCountry__c='Spain',IdentityType__c='Passport');
        insert objAccountCentral;
        objAccountSupplier=new account(RecordTypeId=rt.Id,Name='Enel-X Supplier',XC_Country__c='Chile',CurrencyIsoCode='EUR',IdentityNumber__c='Enel-X-03933',Country__c='Spain',XC_DocumentCountry__c='Lebanon',IdentityType__c='Passport');
         insert objAccountSupplier;
        
    }
     /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description account creation
    */
    
    public static void wareHouseGroupCreation(){
         wareHouseGroup = new gii__WarehouseGroup__c(Name='Test-Network');
        insert wareHouseGroup;
        
    }
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description warehouse creation
    */
    public static void warehouseCreation(){
        lstWh = new List<gii__Warehouse__c>();
        objWh = new gii__Warehouse__c(Name = 'Central Warehouse',
                                      giic_WarehouseType__c='Central',
                                      giic_StorageCapacity__c=400000,
                                      gii__Account__c = objAccountCentral.Id, 
                                      gii__WarehouseGroup__c = wareHouseGroup.Id,
                                      giic_WarehouseCode__c = 'CW',
                                      giic_warehousecountryPick__c = 'Spain',
                                      gii__WareHouseCountry__c = 'Spain',
                                      giic_LegalEntity__c = 'EndesaX',
                                      giic_ServerSystem__c ='Sirkus'
                                      );
        lstWh.add(objWh);
        objWhLocal = new gii__Warehouse__c(Name = 'Local Warehouse',
                                           giic_WarehouseType__c='Local',
                                           giic_StorageCapacity__c=400000,
                                           gii__Account__c = objAccountCentral.Id,
                                           gii__WarehouseGroup__c = wareHouseGroup.Id,
                                           giic_WarehouseCode__c = 'LW',
                                           giic_warehousecountryPick__c = 'Spain',
                                           gii__WareHouseCountry__c = 'Spain',
                                           giic_LegalEntity__c = 'EndesaX',
                                           giic_ServerSystem__c ='Sirkus'
                                           );
        lstWh.add(objWhLocal);
        insert lstWh;
       /* objWh =lstWh[0];
        objWhLocal =lstWh[1]; 
        objWhLocal.giic_ParentWarehouse__c=objWh.Id;
        update objWhLocal; */
    }
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description location creation
    */
    public static void locationCreation(){ 
        objLocationCentral = new gii__Location__c(Name='Central Location',gii__Warehouse__c=lstWh[0].Id, giic_LocationCode__c = 'CLWH', giic_LocationType__c = 'Sales');
        insert objLocationCentral;
        objLocationlocal = new gii__Location__c(Name='Local Location',gii__Warehouse__c=objWhLocal.Id, giic_LocationCode__c = 'LLWH',  giic_LocationType__c = 'Sales');
        insert objLocationlocal; 
        objLocationCentralScrap = new gii__Location__c(Name='Central Location Scrap',gii__Warehouse__c=lstWh[0].Id, giic_LocationCode__c = 'CLWHS', giic_LocationType__c = 'Scrap');
        insert objLocationCentralScrap;
        objLocationlocalScrap = new gii__Location__c(Name='Local Location Scrap',gii__Warehouse__c=objWhLocal.Id, giic_LocationCode__c = 'LLWHS',  giic_LocationType__c = 'Scrap');
        insert objLocationlocalScrap; 
    }
    
    
        /**
* @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
* @date Creation 17/06/2019
* @date Modification dd/mm/yyyy
    * @description productCreation
    */
    public static void productCreation(){
        lstProd = new  List<product2>();
        objProductTL=new product2(Name = 'Tube Light',ProductCode = 'Tube Light', CurrencyIsoCode='EUR',XC_CompanyCode__c='ES21',giic_LegalEntity__c='EndesaX'); 
        lstProd.add(objProductTL);
        objProductTL2 = new product2(Name = 'Tube Light1',ProductCode = 'Tube Light1',CurrencyIsoCode='EUR',XC_CompanyCode__c='ES21',giic_LegalEntity__c='EndesaX'); 
        lstProd.add(objProductTL2);
        insert lstProd; 
        
    }
     

    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description productSerialCreation
    * @param productRef product reference
    */
    public static void productSerialCreation(string productRef){
        objPS = new gii__ProductSerial__c(gii__Product__c=productRef,Name='Tube-1');
        insert objPS;
    }
    
    
     public static void productLotCreation(string productRef){
        objProductLot = new gii__ProductLot__c(gii__Product__c=productRef,Name='Tube-1');
        insert objProductLot;
    }
        
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description purchaseOrderCreation
    */
    public static void purchaseOrderCreation(){
        Date newDeliveryDate = system.today();
        objPO = new gii__PurchaseOrder__c(gii__Supplier__c = objAccountSupplier.Id, 
                                          gii__ShipTo__c = objWh.id,
                                          gii__Approved__c=true,
                                          giic_Status__c='Draft',
                                          giic_PurchasingOrganization__c = 'ED02',
                                          giic_PriceBookId__c = objPriceBook.Id
                                          );
        insert objPO;
        
    }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description purchaseOrderCreation
    */
    public static void purchaseOrderCreationSC(){
        
        objPOSupplier = new gii__PurchaseOrder__c(gii__Supplier__c = objAccountSupplier.id, gii__ShipTo__c = objWh.id,gii__Approved__c=true,giic_Status__c='Open');
        insert objPOSupplier;
    }
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description purchaseOrderLineCreation
    * @param objProdRef product reference
    */
    public static void purchaseOrderLineCreation(gii__Product2Add__c objProdRef){
        System.debug('gii__PurchaseOrder__c>>>>>>>>>>' + objPO);
        System.debug('gii__PurchaseOrder__c>>>>>>>>>>' + objProdRef);
        System.debug('objSalesOrderLine>>>>>>>>>>' + objSalesOrderLine);
        objPOLine = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=objPO.id,gii__Product__c=objProdRef.id,gii__OrderQuantity__c=100.00,gii__UnitPrice__c=10.00,gii__Calc_LineGrossAmount__c=100);
        System.debug('objPOLine>>>>>>>>>>' + objPOLine);
        insert objPOLine;
     //   objPOLine2 = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=objPO.id,gii__Product__c=objProdRef[1].id,gii__OrderQuantity__c=80.00,gii__UnitPrice__c=10.00);
     //   insert objPOLine;
    }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description purchaseOrderLineCreationLST
    * @param objProdRef product reference
    */
     public static void purchaseOrderLineCreationLST(List<gii__Product2Add__c> objProdRef){
        System.debug('gii__PurchaseOrder__c>>>>>>>>>>' + objPO);
         System.debug('gii__PurchaseOrder__c>>>>>>>>>>' + objProdRef);
         List<gii__PurchaseOrderLine__c> lstPOL = new List<gii__PurchaseOrderLine__c>();
        objPOLine = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=objPO.id,gii__Product__c=objProdRef[0].id,gii__OrderQuantity__c=100.00,gii__UnitPrice__c=10.00);
        lstPOL.add(objPOLine);
        objPOLine2 = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=objPO.id,gii__Product__c=objProdRef[1].id,gii__OrderQuantity__c=80.00,gii__UnitPrice__c=10.00);
        lstPOL.add(objPOLine2);
        insert lstPOL;
    }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 28/08/2019
    * @date Modification dd/mm/yyyy
    * @description PO receipt creation
    * @param objProdRef product reference
    */
    public static void purchaseOrderLineCreationLSTForCS(List<gii__Product2Add__c> objProdRef){
        
        System.debug('IN purchaseOrderLineCreationLSTForCS con ' + objProdRef);
        System.debug('IN purchaseOrderLineCreationLSTForCS con ' + objProdRef[0].id);
       
        lstPOLPS = new List<gii__PurchaseOrderLine__c>();
        objPOLine = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=objPO.id,gii__Product__c=objProdRef[0].id,gii__OrderQuantity__c=1.00,gii__UnitPrice__c=10.00);
        system.debug('objPOLine::'+objPOLine);
        lstPOLPS.add(objPOLine);
        objPOLine2 = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=objPO.id,gii__Product__c=objProdRef[1].id,gii__OrderQuantity__c=10.00,gii__UnitPrice__c=10.00);
        system.debug('objPOLine2:::'+objPOLine2);
        lstPOLPS.add(objPOLine2);
        insert lstPOLPS;
    }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 28/08/2019
    * @date Modification dd/mm/yyyy
    * @description PO receipt creation for serial and non serial products
    */
    public static void pOReceiptSC(){
        Date receiptDate = system.today().addMonths(1);
        string receiptDateString = receiptDate.year()+'-'+receiptDate.month()+'-'+receiptDate.day();
        objPOreceiptCS = new gii__PurchaseOrderReceipt__c(gii__ReceiptDate__c =Date.valueOf(receiptDateString), gii__PurchaseOrder__c =objPO.id ,gii__Supplier__c = objAccountCentral.id,gii__ShipTo__c=objWh.id);
        insert objPOreceiptCS;
    }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 28/08/2019
    * @date Modification dd/mm/yyyy
    * @description PO receipt line creation for Product serial and non serial
    */
    public static void pOReceiptLineCS(){
        lstPoRecLine = new List<gii__PurchaseOrderReceiptLine__c>();
        gii__PurchaseOrderReceiptLine__c objPoRecLineCS = new gii__PurchaseOrderReceiptLine__c(gii__PurchaseOrderReceipt__c=objPOreceiptCS.id,gii__PurchaseOrderLine__c=lstPOLPS[0].id,gii__PurchaseOrder__c=objPO.id,gii__Location__c=objLocationCentral.id,gii__ReceivedQuantity__c = 1.00,gii__ProductSerial__c=objPS.id);
        gii__PurchaseOrderReceiptLine__c objPoRecLineNS = new gii__PurchaseOrderReceiptLine__c(gii__PurchaseOrderReceipt__c=objPOreceiptCS.id,gii__PurchaseOrderLine__c=lstPOLPS[1].id,gii__PurchaseOrder__c=objPO.id,gii__Location__c=objLocationCentral.id,gii__ReceivedQuantity__c = 10.00);
        lstPoRecLine.add(objPoRecLineCS);
        lstPoRecLine.add(objPoRecLineNS);
        insert lstPoRecLine;
        
    }
    
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description PO receipt creation
    */
    public static void pOReceipt(){
        Date receiptDate = system.today().addMonths(1);
        string receiptDateString = receiptDate.year()+'-'+receiptDate.month()+'-'+receiptDate.day();
        objPOreceipt = new gii__PurchaseOrderReceipt__c(gii__ReceiptDate__c =Date.valueOf(receiptDateString), gii__PurchaseOrder__c =objPO.id ,gii__Supplier__c = objAccountCentral.id,gii__ShipTo__c=objWh.id, giic_LegalEntity__c= 'EndesaX');
        insert objPOreceipt;
    }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description PO receipt line creation
    */
    public static void createPOReceiptLineWithPI(gii__ProductInventory__c pi){
        objPoRecLine = new gii__PurchaseOrderReceiptLine__c(gii__PurchaseOrderReceipt__c=objPOreceipt.id,gii__ProductInventory__c=pi.Id, gii__PurchaseOrderLine__c=objPOLine.id,gii__PurchaseOrder__c=objPO.id,gii__Location__c=objLocationCentral.id,gii__ReceivedQuantity__c = 100.00);
        insert objPoRecLine;
        
    }
    
     public static void createPOReceiptLineWithPIQD(gii__ProductInventory__c pi,gii__ProductInventoryQuantityDetail__c piqd){
        objPoRecLine = new gii__PurchaseOrderReceiptLine__c(gii__PurchaseOrderReceipt__c=objPOreceipt.id,gii__ProductInventoryQuantityDetail__c=piqd.Id,gii__ProductInventory__c=pi.Id, gii__PurchaseOrderLine__c=objPOLine.id,gii__PurchaseOrder__c=objPO.id,gii__Location__c=objLocationCentral.id,gii__ReceivedQuantity__c = 100.00);
        insert objPoRecLine;
        
    }
    
    
    
    
    public static void pOReceiptLine(){
        objPoRecLine = new gii__PurchaseOrderReceiptLine__c(gii__PurchaseOrderReceipt__c=objPOreceipt.id, gii__PurchaseOrderLine__c=objPOLine.id,gii__PurchaseOrder__c=objPO.id,gii__Location__c=objLocationCentral.id,gii__ReceivedQuantity__c = 100.00);
        insert objPoRecLine;
        
    }
    
    /**
    * @author FirstName : Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com
    * @date Creation 25/01/2020
    * @date Modification dd/mm/yyyy
    * @description Shipment creation
    */
    public static void shipmentCreation(){
        objShipment = new gii__Shipment__c(gii__SalesOrder__c = objSalesOrder.Id);
        insert objShipment;
        
    }
    /** 
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description PI creation
    * @param objWh warehouse
    * @param lstProdRef gii__Product2Add__c
    */
    public static void creationPI(gii__Warehouse__c objWh,list<gii__Product2Add__c> lstProdRef){
        lstProductInventory=new list<gii__ProductInventory__c>();
        for (gii__Product2Add__c pr : lstProdRef){
              lstProductInventory.add(new gii__ProductInventory__c(gii__Product__c=pr.id ,gii__Warehouse__c=objWh.id,giic_BackOrderNew__c=1 ));
        } 
        insert lstProductInventory;
    }
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description PI creation
    * @param objPI product inventory
    * @param objProdRef product reference
    */
    public static void creationPILocation(gii__ProductInventory__c objPI,gii__Product2Add__c objProdRef){
        System.debug('objWh----'+objWh+'objLocationCentral----'+objLocationCentral);
        objPILocation = new gii__ProductInventorybyLocation__c(gii__ProductInventory__c=objPI.id,gii__Product__c=objProdRef.id ,gii__Warehouse__c=objPI.gii__Warehouse__c,gii__Location__c=objLocationCentral.id);
        insert objPILocation;
    }
    
     /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 28/08/2019
    * @date Modification dd/mm/yyyy
    * @description this method used to create PI Location
    * @param lstPI product inventory
    * @param lstProdRef product reference
    */
    public static void creationPILocationList(List<gii__ProductInventory__c> lstPI,List<gii__Product2Add__c> lstProdRef){
        lstPILocation = new List<gii__ProductInventorybyLocation__c>();
        System.debug('lstPI----'+lstPI[0]+'objProdRef----'+lstProdRef[0]);
        gii__ProductInventorybyLocation__c objPILocationCS = new gii__ProductInventorybyLocation__c(gii__ProductInventory__c=lstPI[0].id,gii__Product__c=lstProdRef[0].id ,gii__Warehouse__c=objWh.id,gii__Location__c=objLocationCentral.id);
        gii__ProductInventorybyLocation__c objPILocationNS = new gii__ProductInventorybyLocation__c(gii__ProductInventory__c=lstPI[1].id,gii__Product__c=lstProdRef[1].id ,gii__Warehouse__c=objWh.id,gii__Location__c=objLocationCentral.id);
        lstPILocation.add(objPILocationCS);
        lstPILocation.add(objPILocationNS);
        insert lstPILocation;
    }
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description PIL creation
    * @param objPI productinventory
    * @param objProdRef productreference
    */
    public static void creationPILocationDetail(gii__ProductInventory__c objPI,gii__Product2Add__c objProdRef){
       
        objPID = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=objPI.id,gii__ProductInventorybyLocation__c=objPILocation.id,gii__Warehouse__c=objWh.id,gii__Location__c=objLocationCentral.id,gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=100.00);
        insert objPID;
        objPID2 = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=objPI.id,gii__ProductInventorybyLocation__c=objPILocation.id,gii__Warehouse__c=objWhLocal.id,gii__Location__c=objLocationLocal.id,gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=100.00);
        insert objPID2;
        system.debug('objPID:::'+objPID);
    }
    
    
    public static void creationPILocationDetailForLot(gii__ProductInventory__c objPI,gii__Product2Add__c objProdRef,String productLotId){
       
        objPID = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=objPI.id,gii__ProductInventorybyLocation__c=objPILocation.id,gii__Warehouse__c=objWh.id,gii__Location__c=objLocationCentral.id,gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=100.00,gii__ProductLot__c=productLotId );
        insert objPID;
        objPID2 = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=objPI.id,gii__ProductInventorybyLocation__c=objPILocation.id,gii__Warehouse__c=objWhLocal.id,gii__Location__c=objLocationLocal.id,gii__Product__c=objProdRef.id,gii__OnHandQuantity__c=100.00, gii__ProductLot__c =productLotId );
        insert objPID2;
        system.debug('objPID:::'+objPID);
    }
    
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description PIL creation
    * @param lstPI productinventory
    * @param lstProdRef productreference
    */
    public static void creationPILocationDetailLst(list<gii__ProductInventory__c> lstPI,List<gii__Product2Add__c> lstProdRef){
          lstPIQD = new list<gii__ProductInventoryQuantityDetail__c>(); 
          gii__ProductInventoryQuantityDetail__c objPIQDSC = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=lstPI[0].id,gii__ProductInventorybyLocation__c=lstPILocation[0].id,gii__Warehouse__c=objWh.id,gii__Location__c=objLocationCentral.id,gii__Product__c=lstProdRef[0].id,gii__OnHandQuantity__c=1.00,gii__ProductSerial__c=objPS.id);
           gii__ProductInventoryQuantityDetail__c objPIQDNS = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=lstPI[1].id,gii__ProductInventorybyLocation__c=lstPILocation[1].id,gii__Warehouse__c=objWh.id,gii__Location__c=objLocationCentral.id,gii__Product__c=lstProdRef[1].id,gii__OnHandQuantity__c=10.00);
           lstPIQD.add(objPIQDSC);
           lstPIQD.add(objPIQDNS);
           insert lstPIQD;
    }
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description TO creation
    */    
    public static void transferOrderCreation(){
        
        Date orderDate = system.today();
        Date requiredDate = system.today().addMonths(1);
        orderDateString = orderDate.year()+'-'+orderDate.month()+'-'+orderDate.day();
        requiredDateString = requiredDate.year()+'-'+requiredDate.month()+'-'+requiredDate.day();
        objTO = new gii__TransferOrder__c(gii__Account__c=objAccountCentral.Id,gii__OrderDate__c=date.valueOf(orderDateString),
                                          gii__RequiredDate__c=date.valueOf(requiredDateString),gii__FromWarehouse__c=objWh.Id,
                                          gii__TransferToWarehouse__c=objWhLocal.Id);
        
        insert objTO;
    }
    
    /**
    * @author FirstName : Alberto Pompei alberto.pompei@nttdata.com
    * @date Creation 19/11/2020
    * @date Modification dd/mm/yyyy
    * @description TO creation without insertion
    */  
    public static gii__TransferOrder__c transferOrderCreationWI(){
        
        Date orderDate = system.today();
        Date requiredDate = system.today().addMonths(1);
        orderDateString = orderDate.year()+'-'+orderDate.month()+'-'+orderDate.day();
        requiredDateString = requiredDate.year()+'-'+requiredDate.month()+'-'+requiredDate.day();
        objTO = new gii__TransferOrder__c(gii__Account__c=objAccountCentral.Id,gii__OrderDate__c=date.valueOf(orderDateString),
                                          gii__RequiredDate__c=date.valueOf(requiredDateString),gii__FromWarehouse__c=objWh.Id,
                                          gii__TransferToWarehouse__c=objWhLocal.Id);
        
        return objTO;
    }
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 28/08/2019
    * @date Modification dd/mm/yyyy
    * @description Insert Multiple TO creation for serial and non serial product
    * @param objProdRef gii__Product2Add__c
    */ 
    
    public static void tOLineCreationSC(List<gii__Product2Add__c> objProdRef){
         lstTOLSC = new  List<gii__TransferOrderLine__c>();
         
        objTOline = new gii__TransferOrderLine__c(gii__TransferOrder__c=objTO.id,gii__Product__c=objProdRef[0].id,gii__Quantity__c=1.00,gii__UnitCost__c=10);
        lstTOLSC.add(objTOline);
        
        objTOline2 = new gii__TransferOrderLine__c(gii__TransferOrder__c=objTO.id,gii__Product__c=objProdRef[1].id,gii__Quantity__c=10.00,gii__UnitCost__c=10);
        lstTOLSC.add(objTOline2);
        
        insert lstTOLSC;
         
     }
     public static void toLineCreation(String prodRefId){
         System.debug('In toLineCreation con prodRefId = '+prodRefId);
         lstTOLSC = new  List<gii__TransferOrderLine__c>();
         
        objTOline = new gii__TransferOrderLine__c(gii__TransferOrder__c=objTO.id,gii__Product__c=prodRefId, gii__Quantity__c=1.00,gii__UnitCost__c=10);
        lstTOLSC.add(objTOline);
        
        objTOline2 = new gii__TransferOrderLine__c(gii__TransferOrder__c=objTO.id,gii__Product__c=prodRefId, gii__Quantity__c=10.00,gii__UnitCost__c=10);
        lstTOLSC.add(objTOline2);
        
        insert lstTOLSC;
         
     }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description Insert Multiple TO creation
    */ 
    
    public static void insertTO(){
        lstTO = new List<gii__TransferOrder__c>();
        for(Integer i=0;i<3;i++) {
            lstTO.add(new gii__TransferOrder__c(/*CurrencyIsoCode='USD',*/giic_status__c='Draft',gii__Account__c=objAccountCentral.Id, gii__TransferToWarehouse__c = objWhLocal.Id, gii__FromWarehouse__c=objWh.Id));
        }
        insert lstTO;
    }
    
 
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description TOL creation
    * @param objProdRef product reference
    */
    public static void tOLineCreation(gii__Product2Add__c objProdRef){
        objTOline = new gii__TransferOrderLine__c(gii__TransferOrder__c=objTO.id,gii__Product__c=objProdRef.id,gii__Quantity__c=10.00);
        insert objTOline;
    }
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description TOL creation
    * @param objProdRef product reference
    */
     public static void tOLineCreationLST(List<gii__Product2Add__c> objProdRef){
         lstTOL = new  List<gii__TransferOrderLine__c>();
         for(integer i=0;i<3;i++){
             objTOline = new gii__TransferOrderLine__c(gii__TransferOrder__c=lstTO[i].id,gii__Product__c=objProdRef[0].id,gii__Quantity__c=10.00,gii__UnitCost__c=10);
             lstTOL.add(objTOline);
         }
         
         
         system.debug('lstTOL>>>>'+lstTOL);
         //objTOline2 = new gii__TransferOrderLine__c(gii__TransferOrder__c=objTO.id,gii__Product__c=objProdRef[1].id,gii__Quantity__c=5.00,gii__UnitCost__c=10);
         //lstTOL.add(objTOline2);
         insert lstTOL;
         
     }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 28/08/2019
    * @date Modification dd/mm/yyyy
    * @description To Line creation for serial and non serial product
    * @param objProdRef product reference
    */
    public static void tOLineCreationlistCS(List<gii__Product2Add__c> objProdRef){
         lstTOLCS = new  List<gii__TransferOrderLine__c>();
         objTOline = new gii__TransferOrderLine__c(gii__TransferOrder__c=objTO.id,gii__Product__c=objProdRef[0].id,gii__Quantity__c=10.00,gii__UnitCost__c=10);
         //lstPOLPS
         
         
     }
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description inventory reserevation
    * @param objProdRef product reference
    * @param objPI product inventory
    */
    public static void inventoryReserveCreation(gii__Product2Add__c objProdRef,gii__ProductInventory__c objPI){
        objIR = new gii__InventoryReserve__c(gii__Product__c=objProdRef.id,gii__ProductInventorySequence__c=objPI.id,gii__ReserveQuantity__c=1.00,gii__Warehouse__c=objWh.id,gii__Account__c=objAccountCentral.id,gii__TransferOrder__c=objTO.id,gii__TransferOrderLine__c=objTOline.id   );
        insert objIR;
        
    }
  

    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description receipt queue creation
    * @param pi product inventory
    */
    public static void receiptQCreation(gii__ProductInventory__c pi){
        system.debug('objTO.id::'+objTO.id+'*******'+'objTOline.id:::'+objTOline.id+'orderDateString:::'+orderDateString);
        objRecQueue = New gii__ReceiptQueue__c(gii__InventoryReserveSequence__c=objIR.id,gii__InTransitWarehouse__c=objWhLocal.id,gii__ProductInventorySequence__c=pi.id,gii__TransferOrder__c=objTO.id, gii__TransferOrderLine__c=objTOline.id,gii__OrderType__c='Transfer',gii__ReceiptQuantity__c=100.00,gii__ShippedDate__c=date.valueOf(orderDateString));
        insert objRecQueue;
    }
  
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description Service Appointment creation
    */
    public static void serviceAppointmentCreation(){
    
        objServiceAppointment = New ServiceAppointment(ParentRecordId=objWorkOrder.Id,XC_WorkTypeLabel__c='Installation', Status='New',EarliestStartTime=System.today(),DueDate=System.today(),SchedStartTime=System.today(),SchedEndTime=System.today());
        insert objServiceAppointment;
    }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description Work Type creation
    */
    public static void workTypeCreation(){
    
        objWorkType = New workType(Name='Installation', DurationType='Hours',EstimatedDuration=2.00);
        insert objWorkType;
    }
    
     /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description Work Order creation
    */
    public static void workOrderCreation(){
        Id recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_ESP_WorkOrder').getRecordTypeId();
        objWorkOrder = New WorkOrder(WorkTypeId=objWorkType.Id, RecordTypeId=recordTypeId,AccountId=objAccountSupplier.id,XC_LegalEntity__c='EndesaX',XC_WorkTypeLabel__c='Delivery & Installation - Air Conditioning');
        insert objWorkOrder;
    }
    
    public static void workOrderLineItemCreation(){
         objWorkOrderLineItem = new WorkorderLineItem(WorkOrderId = objWorkOrder.Id);
        
        insert objWorkOrderLineItem;
        
        
    }
    
  
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description Sales Order Creation
    */
    public static void salesOrderCreation(){
        system.debug('@@@@ warehouse:' + objWh.Id);
         system.debug('@@@@ warehouse:' + objAccountCentral.Id);
        objSalesOrder = new gii__SalesOrder__c(gii__Account__c = objAccountCentral.id, gii__OrderType__c='Standard',CurrencyIsoCode ='EUR',gii__Warehouse__c=objWh.id);
        insert objSalesOrder;
    }
    
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description SalesOrderLine Creation
    * @param objProdRef
    */
   public static void salesOrderLineCreation(gii__Product2Add__c objProdRef){
        
        objSalesOrderLine = new gii__SalesOrderLine__c(gii__SalesOrder__c = objSalesOrder.id,gii__Product__c=objProdRef.id,gii__OrderQuantity__c =10);
        insert objSalesOrderLine;
    } 
    
    
    public static void salesOrderLineCreationOne(gii__Product2Add__c objProdRef){
        
        objSalesOrderLine = new gii__SalesOrderLine__c(gii__SalesOrder__c = objSalesOrder.id,gii__Product__c=objProdRef.id,gii__OrderQuantity__c =1,giic_ProductRequiredId__c='PREQ-10');
        insert objSalesOrderLine;
    } 
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description Product Serail Creation
    * @param objProdRef
    */
   public static void productSerailCreation(gii__Product2Add__c objProdRef){
        
        objProductSerial= new gii__ProductSerial__c(Name = 'TUBE1234',gii__Product__c=objProdRef.id);
        insert objProductSerial;
    } 
    
     /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 22/08/2019
    * @date Modification dd/mm/yyyy
    * @description Contract Creation
    */
     public static void contractCreation(){
        RecordType rt = [SELECT Id,name,developerName FROM RecordType WHERE sObjectType = 'Contract' LIMIT 1]; 
        objContract= new Contract(RecordTypeId=rt.Id,AccountId=objAccountSupplier.Id,Status='Draft',XC_LegalEntity__c='EndesaX',XC_CompanyCode__c='7777',StartDate = Date.newInstance(1900, 1, 22),EndDate = Date.newInstance(3000, 1, 22),giic_BudgetConsumption__c=2000,giic_TotalAmount__c=100);
        insert objContract;
        // objContract.Status='Active';
         //update objContract;
    } 
   
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description Price Book Creation
    */
     public static void priceBookCreation(){
        objPriceBook= new gii__PriceBook__c(Name='Test',gii__IsActive__c=true,giic_Contract__c=objContract.Id );
        insert objPriceBook;
    } 
    
    /**
    * @author FirstName : sara.miozza@nttdata.com
    * @date Creation 27/01/2020
    * @date Modification dd/mm/yyyy
    * @description Price Book Creation Duplicate
    */
     public static void priceBookCreationDuplicate(){
        objPriceBookDup= new gii__PriceBook__c(Name='Test2',gii__IsActive__c=true,giic_Contract__c=objContract.Id );
        insert objPriceBookDup;
    } 
    /**
    * @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
    * @date Creation 17/06/2019
    * @date Modification dd/mm/yyyy
    * @description Price Book Entry Creation
    * @param objProdRef
    */
     public static void priceBookEntryCreation(gii__Product2Add__c objProdRef){ 
        objPriceBookEntry= new gii__PriceBookEntry__c(gii__PriceBook__c=objPriceBook.Id,
                                                      gii__Product__c=objProdRef.id,
                                                      CurrencyIsoCode = 'EUR',
                                                      gii__UnitPrice__c=1.0,
                                                      gii__IsActive__c=true,
                                                      giic_CategoryPosition__c = 'K',
                                                      giic_AvgSupplyTime__c=2,
                                                      giic_Default__c=true,
                                                      giic_MinimumOrderQuantity__c = 3
                                                     );
        insert objPriceBookEntry;
    }
     /**
    * @author FirstName : Sara Miozza sara.miozza@nttadat.com
    * @date Creation 24/01/2020
    * @date Modification dd/mm/yyyy
    * @description Price Book Entry Creation
    * @param objProdRef
    */
     public static void priceBookEntryCreation(Id objProdRefId){ 
        objPriceBookEntry= new gii__PriceBookEntry__c(gii__PriceBook__c=objPriceBook.Id,
                                                      gii__Product__c=objProdRefId,
                                                      CurrencyIsoCode = 'EUR',
                                                      gii__UnitPrice__c=1.0,
                                                      gii__IsActive__c=true,
                                                      giic_CategoryPosition__c = 'K');
        insert objPriceBookEntry;
    }
 
    


      /**
* @author FirstName : Patrizia Arcidiacono - patrizia.arcidiacono@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description transferOrderCreation with parameter:
*/
    public static void transferOrderCreationParam(id LWId, id CWId, id AccId){
        Date orderDate = system.today();
        Date requiredDate = system.today().addMonths(1);
        orderDateString = orderDate.year()+'-'+orderDate.month()+'-'+orderDate.day();
        requiredDateString = requiredDate.year()+'-'+requiredDate.month()+'-'+requiredDate.day();
        objTOP = new gii__TransferOrder__c(gii__Account__c=accId,gii__OrderDate__c=date.valueOf(orderDateString),
                                                                gii__RequiredDate__c=date.valueOf(requiredDateString),gii__FromWarehouse__c=CWId,
                                                                gii__TransferToWarehouse__c=LWId);
        
        insert objTOP;
    }  
    
 
     /**
* @author FirstName : Sara Miozza - sara.miozza@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description rma creation
*/
    public static void rmaLineCreation(gii__Product2Add__c objProdRef){
         ObjRMALine = new gii__RMADetail__c( gii__Product__c = objProdRef.Id,
                                                        gii__RMAQuantity__c = 1,
                                                              gii__RMA__c = ObjRMA.Id );
        
        insert ObjRMALine;

    }  
    
        /**
* @author FirstName : Sara Miozza - sara.miozza@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description rma creation
*/
    public static void rmaCreation(){
        ObjRMA = new gii__RMA__c( gii__Account__c = objAccountLocal.Id,
                                              gii__Warehouse__c = objWhLocal.Id,
                                              CurrencyIsoCode = 'EUR');
        
        insert ObjRMA;
    }
/**
* @author FirstName : Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description rma creation
*/
    public static void rmaReceiptCreation(gii__Product2Add__c objProdRef){
          ObjRMAReceipt = new gii__RMAReceipt__c( gii__Product__c = objProdRef.Id,
                                                        gii__ReceiptQuantity__c = 1,
                                                              gii__RMALineDetail__c= objRMALine.id,
                                                              gii__RMA__c = ObjRMA.Id );
        
        insert ObjRMAReceipt;
    }  
    
/**
* @author FirstName : Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description rma creation
*/
    public static void rmaDispositionCreation(gii__Product2Add__c objProdRef){
        
          ObjRMADisposition = new gii__RMADisposition__c( gii__Product__c = objProdRef.Id,
                                                        gii__DispositionQuantity__c = 1,
                                                              gii__Warehouse__c= objRMA.gii__Warehouse__c,
                                                              gii__DispositionLocation__c=objLocationlocalScrap.Id,
                                                              gii__ProductSerial__c =objPS.id,
                                                              gii__RMAReceipt__c = ObjRMAReceipt.Id );
        
        insert ObjRMADisposition;
    }
    
    /**
* @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description rma creation
*/
    public static void purchaseOrderLineCreationOneQty(gii__Product2Add__c objProdRef){
        System.debug('gii__PurchaseOrder__c>>>>>>>>>>' + objPO);
        System.debug('gii__PurchaseOrder__c>>>>>>>>>>' + objProdRef);
        System.debug('objSalesOrderLine>>>>>>>>>>' + objSalesOrderLine);
        objPOLineOneQty = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=objPO.id,gii__Product__c=objProdRef.id, gii__Service__c = objProdRef.gii__Service__c, gii__OrderQuantity__c=1.00,gii__UnitPrice__c=10.00,gii__Calc_LineGrossAmount__c=1);
        System.debug('objPOLine>>>>>>>>>>' + objPOLine);
        insert objPOLineOneQty;
    }
       
}