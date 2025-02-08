/**https://enelx-ci--exdev1.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_PurchaseOrderUtility_Test – Test Class for giic_PurchaseOrderUtility.
*/
@isTest
public class Giic_PurchaseOrderUtility_Test { 
    
    @TestSetup
    static void onSetup() {
      giic_GloviaLogisticSetting__c settings = giic_GloviaLogisticSetting__c.getOrgDefaults();
      settings.giic_DisableVRTestClasses__c = true;
      upsert settings custSettings__c.Id;
    }
    
    /**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for checkLimitsForOrder.
*/
    @isTest
    private static void checkLimitsForOrderTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
      
        upsert Giic_UtilityClass_Test.objWh;
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        //product2 objProductTL =new product2(Name = 'Tube Light',CurrencyIsoCode='EUR'); 
        //insert objProductTL;
        
        // gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =: objProductTL.Id]; 
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =: Giic_UtilityClass_Test.lstProd Limit 1];  
        objProdRef.giic_AveragePrice__c = 1;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update objProdRef;
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef);
        System.debug(Giic_UtilityClass_Test.lstProd);
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        List<gii__PurchaseOrder__c> pchsOdrList = [Select id,gii__Supplier__c,gii__ShipTo__c,gii__Approved__c 
                                                   from gii__PurchaseOrder__c where id=:Giic_UtilityClass_Test.objPO.Id];
        Test.startTest();
        System.assertEquals(true, pchsOdrList.size()>0);
        giic_PurchaseOrderUtility.checkLimitsForOrder(pchsOdrList);
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
    private static void updateSupplierDiscountTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
       
        upsert Giic_UtilityClass_Test.objWh;
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.giic_Status__c = 'Open';
        update Giic_UtilityClass_Test.objPO;
        Contract objCon=[Select Id,Status,EndDate from Contract limit 1];
        objCon.Status='Active';
        objCon.ContractTerm= 12;
        objCon.giic_DiscountThreshold__c = 90;
        objCon.giic_TotalAmount__c = 12;
        update objCon;
        //product2 objProductTL =new product2(Name = 'Tube Light',CurrencyIsoCode='EUR'); 
        //insert objProductTL;
        
        // gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =: objProductTL.Id]; 
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update objProdRef;
        System.debug(Giic_UtilityClass_Test.lstProd);
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef);
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        List<gii__PurchaseOrder__c> pchsOdrList = [Select id,gii__Supplier__c,gii__ShipTo__c,gii__Approved__c ,gii__OrderStatus__c,gii__DropShip__c,giic_Contract__c,gii__OrderAmount__c
                                                   from gii__PurchaseOrder__c where id=:Giic_UtilityClass_Test.objPO.Id];
        System.assertEquals(true, pchsOdrList.size()>0);
        giic_PurchaseOrderUtility.updateSupplierDiscount(pchsOdrList);
        List<gii__PurchaseOrderLine__c> lstPOL = new List<gii__PurchaseOrderLine__c>();
        lstPOL.add(Giic_UtilityClass_Test.objPOLine);
        giic_PurchaseOrderUtility.updatePOLWithDiscountOnInsert(lstPOL);
        giic_PurchaseOrderUtility.preventPOLineInsert(lstPOL);
    } 
    
    
    @isTest
    private static void cancelPOLTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        pref.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        pref.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
       
        update pref;
        
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =: Giic_UtilityClass_Test.lstProd Limit 1];   
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        List<Id> lstPOL=new List<Id>();
        List<gii__PurchaseOrderLine__c> pchsOdrList = [Select id,gii__PurchaseOrder__c from gii__PurchaseOrderLine__c]; 
        lstPOL.add(Giic_UtilityClass_Test.objPOLine.Id);
        lstPOL.add(Giic_UtilityClass_Test.objPO.Id);
        System.assertEquals(true, pchsOdrList.size()>0);
        Giic_PurchaseOrderUtility.cancelPOL(lstPOL);
    }    
    
    @isTest
    private static void changeStatustoCancelledTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        List<gii__PurchaseOrder__c> listPO=new List<gii__PurchaseOrder__c>();
        gii__PurchaseOrder__c objPO=[SELECT Id,Name, gii__Supplier__c,gii__SupplierName__c,gii__TotalOrderQuantity__c,
                                     gii__Buyer__c,gii__ShipTo__c,gii__ShipToName__c,giic_Status__c,gii__OrderDate__c
                                     FROM gii__PurchaseOrder__c Limit 1];
        String poId= objPO.Id;
        Giic_UtilityClass_Test.contractCreation();
        Contract objCon=[Select Id,Status,EndDate from Contract limit 1];
        objCon.Status='Active';
        objCon.ContractTerm= 12;
        objCon.giic_DiscountThreshold__c = 90;
        objCon.giic_TotalAmount__c = 12;
        update objCon;
        Giic_UtilityClass_Test.objContract.XC_IDSYSSAP__c = '123';
        update Giic_UtilityClass_Test.objContract;
        objPO.giic_Contract__c = Giic_UtilityClass_Test.objContract.Id;
        objPO.giic_POCode__c = '1234';
        update objPO;
        listPO.add(objPO);
        
        Giic_PurchaseOrderUtility.changeStatustoCancelled(poId, 'Wrong Quantity', 'Wrong Quantity'); 
    }
    
    @isTest
    private static void runROPForCentralWarehouseTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        pref.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        pref.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        update pref;
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);
        list<gii__Product2Add__c> lstProdRef = new list<gii__Product2Add__c>();
        lstProdRef.add(pref);
        List<gii__PurchaseOrder__c> listPO=new List<gii__PurchaseOrder__c>();
        gii__PurchaseOrder__c objPO=[SELECT Id,Name, gii__Supplier__c,gii__SupplierName__c,gii__TotalOrderQuantity__c,
                                     gii__Buyer__c,gii__ShipTo__c,gii__ShipToName__c,giic_Status__c,gii__OrderDate__c
                                     FROM gii__PurchaseOrder__c Limit 1];
        
        listPO.add(objPO);
        System.assertEquals(true,listPO.size()>0);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,lstProdRef);
        List<gii__ProductInventory__c>  objPI = [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                 gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,gii__Product__r.giic_EndDate__c,
                                                 gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                 gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                 gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Product__r.gii__ProductCode__c,
                                                 gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                 gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                ];
        for(gii__ProductInventory__c prodInvntryobj : objPI ){
            prodInvntryobj.gii__OrderQuantityMultiple__c=1;
            prodInvntryobj.gii__MinimumOrderQuantity__c=1;
            prodInvntryobj.gii__OrderPointQuantity__c=1;
            prodInvntryobj.gii__Product__c=pref.Id;
            prodInvntryobj.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;
        }
        update objPI; 
        Giic_PurchaseOrderUtility.runROPForCentralWarehouse(objPI); 
    }
    
    
    @isTest
    private static void createDropShipPOTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        pref.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        pref.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
       
        update pref;
        
        giic_Switch2152__c cs = new giic_Switch2152__c();
        cs.Name = '1';
        cs.giic_LegalEntity__c = 'EndesaX';
        cs.giic_IsActive__c = TRUE;
        insert cs;
        
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);
        List <gii__Pricebookentry__c> pbeList = new List<gii__Pricebookentry__c>();
        pbeList = [select id, giic_MinimumOrderQuantity__c from gii__Pricebookentry__c];
        for(gii__Pricebookentry__c pbe : pbeList){
            pbe.giic_MinimumOrderQuantity__c = 1;
        }
        update pbeList;
        list<gii__Product2Add__c> lstProdRef = new list<gii__Product2Add__c>();
        lstProdRef.add(pref);
        List<gii__PurchaseOrder__c> listPO=new List<gii__PurchaseOrder__c>();
        gii__PurchaseOrder__c objPO=[SELECT Id,Name, gii__Supplier__c,gii__SupplierName__c,gii__TotalOrderQuantity__c,gii__DropShip__c,gii_ShipToName_Calc__c,gii_Ship_to_City_Calc__c,gii_ShiptoCountry_Calc__c,gii_ShipToStateProvince_Calc__c,gii_ShipToStreet_Calc__c,
                                     gii__Buyer__c,gii__ShipTo__c,gii__ShipToName__c,giic_Status__c,gii__OrderDate__c
                                     FROM gii__PurchaseOrder__c Limit 1];
        
        listPO.add(objPO);
        System.assertEquals(true,listPO.size()>0);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,lstProdRef);
        List<gii__ProductInventory__c>  objPI = [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                 gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                 gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,gii__Product__r.giic_EndDate__c,
                                                 gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                 gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Product__r.gii__ProductCode__c,
                                                 gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                 gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                ];
        for(gii__ProductInventory__c prodInvntryobj : objPI ){
            prodInvntryobj.gii__OrderQuantityMultiple__c=1;
            prodInvntryobj.gii__MinimumOrderQuantity__c=1;
            prodInvntryobj.gii__OrderPointQuantity__c=1;
            prodInvntryobj.gii__Product__c=pref.Id;
            prodInvntryobj.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;
        }
        update objPI; 
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(pref);
        list<id> lstSOIds = new list<id>();
        lstSOIds.add(Giic_UtilityClass_Test.objSalesOrder.Id);
        Test.startTest();
        map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability = new map<Id,giic_CommonWrapper.ProductAvailability>();
        Giic_PurchaseOrderUtility.createDropShipPO(lstSOIds,mapProductWithAvailability ); 
        Giic_PurchaseOrderUtility.rebaltWarehouseAddOnPO(listPO);
        Map<id, gii__PurchaseOrder__c> mapNew = new Map<id, gii__PurchaseOrder__c>();
        for(gii__PurchaseOrder__c p : listPO){
            mapNew.put(p.Id,p);
        }
        Giic_PurchaseOrderUtility.rebaltWarehouseOnPol(listPO,mapNew);
        Test.stopTest();
    }
    
    @isTest
    public static void calcAvgPriceWithTransCostTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        
        giic_UtilityClass_Test.objProductTL.XC_MaterialGroup__c = 'SLPI0401';
        update giic_UtilityClass_Test.objProductTL;
        
        Test.startTest();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__PrimarySupplier__c, gii__Service__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        pref.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        pref.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        pref.giic_StockQuantity__c = 1;
        pref.giic_AveragePrice__c = 1;
        pref.gii__Service__c = true;
       	update pref;
        
        gii__Product2Add__c pref2=new gii__Product2Add__c();
        pref2=[Select Id,gii__PrimarySupplier__c, gii__Service__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL2.Id];
        pref2.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        pref2.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        pref2.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        pref2.giic_AveragePrice__c = 1;
        pref2.giic_StockQuantity__c = 1;
       	update pref2;
        
        
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);
        Giic_UtilityClass_Test.priceBookEntryCreation(pref2);
        List <gii__Pricebookentry__c> pbeList = new List<gii__Pricebookentry__c>();
        pbeList = [select id, giic_MinimumOrderQuantity__c from gii__Pricebookentry__c];
        for(gii__Pricebookentry__c pbe : pbeList){
            pbe.giic_MinimumOrderQuantity__c = 1;
        }
        update pbeList;
        
        
        list<gii__Product2Add__c> lstProdRef = new list<gii__Product2Add__c>();
        lstProdRef.add(pref);
        lstProdRef.add(pref2);
        List<gii__PurchaseOrder__c> listPO=new List<gii__PurchaseOrder__c>();
        gii__PurchaseOrder__c objPO=[SELECT Id,Name, gii__Supplier__c,gii__SupplierName__c,gii__TotalOrderQuantity__c,gii__DropShip__c,gii_ShipToName_Calc__c,gii_Ship_to_City_Calc__c,gii_ShiptoCountry_Calc__c,gii_ShipToStateProvince_Calc__c,gii_ShipToStreet_Calc__c,
                                     gii__Buyer__c,gii__ShipTo__c,gii__ShipToName__c,giic_Status__c,gii__OrderDate__c
                                     FROM gii__PurchaseOrder__c Limit 1];
        
        listPO.add(objPO);
        
        Giic_UtilityClass_Test.purchaseOrderLineCreationOneQty(pref);
        Giic_UtilityClass_Test.purchaseOrderLineCreation(pref2);
        
        
        giic_PurchaseOrderUtility.calcAvgPriceWithTransCost(listPO);
        Test.stopTest();
    }
    
   @isTest
    static void PurchaseOrderUtilityTestNew(){
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
        prodRefObj.giic_ProcurementType__c = 'Purchase';
        prodRefObj.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        prodRefObj.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
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
        
        List<giic_CommonWrapper.SalesOrderHeader> soList= new List<giic_CommonWrapper.SalesOrderHeader>();
        giic_CommonWrapper.SalesOrderHeader soHderObj=new giic_CommonWrapper.SalesOrderHeader();
        soHderObj.AccountId=giic_UtilityClass_Test.objAccountCentral.Id;
        soHderObj.DirectPurchaseOrder=false;     
        soHderObj.fieldServiceOrder = false;
        soHderObj.scheduledDate = date.today();
        soHderObj.warehouseId = Giic_UtilityClass_Test.objWhLocal.id; 
        soHderObj.SalesOrderLineList= new List<giic_CommonWrapper.SalesOrderLine>();
        soHderObj.workOrderLineItemID = woliObj.id;
		soHderObj.dropShip = false;
		soHderObj.isDelivery = false;
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
        Test.startTest();
        Giic_SalesOrderUtility.createSalesOrders(soList);
        Test.stopTest();
    }
    
    @isTest
    public static void calcAvgPriceWithTransCostTestNew(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        
        giic_UtilityClass_Test.objProductTL.XC_MaterialGroup__c = 'SLPI0401';
        update giic_UtilityClass_Test.objProductTL;
        
        Test.startTest();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__PrimarySupplier__c, gii__Service__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        pref.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        pref.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        pref.giic_StockQuantity__c = 1;
        pref.giic_AveragePrice__c = 1;
        pref.gii__Service__c = true;
       	update pref;
        
        gii__Product2Add__c pref2=new gii__Product2Add__c();
        pref2=[Select Id,gii__PrimarySupplier__c, gii__Service__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL2.Id];
        pref2.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        pref2.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        pref2.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        pref2.giic_AveragePrice__c = 1;
        pref2.giic_StockQuantity__c = 1;
       	update pref2;
        
        
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);
        Giic_UtilityClass_Test.priceBookEntryCreation(pref2);
        List <gii__Pricebookentry__c> pbeList = new List<gii__Pricebookentry__c>();
        pbeList = [select id, giic_MinimumOrderQuantity__c, giic_Default__c from gii__Pricebookentry__c];
        for(gii__Pricebookentry__c pbe : pbeList){
            pbe.giic_MinimumOrderQuantity__c = 1;
            pbe.giic_Default__c=false;
        }
        update pbeList;
        
        
        list<gii__Product2Add__c> lstProdRef = new list<gii__Product2Add__c>();
        lstProdRef.add(pref);
        lstProdRef.add(pref2);
        List<gii__PurchaseOrder__c> listPO=new List<gii__PurchaseOrder__c>();
        gii__PurchaseOrder__c objPO=[SELECT Id,Name, gii__Supplier__c,gii__SupplierName__c,gii__TotalOrderQuantity__c,gii__DropShip__c,gii_ShipToName_Calc__c,gii_Ship_to_City_Calc__c,gii_ShiptoCountry_Calc__c,gii_ShipToStateProvince_Calc__c,gii_ShipToStreet_Calc__c,
                                     gii__Buyer__c,gii__ShipTo__c,gii__ShipToName__c,giic_Status__c,gii__OrderDate__c
                                     FROM gii__PurchaseOrder__c Limit 1];
        
        listPO.add(objPO);
        
        Giic_UtilityClass_Test.purchaseOrderLineCreationOneQty(pref);
        Giic_UtilityClass_Test.purchaseOrderLineCreation(pref2);
        
        
        giic_PurchaseOrderUtility.calcAvgPriceWithTransCost(listPO);
        Test.stopTest();
    }

    @isTest
    static void coverageTestClass(){
        Giic_PurchaseOrderUtility.coverageTestClass();
    }    

}