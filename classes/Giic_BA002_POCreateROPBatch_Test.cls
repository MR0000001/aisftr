/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 17/06/2019
* @date Modification dd/mm/yyyy
* @description Giic_BA002_POCreateROPBatch_Test – for Giic_BA002_POCreateROPBatch 
*/
@isTest(SeeAllData=false)
public class Giic_BA002_POCreateROPBatch_Test {

    @TestSetup
    static void onSetup() {
      giic_GloviaLogisticSetting__c settings = giic_GloviaLogisticSetting__c.getOrgDefaults();
      settings.giic_DisableVRTestClasses__c = true;
      upsert settings custSettings__c.Id;
    }
    
    /**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 17/06/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for Giic_BA002_POCreateROPBatch.
*/
    public static testMethod void testReceiveData(){
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
        Test.startTest();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c Limit 1
                                         ];
        objProdRef.gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        objProdRef.giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
       // objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountLocal.Id;
        objProdRef.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update objProdRef;
        Contract objCon=new Contract();    
        objCon=[Select Id,Status,EndDate from Contract Limit 1]; //limitato ad uno il risultato della query
        system.debug('objCon>>>>>'+objCon);
        objCon.Status='Active';
        objCon.ContractTerm= 12;
        update objCon; 
        Giic_UtilityClass_Test.priceBookEntryCreation(objProdRef);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        upsert Giic_UtilityClass_Test.objPO;
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt();
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                  gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                  gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                  gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                  gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                 ];
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
        Test.stopTest();
        prodInvntryobj.gii__OrderQuantityMultiple__c=1;
        prodInvntryobj.gii__MinimumOrderQuantity__c=1;
        prodInvntryobj.gii__OrderPointQuantity__c=1;
        update prodInvntryobj;
        prodinvntylst.add(prodinvntyforLocal); 
        System.assertEquals(true, prodinvntylst.size()>0);
        Giic_BA002_CentralWarehouseROPBatch batchobj = new Giic_BA002_CentralWarehouseROPBatch();
        Id batchId=DataBase.executeBatch(batchobj); 
         String sch = '0 0 0 * * ?'; 
        system.schedule('Test Territory Check', sch, batchobj); 
    }
}