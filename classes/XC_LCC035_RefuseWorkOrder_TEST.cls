/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC035_RefuseWorkOrder_TEST – Test Class of XC_LCC035_RefuseWorkOrder
*/

@isTest
public class XC_LCC035_RefuseWorkOrder_TEST {
    static testMethod void changesWorkOrderTest(){
        String queueName = 'XC_QU_DispatcherQueue';
        Group queue = new Group(Name=queueName, Type='Queue',DoesSendEmailToMembers=true);
        insert queue;
        List<WorkOrder> woListToInsert = new List<WorkOrder>();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        for(WorkOrder wo : woList){
            wo.XC_Refusing_Reason__c = 'Not Interested';
            woListToInsert.add(wo);

        }
        insert woListToInsert;
        insert XC_DF_ServiceAppointment.createServiceAppointment(woList);
        Test.startTest();
        Map<String, String> resMap = XC_LCC035_RefuseWorkOrder.changesWorkOrder(woList[0].Id, 'Not Interested');
        System.assertEquals(resMap.get('status') , 'success');
        Test.stopTest();
     }
    
        static testMethod void changesWorkOrderTestDue(){
        String queueName = 'XC_QU_DispatcherQueue';
        Group queue = new Group(Name=queueName, Type='Queue',DoesSendEmailToMembers=true);
        insert queue;
        List<WorkOrder> woListToInsert = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        insert woListToInsert;
        insert XC_DF_ServiceAppointment.createServiceAppointment(woListToInsert);
        Test.startTest();
        Map<String, String> resMap = XC_LCC035_RefuseWorkOrder.changesWorkOrder(woListToInsert[0].Id, 'Not Interested');
        System.assertEquals(resMap.get('status') , 'success');
        Test.stopTest();
        }
}