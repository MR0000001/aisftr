/**
 * The Class XC_LCC181_CIECannotProceed.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 01/04/2020
 * @description XC_LCC181_CIECannotProceed – Controller for XC_LCP181_CIECannotProceed Component
 */
public without sharing class XC_LCC181_CIECannotProceed {
    
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
    * @author Del Prete Domenico | 1/4/2020 
    * @param recordId 
    * @return ResultWrapper 
    **/
    @AuraEnabled
    public static ResultWrapper cannotProceedCIE (Id recordId){
        ResultWrapper rw = new ResultWrapper(); 
        List<WorkOrder> listOfWo = new List<WorkOrder>([SELECT Id, XC_Configuration__c, XC_WorkTypeLabel__c, XC_Opportunity__c, XC_Check_Final_Status__c FROM WorkOrder WHERE Id =: recordId]);
        WorkOrder wo = listOfWo[0];
        if(!Label.XC_CL_WorkType_SiteInspection_CIE.equals(wo.XC_WorkTypeLabel__c)){
            rw.message = Label.XC_CL_ErroMessage_WorkType;
            return rw;
        }
        if(wo.XC_Check_Final_Status__c){
            rw.message = Label.XC_CL_ServiceAppointment_WOFinalStatus;
            return rw;
        }
        wo.Status = Label.XC_CL_CannotComplete;
        wo.XC_StatusReason__c = Label.XC_CL_StatusReasonWo_CannotProceed; 
        XC_UTIL_Sobject.WrapperResult dmlWo = XC_UTIL_Sobject.updateRecord(wo);        
        if(!dmlWo.success){
            rw.message = dmlWo.errorMessage;
            return rw;
        }
        NE__Order__c ordWo = new NE__Order__c(Id = wo.XC_Configuration__c);
        ordWo.XC_Status__c = Label.XC_CL_Configuration_OrderCancelled;
        XC_UTIL_Sobject.WrapperResult dmlOrder = XC_UTIL_Sobject.updateRecord(ordWo);
        if(!dmlOrder.success){
            rw.message = dmlOrder.errorMessage;
            return rw;
        }
        Opportunity oppWo = new Opportunity (Id = wo.XC_Opportunity__c);
        oppWo.StageName = Label.XC_CL_Opportunity_ClosedLost;
        XC_UTIL_Sobject.WrapperResult dmlOpp = XC_UTIL_Sobject.updateRecord(oppWo);
        if(!dmlOpp.success){
            rw.message = dmlOpp.errorMessage;
            return rw;
        }
        rw.success = true;
        rw.message = Label.XC_CL_WorkOrder_Updated;
        return rw;
    }
}