/**
 * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 18/06/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_ProvisioningStep_U_StepFinalStatus – Class to trigger the Provisioing Process.
 */

public without sharing class XC_TR_ProvisioningStep_U_StepFinalStatus { 

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ProvisioningStep_U_StepFinalStatus');

    /** @description The Class ReturnWrapper */
     public class ReturnWrapper{
        public List<WorkOrder> listWorkOrder ;
        public List<ServiceAppointment> listServiceAppointment;
     }



    /**
     * @description On after update. 
     * @param mapOld the map old
     * @param mapNew the map new
     */ 

    public static void onAfterUpdate(Map<Id,SObject> mapOld, Map<Id,SObject> mapNew){
    	XC_UTIL_Debug.debug(DEBUGACTIVE, '@@afterUpdate');
        List<String> fieldList = new List<String>{'XC_Status__c'};
        List<XC_Provisioning_Step__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<XC_Provisioning_Step__c> listCompletedKOSteps = getListCompletedKOSteps(listChanged);       
        if(listCompletedKOSteps.isEmpty()){ 
            return;
        }
        List<String> orderItemListId = XC_UTIL_Sobject.getListFieldValues(listCompletedKOSteps, 'XC_Configuration_Item__c');
        if(orderItemListId.isEmpty()){     
            return;
        }
        List<NE__OrderItem__c> ciListToUpdate = getCiListToUpdate(orderItemListId);              
        ReturnWrapper returnWrapper = getSaListToUpdate(orderItemListId);

        if(listCompletedKOSteps[0].XC_Flow_API_Name__c == Label.XC_CL_ProvisioningExecutePayment_Flow) {
            updateStatusReason(returnWrapper.listWorkOrder);
        }
        List<SObject> sObjectsToUpdate = new List<SObject>();
        sObjectsToUpdate.addAll( (List<SObject>) returnWrapper.listServiceAppointment);
        sObjectsToUpdate.addAll( (List<SObject>) ciListToUpdate );
        XC_UTIL_Sobject.updateListRecords(sObjectsToUpdate);
    }

    private static List<XC_Provisioning_Step__c> getListCompletedKOSteps(List<XC_Provisioning_Step__c> listChanged){
        List<XC_Provisioning_Step__c> listCompletedKOSteps = new List<XC_Provisioning_Step__c>();
        for(XC_Provisioning_Step__c step : listChanged){
            if(XC_UTIL_ProvisioningStep.isFailed(step.XC_Status__c) && step.XC_ErrorMessage__c != Label.XC_CL_ProductReservationError){
                listCompletedKOSteps.add(step);
            } 
        }
        return listCompletedKOSteps;
    }

    private static List<NE__OrderItem__c> getCiListToUpdate(List<String> orderItemListId){
        List<NE__OrderItem__c> ciListToUpdate = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> ciList = new List<NE__OrderItem__c>([
            SELECT ID, NE__Status__c
            FROM NE__OrderItem__c
            WHERE Id IN:orderItemListId
        ]);
        
        for (NE__OrderItem__c ci : ciList){
            ci.NE__Status__c = Label.XC_CL_Configuration_Cancelled;
            ciListToUpdate.add(ci);
        }
        return ciListToUpdate;
    }
    
    private static ReturnWrapper getSaListToUpdate(List<String> orderItemListId){
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        List<WorkOrder> workOrderList = new List<WorkOrder>([
            SELECT Id, XC_StatusReason__c, XC_WorkTypeCategory__c, Status,
                (SELECT 
                    Id, XC_Reason_Cannot_Complete__c, Status
                FROM ServiceAppointments)
            FROM WorkOrder 
            WHERE XC_Configuration_Item__c IN:orderItemListId
        ]);

        for(WorkOrder wo : workOrderList){

            if(wo.XC_StatusReason__c != 'Technically unviable installation - No viable alternative' && wo.XC_StatusReason__c != 'Technically unviable installation - With alternative' && wo.XC_StatusReason__c != 'Customer wants modifications with an already accepted budget' ){
                for(ServiceAppointment sa : wo.ServiceAppointments){
                    if (sa.Status == Label.XC_CL_ServiceAppointment_In_Progress || sa.Status == Label.XC_CL_ServiceAppointment_Dispatched){
                        sa.Status = Label.XC_CL_CannotComplete; 
                    }else if(sa.Status == Label.XC_CL_ServiceAppointment_Scheduled || sa.Status == Label.XC_CL_ServiceAppointment_None || sa.Status == Label.XC_CL_ServiceAppointment_OnHold){ 
                        sa.Status = Label.XC_CL_Cancelled;
                    }
                    sa.XC_Reason_Cannot_Complete__c = Label.XC_CL_ServiceAppointment_CannotCompleteReason_Disconnection	;
                    saList.add(sa);

                }
            }
        }
        ReturnWrapper returnWrapper = new ReturnWrapper();
        returnWrapper.listWorkOrder = workOrderList;
        returnWrapper.listServiceAppointment = saList;
        return returnWrapper;
    }

    private static void updateStatusReason(List<WorkOrder> listWorkOrder) {
        List<WorkOrder> listWOToUpdate = new List<WorkOrder>();
        for(WorkOrder wo: listWorkOrder) {
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation ) {
                wo.XC_StatusReason__c = Label.XC_CL_WorkOrderReason_PrepaidNotCompleted;
                wo.Status = Label.XC_CL_WorkOrder_Canceled;
                listWOToUpdate.add(wo);
            }
        }
        XC_UTIL_Sobject.updateListRecords(listWOToUpdate);
    }
    
}