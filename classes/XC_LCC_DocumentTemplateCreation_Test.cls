@IsTest
public without sharing class XC_LCC_DocumentTemplateCreation_Test {
    @TestSetup
    static void setup(){
		NE__Order__c o = XC_DF_Order.createOrder('test');
        NE__OrderItem__c orderItem = new NE__OrderItem__c(NE__OrderId__c = o.Id, NE__Qty__c = 5, XC_LegalEntity__c = 'EnelXItalia');
        insert orderItem;
    
        WorkOrder wo = new WorkOrder(XC_Configuration__c= o.Id);
        insert wo;
        wo.XC_Configuration_Item__c = orderItem.Id;
        update wo;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status='New';
        woli.WorkOrderId = wo.Id;
        insert woli;

        Document_Template__c temp = new Document_Template__c(XC_WorkOrderLineItem__c = woli.id) ;
        insert temp ;

    }

    @isTest
    static void PopulatefieldsfromWOLITest(){
        String workOrderId = [SELECT Id FROM WorkOrderLineItem LIMIT 1].Id;
        Test.startTest();
           XC_LCC_DocumentTemplateCreation.PopulatefieldsfromWOLI(workOrderId);
        Test.stopTest();
    }

    @isTest
    static void ClonefieldsfromTemplateTest(){
        String workOrderId = [SELECT Id FROM WorkOrderLineItem LIMIT 1].Id;
        String TemplateId = [SELECT Id FROM Document_Template__c LIMIT 1].Id;
        Test.startTest();
           XC_LCC_DocumentTemplateCreation.ClonefieldsfromTemplate(workOrderId,TemplateId);
        	XC_LCC_DocumentTemplateCreation.NewTemplateId(workOrderId);
        Test.stopTest();
    }
}