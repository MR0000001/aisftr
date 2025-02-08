/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
* @date Creation 29/11/2019
* @description Giic_DF_Glovia – Data Factory for Glovia Sobject
*/
@isTest
public class Giic_DF_Glovia {
     /**
    * @description system policy record
    */
    public static gii__SystemPolicy__c objSystemPolicy;
    /**
    * @description glovia system settings record
    */
    public static gii__GloviaSystemSetting__c objGCS;
     /** @author FirstName : Anil Giri- Anil .Giri@in.fujitsu.com
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
    }
    
    public static gii__SalesOrder__c createSalesOrder(){
        gii__WarehouseGroup__c wareHouseG = new gii__WarehouseGroup__c(Name='Test-GloviaNetwork');
        insert wareHouseG;
        Account a = XC_DF_Account.insertPartnerAccounts(1)[0];
        gii__Warehouse__c wa = new gii__Warehouse__c(Name = 'Central Warehouse2',
                                      giic_WarehouseType__c='Central',
                                      giic_StorageCapacity__c=400000,
                                      gii__Account__c = a.Id, 
                                      gii__WarehouseGroup__c = wareHouseG.Id,
                                      giic_WarehouseCode__c = 'CW2',
                                      giic_warehousecountryPick__c = 'Spain',
                                      giic_LegalEntity__c = 'EnelX'               
                                      );
        insert wa;
        
        gii__SalesOrder__c so = new gii__SalesOrder__c(gii__Account__c = a.Id, gii__Warehouse__c=wa.Id);
        return so;
        
    }
    
    public static gii__SalesOrderLine__c createSalesOrderLine(gii__SalesOrder__c so){
        gii__Product2Add__c p2a = createProductReference();
        gii__ProductInventory__c pi = createProductInventory(so.gii__Warehouse__c,p2a.Id);
        insert pi;
        gii__SalesOrderLine__c sol = new gii__SalesOrderLine__c(gii__SalesOrder__c=so.Id, gii__Warehouse__c=so.gii__Warehouse__c, gii__ProductInventory__c=pi.Id, gii__Product__c=p2a.Id , gii__OrderQuantity__c=3);
        return sol;
        
    }
    
    
    public static List<gii__SalesOrderLine__c> createSalesOrderLineList(gii__SalesOrder__c so,gii__Product2Add__c p2a, gii__ProductInventory__c pi){
        
        
        gii__SalesOrderLine__c sol = new gii__SalesOrderLine__c(gii__SalesOrder__c=so.Id, gii__Warehouse__c=so.gii__Warehouse__c, gii__ProductInventory__c=pi.Id, gii__Product__c=p2a.Id , gii__OrderQuantity__c=3);
        List<gii__SalesOrderLine__c> solList = new List<gii__SalesOrderLine__c>();
        solList.add(sol);
        return solList;
        
    }
    
    
    
    public static gii__ProductInventory__c createProductInventory(Id warehouseId, Id prodRefId){
        
        gii__ProductInventory__c p = new gii__ProductInventory__c(gii__Warehouse__c = warehouseId,gii__Product__c=prodRefId,gii__OrderPointQuantity__c=1 );
        return p;
    }
    
    public static gii__Product2Add__c createProductReference(){
        Product2 p = new Product2(Name = 'Tube Light', CurrencyIsoCode='EUR',IsActive=true,ProductCode='1234', giic_LegalEntity__c = 'EnelX'); 
        insert p;
        List<gii__Product2Add__c> p2List = [SELECT Id FROM gii__Product2Add__c];
        System.debug('aaaaaaaaa = '+p2List);
      
        return p2List[0];
    }
     public static gii__Product2Add__c createProductReference2(){
        Product2 p = new Product2(Name = 'Boiler', CurrencyIsoCode='EUR',IsActive=true,ProductCode='45678'); 
        insert p;
        List<gii__Product2Add__c> p2List = [SELECT Id FROM gii__Product2Add__c];
        System.debug('aaaaaaaaa = '+p2List);
      
        return p2List[0];
    }
    
    public static gii__PurchaseOrder__c createPurchaseOrder(){      
        Date newDeliveryDate = system.today();
        Account a = XC_DF_Account.insertPartnerAccounts(1)[0];
        Contract objContract= new Contract(AccountId=a.Id,Status='Draft',XC_CompanyCode__c='7777',StartDate = Date.newInstance(1900, 1, 22),EndDate = Date.newInstance(3000, 1, 22));
        insert objContract;
        gii__PriceBook__c priceBook= new gii__PriceBook__c(Name='Testtt',gii__IsActive__c=true,giic_Contract__c=objContract.Id );
        insert priceBook;
        gii__WarehouseGroup__c wareHouseG = new gii__WarehouseGroup__c(Name='Test-GloviaNetwork2');
        insert wareHouseG;
        gii__Warehouse__c wa = new gii__Warehouse__c(Name = 'Central Warehouse3',
                                      giic_WarehouseType__c='Central',
                                      giic_StorageCapacity__c=400000,
                                      gii__Account__c = a.Id, 
                                      gii__WarehouseGroup__c = wareHouseG.Id,
                                      giic_WarehouseCode__c = 'CW3',
                                      giic_warehousecountryPick__c = 'Spain',
                                      giic_LegalEntity__c = 'EnelX'               
                                      );
        insert wa;
        gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__Supplier__c = a.Id, 
                                          gii__ShipTo__c = wa.id,
                                          gii__Approved__c=true,
                                          giic_Status__c='Open',
                                          giic_PriceBookId__c = priceBook.Id);
        return objPO;
        
    }
    
    public static gii__PurchaseOrderLine__c createPurchaseOrderLine(gii__PurchaseOrder__c po){
      
      gii__Product2Add__c prodRef = createProductReference();
      gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=po.id,gii__Product__c=prodRef.id,gii__OrderQuantity__c=100.00,gii__UnitPrice__c=10.00);
      System.debug('objPOLine>>>>>>>>>>' + objPOLine);
      return objPOLine;
    }

}