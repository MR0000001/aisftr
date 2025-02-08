/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/05/2019
* @description XC_SC003_AutoCloseOrder_TEST – Test class for XC_SC003_AutoCloseOrder
*/ 

@isTest
private class XC_SC003_AutoCloseOrder_TEST {
    @isTest
    private static void onExecuteBatchWithoutSa() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.assertNotEquals(null, order.NE__OptyId__c);
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_Opportunity__c = order.NE__OptyId__c;
        insert listWorkOrder;
        
        Test.startTest();
        Database.executeBatch(new XC_SC003_AutoCloseOrder(), 50); 
        Test.stopTest();
    }

    @isTest
    private static void onExecuteBatchWithSa() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.assertNotEquals(null, order.NE__OptyId__c);
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_Opportunity__c = order.NE__OptyId__c;
        insert listWorkOrder;
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(listWorkOrder);
        insert listServiceAppointment;
        
        Test.startTest();
        XC_SC003_AutoCloseOrder myClass = new XC_SC003_AutoCloseOrder();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
        Test.stopTest();
        //Database.executeBatch(new XC_SC003_AutoCloseOrder(), 50);  
    }

}