/**
* @author Marco Rosa - marco.rosa@nttdata.com 
* @date Creation 23/10/2018
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_WorkOrder_Handler – Handler for XC_TR_WorkOrder Trigger
*/

public without sharing class XC_TR_WorkOrder_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_Handler');
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {  
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */ 
    public void executedTrigger(){ 
        //mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */ 
    public void onBeforeInsert(List<WorkOrder> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        XC_TR_WorkOrder_U_FillFields.fillSegment(listNew);  // NM 22/04/2020  
        XC_TR_WorkOrder_U_PopulateWorkType_U.setProductSubtypeAndLegalEntity(listNew);
        XC_TR_WorkOrder_U_PopulateWorkType.checkAndPopulateWorkType(listNew);
        XC_TR_WorkOrder_U_FillFieldByConfItem.fillFieldsFromConfigurationItem(listNew);
        XC_TR_WO_MaintenancePlan.createWO(listNew); 
        XC_TR_WorkOrder_U_FillFieldByAsset.fillFieldsFromAsset(listNew,false);  
        XC_TR_WorkOrder_U_CheckCommercialVisit.checkExistingCommercialVisit(listnew); 
        //XC_TR_WorkOrder_U_PopulateServiceType.populateServiceType(listNew);     
        XC_TR_WorkOrder_U_PopulateQualityCheck.retrieveOnlyQualityCheck(listNew);
        XC_TR_WorkOrder_U_SLAManagement.assignSLA(listNew);
        XC_TR_WorkOrder_U_FillFields.concatAddress(listNew);
        //XC_TR_WorkOrder_U_AssignWO.assignWO(listNew);
        XC_TR_WorkOrder_U_FillFields.fillFSLKeyAppointment(listNew);
        XC_TR_WorkOrder_U_FillFields.populateDescriptionFromCase(listNew);
        XC_TR_WorkOrder_U_Fill_Phone.updatePhoneByContact(listNew);
        XC_TR_WorkOrder_U_Fill_Subject.populateSubjectFromOpportunity(listNew); //[DeAv 02-02-2022 NR2252]
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        system.debug('mapOldS'+' '+mapOldS);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);    
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        List<WorkOrder> listNew = mapNewS.values();
        Map<Id, WorkOrder> mapOld = (Map<Id, WorkOrder>) mapOldS; 
        Map<Id, WorkOrder> mapNew = (Map<Id, WorkOrder>) mapNews; 
        //XC_TR_WorkOrder_U_FillFields.checkValidation(listNew, mapOld, mapNew); // MC > commentat chiamata 20191025 
        XC_TR_WorkOrder_U_FinalStatus.checkForSiteInspection(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_FillFieldByAsset.checkChangedWarrantyResolution(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_FinalStatus.updateWorkOrderFinalStatus(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_FinalStatus.updateStartDateOnWorkOrder(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_CloseActions.copyLossReason(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_StartCongaWorkflow.populateCongaFieldOnWOLI(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_SLAManagement.updateAssignedSLA(listNew, mapOld, mapNew); 
        XC_TR_WorkOrder_U_SLAManagement.checkForMilestonesViolations(listNew, mapOld, mapNew); 
        XC_TR_WorkOrder_U_FillFields.updateFSLKeyAppointment(listNew, mapOld, mapNew);
		XC_OnHoldMalfunctioningCase.inProgressdMalfunctioning(listNew, mapOld);
		XC_TR_onHoldWOUpdates.oonHoldWOFillSuspencion(listNew,mapOld);
		XC_TR_onHoldWOUpdates.ReplanningWO(listNew,mapOld);
        XC_TR_WorkOrder_U_FinalStatus.checkWorkOrderCompliance(listNew, mapOld, mapNew);
    } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        system.debug('mapNews'+' '+mapNews);
        Map<Id, WorkOrder> mapNew = (Map<Id, WorkOrder>) mapNews; 
        List<WorkOrder> listNew = mapNewS.values();
        Map<Id, WorkOrder> mapOld = new Map<Id, WorkOrder>(); //ALC 30/11/2021 - WBE Portugal EMPTY MAP JUST TO SEND THE SAME NUMBER OF PARAMETERS TO METHOD UPDATEWBE
        XC_TR_WorkOrder_U_SharingChild.shareChildOnInsert(listNew);
        XC_TR_WorkOrder_U_FillFields.encryptWorkOrderIds(listNew);
        //XC_TR_WorkOrder_U_SetParentCaseStatus.setParentCaseStatusInProgress(listNew);
        XC_TR_WorkOrder_U_SetParentCaseStatus.setParentCaseStatusInPending(listNew);
        XC_TR_WorkOrder_U_PopulateSkills.populateSkills(listNew); 
        XC_TR_WorkOrder_U_RequiredResMgmt.manageRequiredResourcesOnInsert(listNew); //MR NEW FSL
        XC_TR_WorkOrder_U_MaintenancePlan.createMaintenanceAppointment(listNew);
        //XC_TR_WorkOrder_U_CreateWOLineItem.createWorkOrderLineItem(listNew);   // SA - 02/08/2019
        //XC_TR_WorkOrder_U_CreateCustomInter.afterWorkOrderInsert(listNew);  // NM LR - 08/01/2019 - ESCEP-1043
        //XC_TR_WorkOrder_U_CareManagement.cancelCases(listNew); //MR 2019-02-15
        //XC_TR_WorkOrder_U_FillFields.populateRecordType(listNew); // SS - 2020/01/15
        //XC_TR_WorkOrder_U_CloseActions.caseCreationDisputability(listNew);
        XC_TR_WorkOrder_ManageProductRequired.createProductRequired(listNew);
        XC_TR_WorkOrder_U_ManageSubstitution.createChildrenWorkOrder(listNew);  
        XC_TR_WorkOrder_U_ManageBooking.manageForBooking(listNew);
        XC_TR_WorkOrder_U_CareManagement_V.careManagementToScheduleAppointmet(listNew); // MC - 20/01/2020 - Spain BSN Feedback ID39
        XC_TR_WorkOrder_U_CreateChildrenWO.createChildrenWorkOrders(listNew);
        XC_TR_WorkOrder_U_ManageTechnicalSheet.fillWOOnTechnicalSheets(listNew);
        XC_TR_WorkOrder_U_AssignSRProv.insertSRtoProvider(mapNew);
        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntMaintenanceReminder(listNew);
        XC_TR_CreateWoli.createWoli(listNew);
        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForWorkOrdITA(listNew);
        XC_TR_WorkOrder_U_FillFields.updateOrderWithLastSiteInspection(listNew);
        XC_TR_WorkOrder_UpdateDateTimeField.updateDateTime(listNew);
        XC_TR_WorkOrder_U_FillFields.updateWBE(mapOld, mapNew); //ALC 30/11/2021 - WBE Portugal       
      } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record 
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        List<WorkOrder> listNew = mapNewS.values();
        Map<Id, WorkOrder> mapOld = (Map<Id, WorkOrder>) mapOldS;
        Map<Id, WorkOrder> mapNew = (Map<Id, WorkOrder>) mapNews;
          XC_TR_ClosureCaseMalFunctioning.caseClosureMalfunctioning(listNew, mapOld); 		
        XC_TR_WorkOrder_U_SharingChild.shareChildOnUpdate(mapOld, mapNew);
        XC_TR_WorkOrder_U_CareManagement.manageCaseStatusOnUpdate(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_PopulateSkills.populateSkillsOnUpdate(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_FinalStatus.manageWorkOrderFinalStatus(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_SetParentCaseStatus.parentCaseStatusSetAndRemovePending(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_FillFields.updateServiceApp(listNew, mapOld, mapNew);
        //XC_TR_WorkOrder_U_CareManagement.cancelCasesOnUpdate(listNew, mapOld, mapNew); //MR 2019-02-15
        XC_TR_WorkOrder_U_CareManagement.checkExtraWorkAndExtraKm(listNew, mapOld, mapNew); //LC 2021-12-23
        XC_TR_WorkOrder_U_CareManagement.checkForValidationCaseCreation(listNew, mapOld, mapNew); //MC 2019-03-28
        //XC_TR_WorkOrder_U_CancellationManagement.manageWorkOrderCancellation(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_CreateWOLineItem.createWorkOrderLineItem(listNew, mapOld, mapNew); // SA 02/08/2019
        //XC_TR_WorkOrder_U_ManageSATO.checkStatusChildWorkOrderForSato(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_ManageSATO.createChildWorkOrderForSato(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_CloseActions.caseCreationDisputability(listNew,mapOld, mapNew);
        XC_TR_WorkOrder_U_FinalStatus.createForGlovia(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_updateStatusChildWO.updateChildWorkOrderSubstitution(listNew,mapOld, mapNew);
        //XC_TR_WorkOrder_U_CloseParentWorkOrder.checkWorkOrderIsRepair(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_CreateCustomInter.afterWorkOrderUpdate(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_CareManagement_V.careManagementToScheduleAppointmetOnUpdate(listNew, mapOld, mapNew); // MC - 20/01/2020 - Spain BSN Feedback ID39
        XC_TR_WorkOrder_U_CreateChildrenWO.populateFieldOnUpdateAssignedResource(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_ManageMilestone.updateCompletedMilestone(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_SendAppPush.sendPushNotificationOnWoReason(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_ManageTechnicalSheet.searchTechnicalSheetForClosure(mapOld, mapNew);
        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForWorkOrdITA(listNew);
        XC_TR_WorkOrder_U_AssignSRProv.updateSRtoProvider(mapNew,mapOld);
      //  XC_TR_ClosureCaseMalFunctioning.caseClosureMalfunctioning(listNew, mapOld);
        XC_TR_U_WOChangePartnerPreferred.WOChangePartnerPreferred(mapNew,mapOld); 
		XC_OnHoldMalfunctioningCase.onHoldMalfunctioning(listNew,mapOld);
        XC_OnHoldMalfunctioningCase.caseUpdate(listNew,mapOld);
        XC_TR_WorkOrder_U_ChangeOwner.isChangePreferedPartner(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_ChangeOwner.isChangeAssignedResources(listNew, mapOld, mapNew);
		 XC_TR_onHoldWOUpdates.updateSA(listNew,mapOld);
		 XC_TR_onHoldWOUpdates.updateSAReplanning(listNew,mapOld);
		 XC_AssignOwnerWorkOrder.onUpdate(listNew,mapOld);
        XC_TR_WorkOrder_U_AssignedPartner.updateAssignedPartner(listNew, mapOld, mapNew);
        XC_TR_WorkOrder_U_FillFields.updateWBE(mapOld, mapNew); //ALC 30/11/2021 - WBE Portugal
         // START vdb cr 760 24-02-2022
        XC_OnHoldMalfunctioningCase.updateFieldWo(listNew, mapOld);
        XC_TR_CalculationDistance_AssetToWo.updateDistanceWo(listNew, mapOld);
        // END vdb cr 760 24-02-2022
       
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapOld - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapOld) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    }    

}