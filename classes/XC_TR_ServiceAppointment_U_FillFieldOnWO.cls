/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
* @date Creation 26/02/2020
* @description XC_TR_ServiceAppointment_U_FillFieldOnWO - Update the WorkOrder according to SA fields
*/

public without sharing class XC_TR_ServiceAppointment_U_FillFieldOnWO {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceAppointment_U_FillFieldOnWO');

    /**
     * @description Populate fields from work order and Work Order fields
     * @param listNew - List<ServiceAppointment>
     */
    public static void populateFieldsFromWorkOrder(List<ServiceAppointment> listNew) {
        List<String> listOfWorkOrderId = XC_UTIL_SObject.getListFieldValues(listNew, 'ParentRecordId');
        if(!listOfWorkOrderId.isEmpty()) {
            List<WorkOrder> listWorkOrder = new List<WorkOrder>([
                SELECT Id, XC_OriginalDueDate__c, XC_DueDate__c,XC_StatusReasonOfServiceAppointment__c,
                XC_StatusOfServiceAppointment__c,
                    (SELECT Id, DueDate, CreatedDate,XC_StatusReason__c,
                    Status
                    FROM ServiceAppointments)
                FROM WorkOrder
                WHERE Id IN: listOfWorkOrderId
            ]);
            populateDueDates(listWorkOrder);
            populateStatusAndStatusReasonFromSA(listWorkOrder);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateListRecords(listWorkOrder); 
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }       
    }

    /**
     * @description Populate Due Dates fields from Work Order
     * @param listWorkOrder - List<WorkOrder>
     */
    private static void populateDueDates(List<WorkOrder> listWorkOrder) {        
        for(WorkOrder wo : listWorkOrder) {
            // Populate Oringal Due Date From Service Appointment:
            if(wo.XC_OriginalDueDate__c == null){
                for(ServiceAppointment sa : wo.ServiceAppointments){
                    wo.XC_OriginalDueDate__c = sa.DueDate;
                }
            }

            // Populate Due Date from most recent SA:
            Integer rightInteger = 0;
            if(wo.ServiceAppointments.size() > 1){
                for(Integer i=1; i < wo.ServiceAppointments.size(); i++){                
                    if(wo.ServiceAppointments[i].CreatedDate > wo.ServiceAppointments[rightInteger].CreatedDate){
                        rightInteger = i;
                    }
                }
            }    
            wo.XC_DueDate__c = wo.ServiceAppointments[rightInteger].DueDate;    
        }
    }

    /**
     * @description Populate Due Dates fields from Work Order
     * @param listWorkOrder - List<WorkOrder>
     */
    private static void populateStatusAndStatusReasonFromSA(List<WorkOrder> listWorkOrder) {    
        for(WorkOrder wo : listWorkOrder) {
            for(ServiceAppointment sa : wo.ServiceAppointments){
                if(wo.XC_StatusReasonOfServiceAppointment__c == null){
                    wo.XC_StatusReasonOfServiceAppointment__c = sa.XC_StatusReason__c;
                }
                if(wo.XC_StatusOfServiceAppointment__c == null){
                    wo.XC_StatusOfServiceAppointment__c = sa.Status;
                }
            }
        }
    }

}