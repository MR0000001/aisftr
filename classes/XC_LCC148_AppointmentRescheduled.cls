/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation: 04/09/2019
* @date Modification:
* @description XC_LCC148_AppointmentRescheduled - Controller class of the component XC_LCC148_AppointmentRescheduled.
*/
public without sharing class XC_LCC148_AppointmentRescheduled {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC148_AppointmentRescheduled');
    /**
    * @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
    * @param workOrderId
    * @description assign status and statusReason at the Work Orders
    * @return Boolean
    */
    @AuraEnabled        
    public static XC_UTIL_ResultWrapper updateFLS(String workOrderId){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        List<WorkOrder> woList = new List<WorkOrder>([
            SELECT Id, Status, XC_StatusReason__c, XC_WorkTypeCategory__c
            FROM WorkOrder 
            WHERE Id = :workOrderId
        ]);
        List<ServiceAppointment> saList = new List<ServiceAppointment>([SELECT Id, Status, XC_Reason_Cannot_Complete__c, ParentRecordId
            FROM ServiceAppointment 
            WHERE ParentRecordId IN :woList
        ]); 

        WorkOrder wo = woList[0]; 
        ServiceAppointment sa = saList[0];
        
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();

         if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit ||
            wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation){
            sa.XC_StatusReason__c = Label.XC_CL_StatusReason_Appointmentrescheduledbyclient;
            wr = XC_UTIL_Sobject.updateRecord(sa);
            resWrapper.success = wr.success;
            if(wr.success) {
                resWrapper.resultMessage = Label.XC_CL_WorkOrder_Updated;
            }
            else {
                resWrapper.resultMessage = wr.errorMessage;
            }
            
        }else{
            resWrapper.success = false;
            resWrapper.resultMessage = Label.XC_CL_WorkOrder_WorktypeError;
        }
        
        return resWrapper;
    }

}