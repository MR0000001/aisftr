/**
* @author FirstName : Anil Giri
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_GoodIssueTO_Test – Test Class for Giic_GoodIssueTO.
*/
@isTest(SeeAllData=false)
public class Giic_GoodIssueTO_Test {

    @TestSetup
    static void onSetup() {
      giic_GloviaLogisticSetting__c settings = giic_GloviaLogisticSetting__c.getOrgDefaults();
      settings.giic_DisableVRTestClasses__c = true;
      upsert settings custSettings__c.Id;
    }
    
    // To cover fetching data method
    @isTest static void setupData() {
        
        
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
        
        List<gii__Product2Add__c> objProdRef= [Select id,name,gii__ProductCode__c from gii__Product2Add__c ];
        objProdRef[0].gii__ProductCode__c='Test';
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[0].gii__SerialControlled__c = true;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;//lstAccount[0].Id;
        
        objProdRef[1].gii__ProductCode__c='Test1';
        objProdRef[1].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef[1].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[1].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;
        
        update objProdRef;
        
        Giic_UtilityClass_Test.productSerialCreation(objProdRef[0].id);
        
        gii__PurchaseOrder__c objPOSupplier =  Giic_UtilityClass_Test.objPOSupplier;
      //  objPOSupplier.gii__Approved__c=true;
        //update objPOSupplier;
        Test.startTest();
        Giic_UtilityClass_Test.purchaseOrderLineCreationLSTForCS(objProdRef);
        
        Giic_UtilityClass_Test.pOReceiptSC();
        //Giic_UtilityClass_Test.pOReceiptLineCS();
        system.debug('PO rec::'+Giic_UtilityClass_Test.objPOreceiptCS);
        system.debug('PO  Line:::'+Giic_UtilityClass_Test.lstPoRecLine);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.tOLineCreationSC(objProdRef);
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
         
        
        system.debug('TO:::'+Giic_UtilityClass_Test.objTO);
        system.debug('TO Line:::'+Giic_UtilityClass_Test.lstTOLSC);   
        List<gii__ProductInventory__c> prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                       ];
        
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocationList(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetailLst(prodInvntryobj,objProdRef);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[0]);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[1]);
        
        map<String,Object> returnMap = Giic_GoodIssueTO.fetchTOAndToLineData(Giic_UtilityClass_Test.objTO.id);
        Giic_GoodIssueTOWrapper objWrapper = (Giic_GoodIssueTOWrapper)returnMap.get('WrapperData');
        System.assertEquals(Giic_UtilityClass_Test.objTO.Id, objWrapper.transferOrderID,'TO id same');
        Test.stopTest();
        
    }
    
    @isTest static void createTOReservnQshipAPITest() {
        
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
        List<string> lstProdIds = new List<string>();
        lstProdIds.add(Giic_UtilityClass_Test.lstProd[0].id);
        lstProdIds.add(Giic_UtilityClass_Test.lstProd[1].id);
        
        List<gii__Product2Add__c> objProdRef= [Select id,name,gii__ProductCode__c from gii__Product2Add__c];
        objProdRef[0].gii__ProductCode__c='Test';
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[0].gii__SerialControlled__c = true;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;//lstAccount[0].Id;
        
        objProdRef[1].gii__ProductCode__c='Test1';
        objProdRef[1].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef[1].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[1].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;
        
        update objProdRef;
        
        Giic_UtilityClass_Test.productSerialCreation(objProdRef[0].id);
        
        Giic_UtilityClass_Test.purchaseOrderCreation();
        gii__PurchaseOrder__c objPOSupplier =  Giic_UtilityClass_Test.objPOSupplier;
       // objPOSupplier.gii__Approved__c=true;
        //update objPOSupplier;
        
        Giic_UtilityClass_Test.purchaseOrderLineCreationLSTForCS(objProdRef);
        Test.startTest();
        Giic_UtilityClass_Test.pOReceiptSC();
        
        //Giic_UtilityClass_Test.pOReceiptLineCS();
        system.debug('PO rec::'+Giic_UtilityClass_Test.objPOreceiptCS);
        system.debug('PO  Line:::'+Giic_UtilityClass_Test.lstPoRecLine);
       
        System.debug('Location Local id = '+Giic_UtilityClass_Test.objLocationlocal.Id);
        Date orderDate = system.today();
        Date requiredDate = system.today().addMonths(1);
        String orderDateString = orderDate.year()+'-'+orderDate.month()+'-'+orderDate.day();
        String requiredDateString = requiredDate.year()+'-'+requiredDate.month()+'-'+requiredDate.day();
        gii__TransferOrder__c objTO = new gii__TransferOrder__c(gii__Account__c=Giic_UtilityClass_Test.objAccountCentral.Id,gii__OrderDate__c=date.valueOf(orderDateString),
                                                                gii__RequiredDate__c=date.valueOf(requiredDateString),gii__FromWarehouse__c=Giic_UtilityClass_Test.objWh.Id,
                                                                gii__TransferToWarehouse__c=Giic_UtilityClass_Test.objWhLocal.Id);
        
        insert objTO;
        List<gii__TransferOrderLine__c> transferOrderLineList = new  List<gii__TransferOrderLine__c>();
        gii__TransferOrderLine__c tOline1 = new gii__TransferOrderLine__c(gii__TransferOrder__c=objTO.id,gii__Product__c=objProdRef[0].Id, gii__Quantity__c=1.00,gii__UnitCost__c=10);
        transferOrderLineList.add(tOline1);
        gii__TransferOrderLine__c tOline2 = new gii__TransferOrderLine__c(gii__TransferOrder__c=objTO.id,gii__Product__c=objProdRef[0].Id, gii__Quantity__c=10.00,gii__UnitCost__c=10);
        transferOrderLineList.add(tOline2);
        insert transferOrderLineList;
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        gii__warehouse__c transferToWh = Giic_UtilityClass_Test.objWhLocal;
        transferToWh.gii__DefaultReceivingLocation__c = Giic_UtilityClass_Test.objLocationlocal.Id;
        update transferToWh;
     
        
        List<gii__ProductInventory__c> prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                       ];
        
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocationList(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetailLst(prodInvntryobj,objProdRef);
        
        system.debug('PIQD0:: '+Giic_UtilityClass_Test.lstPIQD[0]);
        system.debug('PIQD1:: '+Giic_UtilityClass_Test.lstPIQD[1]);
        
       
        
        List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper> toLines = new List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper>();
        Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        
        System.debug('transferOrderLineList = '+transferOrderLineList);
        for(gii__TransferOrderLine__c t : transferOrderLineList){
            System.debug('t.gii__TransferOrder__c = '+t.gii__TransferOrder__c);
            System.debug('t.gii__TransferOrder__r.gii__TransferToWarehouse__c '+t.gii__TransferOrder__r.gii__TransferToWarehouse__c);
            Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper gtl = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
            gtl.transferOrderLine = t.Id;
            gtl.locationId = Giic_UtilityClass_Test.lstPIQD[0].gii__Location__c;
            Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper asw = new Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper();
            asw.serialNumber = Giic_UtilityClass_Test.objPS.Name;
            gtl.lstAssignedSerial.add(asw);
            System.debug('gii__DefaultReceivingLocation__c = '+gtl.locationId);
            toLines.add(gtl);
        }
        
        
        
        //Mapping main wrapper
        Giic_GoodIssueTOWrapper wrapperTO = new Giic_GoodIssueTOWrapper();
        wrapperTO.transferOrderID = objTO.id;  //Transfer Order ID
        wrapperTO.lstOrderLine = toLines;
        System.debug('@#@# '+wrapperTO.lstOrderLine);
        //Method for API call
        map<string,object> returnMap = Giic_GoodIssueTO.createTOReservnQshipAPI(wrapperTO);
        system.debug('returnMap::'+returnMap);
        //System.assertEquals(((List<gii__InventoryReserve__c>)returnMap.get('listInvReserve')).size(),0,'Nothing inserted');
        Giic_GoodIssueTO.toDirectReservation(new List<gii__InventoryReserve__c>(), Database.setSavepoint());
        Giic_GoodIssueTO.getLotProductIR(new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper(), new Map<string,gii__ProductInventoryQuantityDetail__c>(), new List<gii__InventoryReserve__c>());
        Giic_GoodIssueTO.createDirectReservation(new List<gii__InventoryReserve__c>());
        Giic_GoodIssueTO.updateTransferOrder(new List<gii__InventoryReserve__c>());
        Giic_GoodIssueTOWrapper geWrapper = new Giic_GoodIssueTOWrapper();
        Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper tempLines = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        tempLines.orderQuantity = 1;
        tempLines.isSerialCntr = true;
        tempLines.transferOrderLine = 'aaa';
        geWrapper.lstOrderLine = new List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper>{tempLines};
        Giic_GoodIssueTO.fakeUpdateQuantityAndSerialNumOnTol('aaa', 0, JSON.serialize(geWrapper));
        Giic_GoodIssueTO.coverageTestClass();
        Test.stopTest();
    }
    
    
    
    
    @isTest static void validateDataIA() {
        
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
        List<string> lstProdIds = new List<string>();
        lstProdIds.add(Giic_UtilityClass_Test.lstProd[0].id);
        lstProdIds.add(Giic_UtilityClass_Test.lstProd[1].id);
        
        List<gii__Product2Add__c> objProdRef= [Select id,name,gii__ProductCode__c from gii__Product2Add__c ];
        objProdRef[0].gii__ProductCode__c='Test';
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
     //   objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[0].gii__SerialControlled__c = true;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;//lstAccount[0].Id;
        
        objProdRef[1].gii__ProductCode__c='Test1';   
        objProdRef[1].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
       // objProdRef[1].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[1].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;
        
        update objProdRef;
        
        Giic_UtilityClass_Test.productSerialCreation(objProdRef[0].id);
        
        Giic_UtilityClass_Test.purchaseOrderCreation();
        gii__PurchaseOrder__c objPOSupplier =  Giic_UtilityClass_Test.objPOSupplier;
      //  objPOSupplier.gii__Approved__c=true;
        //update objPOSupplier;
        
        Giic_UtilityClass_Test.purchaseOrderLineCreationLSTForCS(objProdRef);
        Test.startTest();
        Giic_UtilityClass_Test.pOReceiptSC();
        
       //Giic_UtilityClass_Test.pOReceiptLineCS();
        system.debug('PO rec::'+Giic_UtilityClass_Test.objPOreceiptCS);
        system.debug('PO  Line:::'+Giic_UtilityClass_Test.lstPoRecLine);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.tOLineCreationSC(objProdRef);
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        system.debug('TO:::'+Giic_UtilityClass_Test.objTO);
        system.debug('TO Line:::'+Giic_UtilityClass_Test.lstTOLSC);   
        List<gii__ProductInventory__c> prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                       ];
        
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocationList(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetailLst(prodInvntryobj,objProdRef);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[0]);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[1]);
        gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult resultInvAdj = Giic_GoodIssueTO.doInventoryAdjustments(Giic_UtilityClass_Test.lstPIQD);
   
        Test.stopTest();
    }
    
    @isTest static void callDataWrapper() {
        
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
        List<string> lstProdIds = new List<string>();
        lstProdIds.add(Giic_UtilityClass_Test.lstProd[0].id);
        lstProdIds.add(Giic_UtilityClass_Test.lstProd[1].id);
        
        List<gii__Product2Add__c> objProdRef= [Select id,name,gii__ProductCode__c from gii__Product2Add__c ];
        objProdRef[0].gii__ProductCode__c='Test';
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
      //  objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[0].gii__SerialControlled__c = true;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;//lstAccount[0].Id;
        
        objProdRef[1].gii__ProductCode__c='Test1';
        objProdRef[1].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
      //  objProdRef[1].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[1].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;
        
        update objProdRef;
        
        Giic_UtilityClass_Test.productSerialCreation(objProdRef[0].id);
        
        Giic_UtilityClass_Test.purchaseOrderCreation();
        gii__PurchaseOrder__c objPOSupplier =  Giic_UtilityClass_Test.objPOSupplier;
      //  objPOSupplier.gii__Approved__c=true;
        //update objPOSupplier;
        
        Giic_UtilityClass_Test.purchaseOrderLineCreationLSTForCS(objProdRef);
        Test.startTest();
        Giic_UtilityClass_Test.pOReceiptSC();
        
        //Giic_UtilityClass_Test.pOReceiptLineCS();
        system.debug('PO rec::'+Giic_UtilityClass_Test.objPOreceiptCS);
        system.debug('PO  Line:::'+Giic_UtilityClass_Test.lstPoRecLine);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.tOLineCreationSC(objProdRef);
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        system.debug('TO:::'+Giic_UtilityClass_Test.objTO);
        system.debug('TO Line:::'+Giic_UtilityClass_Test.lstTOLSC);   
        List<gii__ProductInventory__c> prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                       ];
        
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocationList(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetailLst(prodInvntryobj,objProdRef);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[0]);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[1]);
        
        List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper> toLines = new List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper>();
        Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        
        //Mapping main wrapper
        Giic_GoodIssueTOWrapper wrapperTO = new Giic_GoodIssueTOWrapper();
        wrapperTO.TransferOrderID = Giic_UtilityClass_Test.objTO.id;  //Transfer Order ID
        wrapperTO.lstOrderLine = toLines;
        //Method for API call
        System.debug('@#@#2'+wrapperTO.lstOrderLine);
        String strWrapper = JSON.serialize(wrapperTO);
        map<string,object> returnMap = Giic_GoodIssueTO.createTOReservnQship(strWrapper);
        System.debug('returnMap:::'+returnMap);
        
       // System.assertEquals(((List<gii__InventoryReserve__c>)returnMap.get('listInvReserve')).size(),0,'Nothing inserted');
        Test.stopTest();
    }
    
    
    
    
    
        
    @isTest static void dataTOUpdate() {
        
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
        system.debug('***TestData1***'+Giic_UtilityClass_Test.objPOreceiptCS);
        List<gii__Product2Add__c> objProdRef= [Select id,name,gii__ProductCode__c from gii__Product2Add__c ];
        objProdRef[0].gii__ProductCode__c='Test';
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
      //  objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[0].gii__SerialControlled__c = true;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;//lstAccount[0].Id;
        objProdRef[1].gii__ProductCode__c='Test1';
        objProdRef[1].gii__PlanningPolicy__c=  'Reorder Point';
        //objProdRef[1].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        //objProdRef[1].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;
        update objProdRef;
        Giic_UtilityClass_Test.productSerialCreation(objProdRef[0].id);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.tOLineCreationSC(objProdRef);
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        system.debug('TO:::'+Giic_UtilityClass_Test.objTO);
        system.debug('TO Line:::'+Giic_UtilityClass_Test.lstTOLSC);  
        Test.startTest();
        try{
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.lstWh[0],objProdRef);
		}catch(exception ex){
            System.debug('Exeception Occured:::'+ex.getMessage()+'::Line Number::'+ex.getLineNumber());
        }
		List<gii__ProductInventory__c> prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                       ];
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocationList(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetailLst(prodInvntryobj,objProdRef);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[0]);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[1]);
        Giic_GoodIssueTO.updateFailDataTO(Giic_UtilityClass_Test.lstTOLSC[0]);
        gii__TransferOrder__c  objTOUpdate = [SELECT id,giic_IntegrationStatus__c FROM gii__TransferOrder__c WHERE id=:Giic_UtilityClass_Test.lstTOLSC[0].gii__TransferOrder__c];
        System.assertEquals(objTOUpdate.id,Giic_UtilityClass_Test.lstTOLSC[0].gii__TransferOrder__c ,'TO Line');
        Test.stopTest();
    }
    
    
    @isTest static void dataTOlineErrorLogData() {
        
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        system.debug('***TestData1***'+Giic_UtilityClass_Test.objPOreceiptCS);
        List<gii__Product2Add__c> objProdRef= [Select id,name,gii__ProductReference__r.name,gii__ProductCode__c from gii__Product2Add__c ];
        objProdRef[0].gii__ProductCode__c='Test';
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //  objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[0].gii__SerialControlled__c = true;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;//lstAccount[0].Id;
        objProdRef[1].gii__ProductCode__c='Test1';
        objProdRef[1].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef[1].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[1].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;
        update objProdRef;
        Giic_UtilityClass_Test.productSerialCreation(objProdRef[0].id);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.tOLineCreationSC(objProdRef);
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        system.debug('TO:::'+Giic_UtilityClass_Test.objTO);
        system.debug('TO Line:::'+Giic_UtilityClass_Test.lstTOLSC);  
        Test.startTest();
        try{
            Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.lstWh[0],objProdRef);
        }catch(exception ex){
            System.debug('Exeception Occured:::'+ex.getMessage()+'::Line Number::'+ex.getLineNumber());
        }
        List<gii__ProductInventory__c> prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                       ];
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocationList(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetailLst(prodInvntryobj,objProdRef);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[0]);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[1]);
        
        List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper> toLines = new List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper>();
        Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        // Non serial product start
        toline.TransferOrderLine = Giic_UtilityClass_Test.lstTOLSC[1].id;  //Transfer Order Line Id
        toline.OrderQuantity = 10.0;   //Transfer Order Line's Quantity
        toLines.add(toline);
        // Non serial product end
        //Product serial start
        toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        toline.TransferOrderLine = Giic_UtilityClass_Test.lstTOLSC[0].id;  //Transfer Order Line Id
        toline.OrderQuantity = 1.0;   //Transfer Order Line's Quantity
        //Serial Number Assignment 
        List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper> assignSerials = new List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper>(); 
        Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper serial = new Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper();
        serial.serialNumber = 'Tube-1';  //Serial Number
        assignSerials.add(serial);
        toline.lstAssignedSerial=assignSerials;
        toLines.add(toline);
        //Product serial end
        
        //Mapping main wrapper
        Giic_GoodIssueTOWrapper wrapperTO = new Giic_GoodIssueTOWrapper();
        wrapperTO.TransferOrderID = Giic_UtilityClass_Test.objTO.id;  //Transfer Order ID
        wrapperTO.lstOrderLine = toLines;
       
        list<giic_ErrorLog__c> lstErrorLogs=Giic_GoodIssueTO.returnListErrorLog(wrapperTO.lstOrderLine[0],Giic_UtilityClass_Test.objTO.Name);
        system.debug('lstErrorLogs:::'+lstErrorLogs);
        System.assertEquals(lstErrorLogs[0].giic_TransferOrderLine__c, wrapperTO.lstOrderLine[0].TransferOrderLine,'Same TO line');
        Map<String,Object>mapReturnResult = Giic_GoodIssueTO.insertErrorLog(objProdRef[0].gii__ProductReference__r.name+',',lstErrorLogs,Giic_UtilityClass_Test.objTO.Name);
        // Giic_GoodIssueTO.updateQuantityOnTol(Giic_UtilityClass_Test.lstTOLSC[0].id,3.0);
        Test.stopTest();
    }
    
      @isTest static void dataTOlineErrorLogData2() {
        
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        system.debug('***TestData1***'+Giic_UtilityClass_Test.objPOreceiptCS);
        List<gii__Product2Add__c> objProdRef= [Select id,name,gii__ProductReference__r.name,gii__ProductCode__c from gii__Product2Add__c ];
        objProdRef[0].gii__ProductCode__c='Test';
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //  objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[0].gii__SerialControlled__c = true;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;//lstAccount[0].Id;
        objProdRef[1].gii__ProductCode__c='Test1';
        objProdRef[1].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef[1].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[1].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;
        update objProdRef;
        Giic_UtilityClass_Test.productSerialCreation(objProdRef[0].id);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.tOLineCreationSC(objProdRef);
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        system.debug('TO:::'+Giic_UtilityClass_Test.objTO);
        system.debug('TO Line:::'+Giic_UtilityClass_Test.lstTOLSC);  
        Test.startTest();
        try{
            Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.lstWh[0],objProdRef);
        }catch(exception ex){
            System.debug('Exeception Occured:::'+ex.getMessage()+'::Line Number::'+ex.getLineNumber());
        }
        List<gii__ProductInventory__c> prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                       ];
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocationList(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetailLst(prodInvntryobj,objProdRef);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[0]);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[1]);
        
        List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper> toLines = new List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper>();
        Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        // Non serial product start
        toline.TransferOrderLine = Giic_UtilityClass_Test.lstTOLSC[1].id;  //Transfer Order Line Id
        toline.OrderQuantity = 10.0;   //Transfer Order Line's Quantity
        toLines.add(toline);
        // Non serial product end
        //Product serial start
        toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        toline.TransferOrderLine = Giic_UtilityClass_Test.lstTOLSC[0].id;  //Transfer Order Line Id
        toline.OrderQuantity = 1.0;   //Transfer Order Line's Quantity
        //Serial Number Assignment 
        List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper> assignSerials = new List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper>(); 
        Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper serial = new Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper();
        serial.serialNumber = 'Tube-1';  //Serial Number
        assignSerials.add(serial);
        toline.lstAssignedSerial=assignSerials;
        toLines.add(toline);
        //Product serial end
        gii__ProductInventoryQuantityDetail__c piqd = [SELECT Id,gii__Available__c,gii__OnHandQuantity__c,giic_Reserved__c,giic_Status__c FROM gii__ProductInventoryQuantityDetail__c LIMIT 1];
        //Mapping main wrapper
        Giic_GoodIssueTOWrapper wrapperTO = new Giic_GoodIssueTOWrapper();
        wrapperTO.TransferOrderID = Giic_UtilityClass_Test.objTO.id;  //Transfer Order ID
        wrapperTO.lstOrderLine = toLines;
        Giic_GoodIssueTO.createIRInstance(toline,piqd);
        Giic_GoodIssueTO.getPIQDAdj(piqd,toline,new Map<String, Decimal>());
        
        Test.stopTest();
    }
    
    
      @isTest static void dataTOlineErrorLogData3() {
        
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.locationCreation();
        system.debug('***TestData1***'+Giic_UtilityClass_Test.objPOreceiptCS);
        List<gii__Product2Add__c> objProdRef= [Select id,name,gii__ProductReference__r.name,gii__ProductCode__c from gii__Product2Add__c ];
        objProdRef[0].gii__ProductCode__c='Test';
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //  objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[0].gii__SerialControlled__c = true;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;//lstAccount[0].Id;
        objProdRef[1].gii__ProductCode__c='Test1';
        objProdRef[1].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef[1].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[1].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;
        update objProdRef;
        Giic_UtilityClass_Test.productSerialCreation(objProdRef[0].id);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.tOLineCreationSC(objProdRef);
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        system.debug('TO:::'+Giic_UtilityClass_Test.objTO);
        system.debug('TO Line:::'+Giic_UtilityClass_Test.lstTOLSC);  
        Test.startTest();
        try{
            Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.lstWh[0],objProdRef);
        }catch(exception ex){
            System.debug('Exeception Occured:::'+ex.getMessage()+'::Line Number::'+ex.getLineNumber());
        }
        List<gii__ProductInventory__c> prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                       ];
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocationList(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetailLst(prodInvntryobj,objProdRef);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[0]);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[1]);
        
        List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper> toLines = new List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper>();
        Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        // Non serial product start
        toline.TransferOrderLine = Giic_UtilityClass_Test.lstTOLSC[1].id;  //Transfer Order Line Id
        toline.OrderQuantity = 10.0;   //Transfer Order Line's Quantity
        toLines.add(toline);
        // Non serial product end
        //Product serial start
        toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        toline.TransferOrderLine = Giic_UtilityClass_Test.lstTOLSC[0].id;  //Transfer Order Line Id
        toline.OrderQuantity = 1.0;   //Transfer Order Line's Quantity
        //Serial Number Assignment 
        List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper> assignSerials = new List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper>(); 
        Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper serial = new Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper();
        serial.serialNumber = 'Tube-1';  //Serial Number
        assignSerials.add(serial);
        toline.lstAssignedSerial=assignSerials;
        toLines.add(toline);
        //Product serial end
        gii__ProductInventoryQuantityDetail__c piqd = [SELECT Id,gii__Available__c,gii__OnHandQuantity__c,giic_Reserved__c,giic_Status__c FROM gii__ProductInventoryQuantityDetail__c LIMIT 1];
        //Mapping main wrapper
        Giic_GoodIssueTOWrapper wrapperTO = new Giic_GoodIssueTOWrapper();
        wrapperTO.TransferOrderID = Giic_UtilityClass_Test.objTO.id;  //Transfer Order ID
        wrapperTO.lstOrderLine = toLines;
        piqd.giic_Reserved__c = 1.0;
        update piqd;
        Giic_GoodIssueTO.getPIQDAdj(piqd,toline, new Map<String, Decimal>());
        
        Test.stopTest();
    }
    
    
    @isTest static void dataTOlineErrorLog2() {
        
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
        system.debug('***TestData1***'+Giic_UtilityClass_Test.objPOreceiptCS);
        List<gii__Product2Add__c> objProdRef= [Select id,name,gii__ProductReference__r.name,gii__ProductCode__c from gii__Product2Add__c ];
        objProdRef[0].gii__ProductCode__c='Test';
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //  objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[0].gii__SerialControlled__c = true;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;//lstAccount[0].Id;
        objProdRef[1].gii__ProductCode__c='Test1';
        objProdRef[1].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef[1].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[1].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;
        update objProdRef;
        Giic_UtilityClass_Test.productSerialCreation(objProdRef[0].id);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.tOLineCreationSC(objProdRef);
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        system.debug('TO:::'+Giic_UtilityClass_Test.objTO);
        system.debug('TO Line:::'+Giic_UtilityClass_Test.lstTOLSC);  
        Test.startTest();
        try{
            Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.lstWh[0],objProdRef);
        }catch(exception ex){
            System.debug('Exeception Occured:::'+ex.getMessage()+'::Line Number::'+ex.getLineNumber());
        }
        List<gii__ProductInventory__c> prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                       ];
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocationList(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetailLst(prodInvntryobj,objProdRef);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[0]);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[1]);
        Giic_UtilityClass_Test.lstPIQD[0].giic_Reserved__c = 1;
        Giic_UtilityClass_Test.lstPIQD[1].giic_Reserved__c = 1;
        update Giic_UtilityClass_Test.lstPIQD[0];
        update Giic_UtilityClass_Test.lstPIQD[1];
        
        List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper> toLines = new List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper>();
        Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        // Non serial product start
        toline.TransferOrderLine = Giic_UtilityClass_Test.lstTOLSC[1].id;  //Transfer Order Line Id
        toline.OrderQuantity = 10.0;   //Transfer Order Line's Quantity
        toline.productCode = 'Test1';
        toLines.add(toline);
        // Non serial product end
        //Product serial start
        toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        toline.TransferOrderLine = Giic_UtilityClass_Test.lstTOLSC[0].id;  //Transfer Order Line Id
        toline.OrderQuantity = 1.0;   //Transfer Order Line's Quantity
        toline.productCode = 'Test';
        //Serial Number Assignment 
        List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper> assignSerials = new List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper>(); 
        Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper serial = new Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper();
        serial.serialNumber = 'Tube-1';  //Serial Number
        assignSerials.add(serial);
        toline.lstAssignedSerial=assignSerials;
        toLines.add(toline);
        //Product serial end
        
        //Mapping main wrapper
        Giic_GoodIssueTOWrapper wrapperTO = new Giic_GoodIssueTOWrapper();
        wrapperTO.TransferOrderID = Giic_UtilityClass_Test.objTO.id;  //Transfer Order ID
        wrapperTO.lstOrderLine = toLines;
        system.debug('@#@#4'+ wrapperTO.lstOrderLine);
        
        map<string,object> returnMap = Giic_GoodIssueTO.createTOReservnQshipAPI(wrapperTO);
       
        Test.stopTest();
    }
    
    
    @isTest static void dataTOlineErrorLog() {
        
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
        system.debug('***TestData1***'+Giic_UtilityClass_Test.objPOreceiptCS);
        List<gii__Product2Add__c> objProdRef= [Select id,name,gii__ProductReference__r.name,gii__ProductCode__c from gii__Product2Add__c ];
        objProdRef[0].gii__ProductCode__c='Test';
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //  objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[0].gii__SerialControlled__c = true;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;//lstAccount[0].Id;
        objProdRef[1].gii__ProductCode__c='Test1';
        objProdRef[1].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef[1].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[1].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;
        update objProdRef;
        Giic_UtilityClass_Test.productSerialCreation(objProdRef[0].id);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.tOLineCreationSC(objProdRef);
        
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c = Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.lstWh;
        
        system.debug('TO:::'+Giic_UtilityClass_Test.objTO);
        system.debug('TO Line:::'+Giic_UtilityClass_Test.lstTOLSC);  
        Test.startTest();
        try{
            Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.lstWh[0],objProdRef);
        }catch(exception ex){
            System.debug('Exeception Occured:::'+ex.getMessage()+'::Line Number::'+ex.getLineNumber());
        }
        List<gii__ProductInventory__c> prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                        gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,
                                                        gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,
                                                        gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                        gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,
                                                        gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c FROM gii__ProductInventory__c
                                                       ];
        System.debug('prodInvntryobj+++++'+prodInvntryobj);
        Giic_UtilityClass_Test.creationPILocationList(prodInvntryobj,objProdRef);
        Giic_UtilityClass_Test.creationPILocationDetailLst(prodInvntryobj,objProdRef);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[0]);
        system.debug('PIQD:: 1'+Giic_UtilityClass_Test.lstPIQD[1]);
        
        List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper> toLines = new List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper>();
        Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        // Non serial product start
        toline.TransferOrderLine = Giic_UtilityClass_Test.lstTOLSC[1].id;  //Transfer Order Line Id
        toline.OrderQuantity = 10.0;   //Transfer Order Line's Quantity
        toLines.add(toline);
        // Non serial product end
        //Product serial start
        toline = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
        toline.TransferOrderLine = Giic_UtilityClass_Test.lstTOLSC[0].id;  //Transfer Order Line Id
        toline.OrderQuantity = 1.0;   //Transfer Order Line's Quantity
        //Serial Number Assignment 
        List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper> assignSerials = new List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper>(); 
        Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper serial = new Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper();
        serial.serialNumber = 'Tube-1';  //Serial Number
        assignSerials.add(serial);
        toline.lstAssignedSerial=assignSerials;
        toLines.add(toline);
        //Product serial end
        
        //Mapping main wrapper
        Giic_GoodIssueTOWrapper wrapperTO = new Giic_GoodIssueTOWrapper();
        wrapperTO.TransferOrderID = Giic_UtilityClass_Test.objTO.id;  //Transfer Order ID
        wrapperTO.lstOrderLine = toLines;
        system.debug('@#@#3'+ wrapperTO.lstOrderLine);
        map<string,object> mapReturnResult = Giic_GoodIssueTO.createErrorLogs(wrapperTO,new set<string>{objProdRef[0].gii__ProductReference__r.name},New Map<string,string>{'toName'=>Giic_UtilityClass_Test.objTO.Name,'checkFor'=>'PIQD'});
       // map<string,object> returnMap = Giic_GoodIssueTO.createTOReservnQshipAPI(wrapperTO);
        system.debug('Map return::'+mapReturnResult.get('Exceptions'));
        System.assertEquals((string)mapReturnResult.get('Exceptions'), 'Goods Issue cannot be done since Product Inventory is not available for Product','Same Exception');
        Test.stopTest();
    }
    
    
    
}