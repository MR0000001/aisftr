/**
* @author Salvatore Scarpato
* @date Creation 12/06/2019
* @description XC_TR_Config_U_CloseWOLI_TEST – Test class for XC_TR_Config_U_CloseWOLI
*/ 
@isTest
private class XC_TR_Config_U_CloseWOLI_TEST {
    
    @TestSetup
    static void insertRecords (){
        Integer n = 10;
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        Id configOptyId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        List<NE__Order__c> orderList = new List<NE__Order__c>();
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(10, true);
        insert oppList;
        for(Integer i = 0; i<n; i++){
            NE__Order__c order = new NE__Order__c();
            order.NE__OptyId__c = oppList[i].Id;
            order.NE__AccountId__c = oppList[i].AccountId;
            order.RecordTypeId = configOptyId;
            orderList.add(order);
        }
        insert orderList;
        insert XC_DF_WorkType.createWorkType (Label.XC_CL_CommercialVisit);
            
        List<WorkOrder> woList = new List<WorkOrder>();
        for(Integer i = 0; i<n; i++){
            WorkOrder wo = new WorkOrder();
            wo.XC_Opportunity__c = oppList[i].Id;
            wo.XC_WorkTypeLabel__c = Label.XC_CL_CommercialVisit;
            woList.add(wo);
        }
        insert woList;
        
        List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();
        for(Integer i = 0; i<n; i++){
            WorkOrderLineItem woli = new WorkOrderLineItem();
            woli.WorkOrderId =  woList[i].Id;
            woli.XC_OrderOfActivity__c = 2;
            woliList.add(woli);
        }
        
        insert woliList;
    }
    
    
    static testMethod void onUpdate() {
        
        Id configOrderId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        List<NE__Order__c> orderList  = [SELECT Id FROM NE__Order__c];
        
        for(NE__Order__c ord : orderList){
            ord.RecordTypeId = configOrderId;
        }
        Test.startTest();
        update orderList;
        Test.stopTest();
        System.assertEquals(10, orderList.size());
    }
}