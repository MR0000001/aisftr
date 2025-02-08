/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  30/05/2019 
* @description XC_TR_WorkOrderLineItem_U_upW_D_TEST – Test class for XC_TR_WorkOrderLineItem_U_upWOS_D
*/
@isTest
public with sharing class XC_TR_WorkOrderLineItem_U_upW_D_TEST {
    // Test method for getWorkOrderFromChildren
    static testMethod void getWorkOrderFromChildren(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        insert woli;
        woli.Status = 'In Progress' ;
        update woli;

        System.assert(wo!=null);   
        Test.stopTest(); 
    }
}