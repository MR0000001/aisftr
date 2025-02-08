/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  30/05/2019 
* @description XC_TR_WorkOrderLineItem_U_upWOS_TEST – Test class for XC_TR_WorkOrderLineItem_U_upWOS
*/
@isTest
public with sharing class XC_TR_WorkOrderLineItem_U_upWOS_TEST {
    
        @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
    }
    // Test method for onBeforeInsertWOLI
    static testMethod void onBeforeInsertWOLI(){
        Test.startTest();
        List<Contact> c= XC_DF_Contact.createResidentialContacts(1);
        insert c; 
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'Commercial Visit');
        insert wo; 
        List<ServiceAppointment> sa= XC_DF_ServiceAppointment.createServiceAppointment(wo);
        sa[0].ParentRecordId = wo[0].Id;
        sa[0].Status = 'Scheduled';
        sa[0].SchedStartTime = DateTime.now();
        sa[0].SchedEndTime = DateTime.now().addHours(2);
        insert sa; 
		
        System.debug('???WORKORDER '+ wo);
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        woli.XC_OrderOfActivity__c=1;
        insert woli;
        WorkOrderLineItem woliInserted = [SELECT Id FROM WorkOrderLineItem LIMIT 1];
 
        woliInserted.Status = 'Closed' ;
        try{
        	update woliInserted; 
        }    
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Closed') ? true : false;
             System.assertEquals(expectedExceptionThrown, true);
        }

        //System.assertEquals();
        Test.stopTest(); 
    }
    
       // Test method for cycleOnWoli1
    static testMethod void onBeforeInsertWOLI1(){
        Test.startTest();
        List<Contact> c= XC_DF_Contact.createResidentialContacts(1);
        insert c; 
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'Commercial Visit');
        wo[0].Status = Label.XC_CL_WorkOrder_Assigned;
        insert wo; 
        List<ServiceAppointment> sa= XC_DF_ServiceAppointment.createServiceAppointment(wo);
        sa[0].ParentRecordId = wo[0].Id;
        sa[0].Status = 'Scheduled';
        sa[0].SchedStartTime = DateTime.now();
        sa[0].SchedEndTime = DateTime.now().addHours(2);
        insert sa; 
		
        System.debug('???WORKORDER '+ wo);
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        woli.XC_OrderOfActivity__c=1;
        insert woli;
        WorkOrderLineItem woliInserted = [SELECT Id FROM WorkOrderLineItem LIMIT 1];
 
        woliInserted.Status = 'Closed' ;
        try{
        	update woliInserted; 
        }    
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Closed') ? true : false;
             System.assertEquals(expectedExceptionThrown, true);
        }

        //System.assertEquals();
        Test.stopTest();
    }

        static testMethod void onBeforeInsertWOLI4(){
        Test.startTest();
        List<Contact> c= XC_DF_Contact.createResidentialContacts(1);
        insert c; 
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'Commercial Visit');
        insert wo; 
        List<ServiceAppointment> sa= XC_DF_ServiceAppointment.createServiceAppointment(wo);
        sa[0].ParentRecordId = wo[0].Id;
        sa[0].Status = 'Scheduled';
        sa[0].SchedStartTime = DateTime.now();
        sa[0].SchedEndTime = DateTime.now().addHours(2);
        insert sa; 
            WorkOrderLineItem woli1 = new WorkOrderLineItem();
        woli1.WorkOrderId= wo[0].Id; 
        woli1.XC_OrderOfActivity__c=1;
        insert woli1;
            WorkOrderLineItem woli3 = new WorkOrderLineItem();
        woli3.WorkOrderId= wo[0].Id; 
        woli3.XC_OrderOfActivity__c=3;
        insert woli3;
        System.debug('???WORKORDER '+ wo);
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        woli.XC_OrderOfActivity__c=4;
        insert woli;
 
        woli.Status = 'Closed' ;
        try{
        	update woli; 
        }    
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Closed') ? true : false;
        }

        //System.assertEquals();
        Test.stopTest();
    }
    
    
     static testMethod void onBeforeInsertWOLI4Bis(){
        Test.startTest();
        List<Contact> c= XC_DF_Contact.createResidentialContacts(1);
        insert c; 
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'Commercial Visit');
        insert wo; 
        List<ServiceAppointment> sa= XC_DF_ServiceAppointment.createServiceAppointment(wo);
        sa[0].ParentRecordId = wo[0].Id;
        sa[0].Status = 'Scheduled';
        sa[0].SchedStartTime = DateTime.now();
        sa[0].SchedEndTime = DateTime.now().addHours(2);
        insert sa; 
            WorkOrderLineItem woli1 = new WorkOrderLineItem();
        woli1.WorkOrderId= wo[0].Id; 
        woli1.XC_OrderOfActivity__c=1;
         woli1.Status = 'Closed';
        insert woli1;
            WorkOrderLineItem woli2 = new WorkOrderLineItem();
        woli2.WorkOrderId= wo[0].Id; 
        woli2.XC_OrderOfActivity__c=2;
        insert woli2;
        System.debug('???WORKORDER '+ wo);
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        woli.XC_OrderOfActivity__c=4;
        insert woli;
 
        woli.Status = 'Closed' ;
        try{
        	update woli; 
        }    
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Closed') ? true : false;
        }

        //System.assertEquals();
        Test.stopTest();
    }
    
    
    static testMethod void onBeforeInsertWOLI3(){
        Test.startTest();
        List<Contact> c= XC_DF_Contact.createResidentialContacts(1);
        insert c; 
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'Commercial Visit');
        insert wo; 
        List<ServiceAppointment> sa= XC_DF_ServiceAppointment.createServiceAppointment(wo);
        sa[0].ParentRecordId = wo[0].Id;
        sa[0].Status = 'Scheduled';
        sa[0].SchedStartTime = DateTime.now();
        sa[0].SchedEndTime = DateTime.now().addHours(2);
        insert sa; 
		
        System.debug('???WORKORDER '+ wo);
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        woli.XC_OrderOfActivity__c=3;
        insert woli;
        WorkOrderLineItem woliInserted = [SELECT Id FROM WorkOrderLineItem LIMIT 1];
 
        woliInserted.Status = 'Closed' ;
        try{
        	update woliInserted; 
        }    
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Closed') ? true : false;
        }

        //System.assertEquals();
        Test.stopTest();
    }
    
     static testMethod void onBeforeInsertWOLI4Bis2(){
        Test.startTest();
        List<Contact> c= XC_DF_Contact.createResidentialContacts(1);
        insert c; 
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'Commercial Visit');
         wo[0].XC_MissingQuoteReason__c = 'Test';
        insert wo; 
        List<ServiceAppointment> sa= XC_DF_ServiceAppointment.createServiceAppointment(wo);
        sa[0].ParentRecordId = wo[0].Id;
        sa[0].Status = 'Scheduled';
        sa[0].SchedStartTime = DateTime.now();
        sa[0].SchedEndTime = DateTime.now().addHours(2);
        insert sa; 
            WorkOrderLineItem woli1 = new WorkOrderLineItem();
        woli1.WorkOrderId= wo[0].Id; 
        woli1.XC_OrderOfActivity__c=1;
         woli1.Status = 'Closed';
        insert woli1;
            WorkOrderLineItem woli2 = new WorkOrderLineItem();
        woli2.WorkOrderId= wo[0].Id; 
        woli2.XC_OrderOfActivity__c=2;
        insert woli2;
        System.debug('???WORKORDER '+ wo);
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        woli.XC_OrderOfActivity__c=4;
        insert woli;
 
        woli.Status = 'Closed' ;
        try{
        	update woli; 
        }    
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Closed') ? true : false;
        }

        //System.assertEquals();
        Test.stopTest();
    }
    
     static testMethod void onBeforeInsertWOLI4Bis3(){
        Test.startTest();
        List<Contact> c= XC_DF_Contact.createResidentialContacts(1);
        insert c; 
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'Commercial Visit');
        insert wo;  
            WorkOrderLineItem woli1 = new WorkOrderLineItem();
        woli1.WorkOrderId= wo[0].Id; 
        woli1.XC_OrderOfActivity__c=1;
        insert woli1;
 
        woli1.Status = 'Closed' ;
        try{
        	update woli1; 
        }    
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Closed') ? true : false;
        }

        //System.assertEquals();
        Test.stopTest();
    }

}