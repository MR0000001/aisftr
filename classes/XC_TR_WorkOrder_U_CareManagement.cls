/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com 
* @date 05/11/2019
* @description XC_TR_WorkOrder_U_CareManagement - Class to manage Case created for WorkOrder (status)
**/

public without sharing class XC_TR_WorkOrder_U_CareManagement {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_CareManagement');

    /** @description CheckWOValidationInput */
    public class CheckWOValidationInput{
        public WorkOrder woToValidate;
        public XC_ComplianceMaster__c validationWORule;
        public ServiceAppointment activeSA;
        public NE__Order__c quote;
        Id commercialProductId;
        String commercialCode;
        Decimal additionalCostAmount;
    }

    /** @description CheckWOValidationOutput */
    public class CheckWOValidationOutput{
        WorkOrder checkedWO;
        Boolean isWOValidated = false;
        Id validationRuleId;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/11/2019
     * @description Method to create case for WO Site Inspection in On Hold
     * @param listWorkOrder - List<WorkOrder>
     * @param caseMDT - XC_CM_Case_Type_Setting__mdt
     * @return List<Case> to insert
     */
    private static List<Case> manageCaseForSiteInspection(List<WorkOrder> listWorkOrder, XC_CM_Case_Type_Setting__mdt caseMDT) {
        List<WorkOrder> listWorkOrderSiteInspectionOnHold = new List<WorkOrder>();
        List<Case> listCaseToInsert = new List<Case>();
        /*XC_CM_Case_Type_Setting__mdt caseMDT = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{'XC_SiteInspection'}).get('XC_SiteInspection');
        if(caseMDT == null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', 'XC_SiteInspection'}));
        }*/

        for(WorkOrder wo : listWorkOrder) {
            if(wo.XC_WorkTypeLabel__c  == Label.XC_CL_WorkType_SIPhotovoltaic && (wo.Status == Label.XC_CL_OnHold || wo.Status == Label.XC_CL_WorkOrder_Canceled || wo.Status == Label.XC_CL_WorkOrder_CannotComplete)) {
                /*Case cs = new Case(
                    XC_Order__c = wo.XC_Configuration__c,
                    XC_WorkOrder__c = wo.Id,
                    AccountId = wo.AccountId,
                    ContactId = wo.ContactId,
                    Origin = caseMDT.XC_Origin__c,
                    RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId(),
                    Reason = caseMDT.XC_Case_Reason__c, 
                    SubCause__c = caseMDT.XC_Sub_Cause__c,
                    XC_Subtype__c = caseMDT.XC_Sub_Type__c
                );
                */
                Case cs = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
                //cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId();
                cs.XC_Order__c = wo.XC_Configuration__c;
                cs.XC_WorkOrder__c = wo.Id;
                cs.AccountId = wo.AccountId;
                cs.ContactId = wo.ContactId;
                cs.XC_LegalEntity__c = wo.XC_LegalEntity__c;
                cs.Country__c = wo.XC_Country__c;
                listCaseToInsert.add(cs);
            }
        }
        return listCaseToInsert;
        /*List<XC_UTIL_Sobject.WrapperResult> listRw = XC_UTIL_Sobject.insertListRecords(listCaseToInsert);
        if(!XC_UTIL_Sobject.checkDMLResults(listRw)) {
            listWorkOrder[0].addError(listRw[0].errorMessage);
        }*/
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 16/01/2020
     * @description Method to close case for ScheduleAppointment if the WO is assigned
     * @param listWorkOrder - List<WorkOrder>
     * @param caseMDT - XC_CM_Case_Type_Setting__mdt
     * @return List<Case> to insert
     */
    private static List<Case> manageCaseClosureForScheduleAppointment(List<WorkOrder> listWorkOrder, XC_CM_Case_Type_Setting__mdt caseMDT) {
        List<Case> result = new List<Case>();
        Set<Id> woIds = XC_UTIL_Sobject.getSetIds(listWorkOrder);
        Map<Id,Case> cases = new Map<Id,Case>([
            SELECT Id, Reason, SubCause__c, XC_Subtype__c, XC_LegalEntity__c
            FROM Case
            WHERE XC_WorkOrder__c IN: woIds
            AND status !=: Label.XC_CL_Case_Status007
            AND status !=: Label.XC_CL_Case_Status008
        ]);
        
        for(Case caso : cases.values()){
            if(XC_UTIL_Case.matchSettings(caso, caseMDT)){
                caso.XC_Resolution__c = caseMDT.XC_Resolution__c;
                caso.XC_Result__c = caseMDT.XC_Result__c;
                caso.CaseRemarks__c = XC_UTIL_Case_U.getCaseRemarksByLegalEntity(caseMDT, caso.XC_LegalEntity__c); // LR - NM 03/05/2020
                result.add(caso);
            }
        }
        return result;
    }

    /**
     * @description Manage case status on update
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void manageCaseStatusOnUpdate(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String>{'Status','OwnerId'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            
            //GDB - PERFORMANCE IMPROVEMENT - MAY 2022 - START
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                System.enqueueJob(new manageCaseStatusOnUpdateAsync(listChanged));
            }else{
                manageCaseStatusOnUpdateLogic(listChanged);
            }                     
            //GDB - PERFORMANCE IMPROVEMENT - MAY 2022 - END
        }
    }

    /**
     * @description Manage case status on update logic
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void manageCaseStatusOnUpdateLogic(List<WorkOrder> listChanged){

        Map<String, XC_CM_Case_Type_Setting__mdt> caseMDT = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{'XC_SiteInspection', Label.XC_CL_CaseToScheduleAppointment});
        if(caseMDT.isEmpty() || caseMDT.get('XC_SiteInspection')==null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', 'XC_SiteInspection'}));
        }else if(caseMDT.isEmpty() || caseMDT.get(Label.XC_CL_CaseToScheduleAppointment)==null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CaseToScheduleAppointment}));
        }
        List<Case> allCaseToUpsert = new List<Case>();
        // Manage Site Inspection Work order in On Hold:
        allCaseToUpsert.addAll(manageCaseForSiteInspection(listChanged, caseMDT.get('XC_SiteInspection')));
        // Manage check to close Case to ScheduleAppointment
        List<WorkOrder> assignedWO = getAssignedWO(listChanged);
        allCaseToUpsert.addAll(manageCaseClosureForScheduleAppointment(assignedWO, caseMDT.get(Label.XC_CL_CaseToScheduleAppointment)));
        //List<Case> listToUpdate = new List<Case>();
        List<WorkOrder> listWO= new List<WorkOrder>();
        List<String> finalStatus = new List<String>{Label.XC_CL_WorkOrder_Completed,Label.XC_CL_WorkOrder_Cancelled,Label.XC_CL_WorkOrder_CannotComplete };
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        for(WorkOrder wo: listChanged){
            //XC_WorkTypeCategory__c
            if(finalStatus.contains(wo.Status) && (wo.XC_WorkTypeLabel__c != null && wo.XC_WorkTypeLabel__c.equals(Label.XC_CL_WorkType_QualityCheckInspection) ||( wo.XC_StatusReason__c != null &&  wo.XC_StatusReason__c.equals('Substitution Required') ) ) && wo.CaseId != null ){
                Case c = new Case( Id= wo.CaseId);
                c.Status = Label.XC_CL_Case_Open;
                c.setOptions(dmlOpts);
                //listToUpdate.add(c);
                allCaseToUpsert.add(c);
            }else{
                listWO.add(wo);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> allCaseRW = XC_UTIL_DML.upsertRecords(allCaseToUpsert);
        if(!XC_UTIL_Sobject.checkDMLResults(allCaseRW)) {
            XC_UTIL_Sobject.WrapperResult errWr = XC_UTIL_Sobject.getGlobalDMLResults(allCaseRW);
            listChanged[0].addError(errWr.errorMessage);
        }
        //XC_UTIL_Sobject.updateListRecords(listToUpdate); 
        XC_UTIL_Case.manageCaseStatusFromRelatedWO(listWO);
        //manageCaseStatus(listChanged);
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description get Assigned WO from the list in input
     * @param woList the wo list
     * @return assigned wo
     */
    private static List<WorkOrder> getAssignedWO(List<WorkOrder> woList){
        List<WorkOrder> result = new List<WorkOrder>();
        for(WorkOrder wo: woList){
            if(wo.Status == Label.XC_CL_WorkOrder_Assigned){
                result.add(wo);
            }
        }
        return result;
    }

    /**
     * @author Luca Calicchio - lcalicchio@deloitte.it
     * @description Create validation case if at least one of ExtraKm/ExtraKm change and status is Completed or Closed
     * @param listNew list of updated work orders
     * @param mapNew map of updated work orders
     * @param mapOld map of work orders before update
     */
    public static void checkExtraWorkAndExtraKm(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ XC_TR_WorkOrder_U_CareManagement - START checkExtraWorkAndExtraKm');
        //retrieve only work orders with XC_ExtraKm__c or XC_ExtraWork__c changed
        List<String> fieldList = new List<String>{'XC_ExtraKm__c', 'XC_ExtraWork__c'};
        List<WorkOrder> listChangedWo = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChangedWo.isEmpty()){
            return;
        }
        //filter the work orders by status
        List<String> statusFilter = new List<String> {Label.XC_CL_Completed, Label.XC_CL_Closed};
        List<WorkOrder> woTovalidate = new List<WorkOrder>();
        for(WorkOrder wo : listChangedWo) {
            if(statusFilter.contains(wo.Status) && String.isBlank(wo.XC_ValidationStatus__c) && !String.isBlank(wo.ContactId)) { // && String.isBlank(wo.ParentWorkOrderId)
                woTovalidate.add(wo);
            }
        }                                   
        if(woTovalidate.isEmpty()){
            return;
        }

        //Check WO Legal Entity > WO Validation enabled
        Map<String, XC_CM_LegalEntity_Configuration__mdt> woValidationEnabledData = getWOValidationEnabledByLE(woTovalidate);
        XC_CM_LegalEntity_Configuration__mdt leConfMtd;
        List<WorkOrder> woValidationExtraEnabled = new List<WorkOrder>();
        for(WorkOrder wo : woTovalidate) {
            leConfMtd = woValidationEnabledData.get(wo.XC_LegalEntity__c+wo.XC_Segment__c);
            //CHECK FOR WO EXTRA VALIDATION -> FOR WO FATHER AND CHILDREN [Change for NR1078 - MC 20201221]
            if(leConfMtd != null && leConfMtd.XC_WOValidationExtra_Enabled__c){
                woValidationExtraEnabled.add(wo);
            }
        }
        if(!woValidationExtraEnabled.isEmpty() ){
            //Skip= true because the status of work order is already filtered
            manageWorkOrderExtraValidate(woValidationExtraEnabled, true);
        }
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description When WO changes its Status to 'Completed' or 'Cannot Complete',
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     * it's created a Validation Case.
     */
    public static void checkForValidationCaseCreation(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ XC_TR_WorkOrder_U_CareManagement - START checkForValidationCaseCreation');
        List<String> fieldList = new List<String>{'Status'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        List<String> statusFilter = new List<String> {Label.XC_CL_Completed, Label.XC_CL_CannotComplete, Label.XC_CL_Cancelled};
        
        // Salvatore Agrillo - salvatore.agrillo@nttdata.com - 15/01/2020
        /*Map<Id,WorkOrder> woTovalidateMap = new Map<Id,WorkOrder>(
            [SELECT Id, WorkTypeId, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, AccountId, ContactId, AssetId, XC_SubStatus__c,
                    XC_ServiceTypeGP__c, XC_CatalogCategory__c, XC_Urgent_Repair__c, XC_WarrantyPossibility__c, XC_Digitized__c, 
                    XC_AssignedResource__c, XC_Configuration__c, XC_CreatedByTechnician__c, XC_ValidationStatus__c
               FROM WorkOrder 
              WHERE Id IN: mapNew.keySet()
                AND Status IN: statusFilter
                AND XC_ValidationStatus__c = ''
                AND ContactId <> NULL ]);*/
        List<WorkOrder> woTovalidate = new List<WorkOrder>();
        for(WorkOrder wo : listChanged) {
            if(statusFilter.contains(wo.Status) && String.isBlank(wo.XC_ValidationStatus__c) && !String.isBlank(wo.ContactId)) { // && String.isBlank(wo.ParentWorkOrderId)
                woTovalidate.add(wo);
            }
        }                                   
        if(woTovalidate.isEmpty()){
            return;
        }

        //Check WO Legal Entity > WO Validation enabled
        Map<String, XC_CM_LegalEntity_Configuration__mdt> woValidationEnabledData = getWOValidationEnabledByLE(woTovalidate);
        XC_CM_LegalEntity_Configuration__mdt leConfMtd;
        List<WorkOrder> woTovalidateEnabled = new List<WorkOrder>();
        List<WorkOrder> woValidationExtraEnabled = new List<WorkOrder>();
        for(WorkOrder wo : woTovalidate) {
            leConfMtd = woValidationEnabledData.get(wo.XC_LegalEntity__c+wo.XC_Segment__c);
            //CHECK FOR WO VALIDATION -> ONLY FOR WO FATHER
            if(String.isBlank(wo.ParentWorkOrderId) && leConfMtd != null && leConfMtd.XC_WOValidation_Enabled__c){
                woTovalidateEnabled.add(wo);
            }
            //CHECK FOR WO EXTRA VALIDATION -> FOR WO FATHER AND CHILDREN [Change for NR1078 - MC 20201221]
            else if(leConfMtd != null && leConfMtd.XC_WOValidationExtra_Enabled__c){
                woValidationExtraEnabled.add(wo);
            }
        }
                                
        if(!woTovalidateEnabled.isEmpty() ){
            manageWorkOrderToValidate(woTovalidateEnabled);
        }
        if(!woValidationExtraEnabled.isEmpty() ){
            //skip=false because we have to filter only work order with completed status
            manageWorkOrderExtraValidate(woValidationExtraEnabled, false);
        }
        return;
    }
    
    /**
     * @description getWOValidationEnabledByLE
     * @param woToCheck the list WO to check if it' possible to validate
     * @return Map<String, XC_CM_LegalEntity_Configuration__mdt> with LE enabled
     **/
    @testVisible
    private static Map<String, XC_CM_LegalEntity_Configuration__mdt> getWOValidationEnabledByLE(List<WorkOrder> woToCheck){
        Map<String, XC_CM_LegalEntity_Configuration__mdt> result = new Map<String, XC_CM_LegalEntity_Configuration__mdt>();
        Set<String> allLE = XC_UTIL_Sobject.getSetIdsStringOnField(woToCheck, 'XC_LegalEntity__c');
        Set<String> segmFilter = XC_UTIL_Sobject.getSetIdsStringOnField(woToCheck, 'XC_Segment__c');
        return XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(allLE, segmFilter);
        //String orgId = UserInfo.getOrganizationId();
        //for(String le : allLE){
        /*String key;
        for(WorkOrder wo : woToCheck){
            key = wo.XC_LegalEntity__c+wo.XC_Segment__c;
            if(leConfigData.get(key) != null){
                result.put(key,(leConfigData.get(key)).get(orgId));
            }
        }
        return result;*/
    }

    /**
     * @description manageWorkOrderExtraValidate
     * @param woValidationExtraEnabled the list of wo to apply extra validation
     **/
    private static void manageWorkOrderExtraValidate(List<WorkOrder> woValidationExtraEnabled, Boolean skipWoStatus){
        //check Extra flags
        List<WorkOrder> woForCaseCreation = new List<WorkOrder>();
        for(WorkOrder wo: woValidationExtraEnabled){
            if((wo.XC_ExtraKm__c || wo.XC_ExtraWork__c) && (wo.Status == 'Completed' || skipWoStatus)){
                woForCaseCreation.add(wo);
            }
        }
        if(woForCaseCreation.isEmpty()){
            return;
        }
        
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_ValidationCase});
        if(caseSettingsMap.isEmpty() || caseSettingsMap.get(Label.XC_CL_ValidationCase)==null){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+Label.XC_CL_ValidationCase);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Validation Case (Extra) NOT created!');
            return;
        }
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_ValidationCase);
        
        List<Case> newCases = new List<Case>();
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
        WorkOrder woToUpd;
        Case newValidationCase;
        List<WorkOrder> allWOToUpdate = new List<WorkOrder>();
        for(WorkOrder wo : woForCaseCreation){
            newValidationCase = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
            newValidationCase.XC_WorkOrder__c = wo.Id;
            newValidationCase.AccountId = wo.AccountId;
            newValidationCase.ContactId = wo.ContactId;
            newValidationCase.Status = null;
            newValidationCase.setOptions(dmlOpts);
            newCases.add(newValidationCase);
            //update WO validation state
            woToUpd = new WorkOrder();
            woToUpd.Id = wo.Id;
            woToUpd.XC_ValidationStatus__c = Label.XC_CL_WO_PendingValidation;
            woToUpd.XC_ValidationCounter__c = 1;
            allWOToUpdate.add(woToUpd);
        }
        
        //GDB - PERFORMANCE IMPROVEMENT - MAY 2022 - START
               
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        //FIRST:upd WO 
        List<XC_UTIL_SObject.WrapperResult> updAllWOResults = XC_UTIL_DML.updateRecords(allWOToUpdate); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Update All WO results = ' + updAllWOResults);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        
        //SECOND:ins Case
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new caseInsertAsync(newCases));
        }else{
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ newCases to create = ' + newCases+ ' - # newCases=' +newCases.size());
            List<XC_UTIL_SObject.WrapperResult> insCasesResults = XC_UTIL_DML.insertRecords(newCases);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Insert Validation Case results = ' + insCasesResults);
        }                     
        //GDB - PERFORMANCE IMPROVEMENT - MAY 2022 - END
    }

    /**
     * @description manageWorkOrderToValidate
     * @param woTovalidate the list wo to validate
     **/
    public static void manageWorkOrderToValidate(List<WorkOrder> woTovalidate){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ manageWorkOrderToValidate...');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ wo To process Validation = ' + woTovalidate);
        //inizializzo il Caso base da creare per ogni WO
        List<String> caseSettingNames = new List<String>{Label.XC_CL_ValidationCase};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        if(caseSettingsMap.isEmpty() || caseSettingsMap.get(Label.XC_CL_ValidationCase)==null){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+Label.XC_CL_ValidationCase);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Validation Case NOT created!');
            return;
        }
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_ValidationCase);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Validation caseSettings='+caseSettings);
        
        Case newValidationCase;
        List<WorkOrder> allWOToUpdate = new List<WorkOrder>();
        //List<XC_CM_WorkOrder_Validation__mdt> woValidations = getMetadataConfiguration(woTovalidate);
        //preparazione dei Case da creare > per ogni Case cerco la corrispondenza nella lista dei XC_CM_WorkOrder_Validation__mdt
        Map<String,List<WorkOrder>> complianceValidationResult = processComplianceMasterValidation(woTovalidate);
        
        //Only for WO to validate manually > retrieve to attach asset info
        Map<Id,Set<Id>> assetsToAttach = calculateAssetToAttachFromWO(complianceValidationResult.get('toValidateWO'));

        List<Case> newCases = new List<Case>();
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
        WorkOrder woToUpd;
        for(WorkOrder wo : complianceValidationResult.get('toValidateWO')){
            newValidationCase = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
            newValidationCase.XC_WorkOrder__c = wo.Id;
            newValidationCase.AccountId = wo.AccountId;
            newValidationCase.ContactId = wo.ContactId;
            newValidationCase.Status = null;
            newValidationCase.XC_AssetAttached__c = (assetsToAttach.get(wo.Id) != null && !(assetsToAttach.get(wo.Id)).isEmpty());
            //Setting the DMLOption on Case instance > TO RUN Assignment Rules (ESCEP-2257 [MC 20191121])
            newValidationCase.setOptions(dmlOpts);
            newCases.add(newValidationCase);
            //update WO validation state
            woToUpd = new WorkOrder();
            woToUpd.Id = wo.Id;
            woToUpd.XC_ValidationStatus__c = Label.XC_CL_WO_PendingValidation; //MC 20190717 - Caring Demo Enancments
            woToUpd.XC_ValidationCounter__c = 1;
            //woToUpd.XC_SentGoodIssue__c = true; //SA 16/01/2020
            allWOToUpdate.add(woToUpd);
        }
        
        //GDB - PERFORMANCE IMPROVEMENT - MAY 2022 - START            
        //FIRST:upd WO 
        allWOToUpdate.addAll(complianceValidationResult.get('automaticValidatedWO'));
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        List<XC_UTIL_SObject.WrapperResult> updAllWOResults = XC_UTIL_DML.updateRecords(allWOToUpdate); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Update All WO results = ' + updAllWOResults);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        
        //SECOND:ins Case
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new caseAndCaseAssetInsertAsync(newCases, assetsToAttach));
        }else{
            insCase(newCases, assetsToAttach);
        }
        //GDB - PERFORMANCE IMPROVEMENT - MAY 2022 - END


        //List<XC_UTIL_SObject.WrapperResult> updWoResults = XC_UTIL_DML.updateRecords(complianceValidationResult.get('automaticValidatedWO')); //(woToUpdate);
        
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ complMasterWOData = ' + complMasterWOData);
        /*for(WorkOrder wo : woTovalidate){
            for(XC_ComplianceMaster__c config : complMasterWOData){
                if(wo.XC_WorkTypeCategory__c == config.XC_WorkType__c &&
                   wo.Status == config.XC_WorkOrder_Status__c &&
                   (config.XC_WorkOrder_StatusReason__c == 'Any' || wo.XC_StatusReason__c == config.XC_WorkOrder_StatusReason__c) 
                   ){
                    
                    newCase.XC_WorkOrder__c = wo.Id;
                    newCase.AccountId = wo.AccountId;
                    newCase.ContactId = wo.ContactId;
                    newCase.Status = null;
                    if(validationConfig.XC_AutomaticValidation__c){
                        newCase.Status = Label.XC_CL_Case_Status007;
                    }else{
                        newCase.Status = null; //ripulisco il Case di un eventuale set precedente
                    }
                    newCases.add(newCase);
                    wo.XC_ValidationStatus__c = Label.XC_CL_WO_PendingValidation; //MC 20190717 - Caring Demo Enancments
                    woToUpdate.add(wo);
                }
            }
        }*/
    }

    /**
     * @description insCase
     * @param woTovalidate manage the insert of case and case asset
     **/
    private static void insCase(List<Case> newCases, Map<Id,Set<Id>> assetsToAttach){ 

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ newCases to create = ' + newCases+ ' - # newCases=' +newCases.size());
        List<XC_UTIL_SObject.WrapperResult> insCasesResults = XC_UTIL_DML.insertRecords(newCases);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Insert Validation Case results = ' + insCasesResults);
                 
        //THIRD: ins CasesAsset
        Set<Id> casesId = new Set<Id>();
        for(XC_UTIL_SObject.WrapperResult caseWR: insCasesResults){
            if(caseWR.recordId != null && caseWR.recordId != ''){
                casesId.add(caseWR.recordId);
            }
        }
        if(!casesId.isEmpty()){
            XC_UTIL_Sobject.WrapperResult caseAssetCreatRes = insertAllCaseAssetRelations(casesId, assetsToAttach);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Insert CaseAssetRelations results = ' + caseAssetCreatRes);
        }
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 17/12/2019
     * @description calculateAssetToAttachFromWO
     * @param woToValidate the list wo to validate
     * @return Map<Id,Map<Id,Set<Id>>> to relate WOId in inputh -> to a Set of assetId related to it or to its wo children
     **/
    private static Map<Id,Set<Id>> calculateAssetToAttachFromWO(List<WorkOrder> woToValidate){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ calculateAssetToAttachFromWO input=' + woToValidate);
        Map<Id,Set<Id>> result = new Map<Id,Set<Id>>();
        //add fathers
        for(WorkOrder wo : woToValidate){
            if(wo.AssetId != null && result.get(wo.Id) == null){
                result.put(wo.Id, new Set<Id>());
            }
            if(wo.AssetId != null){
                (result.get(wo.Id)).add(wo.AssetId);
            }
        }

        //add children
        Set<Id> woIds = XC_UTIL_Sobject.getSetIds(woToValidate);
        Map<Id,WorkOrder> woChildren = new Map<Id,WorkOrder>([
            SELECT Id, AssetId, ParentWorkOrderId FROM WorkOrder WHERE ParentWorkOrderId IN: woIds
        ]);

        for(WorkOrder wo : woChildren.values()){
            if(wo.AssetId != null && result.get(wo.ParentWorkOrderId) == null){
                result.put(wo.ParentWorkOrderId, new Set<Id>());
            }
            if(wo.AssetId != null){
                (result.get(wo.ParentWorkOrderId)).add(wo.AssetId);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ calculateAssetToAttachFromWO res=' + result);
        return result;
    }

    /**
     * @description insertAllCaseAssetRelations
     * @param casesId cases Id
     * @param assetsToAttach assets to attach
     * @return result wrapper
     **/
    public static XC_UTIL_Sobject.WrapperResult insertAllCaseAssetRelations(Set<Id> casesId, Map<Id,Set<Id>> assetsToAttach){
        Map<Id,Case> cases = new Map<Id,Case>([
            SELECT Id, XC_WorkOrder__c FROM Case WHERE Id IN: casesId AND XC_AssetAttached__c = true
        ]);
        if(cases.isEmpty()){
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            wr.success = true;
            return wr;
        }
        
        List<XC_CaseAsset__c> newJO = new List<XC_CaseAsset__c>();
        XC_CaseAsset__c jo;
        for(Case caso : cases.values()){
            if(assetsToAttach.get(caso.XC_WorkOrder__c) == null || (assetsToAttach.get(caso.XC_WorkOrder__c)).isEmpty()){
                continue;
            }
            for(Id id: assetsToAttach.get(caso.XC_WorkOrder__c)){
                jo = new XC_CaseAsset__c();
                jo.XC_Case__c = caso.Id;
                jo.XC_Asset__c = id;
                newJO.add(jo);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult>  dmlResult = XC_UTIL_DML.insertRecords(newJO);
        return XC_UTIL_Sobject.getGlobalDMLResults(dmlResult);
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 05/09/2019
     * @description processComplianceMasterValidation
     * @param woToValidate the list wo to validate
     * @return Map<String,List<WorkOrder>> with analisys Validation result 
     **/
    private static Map<String,List<WorkOrder>> processComplianceMasterValidation(List<WorkOrder> woToValidate){
        Map<String,List<WorkOrder>> complianceValidationResult = new Map<String,List<WorkOrder>>();
        
        /*Set<Id> woIds = XC_UTIL_Sobject.getSetIds(woTovalidate);
        Map<Id,ServiceAppointment> saMapping = XC_UTIL_ServiceAppointment.getDataActiveSAFromWo(woIds);
        List<String> saSubStatus = XC_UTIL_Sobject.getListFieldValues(saMapping.values(), 'XC_SubStatus__c');*/
        Map<Id,ServiceAppointment> saMapping = retrieveServiceAppointmentSubStatus(woTovalidate);

        Set<Id> assetIds = XC_UTIL_Sobject.getSetIdsOnField(woTovalidate, 'AssetId');
        Map<Id,Id> assetProductMapping = XC_UTIL_Asset.retrieveMappingAssetProductId(assetIds);

        Map<Id,String> commercialCodeData = retrieveWOCommercialCodes(woToValidate);

        Map<Id,Decimal> addAmountMapping = retrieveAdditionalAmount(woTovalidate);
        
        CheckWOValidationInput checkInputWrapper = new CheckWOValidationInput();
        CheckWOValidationOutput checkOutputWrapper = new CheckWOValidationOutput();
        XC_UTIL_ComplianceMaster.ComplianceValidationWrapperCheck complWr = new XC_UTIL_ComplianceMaster.ComplianceValidationWrapperCheck();
        complWr.woToValidate = woToValidate;
        complWr.saSubStatus = XC_UTIL_Sobject.getListFieldValues(saMapping.values(), 'XC_StatusReason__c'); // 'XC_SubStatus__c' /*MC ESCEP-2120*/ //saSubStatus; 
        complWr.commercialProductsIds = assetProductMapping.values();
        complWr.additionalCosts = addAmountMapping.values();

        //List<XC_ComplianceMaster__c> complMasterWOData = XC_UTIL_ComplianceMaster.getWOValidationComplianceMaster(woToValidate, saSubStatus, assetProductMapping.values());
        List<XC_ComplianceMaster__c> complMasterWOData = XC_UTIL_ComplianceMaster.getWOValidationComplianceMaster(complWr);
        List<WorkOrder> automaticValidatedWO = new List<WorkOrder>();
        List<WorkOrder> toValidateWO = new List<WorkOrder>();
        WorkOrder woToUpd;
        for(WorkOrder wo : woToValidate){
            checkInputWrapper.woToValidate = wo;
            checkInputWrapper.activeSA = saMapping.get(wo.Id);
            checkInputWrapper.commercialProductId = assetProductMapping.get(wo.AssetId);
            checkInputWrapper.commercialCode = commercialCodeData.get(wo.Id);
            checkInputWrapper.additionalCostAmount = addAmountMapping.get(wo.XC_Configuration__c);
            for(XC_ComplianceMaster__c validationWORule : complMasterWOData){
                checkInputWrapper.validationWORule = validationWORule;
                checkOutputWrapper = checkValidationWOCondition(checkInputWrapper);
                if(checkOutputWrapper.isWOValidated){
                    woToUpd= new WorkOrder();
                    woToUpd.Id = wo.Id;
                    woToUpd.XC_ComplianceValidationId__c = checkOutputWrapper.validationRuleId;
                    woToUpd.XC_ValidationStatus__c = Label.XC_CL_OkStatus;
                    woToUpd.XC_AutomaticValidation__c = true;
                    woToUpd.XC_ValidationCounter__c = 0;

                    automaticValidatedWO.add(woToUpd);
                    break;
                }
                /*else{
                    toValidateWO.add(wo);
                }*/
            }
            if(!checkOutputWrapper.isWOValidated){
                toValidateWO.add(wo);
            }
        }
        complianceValidationResult.put('automaticValidatedWO',automaticValidatedWO);
        complianceValidationResult.put('toValidateWO',toValidateWO);
        return complianceValidationResult;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 17/09/2019
     * @description retrieveServiceAppointmentSubStatus
     * @param workOrders WorkOrder List
     * @return Map<Id,ServiceAppointment> data
     **/
    private static Map<Id,ServiceAppointment> retrieveServiceAppointmentSubStatus(List<WorkOrder> workOrders){
        Set<Id> woIds = XC_UTIL_Sobject.getSetIds(workOrders);
        return XC_UTIL_ServiceAppointment.getDataActiveSAFromWo(woIds);
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 17/09/2019
     * @description retrieveAdditionalAmount
     * @param workOrders WorkOrder List
     * @return Map<Id,Decimal> data
     **/
    private static Map<Id,Decimal> retrieveAdditionalAmount(List<WorkOrder> workOrders){
        Set<Id> configIds = XC_UTIL_Sobject.getSetIdsOnField(workOrders, 'XC_Configuration__c');
        Map<Id,Decimal> result = new Map<Id,Decimal>();
        Map<Id,NE__Order__c> amounts = XC_UTIL_Configuration.getAdditionalAmountFromAcceptedQuoteOrder(configIds);
        for(NE__Order__c conf: amounts.values()){
            result.put(conf.Id,conf.NE__One_Time_Fee_Total__c);
        }
        return result;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 06/09/2019
     * @description map WO Id with its Partner Account Commercial Code
     * @param workOrders WorkOrder List
     * @return Map<Id,String>
     **/
    private static Map<Id,String> retrieveWOCommercialCodes(List<WorkOrder> workOrders){
        Map<Id,String> result = new  Map<Id,String>();
        if(workOrders==null || workOrders.isEmpty()){
            return result;
        }

        Set<Id> assignedResourceIds = XC_UTIL_Sobject.getSetIdsOnField(workOrders, 'XC_AssignedResource__c');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'retrieveWOCommercialCodes - assignedResourceIds='+assignedResourceIds);
        Map<Id,ServiceResource> servisResources = XC_UTIL_ComplianceMaster_D.getDataMapServiceResouces(assignedResourceIds);

        ServiceResource sr;
        for(WorkOrder wo: workOrders){
            if(wo.XC_AssignedResource__c != null){
                sr = servisResources.get(wo.XC_AssignedResource__c);
                result.put(wo.Id, sr.Account.XC_CommercialCode__c);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'retrieveWOCommercialCodes result='+result);
        return result;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 06/09/2019
     * @description check Validation WO Condition
     * @param checkInputWrapper CheckWOValidationInput
     * @return true if is validated, false otherwise
     **/
    public static CheckWOValidationOutput checkValidationWOCondition(CheckWOValidationInput checkInputWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CALL checkValidationWOCondition...');
        CheckWOValidationOutput result = new CheckWOValidationOutput();
        WorkOrder wo = checkInputWrapper.woToValidate;
        ServiceAppointment activeSA = checkInputWrapper.activeSA;
        XC_ComplianceMaster__c validationWORule = checkInputWrapper.validationWORule;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->->-> wo=' + wo);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->->-> activeSA=' + activeSA);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->->-> validationWORule=' + validationWORule);
        if( ('*' == validationWORule.XC_WorkOrder_Status__c || validationWORule.XC_WorkOrder_Status__c == wo.Status) &&
            ('*' == validationWORule.XC_WorkOrder_SubStatus__c || validationWORule.XC_WorkOrder_SubStatus__c == wo.XC_StatusReason__c) &&  //XC_SubStatus__c /*MC ESCEP-2120*/
            ('*' == validationWORule.XC_WorkType__c || validationWORule.XC_WorkType__c == wo.XC_WorkTypeCategory__c) &&
            subCheckCatalogCategory(validationWORule, wo.XC_CatalogCategory__c) &&
            //('*' == validationWORule.XC_ServiceType__c || validationWORule.XC_ServiceType__c == wo.XC_ServiceTypeGP__c) &&
            ('*' == validationWORule.XC_ServiceAppointment_SubStatus__c || validationWORule.XC_ServiceAppointment_SubStatus__c == activeSA.XC_SubStatus__c) && 
            subCheckCommercialProduct(validationWORule, checkInputWrapper.commercialProductId) &&
            checkFlagPicklistValue(validationWORule.XC_Urgent_Repair__c, wo.XC_Urgent_Repair__c) &&
            checkFlagPicklistValue(validationWORule.XC_WarrantyPossibility__c, wo.XC_WarrantyPossibility__c) &&
            checkFlagPicklistValue(validationWORule.XC_Digitized__c, wo.XC_Digitized__c) &&
            checkCommercialCode(validationWORule.XC_CommercialCode__c, checkInputWrapper.commercialCode) &&
            subCheckAdditionalAmount(validationWORule.XC_AdditionalCostAmount__c, checkInputWrapper.additionalCostAmount) &&
            checkFlagPicklistValue(validationWORule.XC_MaintenanceAndRepair__c, wo.XC_CreatedByTechnician__c) ){
                
                //calcolo in base alla probabilità
                if(probabilityEvaluation(Integer.valueOf(validationWORule.XC_Probability__c))){
                    result.isWOValidated = true;
                    result.validationRuleId = validationWORule.Id;
                }
            }
            
        result.checkedWO = wo;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->->-> checkValidationWOCondition result=' + result);
        return result;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 26/09/2019
     * @description probabilityEvaluation
     * @param probabilityValue
     * @return true if it matchs, false otherwise
     **/
    public static Boolean probabilityEvaluation(Integer probabilityValue){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->probabilityEvaluation > probabilityValue=' + probabilityValue);
        Integer randomValue = Integer.valueof((Math.random() * 100));
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->probabilityEvaluation > randomValue=' + randomValue);
        return (randomValue < probabilityValue);
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 06/09/2019
     * @description compare checkCommercialCode values
     * @param ruleCommCodeValue
     * @param woCommCodeValue
     * @return true if they match, false otherwise
     **/
    public static Boolean checkCommercialCode(String ruleCommCodeValue, String woCommCodeValue){
        if(ruleCommCodeValue == null){
            return true;
        }
        if(woCommCodeValue == null && ruleCommCodeValue != null){
            return false;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkCommercialCode - ruleCommCodeValue='+ruleCommCodeValue+' - woCommCodeValue='+woCommCodeValue);
        return ((ruleCommCodeValue.length()==3 && woCommCodeValue!=null && woCommCodeValue.startsWith(ruleCommCodeValue)) ||
                (ruleCommCodeValue.length()==6 && woCommCodeValue!=null && woCommCodeValue.equals(ruleCommCodeValue)));
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 06/09/2019
     * @description compare flag value from Compliance Master picklist and Work Order checkbox
     * @param ruleFlagValue Compliance Master picklist value (Yes, No or Indifferent)
     * @param woCheckboxValue Work Order checkbo value (true or false)
     * @return true if they match, false otherwise
     **/
    public static Boolean checkFlagPicklistValue(String ruleFlagValue, Boolean woCheckboxValue){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkFlagPicklistValue - ruleFlagValue='+ruleFlagValue+' - woCheckboxValue='+woCheckboxValue);
        return (Label.XC_CL_Indifferent == ruleFlagValue || (ruleFlagValue == Label.XC_CL_Yes && woCheckboxValue) || (ruleFlagValue == Label.XC_CL_No && !woCheckboxValue));
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 06/09/2019
     * @description subCheck Commercial Product
     * @param validationWORule XC_ComplianceMaster__c row
     * @param commercialProductId commercialProduct Id
     * @return true if is checked, false otherwise
     **/
    @TestVisible
    private static Boolean subCheckCommercialProduct(XC_ComplianceMaster__c validationWORule, Id commercialProductId ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'subCheckCommercialProduct - validationWORule='+validationWORule+' - commercialProductId='+commercialProductId);
        return ((validationWORule.XC_CommercialProductId__c == null && commercialProductId != null) 
                || validationWORule.XC_CommercialProductId__c == commercialProductId );
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 09/09/2019
     * @description subCheck Catalog Category
     * @param validationWORule XC_ComplianceMaster__c row
     * @param catalogCategoryId catalogCategory Id
     * @return true if is checked, false otherwise
     **/
    @TestVisible
    private static Boolean subCheckCatalogCategory(XC_ComplianceMaster__c validationWORule, Id catalogCategoryId ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'subCheckCatalogCategory - validationWORule='+validationWORule+' - catalogCategoryId='+catalogCategoryId);
        return ((validationWORule.XC_CatalogCategoryId__c == null && catalogCategoryId != null) 
                || validationWORule.XC_CatalogCategoryId__c == catalogCategoryId );
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date 17/09/2019
     * @description subCheck Additional Amount Cost
     * @param validationWORule XC_ComplianceMaster__c row
     * @param catalogCategoryId catalogCategory Id
     * @return true if is checked, false otherwise
     **/
    @TestVisible
    private static Boolean subCheckAdditionalAmount(Decimal validationAdditionalCost, Decimal additionalCostAmount ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'subCheckAdditionalAmount - validationAdditionalCost='+validationAdditionalCost+' - additionalCostAmount='+additionalCostAmount);
        return ((validationAdditionalCost == null || validationAdditionalCost == 0.00 ) //&& additionalCostAmount != null
                || validationAdditionalCost == additionalCostAmount );
    }

    /**
     * @description getComplianceMasterWOData
     * @param woToValidate the list wo to validate
     * @return XC_ComplianceMaster__c results
     **/
    /*private static List<XC_ComplianceMaster__c> getComplianceMasterWOData(List<WorkOrder> woToValidate){
        Set<String> workTypeValues = XC_UTIL_Sobject_U_Retrieve.getSetFieldValues(woToValidate, 'XC_WorkTypeCategory__c');
        Set<String> statusValues = XC_UTIL_Sobject_U_Retrieve.getSetFieldValues(woToValidate, 'Status');

        Map<Id,XC_ComplianceMaster__c> woValidations = new Map<Id,XC_ComplianceMaster__c>(
            [ SELECT XC_WorkType__c, XC_WorkOrder_Status__c
                FROM XC_ComplianceMaster__c
                WHERE XC_WorkType__c IN: workTypeValues
                AND XC_WorkOrder_Status__c IN: statusValues
            ]); //, XC_WorkOrder_StatusReason__c
        return woValidations.values();
    }*/

    /*private static List<XC_CM_WorkOrder_Validation__mdt> getMetadataConfiguration(List<WorkOrder> woTovalidate){
        //recupero le configurazioni dei WO da validare
        Set<String> workTypeValues = XC_UTIL_Sobject_U_Retrieve.getSetFieldValues(woTovalidate, 'XC_WorkTypeCategory__c');
        Set<String> statusValues = XC_UTIL_Sobject_U_Retrieve.getSetFieldValues(woTovalidate, 'Status');
        //Set<String> statusReasonValues = XC_UTIL_Sobject_U_Retrieve.getSetFieldValues(woTovalidate, 'XC_StatusReason__c'); 

        List<XC_CM_WorkOrder_Validation__mdt> woValidations = new List<XC_CM_WorkOrder_Validation__mdt>();
        if(Schema.sObjectType.XC_CM_WorkOrder_Validation__mdt.isAccessible() && Schema.sObjectType.XC_CM_WorkOrder_Validation__mdt.fields.XC_WorkType__c.isAccessible() && Schema.sObjectType.XC_CM_WorkOrder_Validation__mdt.fields.XC_Status__c.isAccessible() && Schema.sObjectType.XC_CM_WorkOrder_Validation__mdt.fields.XC_StatusReason__c.isAccessible() && Schema.sObjectType.XC_CM_WorkOrder_Validation__mdt.fields.XC_AutomaticValidation__c.isAccessible()){
            woValidations = [
                SELECT XC_WorkType__c, XC_Status__c, XC_StatusReason__c, XC_AutomaticValidation__c
                FROM XC_CM_WorkOrder_Validation__mdt
                WHERE XC_WorkType__c IN: workTypeValues
                AND XC_Status__c IN: statusValues];
                //AND XC_StatusReason__c IN: statusReasonValues
        }
        return woValidations;
    }*/

    /** 
     * @description Manage case status.
     * @param listNew the list new
     */
    /*public static void manageCaseStatus(List<WorkOrder> listNew){ 
        Set<Id> caseIdsToPending = new Set<Id>();
        for(WorkOrder newWorkOrder : listNew){ 
            if (newWorkOrder.CaseId != null && newWorkOrder.Status != null){ 
               caseIdsToPending.add(newWorkOrder.CaseId); 
            }  
        } 
        if(!caseIdsToPending.isEmpty()){
            XC_UTIL_Case.isParentCasePending(caseIdsToPending); 
        }
    }*/

    /**
     * @description Cancel cases on update.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    /*public static void cancelCasesOnUpdate(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            cancelCases(listChanged);
        }
    }*/

    /**
     * @description Cancel cases.
     * @param listNew the list new
     */
    /*public static void cancelCases(List<WorkOrder> listNew){ 
        Set<Id> caseIdsToCancel = new Set<Id>();
        for(WorkOrder newWorkOrder : listNew){
            //AJ: c.    Cuando una WO se cancele por cualquier causa, se debe cancelar automáticamente el Caso (independientemente de los otros hijos). 
            //En el campo CaseRemarks__c debe ponerse una información (que por ahora será genérica) pongamos simplemente “Caso Cancelado�?.
            if(newWorkOrder.Status!=null && newWorkOrder.CaseId!=null 
                && newWorkOrder.Status.equals(XC_AT_Constants.WO_STATUS_CANCELED)){
                caseIdsToCancel.add(newWorkOrder.CaseId);
            } 
        }  
        if(!caseIdsToCancel.isEmpty()){
            cancelCase(caseIdsToCancel);
        }
    } */


    /**
     * @description Cancel case.
     * @param caseSet the case set
     */
    /*public static void cancelCase(Set<Id> caseSet){
        List<Case> listCase = new List<Case>();
        for(Id cId : caseSet){
            Case c = new Case();
            c.Id = cId;
            c.Status = XC_AT_Constants.TRIGGER_STATUS_ESTA008;
            c.CaseRemarks__c = Label.XC_CL_Trigger_Error_IsCasoCancel;
            listCase.add(c);
        }
        XC_UTIL_Sobject.updateListRecords(listCase); 
    }*/

   /**
    * @description INNER QUEABLE CLASS for Case Insert
    * @author PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA 
    * @return Boolean
    */
    public class caseInsertAsync implements Queueable{
        List<Case> newCases;
        public caseInsertAsync(List<Case> newCases){
            this.newCases = newCases;
        }

        public void execute(QueueableContext context) {          
            XC_UTIL_DML.insertRecords(this.newCases);
        }
    }

    /**
    * @description INNER QUEABLE CLASS for Case Insert and Case Asset generation
    * @author PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA 
    * @return Boolean
    */
    public class caseAndCaseAssetInsertAsync implements Queueable{
        List<Case> newCases;
        Map<Id,Set<Id>> assetsToAttach;
        public caseAndCaseAssetInsertAsync(List<Case> newCases, Map<Id,Set<Id>> assetsToAttach){
            this.newCases = newCases;
            this.assetsToAttach = assetsToAttach;
        }

        public void execute(QueueableContext context) {          
            insCase(this.newCases, this.assetsToAttach);
        }
    }
    
   /**
    * @description INNER QUEABLE CLASS for Manage Case status on WO Update
    * @author PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA 
    * @return Boolean
    */
    public class manageCaseStatusOnUpdateAsync implements Queueable{
        List<WorkOrder> listChanged;
        public manageCaseStatusOnUpdateAsync(List<WorkOrder> listChanged){
            this.listChanged = listChanged;
        }

        public void execute(QueueableContext context) {
            manageCaseStatusOnUpdateLogic(this.listChanged);
        }
    }
}