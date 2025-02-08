/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation: 09/09/2019
* @date Modification:
* @description XC_LCC151_ContractViolation - Controller class of the component XC_LCC151_ContractViolation.
*/

public without sharing class XC_LCC151_ContractViolation {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC151_ContractViolation');
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
            SELECT Id, XC_StatusReason__c, XC_WorkTypeCategory__c 
            FROM WorkOrder 
            WHERE Id = :workOrderId
        ]);

        List<ServiceAppointment> saList = new List<ServiceAppointment>([
            SELECT Id, XC_Reason_Cannot_Complete__c, ParentRecordId
            FROM ServiceAppointment 
            WHERE ParentRecordId IN :woList
        ]);
        
        if(saList.isEmpty()){
            resWrapper.resultMessage = Label.XC_CL_ServiceAppointmentNotExist;
            return resWrapper;
        }
        ServiceAppointment sa = saList[0];
        WorkOrder wo = woList[0];

        XC_UTIL_Sobject.WrapperResult wrWO = new XC_UTIL_Sobject.WrapperResult();
        XC_UTIL_Sobject.WrapperResult wrSA = new XC_UTIL_Sobject.WrapperResult();

        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair || 
            wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
            wo.status = Label.XC_CL_WorkOrder_Cancelled;
            wo.XC_StatusReason__c = Label.XC_CL_ContractViolation;
            sa.status = Label.XC_CL_ServiceAppointment_Canceled;
            sa.XC_StatusReason__c = Label.XC_CL_ContractViolation;
            wrWO = XC_UTIL_Sobject.updateRecord(wo);
            wrSA = XC_UTIL_Sobject.updateRecord(sa);
            Boolean updateSuccess = wrWO.success && wrSA.success;
            resWrapper.success = updateSuccess;
            if(updateSuccess) {
                resWrapper.resultMessage = Label.XC_CL_WorkOrder_Updated;
            }
            else {
                resWrapper.resultMessage = wrWO.errorMessage;
            }
            
        }else{
            resWrapper.success = false;
            resWrapper.resultMessage = Label.XC_CL_WorkOrder_WorktypeError;
        }
        return resWrapper;
    }
}