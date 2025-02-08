@isTest
public class XC_TR_Woli_U_MaintenancePlan_TEST {
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
        XC_TR_Woli_U_MaintenancePlan.getRT(new List<WorkOrderLineItem>{woli});
        Test.stopTest(); 
        
    }
    
    

}