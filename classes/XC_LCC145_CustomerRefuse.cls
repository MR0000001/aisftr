/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com, Anna Maria Rosanova - annamaria.rosanova@nttdata.com
* @date Creation: 04/09/2019
* @date Modification:
* @description XC_LCC145_CustomerRefuse - Controller class of the component XC_LCC145_CustomerRefuse.
*/
public without sharing class XC_LCC145_CustomerRefuse {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC145_CustomerRefuse');
    
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
    * @author Massimiliano Avallone - massimiliano.avallone@nttdata.com, Anna Maria Rosanova - annamaria.rosanova@nttdata.com
    * @param workOrderId
    * @description assign status and statusReason at the Work Orders
    * @return Boolean
    */  
    @AuraEnabled        
    public static WrapperResult updateFLS(String workOrderId){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        List<WorkOrder> woList = new List<WorkOrder>([
            SELECT Id, Status, XC_StatusReason__c, XC_WorkTypeCategory__c
            FROM WorkOrder 
            WHERE Id = :workOrderId
        ]);

        List<ServiceAppointment> saList = new List<ServiceAppointment>([
            SELECT Id, Status, XC_Reason_Cannot_Complete__c, ParentRecordId
            FROM ServiceAppointment 
            WHERE ParentRecordId IN :woList
        ]);

        WorkOrder wo = woList[0];
        WrapperResult wr = new WrapperResult();
        if(!saList.isEmpty()){
            return cancelServiceAppointmentAndWO(saList[0], wo);
        }else{
            return cancelWorkOrder(wo);
        }
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 07-15-2020 
    * @param ServiceAppointment sa 
    **/
    private static WrapperResult cancelServiceAppointmentAndWO(ServiceAppointment sa, WorkOrder wo){
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        if(sa.Status == Label.XC_CL_ServiceAppointment_None || sa.Status == Label.XC_CL_ServiceAppointment_Scheduled || sa.Status == Label.XC_CL_ServiceAppointment_OnHold){
            sa.Status = Label.XC_CL_ServiceAppointment_Canceled;
            wo.Status = Label.XC_CL_WorkOrder_Canceled;
        } else {
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            wo.Status = Label.XC_CL_WorkOrder_CannotComplete;
            sa.XC_Reason_Cannot_Complete__c = 'No more interest received from customer_FINAL';
        }
        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_CustomerRejectSS;
        wo.XC_Digitized__c = true;
        wo.XC_ToBeManuallyDigitalized__c = true; 
        wr = XC_UTIL_Sobject.updateRecord(sa); 
        WrapperResult myWr = new WrapperResult();
        myWr.success = wr.success;
        myWr.errorMessage = wr.errorMessage;
        myWr.wo = wo;
        myWr.doubleUpdate = true;
        return myWr;
    }
    
    @AuraEnabled        
    public static WrapperResult updateWoAfterSA(WorkOrder wo){ 
        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(wo);
        WrapperResult myWr = new WrapperResult();
        myWr.success = wr.success;
        myWr.errorMessage = wr.errorMessage;
        return myWr; 
    }
    
    

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 07-15-2020 
    * @param wo 
    * @return XC_UTIL_Sobject.WrapperResult 
    **/
    private static WrapperResult cancelWorkOrder(WorkOrder wo){
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        if(wo.Status == Label.XC_CL_WorkOrder_New || wo.Status == Label.XC_CL_OnHold){
            wo.Status = Label.XC_CL_WorkOrder_Canceled;
        } else {
            wo.Status = Label.XC_CL_WorkOrder_CannotComplete;
            wo.XC_Reason_Cannot_Complete__c = 'No more interest received from customer_FINAL';
        }
        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_CustomerRejectSS;
        wr = XC_UTIL_Sobject.updateRecord(wo); 
        WrapperResult myWr = new WrapperResult();
        myWr.success = wr.success;
        myWr.errorMessage = wr.errorMessage;
        return myWr;
    }
}