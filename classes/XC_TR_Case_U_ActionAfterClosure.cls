/**
 * @author Monica Cutillo - mcutillo@deloitte.it 
 * @date Creation 02/04/2020
 * @date Modification dd/mm/yyyy
 * @description util scecific for XC_TR_Case_U_ActionAfterClosure 
 */
public without sharing  class XC_TR_Case_U_ActionAfterClosure {
    
    /**
    * @param listNew the list new
    * @param  the mapmapOld old
    * @param mapNew the map new
    * @description callActionsAfterClosure
    */
    public static void manageActionsAfterClosure(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
        List<String> fieldList = new List<String>{'Status'};
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        
        List<Case> closedCases = new List<Case>();
        for(Case caso : listChanged){
            if(caso.Status == Label.XC_CL_Case_Status007){
                closedCases.add(caso);
            }
        }
        if(closedCases.isEmpty()){
            return;
        }

        List<String> caseTypesName = XC_UTIL_Sobject_U_Retrieve.getPicklistValues('WorkOrder', 'XC_CaseToCreateType__c');
        caseTypesName.add(Label.XC_CL_CMD_AdministrativeTask);
        caseTypesName.add(Label.XC_CL_CMD_CreditTransfer);
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(caseTypesName);
        
        //Call All Activities on closed Cases
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettInput1 = new Map<String, XC_CM_Case_Type_Setting__mdt>();
        for(String caseType: caseTypesName){
            if(mapCaseSetting.get(caseType) != null){
                caseSettInput1.put(caseType, mapCaseSetting.get(caseType));
            }
        }
        checkToReassignSlaOnWorkOrder(closedCases, caseSettInput1);

        /** Post Live Italy - NR0984 Nuova cessione del credito **/
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettInput2 = new Map<String, XC_CM_Case_Type_Setting__mdt>();
        if(mapCaseSetting.get(Label.XC_CL_CMD_AdministrativeTask) != null){
            caseSettInput2.put(Label.XC_CL_CMD_AdministrativeTask, mapCaseSetting.get(Label.XC_CL_CMD_AdministrativeTask));
        }
        if(mapCaseSetting.get(Label.XC_CL_CMD_CreditTransfer) != null){
            caseSettInput2.put(Label.XC_CL_CMD_CreditTransfer, mapCaseSetting.get(Label.XC_CL_CMD_CreditTransfer));
        }
        checkForCreditTransfer(closedCases, caseSettInput2);
        /****/
    }

    /**
    * @param closedCases closed cases
    * @param caseSettingsMap the caseTypeSettings metadata 
    * @description checkForCreditTransfer
    */
    private static void checkForCreditTransfer(List<Case> closedCases, Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap){
        if(caseSettingsMap == null || caseSettingsMap.size() != 2 ) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_AdministrativeTask+','+Label.XC_CL_CMD_CreditTransfer}));
        }
        List<Case> casesToCheck = new List<Case>();
        for(Case caso: closedCases){
            if(XC_UTIL_Case.matchSettings(caso, caseSettingsMap.get(Label.XC_CL_CMD_AdministrativeTask)) || XC_UTIL_Case.matchSettings(caso, caseSettingsMap.get(Label.XC_CL_CMD_CreditTransfer))){
                casesToCheck.add(caso);
            }
        }
        if(casesToCheck.isEmpty()){
            return;
        }

        List<Case> stepToClose = new List<Case>();
        List<Case> relCaseItem;
        Map<Id,List<Case>> relatedCases = searchAllCasesOpenForCreditTransfer(casesToCheck,caseSettingsMap);
        for(Case caso: casesToCheck){
            relCaseItem = relatedCases.get(caso.XC_OrderItem__c);
            if(relCaseItem == null || relCaseItem.size() != 2){
                continue;
            }
            for(Case casoRel: relCaseItem){
                if(casoRel.Id != caso.Id && casoRel.Status == Label.XC_CL_Case_Status007){
                    stepToClose.add(caso);
                }
            }
        }
        closeStepCreditTransfer(stepToClose);
    }

    /**
    * @param casesToCheck
    * @param caseSettingsMap the caseTypeSettings metadata 
    * @description searchAllCasesOpenForCreditTransfer
    */
    private static Map<Id,List<Case>> searchAllCasesOpenForCreditTransfer(List<Case> casesToCheck, Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap){
        Map<Id,List<Case>> result = new Map<Id,List<Case>>();
        Set<Id> orderItems = XC_UTIL_Sobject.getSetIdsOnField(casesToCheck, 'XC_OrderItem__c');
        XC_CM_Case_Type_Setting__mdt admTskMtd = caseSettingsMap.get(Label.XC_CL_CMD_AdministrativeTask);
        XC_CM_Case_Type_Setting__mdt creTraMtd = caseSettingsMap.get(Label.XC_CL_CMD_CreditTransfer);
        Map<Id,Case> relatedCases = new Map<Id,Case>([
            SELECT Id, XC_OrderItem__c, Reason, SubCause__c, XC_Subtype__c, Status
            FROM Case
            WHERE XC_OrderItem__c IN: orderItems
              AND XC_OrderItem__c <> null
              AND ( (Reason =: admTskMtd.XC_Case_Reason__c AND SubCause__c =: admTskMtd.XC_Sub_Cause__c AND XC_Subtype__c =: admTskMtd.XC_Sub_Type__c ) OR
                    (Reason =: creTraMtd.XC_Case_Reason__c AND SubCause__c =: creTraMtd.XC_Sub_Cause__c AND XC_Subtype__c =: creTraMtd.XC_Sub_Type__c ) )
        ]);

        for(Case caso : relatedCases.values()){
            if(result.get(caso.XC_OrderItem__c) == null){
                result.put(caso.XC_OrderItem__c, new List<Case>());
            }
            result.get(caso.XC_OrderItem__c).add(caso);
        }
        return result;
    }

    /**
    * @param stepToClose case to close the step
    * @param caseSettingsMap the caseTypeSettings metadata 
    * @description checkToReassignSlaOnWorkOrder
    */
    private static void closeStepCreditTransfer(List<Case> stepToClose){
        Set<Id> orderItems = XC_UTIL_Sobject.getSetIdsOnField(stepToClose, 'XC_OrderItem__c');
        Map<Id,XC_Provisioning_Step__c> steps = new Map<Id,XC_Provisioning_Step__c>([
            SELECT ID, XC_Status__c
            FROM XC_Provisioning_Step__c 
            WHERE XC_StepLabel__c = 'Check Incentive and Credit Transfer Cases' 
            AND XC_Configuration_Item__c IN: orderItems
        ]);
        
        List<XC_Provisioning_Step__c> stepsToUpd = new List<XC_Provisioning_Step__c>();
        for(XC_Provisioning_Step__c step: steps.values()){
            step.XC_Status__c = 'Completed OK';
            stepsToUpd.add(step);
        }
        List<XC_UTIL_Sobject.WrapperResult> updRes = XC_UTIL_DML.updateRecords(stepsToUpd);
    }

    /**
    * @param closedCases closed case
    * @param caseSettingsMap the caseTypeSettings metadata 
    * @description checkToReassignSlaOnWorkOrder
    */
    private static void checkToReassignSlaOnWorkOrder(List<Case> closedCases, Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap){
        /*List<String> caseTypesName = XC_UTIL_Sobject_U_Retrieve.getPicklistValues('WorkOrder', 'XC_CaseToCreateType__c');
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>(caseTypesName));*/
        if(caseSettingsMap.isEmpty()){
            System.debug('@@@@@ ATTENTION: checkToReassignSlaOnWorkOrder without XC_CM_Case_Type_Setting__mdt data !!!');
            return;
        }
        
        List<Case> slaViolationCases = new List<Case>();
        for(Case caso : closedCases){
            for(XC_CM_Case_Type_Setting__mdt mtd : caseSettingsMap.values()){
                if(XC_UTIL_Case.matchSettings(caso, mtd)){
                    slaViolationCases.add(caso);
                }
            }
        }
        if(!slaViolationCases.isEmpty()){
            workOrderSlaManagement(slaViolationCases);
        }
    }

    /**
    * @param closedCases closed case
    * @description workOrderSlaManagement
    */
    private static void workOrderSlaManagement(List<Case> slaViolationCases){
        Set<Id> woIds = XC_UTIL_Sobject.getSetIdsOnField(slaViolationCases, 'XC_WorkOrder__c');
        List<EntityMilestone> milestoneToUpdate = new List<EntityMilestone>();
        Map<Id,WorkOrder> woData = new Map<Id,WorkOrder>([
            SELECT Id, XC_WorkTypeCategory__c, XC_Urgent_Repair__c, XC_StatusReason__c, Status, XC_UrgentEntitlementCounter__c, XC_LegalEntity__c,
            		(SELECT Id, StartDate FROM EntityMilestones)
              FROM WorkOrder
             WHERE Id IN: woIds
        ]);
        
        //XC_TR_WorkOrder_U_SLAManagement.assignSLA(woData.values());   //No questo nn va + fatto
        //TO DO > Aggiornare WO per far ripartire la Milestone
		
        for(WorkOrder wo : woData.values()){
            if(!woData.get(wo.Id).EntityMilestones.isEmpty()){
                for(EntityMilestone milestone : woData.get(wo.Id).EntityMilestones){
                    milestone.StartDate = System.now();
                    milestoneToUpdate.add(milestone);
                }
            }
        }
        //Update WO con nuovo EntitlementId
        
        List<XC_UTIL_Sobject.WrapperResult> woUpdRes = XC_UTIL_DML.updateRecords(milestoneToUpdate);
    }

}