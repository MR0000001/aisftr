/**
* @author Simone Trenta - strenta@deloitte.it & luca Tedeschi - ltedeschi@deloitte.it
* @date Creation 11/01/2019
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_Configuration_Handler – Handler for NE__Order__c Trigger
*/

public without sharing class XC_TR_Configuration_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_Handler');
    
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
    public void onBeforeInsert(List<NE__Order__c> listNew){
        System.debug('$$$Query before BeforeInsert: ' +  Limits.getQueries());
        system.debug('***getCpuTime()*** 1onBeforeInsert order: '+Limits.getCpuTime()); 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            //XC_TR_Configuration_U_FillFields.changeStatus(listNew, null, null);
            //XC_TR_Configuration_U_FillAddress.populateAddressFromOpportunity(listNew);
            XC_TR_Configuration_U_FillFields.populateFieldsFromOpportunity(listNew);// populate Address + CallType [MC/DT]
			//last modified by Nicola Arrigo
            // XC_TR_Configuration_U_CheckBP.checkBillingProfile(listNew);
            XC_TR_Configuration_U_FillOppFields.populateSkipContractOnOrder(listNew);
        }
		
 
        System.debug('$$$Query after BeforeInsert: ' +  Limits.getQueries());
        system.debug('***getCpuTime()*** 2onBeforeInsert order: '+Limits.getCpuTime()); 
    } 
     
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        System.debug('$$$Query before BeforeUpdate: ' +  Limits.getQueries());
        system.debug('***getCpuTime()*** 1BeforeUpdate order: '+Limits.getCpuTime()); 
		//START-CR725-elisa.caldini@accenture.com-09.05.2022 
        Map<Id, NE__Order__c> mapOld = (Map<Id, NE__Order__c>) mapOldS;
        Map<Id, NE__Order__c> mapNew = (Map<Id, NE__Order__c>) mapNews;
        //END-CR725-elisa.caldini@accenture.com-09.05.2022													
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);     
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapNews =' + mapNews);
            List<NE__Order__c> listNew = mapNewS.values();
            //Map<Id, NE__Order__c> mapOld = (Map<Id, NE__Order__c>) mapOldS; 
            //Map<Id, NE__Order__c> mapNew = (Map<Id, NE__Order__c>) mapNews; 
            XC_TR_Configuration_U_FillFields.changeStatusUpdate(listNew, mapOld, mapNew);
            //XC_TR_Configuration_U_UpFinancialAppr.checkPicklistOnUpdate(listNew, mapOld, mapNew);
            XC_TR_Configuration_U_CreateContract.handleCreationContract(listNew, mapOld, mapNew);
            XC_TR_Configuration_U_ManageVoucher.beforeOrderUpdate(listNew, mapOld, mapNew);
            XC_TR_Configuration_U_GenerateOTP.generateOTP(listNew, mapOld, mapNew);  
            XC_TR_Configuration_U_CloseConfiguration.closeConfiguration(listNew, mapOld, mapNew);          
            XC_TR_Configuration_U_FillOppFields.populateOpportunity(listNew, mapOld, mapNew);  
            XC_TR_Configuration_U_StartCongaWorkflow.populateCongaField(listNew, mapOld, mapNew);
			XC_TR_Configuration_U_CongaWFCustomObj.checkRecordTypeForQuote(listNew,mapOld,mapNew);
            if(!Test.isRunningTest()) {  
             XC_TR_Configuration_U_FillBillAcc.populateBillingAccount(listNew,mapOld, mapNew);  
            }
            XC_TR_Configuration_U_ManageWBE.generateWBE(listNew,mapOld, mapNew);
            XC_TR_Configuration_U_FillFields.setTechnicalProductOnly(listNew,mapOld, mapNew);
																											 
            XC_TR_Config_U_SetVocalOrder.setVocalOrder(listNew,mapOld, mapNew);
            XC_TR_Config_U_QuoteItemsAmountCheck.checkNotifiedQuoteItemsAmount(mapOld, mapNew);
            XC_TR_Configuration_U_AssignOptyAndOpp.assignOwnerIfQuoteApproved(listNew); //20220726 Lorenzo Evangelisti
        }
		XC_TR_Configuration_U_AssignOptyAndOpp.AssignOwnerConfigurationAndOpportunityAfterApproval(mapOld,mapNew); //CR725-elisa.caldini@accenture.com-09.05.2022 
       
        System.debug('$$$Query after BeforeUpdate: ' +  Limits.getQueries());
        system.debug('***getCpuTime()*** 2BeforeUpdate order: '+Limits.getCpuTime()); 
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            
        }        
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after insert 
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
        System.debug('$$$Query before AfterInsert: ' +  Limits.getQueries());
        system.debug('***getCpuTime()*** 1onAfterInsert order: '+Limits.getCpuTime()); 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
          List<NE__Order__c> listNew = mapNewS.values();
          XC_TR_Configuration_U_CountConf.onCountConfigurationInsert(listNew);
          
          //XC_TR_Configuration_U_FillFields.fillPicklistValues(listNew);
        }
        System.debug('$$$Query after AfterInsert: ' +  Limits.getQueries());
        system.debug('***getCpuTime()*** 2onAfterInsert order: '+Limits.getCpuTime());
    } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        System.debug('$$$Query before AfterUpdate: ' +  Limits.getQueries());
        system.debug('***getCpuTime()*** 1onAfterUpdate order: '+Limits.getCpuTime()); 
		if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            List<NE__Order__c> listNew = mapNewS.values();
            //List<NE__Order__c> listOld = mapOlds.values();
            Map<Id, NE__Order__c> mapOld = (Map<Id, NE__Order__c>) mapOldS; 
            Map<Id, NE__Order__c> mapNew = (Map<Id, NE__Order__c>) mapNews; 
            XC_TR_Config_U_SetParentCaseStatus.setParentCaseStatusInPending(listNew, mapOld, mapNew);
            XC_TR_Configuration_U_FillBillAcc.checkIfCostCenter(listNew,mapOld,mapNew);
            XC_TR_Configuration_U_CountConf.onCountConfigurationUpdate(listNew,mapOld,mapNew); 
            //XC_TR_Configuration_U_FillFields.createAssetFromOrder(listNew, mapOld, mapNew);
            //XC_TR_Configuration_U_CreateCase.createCase(listNew, listOld, mapOld, mapNew);
            
            //XC_TR_Configuration_U_ManageVoucher.afterOrderUpdate(listNew, mapOld, mapNew);   // NM LR - 28/11/2018 - ESCEP-144 ESCEP-145 ESCEP-155
            XC_TR_Conf_U_CheckCompliance1Status.checkCompliance1Status(listNew, mapOld, mapNew);    // NM LR - 08/02/2019 - ESCEP-1427
            //XC_TR_Config_U_CloseWOLI.closeWOLI2(listNew, mapOld, mapNew);    // NM - 13/02/2019 
            XC_TR_Configuration_U_CloseConfiguration.caseDisconnectClosure(listNew,mapOld, mapNew); // DT 04/09
            XC_TR_Conf_U_ManageOptyFather.updateFatherOpty(listNew, mapOld, mapNew);
            //XC_TR_Configuration_U_CloseActions.copyLossReason(listNew, mapOld, mapNew);
            XC_TR_Configuration_U_FillFields.checkStepCustomerAcceptance(listNew, mapOld, mapNew);
            //XC_UTIL_Case.manageCasePendingConf(listNew,mapOld,mapNew);
            XC_TR_Config_U_SetParentCaseStatus.manageCasePendingConf(listNew,mapOld,mapNew);
            XC_TR_Config_U_CustomerInteraction.createCustomerInteractionForAcceptedQuote(listNew, mapOld, mapNew);  // NM LR - 01/07/2019
            XC_TR_Config_U_ManageCompletedQuote.manageCompletedQuote(listNew, mapOld, mapNew); 
            XC_TR_Configuration_U_WaitForCommodity.checkWaitForCommodity(listNew, mapOld, mapNew);
            XC_TR_Configuration_U_ManageContract.manageUpdateContract(listNew, mapOld, mapNew); // NM LR - 17/01/2020
            XC_TR_Configuration_U_ExternalFinancing.checkExternalFinancingPayment(listNew, mapOld, mapNew);
            XC_TR_Configuration_U_FillFields.openCartForTechnicalProduct(listNew, mapOld, mapNew);
            XC_TR_Configuration_U_StartCongaWorkflow.onAfterUpdate(mapOld, mapNew);
            XC_TR_Config_U_ManageChangeOffer.onAfterUpdateOrder(listNew, mapOld, mapNew);
            XC_TR_WbetrackingSendToSap.updateWbeTrackingOnClosedOrder(mapOld, mapNew);
			XC_ConfItem_U_CheckOrderType.retrieveOrderType(mapOld,mapNew);
			XC_TR_Configuration_U_CompleteStep.onStatusUpdate(listNew, mapOld, mapNew);
        }
       // XC_TR_Configuration_CreateAutoNumber.createNewRecord((List<NE__Order__c>) mapNewS.values(),(Map<Id,NE__Order__c>)mapOldS); //Create autonumber       
		System.debug('$$$Query after AfterUpdate: ' +  Limits.getQueries());
        system.debug('***getCpuTime()*** 2onAfterUpdate order: '+Limits.getCpuTime()); 
    }
  
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record conf
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
        }           
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }           
    }    
}