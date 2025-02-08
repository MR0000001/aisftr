/** 
* @author Roberta Cossiga - rcossiga@deloitte.it | Emanuela Cacace - ecacace@deloitte.it
* @date Creation 01/07/2019
* @description XC_LCC123_QualityInspectionWorkOrder  –   Controller class for component XC_LCP123_QualityInspectionWorkOrder
*/
public without sharing class XC_LCC123_QualityInspectionWorkOrder {

/**
* Checks 
* @description 
* @param recordId the record id
* @return CreateWOWrapper
*/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkExistingQualityWo (String recordId) {
        XC_UTIL_ResultWrapper wrRes = new XC_UTIL_ResultWrapper();  
        Map<Id, WorkOrder> mapExistingWos = new Map<Id, WorkOrder>([SELECT Id
                                       FROM WorkOrder
                                       WHERE CaseId =: recordId AND XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_QualityCheckInspection
                                       AND (Status !=: Label.XC_CL_WorkOrder_Canceled AND Status !=: Label.XC_CL_WorkOrder_CannotComplete
                                            AND Status !=: Label.XC_CL_WorkOrder_Completed)]);
        List<WorkOrder> existingWos = mapExistingWos.values();
        if (!existingWos.isEmpty()){
            wrRes.success = false;
            wrRes.resultMessage = Label.XC_CL_OpernQiWo;
            return wrRes;
        } else {
            wrRes = checkAddressAndCreateWo(recordId);
        }
        return wrRes;
    }
/**
* Checks 
* @description 
* @param recordId the record id
* @return CreateWOWrapper
*/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkAddressAndCreateWo (String recordId) {
        XC_UTIL_ResultWrapper wrRes = new XC_UTIL_ResultWrapper(); 
        XC_UTIL_Sobject.WrapperResult insertWr = new XC_UTIL_Sobject.WrapperResult();  
        Map<Id, Case> mapParentCase = new Map<Id, Case>([SELECT Id, XC_WorkOrder__r.XC_Address__c, XC_WorkOrder__r.XC_Address__r.XC_PostalCode__c, 
                                                         XC_WorkOrder__r.XC_Address__r.XC_City__c, XC_WorkOrder__r.XC_Address__r.XC_AddressCountry__c,
                                                         XC_WorkOrder__r.XC_Address__r.XC_Address__c, 
                                                         XC_WorkOrder__r.AssetId, XC_WorkOrder__r.Status, XC_WorkOrder__r.AccountId, XC_WorkOrder__r.ContactId
                                                         FROM Case 
                                                         WHERE Id =: recordId]);
        List<Case> listParentCase = mapParentCase.values();
        if(listParentCase[0].XC_WorkOrder__r.XC_Address__c == null){
            wrRes.success = false;
            wrRes.resultMessage = Label.XC_CL_MissingAddressOnWo;
            return wrRes;
        }else if(!isInFinalStatus(listParentCase[0].XC_WorkOrder__r.Status)){
            wrRes.success = false;
            wrRes.resultMessage = Label.XC_CL_WorkOrderNotFinalStatus;
            return wrRes;
        }
        else {
            WorkOrder wo = new WorkOrder();
            wo.WorkTypeId = XC_UTIL_WorkOrder.getWorkTypeByName(Label.XC_CL_WorkType_QualityCheckInspection);
            wo.Street = listParentCase[0].XC_WorkOrder__r.XC_Address__r.XC_Address__c;
            wo.PostalCode = listParentCase[0].XC_WorkOrder__r.XC_Address__r.XC_PostalCode__c;
            wo.City = listParentCase[0].XC_WorkOrder__r.XC_Address__r.XC_City__c;
            wo.Country = listParentCase[0].XC_WorkOrder__r.XC_Address__r.XC_AddressCountry__c;
            wo.XC_Address__c = listParentCase[0].XC_WorkOrder__r.XC_Address__c;
            wo.AssetId = listParentCase[0].XC_WorkOrder__r.AssetId;
            wo.AccountId = listParentCase[0].XC_WorkOrder__r.AccountId;
            wo.ContactId = listParentCase[0].XC_WorkOrder__r.ContactId;
            wo.CaseId = recordId;
            insertWr = XC_UTIL_Sobject.insertRecord(wo);
            return new XC_UTIL_ResultWrapper(insertWr);
        }
    }

    /**
    * Checks 
    * @description 
    * @param workOrderStatus
    * @return Boolean
    */
    private static Boolean isInFinalStatus (String workOrderStatus) {
        if(workOrderStatus == Label.XC_CL_WorkOrder_Completed ||
           workOrderStatus == Label.XC_CL_WorkOrder_CannotComplete ||
           workOrderStatus == Label.XC_CL_WorkOrder_Canceled){
               return true;
        }
        return false;
    }

}