@isTest
public class Giic_WarehouseUtility_Test {

    
    @isTest static void testWHUtilityMethods(){
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
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,giic_ProcurementType__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c =:Giic_UtilityClass_Test.objProductTL.Id];
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update objProdRef;
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        gii__ProductInventory__c prodInvntryobj= new gii__ProductInventory__c();
        prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c, gii__Warehouse__r.gii__WarehouseGroup__c,
                         gii__OrderQuantityMultiple__c, giic_AvailableQty__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                         gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,gii__Warehouse__r.giic_WarehouseType__c,
                         gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c 
                         FROM gii__ProductInventory__c ];
        prodInvntryobj.gii__OrderQuantityMultiple__c=1;
        prodInvntryobj.gii__MinimumOrderQuantity__c=1;
        prodInvntryobj.gii__OrderPointQuantity__c=1;
        update prodInvntryobj;
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        List< gii__ProductInventory__c> prodinvntylst= new List<gii__ProductInventory__c>();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;
        prodinvntyforLocal.gii__OrderQuantityMultiple__c=1;
        prodinvntyforLocal.gii__MinimumOrderQuantity__c=1;
        prodinvntyforLocal.gii__OrderPointQuantity__c=1;
        insert prodinvntyforLocal;
        prodinvntylst.add(prodinvntyforLocal);
        System.assertEquals(true, prodinvntylst.size()>0);
        List<gii__Warehouse__c> lstWh = new List<gii__Warehouse__c>();
        lstWh.add(Giic_UtilityClass_Test.objWhLocal);
        lstWh.add(Giic_UtilityClass_Test.objWh);
        Test.startTest();
        //giic_WarehouseValueCalculationBatch batchobj = new giic_WarehouseValueCalculationBatch();
        //Id batchId=DataBase.executeBatch(batchobj); 
        Giic_WarehouseUtility.calculateValueForWHPage(Giic_UtilityClass_Test.objWhLocal.Id);
        Giic_WarehouseUtility.calculateValueForWHPage();
        String sch = '0 0 0 * * ?'; 
        //system.schedule('Test Territory Check', sch, batchobj);
        Test.stopTest();
    }
    
    
    
    @isTest static void calculateROPTest() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        
    Test.startTest();
        gii__Product2Add__c p = Giic_DF_Glovia.createProductReference();
        p.gii__PlanningPolicy__c = Label.giic_PlanningPolicy;
        update p;
        gii__PurchaseOrder__c po = Giic_DF_Glovia.createPurchaseOrder();
        //insert po;
        gii__Warehouse__c wa = [SELECT id FROM gii__Warehouse__c LIMIT 1];
        wa.giic_WarehouseType__c = Label.giic_WarehouseTypeLocal;
        update wa;
        gii__ProductInventory__c pi = Giic_DF_Glovia.createProductInventory(wa.id,p.id);
        insert pi;
        Giic_WarehouseUtility.calculateROP(pi.id);
    Test.stopTest();
   }
    

    @isTest static void getAllWarehousesForNetworkTest() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        
    Test.startTest();
        
        gii__PurchaseOrder__c po = Giic_DF_Glovia.createPurchaseOrder();
        //insert po;
        set<Id> setWarehouseGroupIds = new set<Id> ();
        List<gii__WarehouseGroup__c> wgList = [SELECT id FROM gii__WarehouseGroup__c ];
        for(gii__WarehouseGroup__c wg : wgList){
            setWarehouseGroupIds.add(wg.Id);
        }
        Giic_WarehouseUtility.getAllWarehousesForNetwork(setWarehouseGroupIds);
        XC_UTIL_ResultWrapper rw = Giic_WarehouseUtility.populateErrorWrapper('errore');
        System.assertEquals(rw.success, false, 'error Wrapper pop');
    Test.stopTest();
   }

    
        
    
    

}