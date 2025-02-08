/**
 * The Class XC_LCC035_RefuseWorkOrder.
 *
 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation 06/11/2018
 * @date Modification dd/mm/yyyy
 * @description Refusing Work Order
 */

public without sharing class XC_LCC035_RefuseWorkOrder {

    /**
     * @description Changes work order.
     *
     * @param workOrderId the work order id
     * @param newRefusingReason the new refusing reason
     * @return the map  
     */
    @AuraEnabled
    public static Map<String, String> changesWorkOrder(String workOrderId, String newRefusingReason) {

        Map<String, String> result = new Map<String, String>();

        try {

            if(!Schema.SObjectType.queueSobject.isAccessible()) {
            result.put('message', System.Label.XC_CL_InsufficientPrivileges);
            result.put('status', 'error');
            return result;
        }


            Map<Id,queueSobject> queueDispatcherMap = new Map<Id,queueSobject>([SELECT queue.id 
                FROM queueSobject WHERE queue.developerName = 'XC_QU_DispatcherQueue' LIMIT 1]); 
            
            queueSobject queueDispatcher = new queueSobject();
            queueDispatcher = queueDispatcherMap.values();
            Map<Id,WorkOrder> workOrderToChangeMap = new Map<Id,WorkOrder>([SELECT Id, Status, OwnerId, XC_Refusing_Reason__c, (SELECT Id, Status, OwnerId, XC_Reason_of_Rejection__c FROM ServiceAppointments)
                                            FROM WorkOrder
                                            WHERE Id =: workOrderId]);
            
            WorkOrder workOrderToChange = new WorkOrder();
            workOrderToChange = workOrderToChangeMap.values();

            if(workOrderToChange.XC_Refusing_Reason__c == null){
                workOrderToChange.XC_Refusing_Reason__c = newRefusingReason;
            }
            workOrderToChange.Status = 'New';
            workOrderToChange.OwnerId = queueDispatcher.queue.id;

            if (workOrderToChange.ServiceAppointments.size()>0) {         
                workOrderToChange.ServiceAppointments[0].Status = 'None';
                workOrderToChange.ServiceAppointments[0].OwnerId = queueDispatcher.queue.id;
                workOrderToChange.ServiceAppointments[0].XC_Reason_of_Rejection__c = workOrderToChange.XC_Refusing_Reason__c;
            }    

            XC_UTIL_Sobject.updateRecord(workOrderToChange);
            XC_UTIL_Sobject.updateRecord(workOrderToChange.ServiceAppointments);

            result.put('status', 'success');
            result.put('message', System.Label.XC_CL_OperationCompleted);

        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
        }
    return result;
    }
}