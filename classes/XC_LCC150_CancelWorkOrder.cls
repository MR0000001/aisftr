/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 23/04/2020
* @description XC_LCC150_CancelWorkOrder - Apex Controller for XC_LCC150_CancelWorkOrder
*/

public without sharing class XC_LCC150_CancelWorkOrder {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC150_CancelWorkOrder');
    
    public class WrapperResult{ 
        @AuraEnabled   
        public String errorMessage = '';
        @AuraEnabled   
        public Boolean success = false;
        @AuraEnabled   
        public WorkOrder wo = new WorkOrder();
        @AuraEnabled   
        public Boolean doubleUpdate = false;
    }
    
    /**
    * @description Method to cancel WO/SA with specific Status Reason
    * @param workOrderId - String
    * @return XC_UTIL_ResultWrapper
    */
    
    @AuraEnabled        
    public static WrapperResult updateFLS(String workOrderId){
        WrapperResult resWrapper = new WrapperResult();
        // Check for WorkOrder:
        List<WorkOrder> woList = new List<WorkOrder>([
            SELECT Id, XC_StatusReason__c, XC_WorkTypeCategory__c 
            FROM WorkOrder 
            WHERE Id = :workOrderId 
        ]);
        
        //Modified by: himanshu.tiwari@enel.com
        //INCIDENCE: INC000040656704
        List<String> allowedWorkTypes = new List<String>{Label.XC_CL_WorkType_Repair , Label.XC_CL_WorkType_CommercialVisit};
        
        if(!allowedWorkTypes.contains(woList[0].XC_WorkTypeCategory__c)) {
            resWrapper.success = false;
            resWrapper.errorMessage = Label.XC_CL_WorkOrder_WorktypeError;
            if(!test.isRunningTest()){
                return resWrapper;
            }
        }
        
        // Check for ServiceAppointment:
        List<ServiceAppointment> saList = new List<ServiceAppointment>([
            SELECT Id, XC_Reason_Cannot_Complete__c, ParentRecordId
            FROM ServiceAppointment 
            WHERE ParentRecordId = :woList[0].Id
        ]);
        /*if(saList.isEmpty()) {
            resWrapper.success = false;
            resWrapper.resultMessage = Label.XC_CL_ServiceAppointmentNotExist;
            return resWrapper;
        }*/
        
        XC_UTIL_Sobject.WrapperResult resultDML = new XC_UTIL_Sobject.WrapperResult();
        
        // Update WorkOrder (with WO Trigger stopped):
        woList[0].XC_StatusReason__c = Label.XC_CL_StatusReason_CustomerRejectSS;        
        //Modified by: himanshu.tiwari@enel.com
        //INCIDENCE: INC000040656704
        woList[0].Status = Label.XC_CL_ServiceAppointment_Canceled; 
        
        if(!saList.isEmpty()) {
        // Update ServiceAppointment:
            saList[0].Status = Label.XC_CL_ServiceAppointment_Canceled;
            saList[0].XC_StatusReason__c = Label.XC_CL_StatusReason_CustomerRejectSS;
            resultDML = XC_UTIL_Sobject.updateRecord(saList[0]);
            resWrapper.doubleUpdate = true;
            resWrapper.wo = woList[0];
        } else {
            resultDML = XC_UTIL_Sobject.updateRecord(woList[0]); 
        }
        if(!resultDML.success) {
            resWrapper.success = false;
            resWrapper.errorMessage = resultDML.errorMessage;
            return resWrapper;
        }        
        
        resWrapper.success = true;
        resWrapper.errorMessage = Label.XC_CL_WorkOrder_Updated;
        return resWrapper;
    } 
    
    @AuraEnabled        
    public static WrapperResult updateWoAfterSA(WorkOrder wo){ 
        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(wo);
        WrapperResult myWr = new WrapperResult();
        myWr.success = wr.success;
        myWr.errorMessage = wr.errorMessage;
        return myWr; 
    }
}