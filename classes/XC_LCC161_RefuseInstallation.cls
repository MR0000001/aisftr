/**
* @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
* @date Creation: 08/10/2019
* @date Modification:
* @description XC_LCC161_RefuseInstallation - Controller class of the component XC_LCP161_RefuseInstallation.
*/

public without sharing class XC_LCC161_RefuseInstallation {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC161_RefuseInstallation');

    /**
    * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
    * @param workOrderId
    * @description assign status and statusReason at the Work Orders
    * @return Boolean
    */
    @AuraEnabled        
    public static XC_UTIL_ResultWrapper updateFLS(String workOrderId){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        List<WorkOrder> woList = new List<WorkOrder>([
            SELECT Id, Status, XC_StatusReason__c, XC_WorkTypeCategory__c, (Select id from ServiceAppointments)
            FROM WorkOrder 
            WHERE Id = :workOrderId
        ]);
        List<ServiceAppointment> saListToUpdate = new List<ServiceAppointment>(); 
        for(WorkOrder wo: woList){
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && wo.status == Label.XC_CL_OnHold && !wo.ServiceAppointments.isEmpty()){
                for(ServiceAppointment sa : wo.ServiceAppointments){
                    wo.XC_StatusReason__c = Label.XC_CL_StatusReason_RejectInstallation;
                    sa.XC_StatusReason__c = Label.XC_CL_StatusReason_RejectInstallation;
                    sa.Status =Label.XC_CL_WorkOrder_CannotComplete;
                    sa.XC_Reason_Cannot_Complete__c ='Rethinking_FINAL';
                    saListToUpdate.add(sa);
                }
            }else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && wo.ServiceAppointments.isEmpty()){
                    wo.XC_StatusReason__c = Label.XC_CL_SaleCanceledByTheCustomer;
                    wo.Status =Label.XC_CL_WorkOrder_Cancelled;
            }else{
                resWrapper.success = false;
                resWrapper.resultMessage = Label.XC_CL_WorkOrder_WorktypeError;
            }   
        }

        List<XC_UTIL_Sobject.WrapperResult> wrList= XC_UTIL_Sobject.updateListRecords(saListToUpdate);
        if(XC_UTIL_Sobject.checkDMLResults(wrList)){
            XC_UTIL_Sobject.updateListRecords(woList);
        }else{
            resWrapper.success = false;
            resWrapper.resultMessage =wrList[0].errorMessage;
        }
        
        return resWrapper;  
}
}