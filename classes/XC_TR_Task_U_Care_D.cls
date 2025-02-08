/**
 * @description DAO Class for XC_TR_Task_U_Care.
 */
public without sharing class XC_TR_Task_U_Care_D {
    /**
    * @description query on Work Orders
    * @param workOrderId the id of work order
    * @return workOrderList list of work order    
    */
    public static List<WorkOrder> getWorkOrders(Set<Id> workOrderId){
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        if(Schema.sObjectType.WorkOrder.isAccessible() && Schema.sObjectType.WorkOrder.fields.Id.isAccessible() && Schema.sObjectType.WorkOrder.fields.OwnerId.isAccessible() && Schema.sObjectType.WorkOrder.fields.XC_ReclamationCounter__c.isAccessible()){   
            workOrderList = [SELECT Id,OwnerId,XC_ReclamationCounter__c FROM WorkOrder WHERE Id IN: workOrderId];
        }
        return workOrderList;
    }
}