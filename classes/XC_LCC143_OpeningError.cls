/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com, Anna Maria Rosanova - annamaria.rosanova@nttdata.com
* @date Creation: 03/09/2019
* @date Modification:
* @description XC_LCC143_OpeningError - Controller class of the component XC_LCP143_OpeningError.
*/

public without sharing class XC_LCC143_OpeningError {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC143_OpeningError');

    /**
    * @author Massimiliano Avallone - massimiliano.avallone@nttdata.com, Anna Maria Rosanova - annamaria.rosanova@nttdata.com
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

        if(woList.isEmpty()){
            resWrapper.resultMessage = Label.XC_CL_WorkOrderNotExist;
            return resWrapper;
        } 
 
        WorkOrder wo = woList[0];
        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
            wo.status = Label.XC_CL_WorkOrder_Cancelled;
            wo.XC_StatusReason__c = Label.XC_CL_Opening_Error;
            XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(wo);
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