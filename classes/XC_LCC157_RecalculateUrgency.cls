/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation 25/09/2019
* @date Modification 25/03/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC157_RecalculateUrgency - Apex Controller for component XC_LCC157_RecalculateUrgency
*/

public without sharing class XC_LCC157_RecalculateUrgency {
     
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC157_RecalculateUrgency');

    /** @description ResultWrapper */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String  resultMessage = '';
        @AuraEnabled
        public Case  cs = new Case();
        @AuraEnabled
        public String woId = '';
    }
    
    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to update WorkOrder to recalculate urgency
    * @date 25/03/2021
    * @param caseId - String
    * @return ResultWrapper
    */     
    /*public static ResultWrapper updateStatus(String caseId){
        ResultWrapper resWrapper = new ResultWrapper();        
        List<WorkOrder> woList = new List<WorkOrder>([
            SELECT Id, XC_WorkTypeCategory__c, Status, CaseId, Case.XC_Subtype__c, Case.Reason, Case.SubCause__c, Case.XC_Address__c, Case.XC_AssetAttached__c, Case.XC_Urgent__c, Case.XC_WithCommitment__c, Case.XC_LegalEntity__c, Case.XC_Segment__c
            FROM WorkOrder 
            WHERE CaseId =: caseId
        ]);        
        if(woList.isEmpty()){
            resWrapper.resultMessage = Label.XC_CL_WorkOrder_NotExist;
            return resWrapper;
        }       
        WorkOrder wo = woList[0];  
        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair  && wo.status == Label.XC_CL_WorkOrder_New) {
            wo.status = Label.XC_CL_WorkOrder_Cancelled;
            XC_UTIL_Sobject.WrapperResult wrWO = XC_UTIL_Sobject.updateRecord(wo); 
            if(wrWO.success) {
                resWrapper.cs = new Case(
                    Id = wo.CaseId,
                    XC_Subtype__c = wo.Case.XC_Subtype__c,
                    Reason = wo.Case.Reason,
                    SubCause__c = wo.Case.SubCause__c,
                    XC_Address__c = wo.Case.XC_Address__c,
                    XC_AssetAttached__c = wo.Case.XC_AssetAttached__c,
                    XC_Urgent__c = wo.Case.XC_Urgent__c,
                    XC_WithCommitment__c = wo.Case.XC_WithCommitment__c,
                    XC_LegalEntity__c = wo.Case.XC_LegalEntity__c,
                    XC_Segment__c = wo.Case.XC_Segment__c
                ); 
                resWrapper.success = true;
            } else {
                resWrapper.success = false;
                resWrapper.resultMessage = wrWO.errorMessage;
            }     
        } else {
            resWrapper.success = false;
            resWrapper.resultMessage = Label.XC_CL_WorkOrder_WorktypeError;
        }
        return resWrapper;
    }*/

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to create new WorkOrder 
    * @date 26/03/2021
    * @param cs - Case
    * @return ResultWrapper
    */     
    /*public static ResultWrapper createWorkOrder(Case cs) {
        ResultWrapper resWrapper = new ResultWrapper();
        XC_UTIL_Sobject.WrapperResult wrapper = XC_TR_Case_U_CaseRepair.workOrderCreation(new List<Case>{cs});
        if(wrapper.success) {
            resWrapper.success = true;
            resWrapper.resultMessage = Label.XC_CL_WorkOrder_WoCreated;
        } else{
            resWrapper.success = false;
            resWrapper.resultMessage = wrapper.errorMessage;
        }
        return resWrapper;
    }*/
    
    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to update WorkOrder to recalculate urgency
    * @date 25/03/2021
    * @param caseId - String
    * @return ResultWrapper
    */  
    public static ResultWrapper createNewWoRepair(String caseId){
        ResultWrapper resWrapper = new ResultWrapper();        
        List<WorkOrder> woList = new List<WorkOrder>([
            SELECT Id, XC_WorkTypeCategory__c, Status, CaseId, Case.XC_Subtype__c, Case.Reason, Case.SubCause__c, Case.XC_Address__c, Case.XC_AssetAttached__c, Case.XC_Urgent__c, Case.XC_WithCommitment__c, Case.XC_LegalEntity__c, Case.XC_Segment__c
            FROM WorkOrder 
            WHERE CaseId =: caseId
        ]);        
        if(woList.isEmpty()){
            resWrapper.resultMessage = Label.XC_CL_WorkOrder_NotExist;
            return resWrapper;
        }       
        WorkOrder wo = woList[0];  
        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair  && wo.status == Label.XC_CL_WorkOrder_New) {
            List<Case> listCase = XC_UTIL_Sobject.selectAllFields(caseId);
            XC_UTIL_Sobject.WrapperResult wrapper = XC_TR_Case_U_CaseRepair.workOrderCreation(listCase);
            if(wrapper.success) {
                resWrapper.woId = wo.Id;
                resWrapper.success = true; 
            } else{
                resWrapper.success = false;
                resWrapper.resultMessage = wrapper.errorMessage;
            }      
        } else {
            resWrapper.success = false;
            resWrapper.resultMessage = Label.XC_CL_WorkOrder_WorktypeError;
        }
        return resWrapper;
    }
    

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to create new WorkOrder 
    * @date 26/03/2021
    * @param cs - Case
    * @return ResultWrapper
    */      
    
    public static ResultWrapper cancelWO(Id woId){
        ResultWrapper resWrapper = new ResultWrapper();        
        WorkOrder wo = new WorkOrder();
        wo.Id = woId;
        wo.status = Label.XC_CL_WorkOrder_Cancelled;
        XC_UTIL_Sobject.WrapperResult wrWO = XC_UTIL_Sobject.updateRecord(wo); 
        if(wrWO.success) {
            resWrapper.success = true; 
            resWrapper.resultMessage = Label.XC_CL_WorkOrder_WoCreated;
        } else{
            resWrapper.success = false;
            resWrapper.resultMessage = wrWO.errorMessage;
        }
        return resWrapper;
    }
}