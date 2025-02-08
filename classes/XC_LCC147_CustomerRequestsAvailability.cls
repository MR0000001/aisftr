/**
 * @File Name          : XC_LCC147_CustomerRequestsAvailability.cls
 * @description        : XC_LCC147_CustomerRequestsAvailability -   Controller for XC_LCP147_CustomerRequestsAvailability Component
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 16/10/2019, 16:37:23
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    05/09/2019   Anna Maria Rosanova - annamaria.rosanova@nttdata.com     Initial Version
**/
public without sharing class XC_LCC147_CustomerRequestsAvailability {
 public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC147_CustomerRequestsAvailability');

    /**
    * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
    * @param workOrderId
    * @description assign status and statusReason at the Work Orders
    * @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled        
    public static XC_UTIL_ResultWrapper updateFLS(String workOrderId){
    XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        List<WorkOrder> woList = new List<WorkOrder>([
            SELECT Id, Status, XC_StatusReason__c, XC_WorkTypeCategory__c, XC_CustomerRequestAnotherAvailability__c
            FROM WorkOrder 
            WHERE Id = :workOrderId
        ]);

        if(woList.isEmpty()){
            resWrapper.resultMessage = Label.XC_CL_WorkOrderNotExist;
            return resWrapper;
        }
        WorkOrder wo = woList[0];
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();

        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation || 
                wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit || 
            wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair){  
            wo.XC_CustomerRequestAnotherAvailability__c = true;
            wo.XC_StatusReason__c = Label.XC_CL_StatusReason_CustomerRequestAnotherAvailability;
            wo.status = Label.XC_CL_WorkOrder_New;
            wr = XC_UTIL_Sobject.updateRecord(wo);
            if(wr.success) {
                XC_LCC084_AssignToBackOffice.assignationToBackOffice(workOrderId);
                createCase(workOrderId);
                resWrapper.success = wr.success;
            } else {
                resWrapper.success = false;
                resWrapper.resultMessage =  wr.errorMessage;
            }
        
        }else {
            resWrapper.success = false;
            resWrapper.resultMessage = Label.XC_CL_WorkOrder_WorktypeError;
        }
        
        return resWrapper;
    }


    /**
    * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
    * @param workOrderId
    * @description Create a case
    */
public static void createCase(String workOrderId) {
        List<Case> listCase = new List<Case>();
        List<WorkOrder> woOwner = new List<WorkOrder>([SELECT id, ownerId, ContactId FROM WorkOrder WHERE id = :workOrderId]);
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_MantenanceCaseSettingsName});
        XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_MantenanceCaseSettingsName);
        if(caseMDT == null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_MantenanceCaseSettingsName}));
        }
        Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
        c.ContactId = woOwner[0].ContactId;
        c.OwnerId = woOwner[0].ownerId;
        c.XC_WorkOrder__c = woOwner[0].id;
        listCase.add(c);
		XC_UTIL_Sobject.insertListRecords(listCase);

    }
}