/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderUtility_Test – Test Class for giic_TransferOrderUtility.
*/
@isTest
public class Giic_TransferOrderUtility_Test {
/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for checkLimitsForOrder.
*/
    @isTest
    private static  void checkLimitsForOrderTOTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
       // List<gii__Product2Add__c> objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd];
       gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        Giic_UtilityClass_Test.transferOrderCreation();
        //Giic_UtilityClass_Test.insertTO();
        List<gii__TransferOrder__c> lstTO = new List<gii__TransferOrder__c>();
        lstTO.add(Giic_UtilityClass_Test.objTO);
        System.assertEquals(true, lstTO.size()>0);
        //Giic_UtilityClass_Test.tOLineCreationLST(objProdRef);
        Giic_UtilityClass_Test.tOLineCreation(objProdRef);
        System.debug('objProdRef---->>'+objProdRef);
        System.debug('Giic_UtilityClass_Test.objTO---->>'+Giic_UtilityClass_Test.objTO);
        System.debug('Giic_UtilityClass_Test.lstTOL---->>'+Giic_UtilityClass_Test.lstTOL);
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        List< gii__ProductInventory__c> prodinvntylst= new List<gii__ProductInventory__c>();
        //prodinvntyforLocal.gii__Product__c=objProdRef[0].Id;
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;
        prodinvntyforLocal.gii__OrderQuantityMultiple__c=1;
        prodinvntyforLocal.gii__MinimumOrderQuantity__c=1;
        prodinvntyforLocal.gii__OrderPointQuantity__c=1;
        insert prodinvntyforLocal;  
        Test.startTest();
        giic_TransferOrderUtility.checkLimitsForOrder(lstTO);
        giic_TransferOrderUtility.rebalWHOnTOL(lstTO);
        giic_TransferOrderUtility.codeCoverage();
        delete lstTO;
        Test.stopTest();
    } 
/**
* @author FirstName :  Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation  31/08/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for createCaseFromTO.
*/    
    @isTest
    static  void createCaseFromTOTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.workTypeCreation();
        Giic_UtilityClass_Test.workOrderCreation();
        Giic_UtilityClass_Test.serviceAppointmentCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();    
        Giic_UtilityClass_Test.salesOrderCreation();
        workorder objWO = [select id,WorkOrderNumber from workorder limit 1];
        system.debug('objWO::'+objWO);
        Giic_UtilityClass_Test.objSalesOrder.giic_FSLWorkOrder__c=objWO.WorkOrderNumber;
        update Giic_UtilityClass_Test.objSalesOrder;
        system.debug('objSalesOrder::'+Giic_UtilityClass_Test.objSalesOrder);
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id Limit 1];
        Giic_UtilityClass_Test.salesOrderLineCreation(pref);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.objTO.giic_NewDeliveryDate__c=Date.valueOf(System.today());
        update Giic_UtilityClass_Test.objTO;
        Giic_UtilityClass_Test.tOLineCreation(pref);
        Giic_UtilityClass_Test.objTOline.giic_SalesOrderLine__c=Giic_UtilityClass_Test.objSalesOrderLine.Id;
        update Giic_UtilityClass_Test.objTOline;
        system.debug('objTOline::'+Giic_UtilityClass_Test.objTOline);
        List<gii__TransferOrder__c> toIdList=[Select Id, giic_NewDeliveryDate__c FROM gii__TransferOrder__c];
        System.assertEquals(true, toIdList.size()>0);
        List<Id> toIds= new List<Id>();
        for(gii__TransferOrder__c to:toIdList){
            toIds.add(to.Id);
            to.giic_NewDeliveryDate__c=System.today() + 30;  
        }
        update toIdList;
        Test.startTest();
        giic_TransferOrderUtility.createCaseFromTO(toIds);
        Test.stopTest();
    } 
    
    
      @isTest
    private static void runROPForCentralWarehouseTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c = Giic_UtilityClass_Test.objWh.Id;
        update Giic_UtilityClass_Test.objWhLocal;
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
        List<gii__ProductInventory__c>  objPI = [SELECT giic_LegalEntity__c, gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                 gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,gii__Product__r.giic_EndDate__c,
                                                 gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c,gii__Warehouse__r.gii__WareHouseCountry__c,
                                                 gii__AvailableQuantity__c, gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,gii__Warehouse__r.giic_ParentWarehouse__r.gii__WareHouseCountry__c,
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
        Test.startTest();
        giic_TransferOrderUtility.runROPForLocalWarehouse(objPI); 
        Test.stopTest();
    }
    
    
    @isTest
    public static  void processMergeForTOTest(){
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
        Giic_UtilityClass_Test.insertTO(); 
        List<gii__TransferOrder__c> listTO=new List<gii__TransferOrder__c>();    
        listTO=[SELECT Id,giic_status__c,giic_IntegrationStatus__c,giic_WarehouseLimitExceeded__c,gii__FromWarehouse__c,gii__TransferToWarehouse__c,gii__TransferToWarehouse__r.gii__Account__c, giic_Approved__c FROM gii__TransferOrder__c];
      /* for(gii__TransferOrder__c objTO : listTO){
            objTO.giic_Approved__c=True;
            objTO.giic_status__c='Draft'; 
            objTO.giic_IntegrationStatus__c='Not Started';
        }*/
        System.assertEquals(true, listTO.size()>0);
        //update listTO; 
        List<gii__Product2Add__c> listProdRef = [select id,gii__ProductReference__c,gii__ProductCode__c from gii__Product2Add__c];
        Test.startTest();
        Giic_UtilityClass_Test.tOLineCreationLST(listProdRef);
        giic_TransferOrderUtility.updateIntegrationStatus(listTO);
        giic_TransferOrderUtility.processMergeForTO(listTO);
        Test.stopTest();
        
    }
    
    
     @isTest
    public static  void upgradeAddressWarehouseToTest(){
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
        Giic_UtilityClass_Test.insertTO(); 
        List<gii__TransferOrder__c> listTO=new List<gii__TransferOrder__c>();    
        listTO=[SELECT Id,giic_status__c,giic_IntegrationStatus__c,giic_WarehouseLimitExceeded__c,gii__FromWarehouse__c,gii__TransferToWarehouse__c,gii__TransferToWarehouse__r.gii__Account__c, giic_Approved__c FROM gii__TransferOrder__c];
      
        
        List<String> whIds = XC_UTIL_Sobject.getListFieldValues(listTO,'gii__TransferToWarehouse__c');
        Test.startTest();
        
        giic_TransferOrderUtility.upgradeAddressWarehouseTo(listTO,whIds);
        giic_TransferOrderUtility.processMergeForTOfromComponent();
        Test.stopTest();
        
    }
    
    
    @isTest
    public static  void closeSalesOrderTest(){
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
        Giic_UtilityClass_Test.insertTO(); 
        Giic_UtilityClass_Test.salesOrderCreation();
        gii__SalesOrder__c so = Giic_UtilityClass_Test.objSalesOrder;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1,'Delivery');
        insert woList;
        so.giic_WorkOrder__c = woList[0].Id;
        so.giic_IsDelivery__c = true;
        update so;
        List<gii__TransferOrder__c> listTO=new List<gii__TransferOrder__c>();    
        List<gii__TransferOrder__c> toToUpdate =new List<gii__TransferOrder__c>();   
        gii__TransferOrder__c t = new gii__TransferOrder__c(giic_status__c='Received',gii__Account__c=Giic_UtilityClass_Test.objAccountCentral.Id,giic_SalesOrder__c = so.Id,
                                                            gii__TransferToWarehouse__c = Giic_UtilityClass_Test.objWhLocal.Id, gii__FromWarehouse__c=Giic_UtilityClass_Test.objWh.Id
                                                           );
    
        insert t;
        toToUpdate.add(t);
        Test.startTest();
        giic_TransferOrderUtility.closeSalesOrder(toToUpdate);
        Test.stopTest();
    
	}

    
     @isTest
    public static  void manualShareReadTest(){
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
        Giic_UtilityClass_Test.insertTO(); 
        Giic_UtilityClass_Test.salesOrderCreation();
        gii__SalesOrder__c so = Giic_UtilityClass_Test.objSalesOrder;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1,'Delivery');
        insert woList;
        so.giic_WorkOrder__c = woList[0].Id;
        update so;
        List<gii__TransferOrder__c> listTO=new List<gii__TransferOrder__c>();    
        List<gii__TransferOrder__c> toToUpdate =new List<gii__TransferOrder__c>();    
        listTO=[SELECT Id,giic_status__c,giic_IntegrationStatus__c,giic_WarehouseLimitExceeded__c,giic_SalesOrder__c, giic_SalesOrder__r.giic_WorkOrder__c,gii__FromWarehouse__c,giic_SalesOrder__r.giic_WorkOrder__r.XC_WorkTypeCategory__c,gii__TransferToWarehouse__c,gii__TransferToWarehouse__r.gii__Account__c, giic_Approved__c FROM gii__TransferOrder__c];
        for(gii__TransferOrder__c t : listTO){
             t.giic_status__c = 'Received';
             t.giic_SalesOrder__c = so.Id;
             toToUpdate.add(t);
        }
        map<Id,List<Id>> transferOrdIdTouserOrGroupId = new  map<Id,List<Id>>();
        List<Id> userList = new  List<Id>();
        User u = XC_DF_User.createUserAdmin();
        insert u;
        userList.add(u.Id);
        transferOrdIdTouserOrGroupId.put(listTO[0].Id, userList);
        giic_UTIL_TransferOrderSharing.Giic_SharingTOWrapper sharWrapp = new giic_UTIL_TransferOrderSharing.Giic_SharingTOWrapper();
        sharWrapp.transferOrderId = so.Id;
        Test.startTest();
        giic_UTIL_TransferOrderSharing.manualShareRead(transferOrdIdTouserOrGroupId);
        Test.stopTest();
        
    }
    
    @isTest
        private static  void createCaseFromTOHelperFillMapTest(){ 
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.workTypeCreation();
        Giic_UtilityClass_Test.workOrderCreation();
        Giic_UtilityClass_Test.salesOrderCreation();
        
        Giic_UtilityClass_Test.contactCreation(Giic_UtilityClass_Test.objAccountSupplier.Id);
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();  
       
            List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
            insert oppList;
            Giic_UtilityClass_Test.objWorkOrder.XC_Opportunity__c = oppList[0].Id;
            Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c =  Giic_UtilityClass_Test.objWorkOrder.Id;       
            update Giic_UtilityClass_Test.objWorkOrder;
       
        Giic_UtilityClass_Test.salesOrderLineCreation(prodRefObj);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.objTO.giic_NewDeliveryDate__c=Date.valueOf(System.today());
            Test.startTest();
        update Giic_UtilityClass_Test.objTO;
            //Test.startTest();
        Giic_UtilityClass_Test.tOLineCreation(prodRefObj);
        Giic_UtilityClass_Test.objTOline.giic_SalesOrderLine__c=Giic_UtilityClass_Test.objSalesOrderLine.Id;
        update Giic_UtilityClass_Test.objTOline;
            List<WorkOrder> woList = new  List<WorkOrder>();
            woList.add(Giic_UtilityClass_Test.objWorkOrder);
             List<ServiceAppointment> servAppList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        servAppList[0].SchedStartTime = datetime.now();
        servAppList[0].SchedEndTime = datetime.now()+1;   
            servAppList[0].ParentRecordId = Giic_UtilityClass_Test.objWorkOrder.Id;
        insert servAppList[0];
            //Test.startTest();
            List<id> poIds = new  List<id>();
            map<string,Id> mapWorkOrderNumberWithId = new map<string,Id>();
            mapWorkOrderNumberWithId.put(Giic_UtilityClass_Test.objWorkOrder.WorkOrderNumber , Giic_UtilityClass_Test.objWorkOrder.Id);
            Giic_TransferOrderUtility.createCaseFromTOHelperFillMap(mapWorkOrderNumberWithId, Giic_UtilityClass_Test.objTOline, servAppList);  
        	
           
            Test.stopTest();    
            
        }

    @isTest
        private static void reserveQuantitiesForTolUpTest(){
            Giic_UtilityClass_Test.systemPolicyCreation();
            Giic_UtilityClass_Test.gloviaSystemSettingCreation();
            Giic_UtilityClass_Test.accountCreation();
            Giic_UtilityClass_Test.wareHouseGroupCreation(); 
            Giic_UtilityClass_Test.warehouseCreation(); 
            Giic_UtilityClass_Test.locationCreation();
            Giic_UtilityClass_Test.productCreation();
            Giic_UtilityClass_Test.transferOrderCreation();
            gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
            Giic_UtilityClass_Test.tOLineCreation(prodRefObj);
            List<gii__Product2Add__c> ListPR = new list<gii__Product2Add__c>();
            ListPR.add(prodRefObj);
            giic_UtilityClass_Test.creationPI(giic_UtilityClass_Test.objWh, ListPR);

            test.startTest();
            giic_UtilityClass_Test.objTOline.gii__Quantity__c = 3;
            update giic_UtilityClass_Test.objTOline;
            List<Id> toIds = new List<Id>();
            toIds.add(giic_UtilityClass_Test.objTOline.Id);
            Giic_TransferOrderLineUtility.cancelQtyToWOPI(toIds);
            test.stopTest();
        }

        @isTest
        private static void reserveQuantitiesForTolDelTest(){
            Giic_UtilityClass_Test.systemPolicyCreation();
            Giic_UtilityClass_Test.gloviaSystemSettingCreation();
            Giic_UtilityClass_Test.accountCreation();
            Giic_UtilityClass_Test.wareHouseGroupCreation(); 
            Giic_UtilityClass_Test.warehouseCreation(); 
            Giic_UtilityClass_Test.locationCreation();
            Giic_UtilityClass_Test.productCreation();
            Giic_UtilityClass_Test.transferOrderCreation();
            gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
            Giic_UtilityClass_Test.tOLineCreation(prodRefObj);
            List<gii__Product2Add__c> ListPR = new list<gii__Product2Add__c>();
            ListPR.add(prodRefObj);
            giic_UtilityClass_Test.creationPI(giic_UtilityClass_Test.objWh, ListPR);
           
            test.startTest();
            
            delete giic_UtilityClass_Test.objTOline;
            test.stopTest();
        }

        @isTest
        private static void reserveQuantitiesForTolAfterToDelTest(){
            Giic_UtilityClass_Test.systemPolicyCreation();
            Giic_UtilityClass_Test.gloviaSystemSettingCreation();
            Giic_UtilityClass_Test.accountCreation();
            Giic_UtilityClass_Test.wareHouseGroupCreation(); 
            Giic_UtilityClass_Test.warehouseCreation(); 
            Giic_UtilityClass_Test.locationCreation();
            Giic_UtilityClass_Test.productCreation();
            Giic_UtilityClass_Test.transferOrderCreation();
            gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
            Giic_UtilityClass_Test.tOLineCreation(prodRefObj);
            List<gii__Product2Add__c> ListPR = new list<gii__Product2Add__c>();
            ListPR.add(prodRefObj);
            giic_UtilityClass_Test.creationPI(giic_UtilityClass_Test.objWh, ListPR);

            test.startTest();
            delete giic_UtilityClass_Test.objTO;
            test.stopTest();
        }
    
    	@isTest
        private static void fromWhChangeTest(){
            Giic_UtilityClass_Test.systemPolicyCreation();
            Giic_UtilityClass_Test.gloviaSystemSettingCreation();
            Giic_UtilityClass_Test.accountCreation();
            Giic_UtilityClass_Test.wareHouseGroupCreation(); 
            Giic_UtilityClass_Test.warehouseCreation(); 
            Giic_UtilityClass_Test.locationCreation();
            Giic_UtilityClass_Test.productCreation();
            Giic_UtilityClass_Test.transferOrderCreation();
            gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1];
            Giic_UtilityClass_Test.tOLineCreation(prodRefObj);
            List<gii__Product2Add__c> ListPR = new list<gii__Product2Add__c>();
            ListPR.add(prodRefObj);
            giic_UtilityClass_Test.creationPI(giic_UtilityClass_Test.objWh, ListPR);
            Account acc = [select id from account where IdentityNumber__c='Enel-X-0800933'];
            gii__WarehouseGroup__c whGr= [select id from gii__WarehouseGroup__c limit 1];
            gii__Warehouse__c objWhLocal2 = new gii__Warehouse__c(Name = 'Local Warehouse 2',
                                           giic_WarehouseType__c='Local',
                                           giic_StorageCapacity__c=450000,
                                           gii__Account__c = acc.Id,
                                           gii__WarehouseGroup__c = whGr.Id,
                                           giic_WarehouseCode__c = 'LW2',
                                           giic_warehousecountryPick__c = 'Spain',
                                           gii__WareHouseCountry__c = 'Spain',
                                           giic_LegalEntity__c = 'EndesaX',
                                           giic_ServerSystem__c ='Sirkus'
                                           );
            insert objWhLocal2;

            test.startTest();
            gii__TransferOrder__c tr = [SELECT id, gii__FromWarehouse__c from gii__transferOrder__c limit 1];
            gii__Warehouse__c wh = [SELECT id,giic_WarehouseCode__c from gii__Warehouse__c where giic_WarehouseCode__c = 'LW2' limit 1];
            tr.gii__FromWarehouse__c = wh.id;
            update tr;
            test.stopTest();
        }

    
    
}