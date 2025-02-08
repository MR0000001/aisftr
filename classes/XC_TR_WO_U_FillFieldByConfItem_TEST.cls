/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 21/05/2019 
* @description XC_TR_WO_U_FillFieldByConfItem_TEST – Test class 
*/
@isTest
private class XC_TR_WO_U_FillFieldByConfItem_TEST {
    
    static testMethod void fillFieldsFromAsset() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c neOrder =  XC_DF_Order.createOrder('InOrder');
        List<XC_Address__c> addressList =  [SELECT Id, XC_Account__c FROM XC_Address__c];
        neOrder.XC_InstallationAddress__c = addressList[0].id;
        neOrder.NE__AccountId__c = addressList[0].XC_Account__c;
        update neOrder;
        List<NE__OrderItem__c> neOrderItem =  XC_DF_OrderItem.createOrderItems(1);
        neOrderItem[0].NE__OrderId__c = neOrder.id;
        neOrderItem[0].NE__SerialNum__c = 'TEST1234';
        neOrderItem[0].NE__Account__c = addressList[0].XC_Account__c;
        insert neOrderItem;
        Test.startTest();
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_Installation);
        for(WorkOrder wo : woList){
            wo.XC_Configuration_Item__c = neOrderItem[0].Id;
            wo.AccountId = addressList[0].XC_Account__c;
        }
        insert woList;
        System.debug('@@@TEST woList ' + woList);
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
     static testMethod void fillFieldsFromAsset1() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c neOrder =  XC_DF_Order.createOrder('InOrder');
        List<XC_Address__c> addressList =  [SELECT Id, XC_Account__c FROM XC_Address__c];
        neOrder.XC_InstallationAddress__c = addressList[0].id;
        neOrder.NE__AccountId__c = addressList[0].XC_Account__c;
        update neOrder;
         NE__Catalog_Item__c neCatalogItem =  XC_DF_CatalogItem.createCatalogItem();
         neCatalogItem.XC_DurationInMinutes__c = 30;
         insert neCatalogItem;
        List<NE__OrderItem__c> neOrderItem =  XC_DF_OrderItem.createOrderItems(1);
        neOrderItem[0].NE__OrderId__c = neOrder.id;
        neOrderItem[0].NE__CatalogItem__c = neCatalogItem.id;
        neOrderItem[0].NE__SerialNum__c = 'TEST1234';
        neOrderItem[0].NE__Account__c = addressList[0].XC_Account__c;
        insert neOrderItem;
        Test.startTest();
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_DeliveryInstallation);
        for(WorkOrder wo : woList){
            wo.XC_Configuration_Item__c = neOrderItem[0].Id;
            wo.AccountId = addressList[0].XC_Account__c;
        }
        insert woList;
        
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
   	static testMethod void fillFieldsFromAsset2() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(2,  Label.XC_CL_WorkType_DeliveryInstallation);
        insert woList;
        
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(2, listInsertedWorkOrders.size());
        Test.stopTest();
    }
     
    static testMethod void fillFieldsFromConfItem() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c neOrder =  XC_DF_Order.createOrder('InOrder');
        List<XC_Address__c> addressList =  [SELECT Id, XC_Account__c FROM XC_Address__c];
        neOrder.XC_InstallationAddress__c = addressList[0].id;
        neOrder.NE__AccountId__c = addressList[0].XC_Account__c;
        update neOrder;
         NE__Catalog_Item__c neCatalogItem =  XC_DF_CatalogItem.createCatalogItem();
         neCatalogItem.XC_DurationInMinutes__c = 30;
         insert neCatalogItem;
        List<NE__OrderItem__c> neOrderItem =  XC_DF_OrderItem.createOrderItems(1);
        neOrderItem[0].NE__OrderId__c = neOrder.id;
        neOrderItem[0].NE__CatalogItem__c = neCatalogItem.id;
        neOrderItem[0].NE__SerialNum__c = 'TEST1234';
        neOrderItem[0].NE__Account__c = addressList[0].XC_Account__c;
        insert neOrderItem;
        Test.startTest();
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_DeliveryInstallation);
        for(WorkOrder wo : woList){
            wo.XC_Configuration__c = neOrder.id;
            wo.XC_WorkTypeCategory__c = 'Site Inspection';
            wo.XC_Configuration_Item__c = neOrderItem[0].Id;
            wo.AccountId = addressList[0].XC_Account__c;
        }
        insert woList;
        
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }   
    
}