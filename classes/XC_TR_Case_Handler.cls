/**
* @author Chiara Turco - cturco@deloitte.it & Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 19/03/2019
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_Case_Handler - Handler for Case Trigger
*/ 

public without sharing class XC_TR_Case_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_Handler');
    
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
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<Case> listNew){
        
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            /* MC - Queste chiamate devono stare all'inizio del TR, in questo ordine - INIZIO*/
            XC_TR_Case_U_DefaultSettings.applyDefaultSettings(listNew);
            XC_TR_Case_U_DefaultSettings.setFieldEmail2Case(listNew);
            XC_TR_Case_U_DefaultSettings.setCaseCreatorProfile(listNew);
            XC_TR_Case_U_SurveyManagement.setLegalEntityFromSurveyContact(listNew); //MC [29/07/2020];
            XC_TR_Case_U_PopulateFields.populateLegalEntityAndGeoCountry(listNew);// NM-LR [18/07/2019] //DT [02/11/2020]
            XC_TR_Case_U_PopulateFields.setNeedInternalCheckOnInsert(listNew);  // NM [01/12/2020]
            //XC_TR_Case_U_CheckCase.checkExistAppropriateCase(listNew); // DT [20/11/2019] // MC [15/06/2020]
            XC_TR_Case_U_PopulateFields.setTechnicalAssetOnCaseB2BG(listNew); //DeAv 06.07.2022 NR2330
            XC_TR_FillAssetCategory.fillAssetCategoryonInsert(listNew);
            /* MC - Queste chiamate devono stare all'inizio del TR, in questo ordine - FINE*/
            XC_TR_Case_U_CheckCase.assingSLA(listNew);
            XC_TR_Case_U_CheckDuplicates.checkDuplicates(listNew);
            //XC_TR_Case_U_PopulateFields.populateAssetListDetails(listNew);
            XC_TR_Case_U_CheckAppCancellation.manageAppointmentCancellation(listNew);
            XC_TR_Case_U_CheckCase.fillRecordType(listNew);     
            XC_TR_Case_U_ClosureManagement.populateRequiredClosedCaseClosureFields(listNew); // NM-LR [03/07/2019]
            XC_TR_CustomerInteractionRelationship.setInteractionId(listNew); // MC [19/02/2020]
            XC_TR_Case_U_ClosureManagement.updateIsStopped(listNew);
            //XC_TR_Case_U_DefaultSettings.setCaseRecordType(listNew); // SM-LO [24/07/2019]    //20200113 [MC] fix email2case B2B, set RT
            //XC_TR_Case_U_DefaultSettings.setCaseStatusOnCreation(listNew); // CM [30/08/2019 - ESCP 2057]
            XC_TR_Case_U_SurveyManagement.linkCaseAndSurvey(listNew); //OTTAVIANO Survey Management [22/10/2019];
            XC_TR_Case_U_ChechLclSusp.checkCase(listNew);
            XC_TR_U_CaseMalfunctioningB2C.onInsertCase(listNew);  // Arrigo case b2c Malfunctioning
            XC_TR_CheckParentMalfunctioning.onInsert(listNew); //Arrigo link a malfunctioning case to a parent case [25092020]
            XC_TR_WoMalFunctioning.onInsertSerialNumber(listNew);//Arrigo add the serial number of the technical asset to the Case Insert 
            XC_TR_Case_CreditMemoAssign.updateCredtiMemp(listNew);      
        XC_TR_Case_PopulateBPLI.setBillingProfileLineItem(listNew);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            List<Case> listNew = mapNewS.values();
            Map<Id, Case> mapOld = (Map<Id, Case>) mapOldS; 
            Map<Id, Case> mapNew = (Map<Id, Case>) mapNews; 
            XC_TR_Case_U_CheckCase.checkPermittingStatus(listNew, mapOld, mapNew); //CP [CR 2298 run before closeCase]
            XC_TR_FillAssetCategory.fillAssetCategoryonUpdate(listNew,mapOld); // to be runned before the checkCaseAndAssignSLA has an impact on sla assignment 
            XC_TR_Case_U_CheckDuplicates.checkDuplicates(listNew, mapOld, mapNew); //MC [15/07/2019]
            XC_TR_Case_U_ClosureManagement.populateRequiredCaseClosureFields(listNew, mapOld, mapNew); // NM-LR [03/07/2019]
            XC_TR_Case_U_ClosureManagement.closeCaseForFieldsFilled(listNew, mapOld, mapNew); // NM-LR [03/07/2019]
            XC_TR_Case_U_ClosureManagement.checkLegalization(listNew, mapOld, mapNew);
            XC_AffiliateBeneficiary_U.checkValidateAffBenBeforeClosure(listNew); //[DeAv 20211008 - CR NR1857]
            
            XC_TR_Case_U_CheckCase.checkCaseAndAssignSLA(listNew, mapOld, mapNew);
            XC_TR_Case_U_PopulateFields.updateLastQueue(listNew, mapOld, mapNew);
            //XC_TR_Case_U_PopulateFields.populateAssetListDetails(listNew, mapOld, mapNew);
            XC_TR_Case_U_DefaultSettings.updateAssetRelation(listNew, mapOld, mapNew);
            XC_TR_Case_U_ClosureManagement.updateIsStopped(listNew);
            XC_TR_Case_U_CancellationManagement.manageChildrenCaseStatusOnUpdate(listNew, mapOld, mapNew);
            XC_TR_Case_U_ManageIndemnification.manageApprovalStatus(mapOld, mapNew);
            XC_TR_Case_U_WOVerification.checkForValidationCaseKOClosure(listNew, mapOld, mapNew);
            XC_TR_Case_U_CongaCase.checkDocumentType(listNew);
			XC_TR_CloseLclCase.closeWoli(listNew, mapOld, mapNew);            
            XC_TR_U_CaseMalfunctioningB2C.onUpdateCase(listNew, mapOld);
            //XC_REST_ZUORA_CreditMemo.sentToZuora(mapNew,mapOld);
            XC_TR_CheckParentMalfunctioning.onUpdate(listNew,mapOld);
            XC_TR_WoMalFunctioning.onUpdateSerialNumber(listNew,mapOld); //Arrigo add the serial number of the technical asset to the Case on Update  
            
            XC_TR_Case_U_PopulateFields.setNeedInternalCheckOnUpdate(listNew, mapOld, mapNew);  // NM [01/12/2020]
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
            List<Case> listNew = mapNewS.values();
            XC_TR_Case_U_CreateObjectsLinked.checkCaseAndCreateOnInsert(listNew);
            XC_TR_Case_U_CreateObjectsLinked.createCaseDisconnect(listNew);
            XC_TR_Case_U_DefaultSettings.sendNotificationForCaseCreation(listNew);
            XC_TR_Case_U_DefaultSettings.setParentWithChildren(listNew);
            XC_TR_Case_U_Care_ActionPlan.setActionPlan(listNew);
            XC_TR_CustomerInteractionRelationship.setCTIinteraction(listNew); //MC [19/02/2020]   
            XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForCaseSurveyITA(listNew);
            XC_TR_Case_U_CloseClaim.checkcase(listNew, new Map<Id, Case>()); //NR2173-r1.2
            XC_TR_Case_U_SurveyManagement.afterInsertgetFeedBackCloseTheLoop(listNew); //MO [22/06/2020];
            XC_TR_Case_U_AutomaticDeactivation.onAfterInsert(listNew);
            XC_TR_Case_AssignCase.caseAssignment(listNew);
            XC_TR_WoMalFunctioning.insertCaseFut(listNew);
            XC_TR_Case_CallYourban.callOnInsert(listNew); 
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
            List<Case> listNew = mapNewS.values();
            Map<Id, Case> mapOld = (Map<Id, Case>) mapOldS; 
            Map<Id, Case> mapNew = (Map<Id, Case>) mapNews; 
            XC_TR_Case_U_CreateObjectsLinked.checkCaseAndCreateOnUpdate(listNew, mapOld, mapNew);
            XC_TR_Case_U_CareManagement.manageCaseStatusOnUpdate(listNew, mapOld, mapNew);
            XC_UTIL_Case.manageCasePendingFromRelatedCase(listNew, mapOld, mapNew);  // LO 31/01/19
            // XC_TR_Case_U_CareManagement.makeInProgressWhenAssigned(listNew, mapOld, mapNew);         //DO 09/03/2020
            XC_TR_Case_U_CareManagement.manageActivityOnOwnerChanging(listNew, mapOld, mapNew);
            XC_TR_Case_U_CaseRepair.workOrderCreation(listNew, mapOld, mapNew);
            XC_TR_Case_U_QualityCheck.updateWorkOrder(mapOld, mapNew);
            XC_TR_Case_U_WOVerification.workOrderValidation(listNew, mapOld, mapNew); //MC 20190529
            XC_TR_Case_U_WOVerification.resetCaseValidationParent(listNew, mapOld, mapNew); //MC 20190530
            //XC_TR_CustomerInteractionRelationship.setInteractionId(listNew);
            XC_TR_Case_U_ClosureManagement.closeAdministrativeStep(listNew, mapOld, mapNew);
            //XC_TR_Case_U_CreateObjectsLinked.createCustomerInteractionOnCaseUpdateOwner(listNew, mapOld, mapNew); //GDB 17/10/2019 //Commentato il 03/02/2020 in attesa di specifiche
            XC_TR_Case_U_CreateObjectsLinked.createCustomerInteractionOnCaseUpdate(listNew, mapOld, mapNew); //GDB 17/10/2019
            XC_TR_Case_U_ManageIndemnification.manageIndemnification(mapOld, mapNew);   // NM LR 31/10/2019
            XC_TR_Case_U_ManageFinalStatus.closeServiceAppointment(listNew, mapOld, mapNew); // SS 05/11/2019
            XC_TR_Case_U_ManageFinalStatus.photovoltaicRefundClosure(listNew, mapOld, mapNew);
            XC_TR_Case_U_ActionAfterClosure.manageActionsAfterClosure(listNew, mapOld, mapNew);
            XC_CaseClosure_CreditCheck.caseClosure(mapNew,mapOld); //NA 22062020
            XC_CaseClosure_RiskScoring.caseClosureRiskScoring(mapNew,mapOld); // NA 22062020
            XC_TR_Case_U_CloseClaim.checkcase(listNew,mapOld); //NR2173-r1.2
            XC_TR_Case_UpdateDealStatus.updateDealStatus(listNew);
            XC_TR_WoMalFunctioning.onUpdate(listNew, mapOld);//NA1208
            XC_REST_ZUORA_CreditMemo.sentToZuora(mapNew,mapOld);
            XC_TR_Case_CallYourban.callOnUpdate(listNew,mapOld); //NA 06/11/2020
            //XC_TR_CloseLclCase.closeWoli(listNew, mapOld, mapNew);   
            XC_TR_Case_U_ClosureManagement.sendCI(listNew, mapOld, mapNew);    
            XC_TR_Case_U_SurveyManagement.interactionForChangeMOP(mapOld, mapNew);
            XC_TR_Case_U_SetQualityCheckStatus.setQCStatusToValidated(mapOld, mapNew);
            XC_TR_Case_U_SetQualityCheckStatus.completeMilestoneQualityCheck(mapOld, mapNew);
        	XC_TR_Case_MalfunctioningNotification.checkCaseAndUpdateCustomerInteraction( listNew,  mapOld, mapNew);
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
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
                   
    }    
}