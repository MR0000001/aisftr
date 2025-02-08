/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  30/05/2019 
* @description XC_TR_WorkOrderLineItem_U_upWU_TEST – Test class for XC_TR_WorkOrderLineItem_U_upWOSUtil
*/
@isTest
public with sharing class XC_TR_WorkOrderLineItem_U_upWU_TEST {
   // Test method for cycleOnWoli
    static testMethod void cycleOnWoli(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'General Work');
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        insert woli;
        woli.Status = 'In Progress' ;
        woli.XC_OrderOfActivity__c=1;
        update woli;
        System.assert(wo!=null);
        Test.stopTest(); 
    }

       // Test method for cycleOnWoli2
    static testMethod void cycleOnWoli2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();

        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'General Work');
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        insert woli;
        woli.Status = Label.XC_CL_WorkOrderLineItem_Closed ;
        woli.XC_Action_Start__c=null;
        update woli;
        System.assert(wo!=null);
        Test.stopTest(); 
    }

}