/**
 * @author Monica Cutillo - mcutillo@deloitte.it 
 * @date Creation 27/03/2020
 * @date Modification dd/mm/yyyy
 * @description util scecific for XC_TR_WorkOrder_U_SLAManagement 
 */
public without sharing class XC_TR_WorkOrder_U_SLAManagement {

    private class ManagementViolationData {
        WorkOrder wo;
        List<Case> newCasesToInsert;
        XC_CM_Case_Type_Setting__mdt caseSettingsMetadata;
        Decimal maxNumIteration;
        Database.DMLOptions dmlOptsCase;
    }

    /**
     * @description Assing SLA
     * @param woList the WorkOrder list
     */
    public static void assignSLA(List<WorkOrder> woList) {
        Map<String, Entitlement> slaMap = XC_AT_Utils.getSLAEntitlement('WorkOrder');
        Map<String, XC_CM_WorkOrder_AttentionType__mdt> attentionTypeMap = retriveWOAttentionTypesFromWO(woList);
        for(WorkOrder wo : woList){
            //serch the SLA Proces to assign from metadata
            for(XC_CM_WorkOrder_AttentionType__mdt mtd: attentionTypeMap.values()){
                if(checkConditionToAssignSLA(wo, mtd)){
                    populateEntitlementOnWO(wo, slaMap, mtd.XC_SLAProcess__c);
                    break;
                } 
            }
        }
    }

    /**
     * @description update the Assingned SLA
     * @param woList the WorkOrder list
     * @param mapOld
     * @param mapNew
     */
    public static void updateAssignedSLA(List<WorkOrder> listNew, Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
        List<String> fieldList = new List<String>{'XC_StatusReason__c'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        assignSLA(listChanged);
    }

    /**
     * @description update the Assingned SLA
     * @param woList the WorkOrder list
     * @param mapOld
     * @param mapNew
     */
    public static void checkForMilestonesViolations(List<WorkOrder> listNew, Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
        List<String> fieldList = new List<String>{'XC_CaseToCreateType__c'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }

        Set<String> caseTypesName = new Set<String>(XC_UTIL_Sobject.getListFieldValues(listChanged, 'XC_CaseToCreateType__c'));
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>(caseTypesName));
        if(caseSettingsMap.isEmpty() || caseSettingsMap.size() != caseTypesName.size()){
            System.debug('@@@@@ ATTENTION: checkForMilestonesViolations without XC_CM_Case_Type_Setting__mdt data !!!');
            return;
        }

        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;

        Map<String, Decimal> mtdDataByCase = maxNumIterationMap(listChanged);

        List<Case> newCaseToInsert = new List<Case>();
        ManagementViolationData inputData = new ManagementViolationData();
        inputData.newCasesToInsert = new List<Case>();
        inputData.dmlOptsCase = dmlOpts;
        for(WorkOrder wo : listChanged){
            inputData.wo = wo;
            if(wo.XC_CaseToCreateType__c == 'XC_UrgentWorkOrderViolation'){
                inputData.caseSettingsMetadata = caseSettingsMap.get('XC_UrgentWorkOrderViolation');
                inputData.maxNumIteration = mtdDataByCase.get('XC_UrgentWorkOrder');
                manageWorkOrderViolation(inputData);
            } else if(wo.XC_CaseToCreateType__c == 'XC_NonUrgentWorkOrderViolation'){
                inputData.caseSettingsMetadata = caseSettingsMap.get('XC_NonUrgentWorkOrderViolation');
                manageWorkOrderViolation(inputData);
            }
        }
        if(!inputData.newCasesToInsert.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> dmlCasesRes = XC_UTIL_DML.insertRecords(inputData.newCasesToInsert);
        }
    }

    /**
     * @description manageWorkOrderViolation
     * @param inputData input data wrapper
     */
    private static void manageWorkOrderViolation(ManagementViolationData inputData){
        if(inputData.maxNumIteration != null && inputData.maxNumIteration == inputData.wo.XC_UrgentEntitlementCounter__c){
            //max num iteration achieved => no case creation
            return;
        }
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(inputData.caseSettingsMetadata);
        caso.AccountId = inputData.wo.AccountId;
        caso.ContactId = inputData.wo.ContactId;
        caso.XC_WorkOrder__c = inputData.wo.Id;
        caso.setOptions(inputData.dmlOptsCase);
        inputData.newCasesToInsert.add(caso);

        //to empty EntitlementId
        //inputData.wo.EntitlementId = null;    //L'entitlement non va + sbiancato

        //increment Urgent counter
        if(inputData.maxNumIteration != null){
            inputData.wo.XC_UrgentEntitlementCounter__c = inputData.wo.XC_UrgentEntitlementCounter__c + 1;
        }
        inputData.wo.XC_CaseToCreateType__c = null;
    }

    /**
     * @description manageWorkOrderViolation
     * @param woList input WO
     * @return data mapping SlaProcess -> maxNumIteration
     */
    private static Map<String, Decimal> maxNumIterationMap(List<WorkOrder> woList){
        Map<String, XC_CM_WorkOrder_AttentionType__mdt> attentionTypeMap = retriveWOAttentionTypesFromWO(woList);
        Map<String, Decimal> result = new Map<String, Decimal>();
        for(XC_CM_WorkOrder_AttentionType__mdt mtd : attentionTypeMap.values()){
            result.put(mtd.XC_SLAProcess__c, mtd.XC_MaxIterationCounter__c);
        }
        return result;
    }

    /**
     * @description checkConditionToAssignSLA
     * @param wo the WorkOrder 
     * @param mtd the XC_CM_WorkOrder_AttentionType__mdt
     * @return check result
     */
    private static Boolean checkConditionToAssignSLA(WorkOrder wo, XC_CM_WorkOrder_AttentionType__mdt mtd){
        return ((String.isBlank(mtd.XC_WorkTypeCategory__c) || mtd.XC_WorkTypeCategory__c == wo.XC_WorkTypeCategory__c) && 
               (XC_TR_WorkOrder_U_CareManagement.checkFlagPicklistValue(mtd.XC_Urgent_Repair__c, wo.XC_Urgent_Repair__c)) &&
               (String.isBlank(mtd.XC_StatusReason__c) || mtd.XC_StatusReason__c == wo.XC_StatusReason__c) &&
               (String.isBlank(mtd.XC_WorkOrder_Status__c) || mtd.XC_WorkOrder_Status__c == wo.Status) &&
               checkConditionOnUrgentIterations(wo,mtd));
    }

    /**
     * @description checkConditionOnUrgentIterations
     * @param wo the WorkOrder 
     * @param mtd the XC_CM_WorkOrder_AttentionType__mdt
     * @return check result
     */
    private static Boolean checkConditionOnUrgentIterations(WorkOrder wo, XC_CM_WorkOrder_AttentionType__mdt mtd){
        return (mtd.XC_MaxIterationCounter__c == null || wo.XC_UrgentEntitlementCounter__c < mtd.XC_MaxIterationCounter__c);
    }

    /**
     * @description populate EntitlementId in the WO in input
     * @param wo the WorkOrder 
     * @param slaMap mapping between SLA Process Name and the EntitlmentId
     * @param slaProcessName the slaProcess Name
     */
    private static void populateEntitlementOnWO(WorkOrder wo, Map<String, Entitlement> slaMap, String slaProcessName){
        if(!slaMap.isEmpty()) {  
            Entitlement ent = slaMap.get(slaProcessName);
            if(ent != null ){
                wo.EntitlementId = ent.Id;
            }
        }
    }
    
    /**
     * @description retrive WO XC_CM_WorkOrder_AttentionType__mdt map From WO
     * @param woList the WorkOrder list
     */
    private static Map<String, XC_CM_WorkOrder_AttentionType__mdt> retriveWOAttentionTypesFromWO(List<WorkOrder> woList) {
        List<String> leValues = XC_UTIL_Sobject.getListFieldValues(woList, 'XC_LegalEntity__c');
        Set<String> filterLE = new Set<String>(leValues);
        Map<String, XC_CM_WorkOrder_AttentionType__mdt> result = new Map<String, XC_CM_WorkOrder_AttentionType__mdt>([
            SELECT Id, XC_WorkTypeCategory__c, XC_Urgent_Repair__c, XC_StatusReason__c, XC_SLAProcess__c, XC_MaxIterationCounter__c, XC_WorkOrder_Status__c, XC_LegalEntity__c
              FROM XC_CM_WorkOrder_AttentionType__mdt
             WHERE XC_LegalEntity__c IN: filterLE
        ]);
        
        return result;
    }

}