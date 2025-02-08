/**
* @author FirstName : Sara Miozza - sara.miozza@nttdata.com
* @date Creation 24/01/2020
* @date Modification dd/mm/yyyy
* @description giic_TR_PurchaseOrder_ManageUpdate_Test – Test Class for giic_TR_PurchaseOrder_ManageUpdate.
*/

@isTest
private class giic_TR_PurchaseOrder_ManageUpdate_Test {
    
    @isTest
    private static  void createCaseFromPOTest(){ 
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
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.giic_NewDeliveryDate__c = date.today()+1;
        Giic_UtilityClass_Test.objPO.giic_status__c = System.Label.giic_POStatusCancelled;
        Giic_UtilityClass_Test.objPO.giic_IntegrationStatus__c = System.Label.giic_IntegrationStatusSuccess;
        Giic_UtilityClass_Test.objPO.giic_IntegrationOperation__c = System.Label.giic_CancellationRequest;
        Giic_UtilityClass_Test.objPO.giic_MultiTargetSystem__c = System.Label.giic_TargetSystemGlovia+';';
        Giic_UtilityClass_Test.objPO.giic_POCode__c = '0000';    
        Giic_UtilityClass_Test.objPO.giic_ReasonOfCancellation__c = 'Cancellation';    
        Test.startTest();
        
        update Giic_UtilityClass_Test.objPO;
        System.assertEquals(date.today()+1, Giic_UtilityClass_Test.objPo.giic_NewDeliveryDate__c);
        Test.stopTest();    
        
    }
    @isTest
    private static  void createCaseFromPOHeplerTest(){ 
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
        Giic_UtilityClass_Test.purchaseOrderCreation();
        List<ServiceAppointment> servAppList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        servAppList[0].SchedStartTime = datetime.now();
        servAppList[0].SchedEndTime = datetime.now()+1;    
        insert servAppList[0];    
        
        Test.startTest();
        List<gii__PurchaseOrder__c> poList = new List<gii__PurchaseOrder__c>();
        poList.add(Giic_UtilityClass_Test.objPO);
        giic_TR_PurchaseOrder_ManageUpdate.createCaseFromPOHelper(servAppList,poList);
        Map<String,Id> mapWorkOrderNumberWithId = new Map<String,Id>();
        mapWorkOrderNumberWithId.put(servAppList[0].ParentRecord.Name,servAppList[0].ParentRecordId);
        giic_TR_PurchaseOrder_ManageUpdate.createCaseFromPOHelperFillMAp(mapWorkOrderNumberWithId,poList[0],servAppList);
        System.assertEquals(true, servAppList.size()>0);
        Test.stopTest();    
        
    }
    
    /*
@isTest
private static  void checkIfNeedCITest(){ 
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
Giic_UtilityClass_Test.priceBookCreation();
Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
Giic_UtilityClass_Test.purchaseOrderCreation();
Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
Giic_UtilityClass_Test.objPO.giic_NewDeliveryDate__c = date.today()+1;
Giic_UtilityClass_Test.objPO.giic_status__c = 'Open';
Giic_UtilityClass_Test.objPO.giic_LegalEntity__c = 'EndesaX';
Giic_UtilityClass_Test.objPO.gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.Id;
Giic_UtilityClass_Test.objPO.gii__Dropship__c = true;
Giic_UtilityClass_Test.objPO.giic_WorkOrder__c = Giic_UtilityClass_Test.objWorkOrder.Id;
Giic_UtilityClass_Test.objWorkOrder.ContactId = Giic_UtilityClass_Test.objContact.Id;
Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c =  Giic_UtilityClass_Test.objWorkOrder.Id;
Giic_UtilityClass_Test.objPO.giic_IntegrationStatus__c = System.Label.giic_IntegrationStatusSuccess;
Giic_UtilityClass_Test.objPO.giic_IntegrationOperation__c = System.Label.giic_CancellationRequest;
Giic_UtilityClass_Test.objPO.giic_MultiTargetSystem__c = System.Label.giic_TargetSystemGlovia+';';
Giic_UtilityClass_Test.objPO.giic_POCode__c = '0000';   
Giic_UtilityClass_Test.objPO.giic_NewDeliveryDate__c = (Date.today()).addYears(10);
update Giic_UtilityClass_Test.objPO;
update Giic_UtilityClass_Test.objWorkOrder;
Giic_UtilityClass_Test.objPO.giic_status__c = 'Sent To Supplier';
update Giic_UtilityClass_Test.objPO;
Giic_UtilityClass_Test.objPO.giic_status__c = 'Reviewed';
Giic_UtilityClass_Test.objPO.giic_Note__c = 'Reviewed';
List<WorkOrder> woList = new  List<WorkOrder>();
woList.add(Giic_UtilityClass_Test.objWorkOrder);
List<ServiceAppointment> servAppList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
servAppList[0].SchedStartTime = datetime.now();
servAppList[0].SchedEndTime = datetime.now()+1;    
insert servAppList[0];
Test.startTest();
update Giic_UtilityClass_Test.objPO;
giic_TR_PurchaseOrder_ManageUpdate.populateCustomInterListFromPO(woList,'Orders_Pickup_Closed');  


Test.stopTest();    

}
*/
    @isTest
    private static  void checkIfNeedCITest2(){ 
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
        Test.startTest();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();  
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        //Giic_UtilityClass_Test.purchaseOrderCreation();
        //Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
          gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__Supplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id, 
                                                                gii__ShipTo__c = Giic_UtilityClass_Test.objWh.id,
                                                                gii__Approved__c=true,
                                                                giic_PurchasingOrganization__c = 'ED02',
                                                                giic_PriceBookId__c = Giic_UtilityClass_Test.objPriceBook.Id
                                                               );
        objPO.giic_NewDeliveryDate__c = date.today()+1;
        objPO.giic_status__c = 'Open';
        objPO.giic_LegalEntity__c = 'EndesaX';
        objPO.gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.Id;
        objPO.gii__Dropship__c = true;
        objPO.giic_WorkOrder__c = Giic_UtilityClass_Test.objWorkOrder.Id;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        insert oppList;
        Giic_UtilityClass_Test.objWorkOrder.XC_Opportunity__c = oppList[0].Id;
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c =  Giic_UtilityClass_Test.objWorkOrder.Id;
        objPO.giic_IntegrationStatus__c = System.Label.giic_IntegrationStatusSuccess;
        objPO.giic_IntegrationOperation__c = System.Label.giic_CancellationRequest;
        objPO.giic_MultiTargetSystem__c = System.Label.giic_TargetSystemGlovia+';';
        objPO.giic_POCode__c = '0000';   
        objPO.giic_NewDeliveryDate__c = (Date.today()).addYears(10);
        update Giic_UtilityClass_Test.objWorkOrder;
        objPO.giic_status__c = 'Sent To Supplier';
        insert objPO;
        gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=objPO.id,gii__Product__c=prodRefObj.id,gii__OrderQuantity__c=100.00,gii__UnitPrice__c=10.00,gii__Calc_LineGrossAmount__c=100);
        
        
        insert objPOLine;
        objPO.giic_status__c = 'Reviewed';
        objPO.giic_Note__c = 'Reviewed';
        List<WorkOrder> woList = new  List<WorkOrder>();
        woList.add(Giic_UtilityClass_Test.objWorkOrder);
        List<ServiceAppointment> servAppList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        servAppList[0].SchedStartTime = datetime.now();
        servAppList[0].SchedEndTime = datetime.now()+1;    
        insert servAppList[0];
        
        update objPO;
        
        map<Id,String> workOrderRejectReason = new  map<Id,String>();
        giic_TR_PurchaseOrder_ManageUpdate.populateCustomInterListFromPO(woList,'Orders_Pickup_Closed',workOrderRejectReason);  
        
        
        Test.stopTest();    
        
    }
    @isTest
    private static  void checkIfNeedCITest4(){ 
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
        Test.startTest();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();  
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        // Giic_UtilityClass_Test.purchaseOrderCreation();
        gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__Supplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id, 
                                                                gii__ShipTo__c = Giic_UtilityClass_Test.objWh.id,
                                                                gii__Approved__c=true,
                                                                giic_PurchasingOrganization__c = 'ED02',
                                                                giic_PriceBookId__c = Giic_UtilityClass_Test.objPriceBook.Id
                                                               );
        objPO.giic_NewDeliveryDate__c = date.today()+1;
        objPO.giic_LegalEntity__c = 'EndesaX';
        objPO.gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.Id;
        objPO.gii__Dropship__c = true;
        objPO.giic_WorkOrder__c = Giic_UtilityClass_Test.objWorkOrder.Id;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        insert oppList;
        Giic_UtilityClass_Test.objWorkOrder.XC_Opportunity__c = oppList[0].Id;
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c =  Giic_UtilityClass_Test.objWorkOrder.Id;
        objPO.giic_IntegrationStatus__c = System.Label.giic_IntegrationStatusSuccess;
        objPO.giic_IntegrationOperation__c = System.Label.giic_CancellationRequest;
        objPO.giic_MultiTargetSystem__c = System.Label.giic_TargetSystemGlovia+';';
        objPO.giic_POCode__c = '0000';   
        objPO.giic_NewDeliveryDate__c = (Date.today()).addYears(10);
        
        update Giic_UtilityClass_Test.objWorkOrder;
        objPO.giic_status__c = 'Sent To Supplier';
        insert objPO;
        gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__PurchaseOrder__c=objPO.id,gii__Product__c=prodRefObj.id,gii__OrderQuantity__c=100.00,gii__UnitPrice__c=10.00,gii__Calc_LineGrossAmount__c=100);
        
        
        insert objPOLine;
        objPO.giic_status__c = 'Open';
        objPO.giic_Note__c = 'Reviewed';
        objPO.giic_SupplierRejectReason__c = 'Product not available and not supplied';
        List<WorkOrder> woList = new  List<WorkOrder>();
        woList.add(Giic_UtilityClass_Test.objWorkOrder);
        List<ServiceAppointment> servAppList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        servAppList[0].SchedStartTime = datetime.now();
        servAppList[0].SchedEndTime = datetime.now()+1;    
        insert servAppList[0];
        
        update objPO;
        
        map<Id,String> workOrderRejectReason = new  map<Id,String>();
        workOrderRejectReason.put(Giic_UtilityClass_Test.objWorkOrder.id,'Product not available and not supplied' );
        giic_TR_PurchaseOrder_ManageUpdate.populateCustomInterListFromPO(woList,'Orders_Pickup_Closed',workOrderRejectReason);  
        
        
        Test.stopTest();    
        
    }
    
    @isTest
    private static  void checkIfNeedCITest3(){ 
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
        Test.startTest();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();  
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        Giic_UtilityClass_Test.objPO.giic_NewDeliveryDate__c = date.today()+1;
        Giic_UtilityClass_Test.objPO.giic_status__c = 'Open';
        Giic_UtilityClass_Test.objPO.giic_LegalEntity__c = 'EndesaX';
        Giic_UtilityClass_Test.objPO.gii__SalesOrder__c = Giic_UtilityClass_Test.objSalesOrder.Id;
        Giic_UtilityClass_Test.objPO.gii__Dropship__c = true;
        Giic_UtilityClass_Test.objPO.giic_WorkOrder__c = Giic_UtilityClass_Test.objWorkOrder.Id;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        insert oppList;
        Giic_UtilityClass_Test.objWorkOrder.XC_Opportunity__c = oppList[0].Id;
        Giic_UtilityClass_Test.objSalesOrder.giic_WorkOrder__c =  Giic_UtilityClass_Test.objWorkOrder.Id;
        Giic_UtilityClass_Test.objPO.giic_IntegrationStatus__c = System.Label.giic_IntegrationStatusSuccess;
        Giic_UtilityClass_Test.objPO.giic_IntegrationOperation__c = System.Label.giic_CancellationRequest;
        Giic_UtilityClass_Test.objPO.giic_MultiTargetSystem__c = System.Label.giic_TargetSystemGlovia+';';
        Giic_UtilityClass_Test.objPO.giic_POCode__c = '0000';   
        Giic_UtilityClass_Test.objPO.giic_NewDeliveryDate__c = (Date.today()).addYears(100);
        update Giic_UtilityClass_Test.objPO;
        update Giic_UtilityClass_Test.objWorkOrder;
        Giic_UtilityClass_Test.objPO.giic_status__c = 'Sent To Supplier';
        update Giic_UtilityClass_Test.objPO;
        Giic_UtilityClass_Test.objPO.giic_status__c = 'Reviewed';
        Giic_UtilityClass_Test.objPO.giic_Note__c = 'Reviewed';
        List<WorkOrder> woList = new  List<WorkOrder>();
        woList.add(Giic_UtilityClass_Test.objWorkOrder);
        List<ServiceAppointment> servAppList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        servAppList[0].SchedStartTime = datetime.now();
        servAppList[0].SchedEndTime = datetime.now()+1;   
        servAppList[0].ParentRecordId = Giic_UtilityClass_Test.objWorkOrder.Id;
        insert servAppList[0];
            //Test.startTest();
            List<id> poIds = new  List<id>();
            poIds.add(Giic_UtilityClass_Test.objPO.Id);
            map<string,Id> mapWorkOrderNumberWithId = new map<string,Id>();
            mapWorkOrderNumberWithId.put(Giic_UtilityClass_Test.objWorkOrder.WorkOrderNumber , Giic_UtilityClass_Test.objWorkOrder.Id);
            giic_TR_PurchaseOrder_ManageUpdate.createCaseFromPOHelperFillMap(mapWorkOrderNumberWithId,Giic_UtilityClass_Test.objPO, servAppList);  
        	
           
            Test.stopTest();    
         
     }

    @isTest
    private static void CIDeliveryTrackingTest(){
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
        Giic_UtilityClass_Test.purchaseOrderCreation();
        List<ServiceAppointment> servAppList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        servAppList[0].SchedStartTime = datetime.now();
        servAppList[0].SchedEndTime = datetime.now()+1;    
        insert servAppList[0];    
        
            Test.startTest();
            List<gii__PurchaseOrder__c> poList = new List<gii__PurchaseOrder__c>();
            List<gii__PurchaseOrder__c> poList2 = new List<gii__PurchaseOrder__c>();
            List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersForLead(1);
            insert woList;
            poList2.add(Giic_UtilityClass_Test.objPO);
            for (gii__PurchaseOrder__c po : poList2){
                po.giic_DeliveryTracking__c='12345';
                po.giic_WorkOrder__c=woList[0].Id;
                poList.add(po);
            }
            update poList;
            
            giic_TR_PurchaseOrder_ManageUpdate.createCaseFromPOHelper(servAppList,poList);
            Map<String,Id> mapWorkOrderNumberWithId = new Map<String,Id>();
            mapWorkOrderNumberWithId.put(servAppList[0].ParentRecord.Name,servAppList[0].ParentRecordId);
            giic_TR_PurchaseOrder_ManageUpdate.createCaseFromPOHelperFillMAp(mapWorkOrderNumberWithId,poList[0],servAppList);
            Test.stopTest();
    }


}