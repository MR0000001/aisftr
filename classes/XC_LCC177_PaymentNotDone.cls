/**
 * The Class XC_LCC139_DocumentVerification.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 02/03/2020
 * @description XC_LCC177_PaymentNotDone – Controller for XC_LCP177_PaymentNotDone Component
 */
public without sharing class XC_LCC177_PaymentNotDone {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC177_PaymentNotDone');
    
    /**
    * @description The Class resultWrapper.
    */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String  message = 'Error'; 
    }

    /**
    * @description 
    * @author Del Prete Domenico | 2/3/2020 
    * @param recordId 
    * @return ResultWrapper 
    **/
    @AuraEnabled
    public static ResultWrapper paymentNotDone (Id recordId){
        ResultWrapper rw = new ResultWrapper();
        List<XC_Provisioning_Step__c> listOfProvStep = new List<XC_Provisioning_Step__c>([SELECT Id, XC_StepLabel__c, XC_Configuration_Item__c, XC_Status__c FROM XC_Provisioning_Step__c WHERE Id =: recordId]);
        XC_Provisioning_Step__c provStep = listOfProvStep[0];
        if(!Label.XC_CL_ProvStep_PaymentCheck.equals(provStep.XC_StepLabel__c)){
            rw.message = Label.XC_CL_StepNotCorrect;
            return rw;
        }
        if(!provStep.XC_Status__c.equals(Label.XC_CL_Provisioning_Step_NotStarted) && !provStep.XC_Status__c.equals(Label.XC_CL_Provisioning_Step_InProgress)){
            rw.message = Label.XC_CL_PaymentNotDone_StepAlreadyInACompletedStatus;
            return rw;
        }

        List<WorkOrder> listOfWo = new List<WorkOrder>([SELECT Id FROM WorkOrder WHERE XC_Configuration_Item__c =: provStep.XC_Configuration_Item__c]);
        WorkOrder woToUpdate = new WorkOrder();
        ServiceAppointment saToUpdate = new ServiceAppointment();
        if(!listOfWo.isEmpty()){
            List<ServiceAppointment> listOfSa = new List<ServiceAppointment>([SELECT Id FROM ServiceAppointment WHERE ParentRecordId =:listOfWo[0].Id]);
            if(!listOfSa.isEmpty()){
                saToUpdate.Id = listOfSa[0].Id;
                saToUpdate.Status = Label.XC_CL_WorkOrder_Cancelled;
                saToUpdate.XC_StatusReason__c = Label.XC_CL_ServiceAppointment_StatusReason_PrepaidNotCompleted;
            }
            woToUpdate.Id = listOfWo[0].Id;
            woToUpdate.Status = Label.XC_CL_WorkOrder_Cancelled;
            woToUpdate.XC_StatusReason__c = Label.XC_CL_WorkOrder_StatusReason_PrepaidNotCompleted;
        }
        XC_UTIL_Sobject.WrapperResult dmlProvSa =XC_UTIL_Sobject.updateRecord(saToUpdate);
        if(!dmlProvSa.success){
            rw.message = dmlProvSa.errorMessage;
            return rw;
        }
        XC_UTIL_Sobject.WrapperResult dmlWorkOrder = XC_UTIL_Sobject.updateRecord(woToUpdate);
        if(!dmlWorkOrder.success){
            rw.message = dmlWorkOrder.errorMessage;
            return rw;
        }
        provStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        XC_UTIL_Sobject.WrapperResult dmlProvStep =XC_UTIL_Sobject.updateRecord(provStep);
        if(!dmlProvStep.success){
            rw.message = dmlProvStep.errorMessage;
            return rw;
        }
        rw.success = true;
        rw.message = Label.XC_CL_SuccessUpdatePaymentNotDone;
        return rw;
    }
}