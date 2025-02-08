/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation: 01/10/2019
* @date Modification:
* @description XC_LCC159_CustomerNotReachable - Controller class of the component XC_LCC159_CustomerNotReachable.
*/ 

public without sharing class XC_LCC159_CustomerNotReachable {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC159_CustomerNotReachable');
    /**
    * @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
    * @param workOrderId
    * @param selectedOptionValue
    * @description assign status and statusReason at the Work Orders
    * @return resWrapper 
    */
    @AuraEnabled        
    public static XC_UTIL_ResultWrapper updateFLS(String workOrderId, string selectedOptionValue){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        List<WorkOrder> woList = new List<WorkOrder>([
            SELECT Id, XC_StatusReason__c, XC_WorkTypeCategory__c 
            FROM WorkOrder 
            WHERE Id = :workOrderId
        ]);
        WorkOrder wo = woList[0];
        XC_UTIL_Sobject.WrapperResult wrWO = new XC_UTIL_Sobject.WrapperResult();       
        wo.XC_StatusReason__c = Label.XC_CL_CustomerNotReachable;
        wo.XC_Comments__c = selectedOptionValue;
        wrWO = XC_UTIL_Sobject.updateRecord(wo);
        Boolean updateSuccess = wrWO.success;
        resWrapper.success = updateSuccess;
        if(updateSuccess) {
            resWrapper.resultMessage = Label.XC_CL_WorkOrder_Updated;
        }else {
             resWrapper.resultMessage = wrWO.errorMessage;
        }
       return resWrapper; 
     }
}