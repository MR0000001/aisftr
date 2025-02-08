public class XC_LCC152_CustomerRequestsUnsubscribe {
public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC152_CustomerRequestsUnsubscribe');

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
            SELECT Id, Status, AccountId, ContactId, XC_StatusReason__c, XC_WorkTypeCategory__c,XC_CustomerRequestAnotherAvailability__c, AssetId, Asset.XC_Product_Type__c, XC_Segment__c, XC_LegalEntity__c,
                    (SELECT Id FROM ServiceAppointments)
            FROM WorkOrder 
            WHERE Id = :workOrderId
        ]);
        List<XC_UTIL_Sobject.WrapperResult> wrList = new List<XC_UTIL_Sobject.WrapperResult>();
        List <WorkOrder> listOfWo = new List<WorkOrder>();
        for(WorkOrder wo: woList){
            if(!wo.ServiceAppointments.isEmpty()){
                wo.Status = Label.XC_CL_OnHold;
                wo.XC_StatusReason__c = Label.XC_CL_StatusReason_Customerrequestsunsubscribe;
            }else {
                resWrapper.success = false;
                resWrapper.resultMessage = Label.XC_CL_ServiceAppointmentNotExist;
                return resWrapper;
            }
        }
        XC_UTIL_Sobject.updateListRecords(woList);
        if(!XC_UTIL_Sobject.checkDMLResults(wrList)){
            XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.getGlobalDMLResults(wrList);
            resWrapper.success = false;
            resWrapper.resultMessage = wr.errorMessage;
            return resWrapper;
        }
        List<XC_UTIL_Sobject.WrapperResult> wrappDmlCase = createCase(woList);
        if(!XC_UTIL_Sobject.checkDMLResults(wrappDmlCase)){
            XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.getGlobalDMLResults(wrappDmlCase);
            resWrapper.success = wr.success;
            resWrapper.resultMessage = wr.errorMessage;
            return resWrapper;
        }
        resWrapper.success = true;
        resWrapper.resultMessage = Label.XC_CL_Configuration_Success;
        return resWrapper;
    }


    /**
    * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
    * @param workOrderId
    * @description Create a case
    * @return void
    */
    public static List<XC_UTIL_Sobject.WrapperResult> createCase(List<WorkOrder> woList) {
        WorkOrder wo = woList[0];
        List<Case> listCase = new List<Case>();
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = new Map<String, XC_CM_Case_Type_Setting__mdt>();
        if(String.isNotBlank(wo.AssetId) && String.isNotBlank(wo.Asset.XC_Product_Type__c)){
            //if(wo.Asset.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment){
            Case caso = populateCase(wo.Asset.XC_Product_Type__c, wo);
            if(caso != null){
                listCase.add(caso);
            }
            /*}else if (wo.Asset.XC_Product_Type__c == Label.XC_CL_ProductTypeService){
                Case c = populateCase(wo.Asset.XC_Product_Type__c, wo);
                listCase.add(c);
            }*/
        }
        List<XC_UTIL_Sobject.WrapperResult> wrList = XC_UTIL_Sobject.insertListRecords(listCase);
        return wrList;
    }

    public static Case populateCase(String assetType, Workorder wo){
        Case caseToInsert;
        XC_CM_Case_Type_Setting__mdt caseMDT;
        if(assetType == Label.XC_CL_ProductTypeEquipment){
            Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{'XC_UnsubscribeCaseSettingsEquip'});
            caseMDT = mapCaseSetting.get('XC_UnsubscribeCaseSettingsEquip');
            if(caseMDT == null) {
                throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', 'XC_UnsubscribeCaseSettingsEquip'}));
            }
            //caseToInsert = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
            //caseToInsert.XC_WorkOrder__c = wo.Id;
            //caseToInsert.AccountId = wo.AccountId;
        }else if (assetType == Label.XC_CL_ProductTypeService){
            Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{'XC_UnsubscribeCaseSettingsService'});
            caseMDT = mapCaseSetting.get('XC_UnsubscribeCaseSettingsService');
            if(caseMDT == null) {
                throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', 'XC_UnsubscribeCaseSettingsService'}));
            }
            //caseToInsert = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
            //caseToInsert.XC_WorkOrder__c = wo.Id;
            //caseToInsert.AccountId = wo.AccountId;
        }

        if(caseMDT != null){
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;

            caseToInsert = new Case();
            caseToInsert = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
            caseToInsert.XC_WorkOrder__c = wo.Id;
            caseToInsert.AccountId = wo.AccountId;
            caseToInsert.ContactId = wo.ContactId;
            caseToInsert.XC_LegalEntity__c = wo.XC_LegalEntity__c;
            caseToInsert.XC_Segment__c = wo.XC_Segment__c;
            caseToInsert.setOptions(dmlOpts);
        }

        return caseToInsert;
    }
}