@isTest(SeeAllData=false)
public class Giic_InventoryUtility_D_Test {

    public static testMethod void testReceiveData(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        update Giic_UtilityClass_Test.objPO;
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c Limit 1
                                         ];
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountLocal.Id;
        update objProdRef;
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
         Test.startTest();
        Giic_UtilityClass_Test.pOReceipt(); 
        //Giic_UtilityClass_Test.pOReceiptLine();
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.objTO.giic_Status__c='Open';
        Giic_UtilityClass_Test.objTO.giic_Approved__c=true;
        update Giic_UtilityClass_Test.objTO;
        Giic_UtilityClass_Test.tOLineCreation(objProdRef);
        map<string,gii__TransferOrder__c> mapTO= new map<string,gii__TransferOrder__c> ();
        gii__TransferOrder__c objTo=new gii__TransferOrder__c(gii__Account__c=Giic_UtilityClass_Test.objAccountCentral.Id, gii__TransferToWarehouse__c = Giic_UtilityClass_Test.objWhLocal.Id, 
                                                              gii__FromWarehouse__c=Giic_UtilityClass_Test.objWh.Id);
        mapTO.put('key',objTo);
        map<string,List<gii__TransferOrderLine__c>> mapTOLine = new map<string,List<gii__TransferOrderLine__c>>();
        gii__TransferOrderLine__c objTOline = new gii__TransferOrderLine__c(gii__Product__c=objProdRef.id,gii__Quantity__c=10.00);
        List<gii__TransferOrderLine__c> lstTOLine= new List<gii__TransferOrderLine__c>();
        lstTOLine.add(objTOline);
        mapTOLine.put('key',lstTOLine);
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                 ];
        prodInvntryobj.gii__OrderQuantityMultiple__c=10;
        prodInvntryobj.gii__MinimumOrderQuantity__c=150; 
        prodInvntryobj.gii__OrderPointQuantity__c=150;
        update prodInvntryobj;
        Giic_UtilityClass_Test.creationPILocation(prodInvntryobj,objProdRef); 
        Giic_UtilityClass_Test.creationPILocationDetail(prodInvntryobj,objProdRef);
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        List< gii__ProductInventory__c> prodinvntylst= new List<gii__ProductInventory__c>();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;
        prodinvntyforLocal.gii__OrderQuantityMultiple__c=10;
        prodinvntyforLocal.gii__MinimumOrderQuantity__c=150;
        prodinvntyforLocal.gii__OrderPointQuantity__c=150;
        insert prodinvntyforLocal;   
        prodinvntylst.add(prodinvntyforLocal);        
        prodInvntryobj.gii__OrderQuantityMultiple__c=10;
        prodInvntryobj.gii__MinimumOrderQuantity__c=150;
        prodInvntryobj.gii__OrderPointQuantity__c=150;
        update prodInvntryobj;
         Test.stopTest();
        System.assertEquals(true, prodinvntylst.size()>0);
        set<Id> setWarehouseIds= new Set<Id>();
        set<Id> setProductIds=new Set<Id>();
        set<id> setLocationIds=new Set<Id>();
        setWarehouseIds.add(Giic_UtilityClass_Test.objWhLocal.Id);
        setWarehouseIds.add(Giic_UtilityClass_Test.lstWh[0].Id);
        setProductIds.add(objProdRef.Id);
        setLocationIds.add(Giic_UtilityClass_Test.objPILocation.Id);
		//Giic_InventoryUtility_D.getProductInventory(setWarehouseIds,setProductIds);
		Giic_InventoryUtility_D.getPIForStockAvailability(setWarehouseIds,setProductIds);
        Giic_InventoryUtility_D.getPIQD(setWarehouseIds,setProductIds,setLocationIds);
        Giic_InventoryUtility_D.getAvailQtyFromPIBL(setWarehouseIds,setProductIds,setLocationIds);
        //Giic_TransferOrderUtility.insertTO(mapTO, mapTOLine);

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
}