@istest
public class XC_TR_WOLI_U_ClosureManagementB2B_test {
    static testMethod  void closeWoli ()
    {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
        List<Lead> lea=XC_DF_Lead.createResidentialLeads(1);
        lea[0].XC_Segment__c='B2G';
        lea[0].Phone='3334567890';
        lea[0].RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        insert wo; 
        List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(1);
        insert listNew;
        WorkType wor= XC_DF_WorkType.createWorkType('Delivery');
        insert wor;
        //XC_Provisioning_Step__c stepsToUpdate = new XC_Provisioning_Step__c();
        //stepsToUpdate.XC_Configuration_Item__c= listNew[0].id;
        //List <XC_Provisioning_Step__c> steps = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c steps = new XC_Provisioning_Step__c();
        steps.XC_Configuration_Item__c =listNew[0].id;
        steps.XC_Status__c = 'In Progress';
        steps.XC_Step_Order__c = 1;
        //insert provisioningStep;
        //steps.XC_Configuration_Item__c=listNew[0].id; 
        //steps.add(stepsToUpdate);
        insert steps;
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= wo[0].Id; 
  		woli.Status = 'In Progress';
        woli.XC_OrderOfActivity__c=1;
        woli.XC_ProvisioningStep__c=steps.id;
        woli.XC_WOLIType__c ='Partner Engagement';
        List<WorkOrderLineItem> wolili = new list<WorkOrderLineItem>();
        wolili.add(woli);
        insert wolili;
        woli.Status = 'Completed';
        update woli;
        Map<id,WorkOrderLineItem> mapNew= new Map <id,WorkOrderLineItem>();
   		mapNew.put(wolili[0].id,wolili[0]);
        Map<id,WorkOrderLineItem> mapOld= new Map <id,WorkOrderLineItem>();
   		mapOld.put(wolili[0].id,wolili[0]); 
        
        //stepsToUpdate.id=woli.XC_ProvisioningStep__c;
        //update stepsToUpdate;
        insert u;
        System.assert(wo!=null);
        System.runAs(u)
        {
            XC_TR_WOLI_U_ClosureManagementB2B.closeWoli(wolili,mapOld,mapNew);
        }
        test.stopTest();
    }
}