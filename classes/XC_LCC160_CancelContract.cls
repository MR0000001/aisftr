/**
 * The Class XC_LCC160_CancelContract.
 *
 * @author Valeria Martino - valeria.martino@nttadata.com
 * @date Creation 08/10/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC160_CancelContract – Controller for XC_LCP160_CancelContract Component
 */
public without sharing class XC_LCC160_CancelContract {
    

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC160_CancelContract');
    /**
    * @description The Class resultWrapper.
    */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String  message = Label.XC_CL_WorkOrder_SuccessUpdateStatus; 
    }
     /**
    * @description
    * @author Valeria Martino - 08/10/2019
    * @param recordId String 
    * @return XC_LCC139_DocumentVerification.XC_LCC139_DocumentVerification.ResultWrapper
    */
    @AuraEnabled
    public static XC_LCC160_CancelContract.ResultWrapper cancelContract(String recordId){
        
        List<WorkOrder> listWo = new List<WorkOrder>([SELECT Id, Status, XC_StatusReason__c, XC_WorkTypeCategory__c FROM WorkOrder WHERE Id = :recordId LIMIT 1]);
        WorkOrder workOrderToUpdate = new WorkOrder();               
        XC_LCC160_CancelContract.ResultWrapper resultWrapper = new XC_LCC160_CancelContract.ResultWrapper();
            workOrderToUpdate.Status = Label.XC_CL_WorkOrder_Cancelled;
            workOrderToUpdate.XC_StatusReason__c = Label.XC_CL_StatusReason_LowContract;
            workOrderToUpdate.Id = recordId;
        XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.updateRecord(workOrderToUpdate);
        if(!result.success) {
            resultWrapper.message = result.errorMessage;
        }
        resultWrapper.success = result.success;
        return resultWrapper;
    }

}