@Istest
public with sharing class XC_AssignOwnerWorkOrder_Test {
    static testmethod void assignOwner(){
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
        u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXItalia';
        insert u;
        system.runAs(u){
            List<WorkOrder> woList=XC_DF_WorkOrder.createWorkOrders (1,'Organizer');
            woList[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
            woList[0].XC_Segment__c='B2B';
           	woList[0].XC_LegalEntity__c='EnelXItalia';
            insert woList;
            SYSTEM.DEBUG('woList Test '+woList);
            WorkOrderLineItem woli=new WorkOrderLineItem();
            woli.Status='New';
            woli.XC_WOLIType__c='Partner Payment';
            woli.WorkOrderId=woList[0].id;
            insert woli;
            
        
        
        test.stopTest();
            }
    }
    
    static testmethod void checkWo(){
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
         u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXMobilityItalia';
        insert u;
        system.runAs(u){
            List<WorkOrder> woList=XC_DF_WorkOrder.createWorkOrders (1,'Organizer');
            woList[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
            woList[0].XC_Segment__c='B2B';
           	woList[0].XC_LegalEntity__c='EnelXMobilityItalia';
            insert woList;
            SYSTEM.DEBUG('woList Test '+woList);
            WorkOrderLineItem woli=new WorkOrderLineItem();
            woli.Status='New';
            woli.XC_WOLIType__c='Partner Payment';
            woli.WorkOrderId=woList[0].id;
            insert woli;
            
        }
        test.stopTest();
    }
    
    static testmethod void checkWo1(){
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
         u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXMobilityItalia';
        insert u;
        system.runAs(u){
            List<WorkOrder> woList=XC_DF_WorkOrder.createWorkOrders (1,'Organizer');
            woList[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
            woList[0].XC_Segment__c='B2B';
           	woList[0].XC_LegalEntity__c='EnelXMobilityHolding';
            insert woList;
            SYSTEM.DEBUG('woList Test '+woList);
            WorkOrderLineItem woli=new WorkOrderLineItem();
            woli.Status='New';
            woli.XC_WOLIType__c='Partner Payment';
            woli.WorkOrderId=woList[0].id;
            insert woli;
            
        }
        test.stopTest();
    }
    
     static testmethod void checkWo2(){
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
         u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXMobilityItalia';
        insert u;
        system.runAs(u){
            List<WorkOrder> woList=XC_DF_WorkOrder.createWorkOrders (1,'Organizer');
            woList[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_WorkOrder').getRecordTypeId();
            woList[0].XC_Segment__c='B2G';
           	woList[0].XC_LegalEntity__c='EnelXItalia';
            insert woList;
            SYSTEM.DEBUG('woList Test '+woList);
            WorkOrderLineItem woli=new WorkOrderLineItem();
            woli.Status='New';
            woli.XC_WOLIType__c='Partner Payment';
            woli.WorkOrderId=woList[0].id;
            insert woli;
         
            
        }
        test.stopTest();
    }
    
    
   static testmethod void onUpdate(){
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
        u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXMobility';
        insert u;
        system.runAs(u){
            List<WorkOrder> woList=XC_DF_WorkOrder.createWorkOrders (1,'Organizer');
            woList[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_WorkOrder').getRecordTypeId();
            woList[0].XC_Segment__c='B2G';
           	woList[0].XC_LegalEntity__c='EnelXMobility';
            woList[0].Ownerid = UserInfo.getUserId();
            insert woList;
            SYSTEM.DEBUG('woList Test '+woList);
            WorkOrderLineItem woli=new WorkOrderLineItem();
            woli.Status='New';
            woli.XC_WOLIType__c='Partner Payment';
            woli.WorkOrderId=woList[0].id;
            insert woli;
            
      		List<Id> woId=new List<id>();
       		List<WorkOrderLineItem> woliTocheck=new List<WorkOrderLineItem>();
               //
            List<WorkOrder> woList2= XC_DF_WorkOrder.createWorkOrders (1,'Delivery & Installation');
            woList[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_WorkOrder').getRecordTypeId();
            woList[0].XC_Segment__c='B2G';
           	woList[0].XC_LegalEntity__c='EnelXMobility';
            woList2[0].Ownerid = UserInfo.getUserId();
            insert woList2;
            Map<id,WorkOrder> mapwo = new Map<id,WorkOrder>();
            mapwo.put(woList[0].id,woList2[0]);
            XC_AssignOwnerWorkOrder.onUpdate(woList, mapwo);
           //System.assertEquals('EnelXMobility', woList[0].XC_LegalEntity__c);
            
        }
        test.stopTest();
    }
    
     
}