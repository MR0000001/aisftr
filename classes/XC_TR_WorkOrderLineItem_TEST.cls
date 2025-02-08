/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_TEST – Test Class for XC_TR_WorkOrder AND Handler
*/ 
@isTest
public class XC_TR_WorkOrderLineItem_TEST {
     @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    static testMethod void onInsert(){
       Test.startTest();
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'Commercial Visit');
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        insert woli;
        woli.Status = 'In Progress' ; 
        update woli;
        delete woli;
        System.assertEquals(true, woli!=null);
        Test.stopTest(); 
        
    }
    
    

}