@isTest
public with sharing class XC_TR_ProductRequired_U_WOLIPName_TEST {

   @testSetup()
   public static void setSetup(){
      List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'General');
      insert wo;

      NE__Product__c product = new NE__Product__c(name = 'testing');
      insert product;

      NE__Order__c order = new NE__Order__c();
      insert order;


   }

   @isTest
   static void updateProdID_test_materialsupply(){
      insert XC_DF_OneOrg.createOneOrg('Spain');
      
      WorkOrder wo = [SELECT ID FROM WorkOrder][0];
      WorkOrderLineItem woli = new WorkOrderLineItem();
      woli.WorkOrderId= wo.Id;
      Id WOLI_RECORDTYPE = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_MR_WOLI').getRecordTypeId();
      woli.RecordTypeId = WOLI_RECORDTYPE;
      woli.XC_WoliType__c= 'Material Supply';
      woli.XC_OrderOfActivity__c=1;
      woli.Status = 'In Progress' ;
      insert woli;
      
      Test.startTest();

      NE__Product__c product = [SELECT ID, NAME FROM NE__PRODUCT__C LIMIT 1];
      NE__Order__c order = [SELECT ID FROM NE__ORDER__C LIMIT 1];


      NE__OrderItem__c orderItem = new NE__OrderItem__c();
      orderItem.NE__OrderId__c = order.id;
      orderItem.NE__Qty__c = 1;
      orderItem.NE__ProdId__c = product.id;
      orderItem.XC_WBE__c = 'IT2KE60000YS000100';
      insert orderItem;

      wo.XC_Configuration__c = order.id;
      update wo;
      
      XC_RequiredPosition__c rp = new XC_RequiredPosition__c();
      rp.XC_WorkOrderLineItem__c = woli.Id;
      rp.XC_WBE__c = 'IT2KE60000YS000100';
      insert rp;
		
      Test.stopTest(); 
      WorkOrderLineItem retrievedWOLI = [SELECT ID, XC_ProductName__c FROM WORKORDERLINEITEM LIMIT 1];

      System.assertEquals(product.Name, retrievedWOLI.XC_ProductName__c);
   }

   @isTest
   public static void updateProdID_test_partnerengagement(){
      insert XC_DF_OneOrg.createOneOrg('Spain');
      
      WorkOrder wo = [SELECT ID FROM WorkOrder][0];
      WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
      woli.WorkOrderId = wo.Id; 
      Id WOLI_RECORDTYPE = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2G_EnelXItalia_PE_WOLI').getRecordTypeId();
      woli.RecordTypeId = WOLI_RECORDTYPE;
      woli.XC_WoliType__c = 'Partner Engagement';
      insert woli;

      woli.XC_LCLDocument__c='Chiusura Lavori';
      woli.XC_LCLDocumentRequired__c = true;
      woli.Status = 'In Progress' ;
      woli.XC_OrderOfActivity__c=1;
      update woli;
      
      Test.startTest();

      NE__Product__c product = [SELECT ID, NAME FROM NE__PRODUCT__C LIMIT 1];
      NE__Order__c order = [SELECT ID FROM NE__ORDER__C LIMIT 1];


      NE__OrderItem__c orderItem = new NE__OrderItem__c();
      orderItem.NE__OrderId__c = order.id;
      orderItem.NE__Qty__c = 1;
      orderItem.NE__ProdId__c = product.id;
      orderItem.XC_WBE__c = 'IT2KE60000YS000100';
      insert orderItem;

      wo.XC_Configuration__c = order.id;
      update wo;
      
      XC_RequiredPosition__c rp = new XC_RequiredPosition__c();
      rp.XC_WorkOrderLineItem__c = woli.Id;
      rp.XC_WBE__c = 'IT2KE60000YS000100';
      insert rp;
		
      Test.stopTest(); 
      WorkOrderLineItem retrievedWOLI = [SELECT ID, XC_ProductName__c FROM WORKORDERLINEITEM LIMIT 1];

      System.assertEquals(product.Name, retrievedWOLI.XC_ProductName__c);
   }

   @isTest
   static void updateProdID_test_productrequired(){
      insert XC_DF_OneOrg.createOneOrg('Spain');
      
      WorkOrder wo = [SELECT ID FROM WorkOrder][0];
      WorkOrderLineItem woli = new WorkOrderLineItem();
      woli.WorkOrderId= wo.Id;
      Id WOLI_RECORDTYPE = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_MR_WOLI').getRecordTypeId();
      woli.RecordTypeId = WOLI_RECORDTYPE;
      woli.XC_WoliType__c= 'Material Supply';
      woli.XC_OrderOfActivity__c=1;
      woli.Status = 'In Progress' ;
      insert woli;
      
      Test.startTest();

      NE__Product__c product = [SELECT ID, NAME FROM NE__PRODUCT__C LIMIT 1];
      NE__Order__c order = [SELECT ID FROM NE__ORDER__C LIMIT 1];


      NE__OrderItem__c orderItem = new NE__OrderItem__c();
      orderItem.NE__OrderId__c = order.id;
      orderItem.NE__Qty__c = 1;
      orderItem.NE__ProdId__c = product.id;
      orderItem.XC_WBE__c = 'IT2KE60000YS000100';
      insert orderItem;

      wo.XC_Configuration__c = order.id;
      update wo;

      Product2 prod = new Product2();
      prod.name='test';insert prod;

      ProductRequired pr = new ProductRequired();
      pr.ParentRecordId=woli.id;
      pr.Product2Id=prod.Id;
      pr.XC_WBSElement__c = 'IT2KE60000YS000100';
      insert pr;
		
      Test.stopTest(); 
      WorkOrderLineItem retrievedWOLI = [SELECT ID, XC_ProductName__c FROM WORKORDERLINEITEM LIMIT 1];

      System.assertEquals(product.Name, retrievedWOLI.XC_ProductName__c);
   }
}