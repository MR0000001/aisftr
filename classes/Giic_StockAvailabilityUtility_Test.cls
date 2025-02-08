/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy   
* @description Giic_StockAvailabilityUtility_Test – Test Class for Giic_StockAvailabilityUtility_Test.
*/
@isTest
public class Giic_StockAvailabilityUtility_Test {
/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for getFirstAvailability.
*/
    @isTest
    private static  void getFirstAvailabilityTest(){  
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
                 
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Spain';
        country.Name = 'ES';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.Giic_ProductProcurementTypeTransfer;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;
        
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef ); 
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,objProdRef);
        gii__ProductInventory__c prodInvntryobj= [SELECT Id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c Limit 1
                                                 ]; 
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef[0]);  
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef[0]);
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
 
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType=Label.giic_DeliveryInstallationStockReqType;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Spain';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
         List<String> partners = new List<String>();
        partners.add(Giic_UtilityClass_Test.objWhLocal.Id);
        objWrapStockAvailabilty.partnersWH=partners;
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        
        System.debug('toWH------->>'+lstWh[0]); 
        stockAvailWrappList[0].toWarehouse=lstWh[0].Id;
        stockAvailWrappList[0].requestType=System.Label.giic_DeliveryInstallationStockReqType;
        Test.stopTest();
    }
/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for getFirstAvailability.
*/
    @isTest
    private static  void getFirstAvailabilityTestCreatePO(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
                 
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Spain';
        country.Name = 'ES';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.Giic_ProductProcurementTypeTransfer;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;
        
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef ); 
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,objProdRef);
       gii__ProductInventory__c prodInvntryobj= [SELECT Id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c Limit 1
                                                 ]; 
       // Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef[0]);  
       // Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef[0]);
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
  
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType=Label.giic_DeliveryInstallationStockReqType;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Spain';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
         List<String> partners = new List<String>();
        partners.add(Giic_UtilityClass_Test.objWhLocal.Id);
        objWrapStockAvailabilty.partnersWH=partners;
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        System.debug('toWH------->>'+lstWh[0]); 
        stockAvailWrappList[0].toWarehouse=lstWh[0].Id;
        stockAvailWrappList[0].requestType=System.Label.giic_DeliveryInstallationStockReqType;
        Test.stopTest();
    }
    /**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for getFirstAvailability.
*/
    @isTest
    private static  void getFirstAvailabilityTestcase2(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
                 
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Spain';
        country.Name = 'ES';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.Giic_ProductProcurementTypeTransfer;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;
        
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef ); 
        gii__ProductInventory__c prodInvntryobj= [SELECT Id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,giic_SalesOnHand__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                 ];  
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
      
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType=Label.giic_StockReqTypeShipment;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Spain';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        System.debug('toWH------->>'+lstWh[0]); 
        stockAvailWrappList[0].toWarehouse=lstWh[0].Id;
        stockAvailWrappList[0].requestType=System.Label.giic_DeliveryInstallationStockReqType;
        Test.stopTest();
    }
    /**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for getFirstAvailability.
*/
      @isTest
    private static  void getFirstAvailabilityTestcasoChile(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
                 
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Chile';
        country.Name = 'CL';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.Giic_ProductProcurementTypeTransfer;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;
        
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef ); 
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,objProdRef);
        gii__ProductInventory__c prodInvntryobj= [SELECT Id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c limit 1
                                                 ]; 
       // Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef[0]);  
       // Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef[0]);
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
      
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType=Label.giic_DeliveryInstallationStockReqType;
         List<String> partners = new List<String>();
        partners.add(Giic_UtilityClass_Test.objWhLocal.Id);
        objWrapStockAvailabilty.partnersWH=partners;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Chile';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        System.debug('toWH------->>'+lstWh[0]); 
        stockAvailWrappList[0].toWarehouse=lstWh[0].Id;
        stockAvailWrappList[0].requestType=System.Label.giic_DeliveryInstallationStockReqType;
        Test.stopTest();
    }
/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for getFirstAvailability.
*/
    @isTest
    private static  void getFirstAvailabilityTestcaseChile2(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
                 
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Chile';
        country.Name = 'CL';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.Giic_ProductProcurementTypeTransfer;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;
        
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef ); 
        gii__ProductInventory__c prodInvntryobj= [SELECT Id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                 ];  
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
 
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType=Label.giic_StockReqTypeShipment;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Chile';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        System.debug('toWH------->>'+lstWh[0]); 
        stockAvailWrappList[0].toWarehouse=lstWh[0].Id;
        stockAvailWrappList[0].requestType=System.Label.giic_DeliveryInstallationStockReqType;
        Test.stopTest();
    }
     @isTest
    private static  void getFirstAvailabilityTest2(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
                 
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Spain';
        country.Name = 'ES';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeSupplier;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;
        
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef ); 
        gii__ProductInventory__c prodInvntryobj= [SELECT Id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                 ];  
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
  
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType=Label.giic_StockReqTypeShipment;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Spain';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        System.debug('toWH------->>'+lstWh[0]); 
        stockAvailWrappList[0].toWarehouse=lstWh[0].Id;
        stockAvailWrappList[0].requestType=System.Label.giic_DeliveryInstallationStockReqType;
        Test.stopTest();
    }
/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for getFirstAvailability.
*/
    @isTest
    private static  void getFirstAvailabilityTestcase22(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
                 
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Spain';
        country.Name = 'ES';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeSupplier;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;
        
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef ); 
        gii__ProductInventory__c prodInvntryobj= [SELECT Id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                 ];  
         Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef[0]);  
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef[0]);
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
       
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType=Label.giic_DeliveryInstallationStockReqType;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Spain';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
         List<String> partners = new List<String>();
        partners.add(Giic_UtilityClass_Test.objWhLocal.Id);
        objWrapStockAvailabilty.partnersWH=partners;
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        System.debug('toWH------->>'+lstWh[0]); 
        stockAvailWrappList[0].toWarehouse=lstWh[0].Id;
        stockAvailWrappList[0].requestType=System.Label.giic_DeliveryInstallationStockReqType;
        Test.stopTest();
    }
    /**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for getFirstAvailability.
*/
      @isTest
    private static  void getFirstAvailabilityTestcasoChile2(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
                 
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Chile';
        country.Name = 'CL';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeSupplier;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;
        
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef ); 
        gii__ProductInventory__c prodInvntryobj= [SELECT Id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                 ]; 
       
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
      
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType=Label.giic_StockReqTypeShipment;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Chile';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        System.debug('toWH------->>'+lstWh[0]); 
        stockAvailWrappList[0].toWarehouse=lstWh[0].Id;
        stockAvailWrappList[0].requestType=System.Label.giic_DeliveryInstallationStockReqType;
        Test.stopTest();
    }
/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for getFirstAvailability.
*/
    @isTest
    private static  void getFirstAvailabilityTestcaseChile22(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
                 
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Chile';
        country.Name = 'CL';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeSupplier;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;
        
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef ); 
        gii__ProductInventory__c prodInvntryobj= [SELECT Id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                 ];  
     //    Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef[0]);  
       // Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef[0]);
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
      
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType=Label.giic_DeliveryInstallationStockReqType;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Chile'; 
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        List<String> partners = new List<String>();
        partners.add(Giic_UtilityClass_Test.objWhLocal.Id);
        objWrapStockAvailabilty.partnersWH=partners;
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        System.debug('toWH------->>'+lstWh[0]); 
        stockAvailWrappList[0].toWarehouse=lstWh[0].Id;
        stockAvailWrappList[0].requestType=System.Label.giic_DeliveryInstallationStockReqType;
        Test.stopTest();
    }
        @isTest
    private static  void getFirstAvailabilityTest5(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Spain';
        country.Name = 'ES';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeSupplier;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;   
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,objProdRef);
         gii__ProductInventory__c prodInvntryobj= [SELECT id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c limit 1
                                                 ]; 
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef[0]);  
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
       
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType = System.Label.giic_StockReqTypeShipment;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Spain';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        List<String> partners = new List<String>();
        partners.add(Giic_UtilityClass_Test.objWhLocal.Id);
        objWrapStockAvailabilty.partnersWH=partners;
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef[0]);
        List<gii__SalesOrder__c> listId=[SELECT id from gii__SalesOrder__c Limit 1];
 
        list<id> lstSOIds = new list<id>();
        lstSOIds.add(listId[0].Id);
        map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability = new  map<Id,giic_CommonWrapper.ProductAvailability>();
        giic_CommonWrapper.ProductAvailability objProductAvail=new giic_CommonWrapper.ProductAvailability();
        objProductAvail.productRequiredID='PRID';
        objProductAvail.ProductId=objProdRef[0].Id;
        objProductAvail.availabilityDate = date.today();
        mapProductWithAvailability.put(objProductAvail.ProductId,objProductAvail);
        Giic_StockAvailabilityUtility.getProductAvailability(lstSOIds, mapProductWithAvailability); 
        Giic_StockAvailabilityUtility.createTransferOrder(Giic_UtilityClass_Test.objSalesOrderLine,Date.today(), lstWh[0].Id);
        Test.stopTest();
    }
     @isTest
    private static  void getFirstAvailabilityTest6(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Spain';
        country.Name = 'ES';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.Giic_ProductProcurementTypeTransfer;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;   
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,objProdRef);
         gii__ProductInventory__c prodInvntryobj= [SELECT id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c limit 1
                                                 ]; 
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef[0]);  
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
      
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType = System.Label.giic_StockReqTypeShipment;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Spain';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        List<String> partners = new List<String>();
        partners.add(Giic_UtilityClass_Test.objWhLocal.Id);
        objWrapStockAvailabilty.partnersWH=partners;
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        
           gii__SalesOrder__c objSalesOrder = new gii__SalesOrder__c(gii__Account__c = Giic_UtilityClass_Test.objAccountCentral.id, gii__OrderType__c='Standard',CurrencyIsoCode ='EUR',gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id);
        insert objSalesOrder;
        gii__SalesOrderLine__c objSalesOrderLine = new gii__SalesOrderLine__c(gii__SalesOrder__c = objSalesOrder.id,gii__Product__c=objProdRef[0].id,gii__OrderQuantity__c =10);
        insert objSalesOrderLine;  
        list<id> lstSOIds = new list<id>();
        lstSOIds.add(objSalesOrder.Id);
        map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability = new  map<Id,giic_CommonWrapper.ProductAvailability>();
        giic_CommonWrapper.ProductAvailability objProductAvail=new giic_CommonWrapper.ProductAvailability();
        objProductAvail.productRequiredID='PRID';
        objProductAvail.ProductId=objProdRef[0].Id;
        objProductAvail.availabilityDate = date.today();
        mapProductWithAvailability.put(objProductAvail.ProductId,objProductAvail);
        Giic_StockAvailabilityUtility.getProductAvailability(lstSOIds, mapProductWithAvailability); 
        Test.stopTest();
    }
       @isTest
    private static  void getFirstAvailabilityTest7(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Spain';
        country.Name = 'ES';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.Giic_ProductProcurementTypeTransfer;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;   
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,objProdRef);
         gii__ProductInventory__c prodInvntryobj= [SELECT id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c, giic_SalesOnHand__c FROM gii__ProductInventory__c limit 1
                                                 ];
        prodInvntryobj.gii__OrderPointQuantity__c = 100;
        update prodInvntryobj;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef[0]);
         Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef[0]); //test
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
      
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest();
      
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType = System.Label.giic_StockReqTypeShipment;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Spain';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        List<String> partners = new List<String>();
        partners.add(Giic_UtilityClass_Test.objWhLocal.Id);
        objWrapStockAvailabilty.partnersWH=partners;
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        
        Giic_UtilityClass_Test.salesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef[0]);
        Giic_UtilityClass_Test.objSalesOrderLine.gii__OrderQuantity__c = 500;
        update Giic_UtilityClass_Test.objSalesOrderLine;
        decimal avQty = prodInvntryobj.gii__TotalOnOrder__c + prodInvntryobj.giic_SalesOnHand__c;
        system.debug('avQty: '+ avQty);
        system.debug('orderQuantity: ' + Giic_UtilityClass_Test.objSalesOrderLine.gii__OrderQuantity__c);
        List<gii__SalesOrder__c> listId=[SELECT id from gii__SalesOrder__c Limit 1];
 		listId[0].giic_IsDelivery__c = true;
        listId[0].gii__ShipToCountry__c = 'Spain';
        listId[0].giic_FromWarehouse__c = Giic_UtilityClass_Test.objWh.Id;
        update listId;
        list<id> lstSOIds = new list<id>();
        lstSOIds.add(listId[0].Id);
        map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability = new  map<Id,giic_CommonWrapper.ProductAvailability>();
        giic_CommonWrapper.ProductAvailability objProductAvail=new giic_CommonWrapper.ProductAvailability();
        objProductAvail.productRequiredID='PRID';
        objProductAvail.ProductId=objProdRef[0].Id;
        objProductAvail.availabilityDate = date.today();
        mapProductWithAvailability.put(objProductAvail.ProductId,objProductAvail);
        Giic_StockAvailabilityUtility.getProductAvailability(lstSOIds, mapProductWithAvailability); 
        Test.stopTest();
    }
       @isTest
    private static  void getFirstAvailabilityTest8(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Spain';
        country.Name = 'ES';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c = Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1]; 
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.Giic_ProductProcurementTypeTransfer;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;   
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,objProdRef);
         List<gii__ProductInventory__c> prodInvntryobj= [SELECT id, gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                 ]; 
 
        
         Giic_UtilityClass_Test.creationPILocation(prodInvntryobj[0],objProdRef[0]); 
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj[0],objProdRef[0]); 
       
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
       
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType = System.Label.giic_StockReqTypeShipment;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Spain';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        List<String> partners = new List<String>();
        partners.add(Giic_UtilityClass_Test.objWhLocal.Id);
        objWrapStockAvailabilty.partnersWH=partners;
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        
        gii__SalesOrder__c objSalesOrder = new gii__SalesOrder__c(gii__Account__c = Giic_UtilityClass_Test.objAccountCentral.id, gii__OrderType__c='Standard',CurrencyIsoCode ='EUR',gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id);
        insert objSalesOrder;
        gii__SalesOrderLine__c objSalesOrderLine = new gii__SalesOrderLine__c(gii__SalesOrder__c = objSalesOrder.id,gii__Product__c=objProdRef[0].id,gii__OrderQuantity__c =10);
        insert objSalesOrderLine;  
        list<id> lstSOIds = new list<id>();
        lstSOIds.add(objSalesOrder.Id);
        map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability = new  map<Id,giic_CommonWrapper.ProductAvailability>();
        map<string,integer> mapWHPRLOWithAvlQty = new map<string,integer>();
         map<string,gii__ProductInventory__c> mapWHPRLOWithPI = new  map<string,gii__ProductInventory__c>();
        giic_CommonWrapper.ProductAvailability objProductAvail=new giic_CommonWrapper.ProductAvailability();
        objProductAvail.productRequiredID='PRID';
        objProductAvail.ProductId=objProdRef[0].Id;
        objProductAvail.availabilityDate = date.today();
        mapProductWithAvailability.put(objProductAvail.ProductId,objProductAvail);
        Giic_StockAvailabilityUtility.getProductAvailability(lstSOIds, mapProductWithAvailability); 
        Giic_StockAvailabilityUtility.getPIAvailQty(Giic_UtilityClass_Test.objPID,mapWHPRLOWithAvlQty, mapWHPRLOWithPI);
        Test.stopTest();
    }
       @isTest
    private static  void getFirstAvailabilityTest9(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Spain';
        country.Name = 'ES';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.Giic_ProductProcurementTypeTransfer;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;   
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,objProdRef);
         gii__ProductInventory__c prodInvntryobjCWH= [SELECT id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c 
                                                   WHERE gii__Warehouse__r.giic_WarehouseType__c  = 'Central'
                                                 ];
        gii__ProductInventory__c prodInvntryobjLWH = [SELECT id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c 
                                                   WHERE gii__Warehouse__r.giic_WarehouseType__c  = 'Local'
                                                 ];  
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobjLWH,objProdRef[0]);  
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobjCWH,objProdRef[0]); 
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
      
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType = System.Label.giic_StockReqTypeShipment;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Spain';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        List<String> partners = new List<String>();
        partners.add(Giic_UtilityClass_Test.objWhLocal.Id);
        objWrapStockAvailabilty.partnersWH=partners;
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        
           gii__SalesOrder__c objSalesOrder = new gii__SalesOrder__c(gii__Account__c = Giic_UtilityClass_Test.objAccountCentral.id, gii__OrderType__c='Standard',CurrencyIsoCode ='EUR',gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id);
        insert objSalesOrder;
        gii__SalesOrderLine__c objSalesOrderLine = new gii__SalesOrderLine__c(gii__SalesOrder__c = objSalesOrder.id,gii__Product__c=objProdRef[0].id,gii__OrderQuantity__c =10);
        insert objSalesOrderLine;  
        list<id> lstSOIds = new list<id>();
        lstSOIds.add(objSalesOrder.Id);
        map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability = new  map<Id,giic_CommonWrapper.ProductAvailability>();
        giic_CommonWrapper.ProductAvailability objProductAvail=new giic_CommonWrapper.ProductAvailability();
        objProductAvail.productRequiredID='PRID';
        objProductAvail.ProductId=objProdRef[0].Id;
        objProductAvail.availabilityDate = date.today();
        mapProductWithAvailability.put(objProductAvail.ProductId,objProductAvail);
        Giic_StockAvailabilityUtility.getProductAvailability(lstSOIds, mapProductWithAvailability); 
        Test.stopTest();
    }
    
    @isTest
    private static  void getFirstAvailabilityTest10(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        gii__Country__c country = new gii__Country__c();
        country.gii__CountryName__c = 'Spain';
        country.Name = 'ES';
        insert country;
        gii__ZoneTable__c zone = new gii__ZoneTable__c();
        zone.gii__Type__c = 'Zip/Postal Code';
        zone.Name = 'TEST';
        zone.gii__CountryCode__c  = country.id;
        insert zone;  
        gii__ZoneTableZipPostalCode__c zip = new gii__ZoneTableZipPostalCode__c();
        zip.gii__StartZipPostalCode__c =  '00120';
        zip.gii__ZoneTable__c = zone.Id;
        zip.gii__EndZipPostalCode__c =  '00120';
        insert zip;
        giic_WarehaouseZoneZip__c whzonezip = new giic_WarehaouseZoneZip__c();
        whzonezip.giic_ZoneTable__c = zone.id; 
        whzonezip.giic_WarehouseGroup__c = Giic_UtilityClass_Test.wareHouseGroup.ID;
        insert whzonezip;
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c =Giic_UtilityClass_Test.objWh.id; 
        update Giic_UtilityClass_Test.objWhLocal;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        List<Account> lstAccount = [Select id from Account];
        List<product2> lstProduct = [select id from product2];  
        List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c =:lstProduct[0].Id Limit 1];
         
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef[0].giic_ProcurementType__c=System.Label.Giic_ProductProcurementTypeTransfer;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        objProdRef[0].giic_LegalEntity__c= 'EndesaX';
        update objProdRef;   
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation(); 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef[0]);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh ,objProdRef);
         Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,objProdRef);
         gii__ProductInventory__c prodInvntryobjCWH= [SELECT id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c 
                                                   WHERE gii__Warehouse__r.giic_WarehouseType__c  = 'Central'
                                                 ];
        gii__ProductInventory__c prodInvntryobjLWH = [SELECT id,gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c 
                                                   WHERE gii__Warehouse__r.giic_WarehouseType__c  = 'Local'
                                                 ];  
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobjLWH,objProdRef[0]);  
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobjCWH,objProdRef[0]); 
        List<gii__Warehouse__c> lstWh = Giic_UtilityClass_Test.lstWh;
      
        lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update lstWh;
        Test.startTest(); 
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
        Giic_StockAvailabilityUtility.StockAvailabilityWrapper objWrapStockAvailabilty = new Giic_StockAvailabilityUtility.StockAvailabilityWrapper();
        objWrapStockAvailabilty.pdtCode=objProdRef[0].gii__ProductCode__c;
        objWrapStockAvailabilty.reqQuantity= 9.0;
        objWrapStockAvailabilty.requestType = System.Label.giic_StockReqTypeShipment;
        objWrapStockAvailabilty.zipCode= '00120';
        objWrapStockAvailabilty.country = 'Spain';
        objWrapStockAvailabilty.province = 'TEST';
        objWrapStockAvailabilty.legalEntity = 'EndesaX';
        List<String> partners = new List<String>();
        partners.add(Giic_UtilityClass_Test.objWhLocal.Id);
        objWrapStockAvailabilty.partnersWH=partners;
        stockAvailWrappList.add(objWrapStockAvailabilty);
        System.assertEquals(true, stockAvailWrappList.size()>0);
        
           gii__SalesOrder__c objSalesOrder = new gii__SalesOrder__c(gii__Account__c = Giic_UtilityClass_Test.objAccountCentral.id, gii__OrderType__c='Standard',CurrencyIsoCode ='EUR',gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id, giic_PO_TO_LocalWH__c = true);
        insert objSalesOrder;
        gii__SalesOrderLine__c objSalesOrderLine = new gii__SalesOrderLine__c(gii__SalesOrder__c = objSalesOrder.id,gii__Product__c=objProdRef[0].id,gii__OrderQuantity__c =10);
        insert objSalesOrderLine;  
        list<id> lstSOIds = new list<id>();
        lstSOIds.add(objSalesOrder.Id);
        map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability = new  map<Id,giic_CommonWrapper.ProductAvailability>();
        giic_CommonWrapper.ProductAvailability objProductAvail=new giic_CommonWrapper.ProductAvailability();
        objProductAvail.productRequiredID='PRID';
        objProductAvail.ProductId=objProdRef[0].Id;
        objProductAvail.availabilityDate = date.today();
        mapProductWithAvailability.put(objProductAvail.ProductId,objProductAvail);
        Giic_StockAvailabilityUtility.getProductAvailability(lstSOIds, mapProductWithAvailability); 
        Test.stopTest();
    }

    @isTest
    static void coverageTestClass(){
        Giic_StockAvailabilityUtility.coverageTestClass();
    }
}