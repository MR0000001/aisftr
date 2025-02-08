/**
* @author FirstName : Sara Miozza - sara.miozza@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description Giic_TR_SalesOrder_Test
*/

@isTest
private class Giic_TR_SalesOrder_Test {
    
    @isTest
    static void salesOrderTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        
        Test.startTest();
        WorkOrder workOrder = XC_DF_WorkOrder.createWorkOrders(1,'Delivery')[0];
        insert workOrder;
        gii__SalesOrder__c salesOrder = Giic_DF_Glovia.createSalesOrder();
        salesOrder.gii__Status__c = 'Shipped';
        salesOrder.giic_IsDelivery__c = true;
        salesOrder.giic_WorkOrder__c = workOrder.Id; 
        insert salesOrder;
        update salesOrder;
        delete salesOrder;
        //System.debug('@@@SalesOrder' +salesOrder);
        System.assertEquals('Shipped', salesOrder.gii__Status__c);
        Test.stopTest();
    }
    
     @isTest
    static void salesOrderWithWOLITest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        
        Test.startTest();
        WorkOrder workOrder = XC_DF_WorkOrder.createWorkOrders(1,'Delivery')[0];
        insert workOrder;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= workOrder.Id;
        insert woli;
        gii__SalesOrder__c salesOrder = Giic_DF_Glovia.createSalesOrder();
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.objTO.giic_SalesOrder__c =salesOrder.id ;
        update Giic_UtilityClass_Test.objTO;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();  
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__SalesOrder__c =salesOrder.id ;
        update Giic_UtilityClass_Test.objPO;
        salesOrder.gii__Status__c = 'Shipped';
        salesOrder.giic_IsDelivery__c = true;
        salesOrder.gii__Dropship__c = false;
        salesOrder.giic_WorkOrder__c = workOrder.Id;
        salesOrder.giic_WorkOrderLineItem__c = woli.Id;
        insert salesOrder;
        salesOrder.giic_OrderStatus__c = 'Completed';
        update salesOrder;
        delete salesOrder;
        //System.debug('@@@SalesOrder' +salesOrder);
        System.assertEquals('Shipped', salesOrder.gii__Status__c);
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
        Giic_UtilityClass_Test.salesOrderCreation();
        /*
        List<ServiceAppointment> servAppList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        servAppList[0].SchedStartTime = datetime.now();
        servAppList[0].SchedEndTime = datetime.now()+1;    
        insert servAppList[0];    
        */
            Test.startTest();
            List<gii__SalesOrder__c> soList = new List<gii__SalesOrder__c>();
            List<gii__SalesOrder__c> soList2 = new List<gii__SalesOrder__c>();
            List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersForLead(1);
            insert woList;
            /*
            gii__SalesOrder__c objSalesOrder = new gii__SalesOrder__c();
            System.debug('@@@objSalesOrder');
            System.debug(objSalesOrder);
            insert objSalesOrder;
            */
            soList2.add(Giic_UtilityClass_Test.objSalesOrder);
            for (gii__SalesOrder__c so : soList2){
                so.giic_DeliveryTracking__c='12345';
                so.giic_WorkOrder__c=woList[0].Id;
                soList.add(so);
            }
            update soList;
            
            //giic_TR_PurchaseOrder_ManageUpdate.createCaseFromPOHelper(servAppList,soList);
            //Map<String,Id> mapWorkOrderNumberWithId = new Map<String,Id>();
            //mapWorkOrderNumberWithId.put(servAppList[0].ParentRecord.Name,servAppList[0].ParentRecordId);
            //giic_TR_PurchaseOrder_ManageUpdate.createCaseFromPOHelperFillMAp(mapWorkOrderNumberWithId,soList[0],servAppList);
            Test.stopTest();
    }

}