/**
* @author Chiara Turco cturco@deloitte.it & Roberta Cossiga rcossiga@deloitte.it
* @description Class for manage WorkOrder Cancellation
**/
public without sharing class XC_TR_WorkOrder_U_CancellationManagement {

    /**
     * @description Manage case status on update.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void manageWorkOrderCancellation(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            checkServiceAppointmentCancellation(listChanged);
        }
    }

    /**
     * @description Manage case status on update.
     * @param listNew the list new   
     */
    public static void checkServiceAppointmentCancellation(List<WorkOrder> listNew){
        List<WorkOrder> listToManage = new List<WorkOrder>();
        for(WorkOrder wo : listNew){
            if(
                (wo.XC_WorkTypeCategory__c == Label.XC_CL_CommercialVisit || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance)
                && (wo.Status == Label.XC_CL_WorkOrder_Canceled || wo.Status == Label.XC_CL_WorkOrder_CannotComplete)
            ) {
                listToManage.add(wo);
            }
        }
        if(listToManage.isEmpty()){
            return;
        }

        List<Id> woIds = XC_UTIL_SObject.getIds(listToManage);
        Map<Id,WorkOrder> mapWorkOrder = new Map<Id,WorkOrder>( 
            [SELECT Id, Status,
                (SELECT Id, Status, XC_Reason_Cannot_Complete__c
                 FROM ServiceAppointments)
            FROM WorkOrder
            WHERE Id IN: woIds
            ]);
        for(WorkOrder wo : listToManage){
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_CommercialVisit || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
                if(wo.Status == Label.XC_CL_WorkOrder_Canceled){
                    manageCanceled(wo, mapWorkOrder);
                }else if(wo.Status == Label.XC_CL_WorkOrder_CannotComplete){
                    manageCannotComplete(wo, mapWorkOrder);
                }
            }
        }
    }

    /**
     * @description Manage case status on update.
     * @param wo
     * @param mapWorkOrder 
     */

    public static void manageCanceled(WorkOrder wo, Map<Id,WorkOrder> mapWorkOrder){
        List<ServiceAppointment> serviceAppointmentCanceled = new List<ServiceAppointment>();
        if(!mapWorkOrder.get(wo.Id).ServiceAppointments.isEmpty()){
            for(ServiceAppointment sa : mapWorkOrder.get(wo.Id).ServiceAppointments){
                if(sa.Status == Label.XC_CL_WorkOrder_Canceled){
                    serviceAppointmentCanceled.add(sa);
                }
            }
        }
        if(!mapWorkOrder.get(wo.Id).ServiceAppointments.isEmpty() && serviceAppointmentCanceled.isEmpty()){
            wo.addError(Label.XC_CL_WorkOrder_CannotCancel);
        }
    }

    /**
     * @description Manage case status on update.
     * @param wo 
     * @param mapWorkOrder 
     */

    public static void manageCannotComplete(WorkOrder wo, Map<Id,WorkOrder> mapWorkOrder){
        List<ServiceAppointment> serviceAppointmentCannotComplete = new List<ServiceAppointment>();
        if(!mapWorkOrder.get(wo.Id).ServiceAppointments.isEmpty()){
            for(ServiceAppointment sa : mapWorkOrder.get(wo.Id).ServiceAppointments){
                if(sa.Status == Label.XC_CL_WorkOrder_CannotComplete && sa.XC_Reason_Cannot_Complete__c.containsIgnoreCase(Label.XC_CL_ReasonFinal) ){
                    serviceAppointmentCannotComplete.add(sa);
                }
            }
        }
        if(!mapWorkOrder.get(wo.Id).ServiceAppointments.isEmpty() && serviceAppointmentCannotComplete.isEmpty()){
            wo.addError(Label.XC_CL_WorkOrder_PutInCannotComplete);
        }
    }

}