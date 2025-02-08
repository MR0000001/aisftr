/*
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 02/05/2020
* @description XC_LCC185_PendingOrder_TEST – Test Class for XC_LCC185_PendingOrder
*/

@isTest
private class XC_LCC185_PendingOrder_TEST {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC185_PendingOrder_TEST');
    
    @isTest 
    static void successPendingOrder() {
        insert new OneOrg__c(Name = 'OneOrg (User)', XC_Spain_Triggers__c = true); 
        ServiceAppointment sa = XC_DF_ServiceAppointment.createServiceAppointment(1)[0];
        insert sa;
        WorkOrder wo = new WorkOrder(
            Id = sa.ParentRecordId,
            Status = Label.XC_CL_WorkOrder_Assigned      
        );
        update wo;
        wo.Status = Label.XC_CL_WorkOrder_InProgress;
        update wo;
        Test.startTest();
        XC_LCC185_PendingOrder.managePendingOrder(wo.Id);
        Test.stopTest();
    }

    @isTest 
    static void errorStatusPendingOrder() {
        insert new OneOrg__c(Name = 'OneOrg (User)', XC_Spain_Triggers__c = true); 
        ServiceAppointment sa = XC_DF_ServiceAppointment.createServiceAppointment(1)[0];
        insert sa;
        Test.startTest();
        XC_LCC185_PendingOrder.managePendingOrder(sa.ParentRecordId);
        Test.stopTest();
    }

    @isTest 
    static void errorNoSAPendingOrder() {
        insert new OneOrg__c(Name = 'OneOrg (User)', XC_Spain_Triggers__c = true); 
        XC_Address__c address = XC_DF_Address.createAddress(1)[0];
        insert address;
        WorkOrder workOrderToInsert = new WorkOrder();
        workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_CommercialVisit;
        workOrderToInsert.XC_LegalEntity__c = Label.XC_CL_EndesaX;
        workOrderToInsert.XC_Address__c = address.Id;
        workOrderToInsert.Street = address.XC_Address__c;
        insert workOrderToInsert;
        Test.startTest();
        XC_LCC185_PendingOrder.managePendingOrder(workOrderToInsert.Id);
        Test.stopTest();
    }

}