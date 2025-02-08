/**
* @author Simone Trenta - strenta@deloitte.it & Luca Tedeschi - ltedeschi@deloitte.it
* @date Creation 11/01/2019
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_ConfigurationItem_Handler – Handler for NE__Order__c Trigger
*/

public without sharing class XC_TR_ConfigurationItem_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_Handler');
    //20220301_GestioneCruscotto - start
    public static Boolean bypassBeforeUpdate = false;
    public static Boolean bypassAfterUpdate = false;
    //20220301_GestioneCruscotto - end
	/*20220316_NicoloFodera Ottimizzazione createOrder - start*/ 
	public static Boolean asyncAggreateAfterUpdate = false;
	public class TriggerContext{ 
		Map<Id, SObject> mapOldS; Map<Id, SObject> mapNewS;
		public TriggerContext(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
			this.mapOldS = mapOldS;
			this.mapNewS = mapNewS;
		}
	}
	public static List<TriggerContext> triggerContextList = new List<TriggerContext>(); 
	/*20220316_NicoloFodera Ottimizzazione createOrder - end*/ 

    
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
     * @modified by Nicola Arrigo 2101
    */
    public void onBeforeInsert(List<NE__OrderItem__c> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on NE__OrderItem__c on ' + Trigger.operationType);
            XC_TR_ConfigurationItem_U_CheckIfProduct.onBeforeInsert(listNew);
            //XC_TR_ConfItem_U_CopyCatFields.copyCategoryFields(listNew, mapNew);
            //XC_TR_ConfigurationItem_U_GenerateWBE.populateWBEfields(listNew);
            XC_TR_ConfigurationItem_U_BillingModel.onInsert(listNew);
            XC_TR_ConfigurationItem_U_FillProdFields.onInsert(listNew);
            //XC_TR_ConfigurationItem_U_FillFields.fillFieldsOnInsert(listNew);
            XC_TR_ConfigurationItem_U_BillingProfile.hasBillingProfileInsert (listNew);   // NA 2101
            XC_TR_ConfigurationItem_U_createDaneCode.createDaneCodeInsert(listNew);       //NA1002
          //  XC_TR_Configuration_U_CheckBP.checkBillingProfile(listNew); //NA 2101
            XC_TR_ConfigurationItem_U_FillFields.fillTranslatedProductName(listNew);
            XC_TR_ConfigurationItem_PPMChecks.legalEntityConfItemBeforeInsert(listNew);
        }
            XC_TR_ConfiItem_U_FillAddress.populateAddressFromConf(listNew);
            XC_TR_ConfigurationItem_U_BillingProfile.setPartnerAccount(listNew);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
     * @lastmodifiedBy Nicola Arrigo 20/01/2019
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        //20220301_GestioneCruscotto - start
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on NE__OrderItem__c on ' + Trigger.operationType);
		mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
		Map<Id, NE__OrderItem__c> mapOld = (Map<Id, NE__OrderItem__c>) mapOldS;
		Map<Id, NE__OrderItem__c> mapNew = (Map<Id, NE__OrderItem__c>) mapNews;
		
        if(!bypassBeforeUpdate){
            //20220301_GestioneCruscotto - end
            List<NE__OrderItem__c> listNew = mapNewS.values();
            if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
                
                //XC_TR_ConfItem_U_CopyCatFields.copyCategoryFields(listNew, mapNew);
                XC_TR_ConfigurationItem_U_CloseConfItem.closeConfigurationItem(listNew,mapOld,mapNew);
                XC_TR_ConfigurationItem_U_CheckCase.checkIfCloseable(listNew,mapOld,mapNew);
                XC_TR_ConfigurationItem_U_CheckIfProduct.onBeforeUpdate(listNew,mapOld,mapNew);
                XC_TR_ConfigurationItem_U_BillingModel.onUpdate(mapOld,mapNew);
                //XC_TR_ConfigurationItem_U_CheckForZQuote.checkBillingProfileConditions(listNew, mapOld, mapNew);
                XC_TR_ConfigurationItem_U_FillProdFields.onUpdate(listNew, mapOld, mapNew);
                XC_TR_ConfigurationItem_U_FillFields.fillFieldsOnUpdate(mapOld, mapNew);
                XC_TR_ConfigurationItem_U_BillingProfile.hasBillingProfile (listNew,mapOld);  //NA2001
                XC_TR_ConfigurationItem_U_GenerateWbeB2B.wbeChangeOrder(listNew); // In this method is managed Technical Product too
                XC_TR_ConfigurationItem_U_BillingModel.checkPaymentMethodOfBundle(listNew, mapOld, mapNew);
                XC_TR_ConfigurationItem_U_StartCongaWF.onUpdate(mapOld,mapNew);
                XC_TR_ConfItem_U_ChangeOffer.onBeforeUpdate(mapOld, mapNew);
                XC_TR_ConfigurationItem_U_BillingModel.populateBillingModelComplexProd(mapOld, mapNew);
                XC_TR_ConfItem_U_SetAllowPaymentTypes.onBeforeUpdate(mapOld, mapNew);
                XC_TR_ConfigurationItem_CheckTemplatePPM.confItemCheckTemplateOnProjectIsFilled(mapOld,mapNew);
                XC_TR_ConfigurationItem_U_AttributesUpd.checkForCostValueUpdate(listNew,mapOld,mapNew);
                XC_TR_ConfigurationItem_U_AttributesUpd.updateOneTimeCostOncommercialItem(mapOld,mapNew);
                //XC_TR_ConfigurationItem_U_AttributesUpd.rollUpPriceOnParent(mapOld,mapNew);
                //XC_TR_ConfigurationItem_U_AttributesUpd.updateOneTimePriceOnParent(mapOld,mapNew);

                XC_TR_ConfigurationItem_PPMChecks.updateCommercialParent(listNew);
                // XC_TR_ConfigurationItem_U_ChangeOrder.updateChildByParent(mapOld,mapNew);
                // XC_TR_ConfigurationItem_U_DurationField.updateActionB2W(mapOld,mapNew);                
                //XC_TR_ConfigurationItem_U_ManageFullD.onAfterInsert(listNew);
                //VAT Tax management 08/11/2021 alag@deloitte.es
                XC_VATManagementTriggersHandler.applyNormalTaxByDefault(mapOld, mapNew);
                XC_VATManagementTriggersHandler.setTaxTypes(mapNew);
				XC_TR_ConfigurationItem_U_ManageFullLife.onBeforeUpdate(listNew,mapOld); // CR 1893
            }

            //CR2349 - mario.a.giordano@accenture.com R1 2022
			if(XC_UTIL_OneOrg.isRightCountryItaly(mapOldS)){                 
			  XC_TR_ConItem_CheckCustomerInsight.checkProductsCustomerInsight(mapNew);
            } 
			//END

            XC_TR_ConfigurationItem_U_ChangeOrder.updateChildByParent((Map<Id, NE__OrderItem__c>) mapOlds ,(Map<Id, NE__OrderItem__c>)mapNews);
            XC_TR_ConfigurationItem_U_DurationField.updateActionB2W((Map<Id, NE__OrderItem__c>) mapOlds ,(Map<Id, NE__OrderItem__c>)mapNews);
            // @ Mod CV CR.NR @date 29/10/2021 add XC_Zone__c to quey Start-->
            //CR2249 - Gestione date contrattuali - federico.manni@accenture.com R1 2022
            //XC_TR_ConfigurationItem_U_DurationField.updateEndDate((Map<Id, NE__OrderItem__c>) mapOlds ,(Map<Id, NE__OrderItem__c>)mapNews);
            XC_TR_ConfigurationItem_U_DurationField.setRecurringDurationRoot((Map<Id, NE__OrderItem__c>) mapOlds ,(Map<Id, NE__OrderItem__c>)mapNews);
            XC_TR_ConfigurationItem_U_UpdateEndDate.updateDate((Map<Id, NE__OrderItem__c>) mapOlds ,(Map<Id, NE__OrderItem__c>)mapNews);
            //End <--

        }//20220301_GestioneCruscotto - end
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on NE__OrderItem__c on ' + Trigger.operationType);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
     * @lastmodifiedBy Nicola Arrigo 20/01/2019
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) {
        List<NE__OrderItem__c> listNew = mapNewS.values();
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on NE__OrderItem__c on ' + Trigger.operationType);
            XC_TR_ConfigurationItem_U_FillProdFields.fillB2WFields(listNew);
            //XC_TR_ConfigurationItem_U_BillingProfile.hasBillingProfileInsert (listNew);
            //XC_TR_Configuration_U_CheckBP.checkBillingProfile(listNew); //NA 2101
            XC_TR_ConfigurationItem_U_GenerateWBE.generateWBEchangeOrder(listNew);
            XC_TR_ConfigurationItem_U_StartCongaWF.onInsert(listNew);
            XC_TR_ConfItem_U_ChangeOffer.onAfterInsert(listNew);
            XC_TR_ConfItem_U_SetAllowPaymentTypes.onAfterInsert(listNew);
            //XC_TR_ConfigurationItem_ManageSite.cloneSitesNextStep(listNew);
            //XC_TR_Configuration_FiscalProducts.checkFiscalProduct(listNew);
        }
        XC_TR_ConfigurationItem_U_ManageFullLife.fillCostTechItems(listNew); //elisa.caldini@accenture.com-22.06.2022-hotfix CR758
      }
	  
	  
	  
	 /**
     * @author Nicolo Fodera - nicolo.fodera@enel.com 
     * @description Method to be executed on after update SYNC 
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
	 * @date Creation 16/03/2022
    */
	public static void onAfterUpdateSync(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
		//20220301_GestioneCruscotto - start 
        if(!bypassAfterUpdate){
            //20220301_GestioneCruscotto - end

            if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on NE__OrderItem__c on ' + Trigger.operationType);
                mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapNews =' + mapNews);
                List<NE__OrderItem__c> listNew = mapNewS.values();
                Map<Id, NE__OrderItem__c> mapOld = (Map<Id, NE__OrderItem__c>) mapOldS;
                Map<Id, NE__OrderItem__c> mapNew = (Map<Id, NE__OrderItem__c>) mapNews;
                XC_TR_ConfigurationItem_U_CancelOrder.checkConfigurationItemStatus(listNew, mapOld, mapNew);
                XC_TR_ConfigurationItem_U_UpdateAsset.updateOnStatusCompleted(listNew, mapOld, mapNew);
                XC_TR_ConfigurationItem_U_UpdateAsset.updateOriginalBillingProfile(listNew, mapOld, mapNew);
                XC_TR_ConfigurationItem_U_UpdateAsset.updateBillingProfileLineItemOnAsset(listNew, mapOld, mapNew);
                XC_TR_ConfItem_U_CheckComplianceStatus.checkCompliance1Status(listNew, mapOld, mapNew);     // NM LR - 11/01/2019 - ESCEP-802
                XC_TR_ConfItem_U_CheckComplianceStatus.checkCompliance2Status(listNew, mapOld, mapNew);     // NM LR - 16/01/2019 - ESCEP-802
                XC_TR_ConfItem_U_CheckComplianceStatus.checkCompliance3Status(listNew, mapOld, mapNew);     // NM LR - 16/01/2019 - ESCEP-802
                XC_TR_ConfItem_U_CheckComplianceStatus.checkCompliance4Status(listNew, mapOld, mapNew);
                XC_TR_ConfItem_U_CompleteStep.onAfterUpdate(mapOld, mapNew);
                XC_TR_ConfigurationItem_U_BillingModel.setModelFromBundle(listNew, mapOld, mapNew);
                XC_TR_ConfigurationItem_U_BillingModel.onAfterUpdate(mapOld,mapNew);
                // vdb 23-11-2021
                //XC_TR_ConfigurationItem_U_BillingModel.updateBillingProfileItem(listNew,mapOld,mapNew);
                XC_TR_ConfItem_U_PopulateDocCharacterist.populateDocCharacterist(listNew, mapOld, mapNew);
                XC_TR_ConfigItem_U_BundleAmount.calculateBundleTotalAmountOnUpdate(mapOld, mapNew);
                XC_TR_ConfigurationItem_U_FillFields.fillCreditAssignmentOnUpdate(mapOld, mapNew);
                XC_TR_ConfigurationItem_U_FillFields.populateExternalFinancingFieldsOnOrder(mapOld, mapNew);
                //XC_TR_ConfigurationItem_U_CheckForZQuote.checkBillingProfileConditions(listNew, mapOld, mapNew);
                XC_TR_ConfigurationItem_U_StartCongaWF.onAfterUpdate(mapOld, mapNew);
                XC_TR_ConfigurationItem_PPMChecks.checkProjectTemplate( listNew,mapOld,mapNew);
                XC_TR_ConfiItem_U_CheckInstalAddress.onUpdate(mapOld, mapNew);
                XC_TR_ConfigurationItem_U_StartCongaWF.populatePenalty(mapOld, mapNew);


                //Billing Preview
                XC_TR_ConfigurationItem_U_ManagePreview.populateAmountsOnOrder(mapOld, mapNew);
                XC_TR_ConfItem_U_ChangeOffer.onAfterUpdate(mapOld, mapNew);
                XC_TR_ConfigurationItem_U_BillingProfile.billingProfileComplexProduct ( mapNew,mapOld);
                XC_TR_ConfigurationItem_ResendWBE.resendKO(mapOld,mapNew);

                //Consip
                XC_TR_Opportunity_UpdateConsipLot.checkOrderItems(mapOld,mapNew);

                //DTT 20-12-2021 VAT Management 
                XC_VATManagementTriggersHandler.applyNormalTaxByDefaultPropagation(mapOld, mapNew);
            }
			
			
			
            //CR2249 - Gestione date contrattuali - federico.manni@accenture.com R1 2022
            XC_TR_ConfigurationItem_U_DurationField.setRecurringDurationFromDate((Map<Id, NE__OrderItem__c>)mapOldS,(Map<Id, NE__OrderItem__c>)mapNewS);
            XC_TR_ConfigurationItem_U_ManageFullLife.emptyCostOnCapex((Map<Id, NE__OrderItem__c>)mapNewS); //elisa.caldini@accenture.com-23.06.2022-hotfix CR758
        }//20220301_GestioneCruscotto - end
    }

    
	/** 
    * @author Nicolo Fodera - nicolo.fodera@enel.com
    * @description Queueable Class to be executed on after update ASYNC aggregate
    * @param mapOldS - map Id -> old value of record
    * @param mapNewS - map Id -> new value of record
	* @date Creation 16/03/2022
   */
	public class OnAfterUpdateAsyncAggregate implements Queueable{  
		public XC_UTIL_IntegrationLog intLog;
        public List<TriggerContext> contextList;
	    public OnAfterUpdateAsyncAggregate(XC_UTIL_IntegrationLog intLog){
			this.intLog = intLog;
            this.contextList = XC_TR_ConfigurationItem_Handler.triggerContextList;
			
		}
        public void execute(QueueableContext context) {
            String logError = '';
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'NF triggerContextList >>> ' +  this.contextList.size());
            try{

                for(XC_TR_ConfigurationItem_Handler.TriggerContext tr_ctx : this.contextList){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'NF >>> mapOldS :' + tr_ctx.mapOldS.size() + ' --- ' + 'mapNewS :' + tr_ctx.mapNewS.size());

                    XC_TR_ConfigurationItem_Handler.onAfterUpdateSync(tr_ctx.mapOldS, tr_ctx.mapNewS);
                }
            }catch (Exception e) {
                logError = 'INTERNAL ERROR: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
                XC_UTIL_Debug.debug(DEBUGACTIVE, logError);
            }
            if(intLog != null){
                intLog.setHttpMethod('ASYNTR');
                intLog.insertIntegRespInboundLog('', logError=='' ? true : false, '', logError);
            }

        }
	}	
	
	 
	 /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
   * @lastmodifiedBy Nicolo Fodera 16/03/2022
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
		/*20220316_NicoloFodera Ottimizzazione createOrder - start moved logic to onAfterUpdateSync*/         
        if(!asyncAggreateAfterUpdate){
			XC_UTIL_Debug.debug(DEBUGACTIVE,'NF asyncAfterUpdate: ----> SYNC BRANCH - mapNewS.size()' + mapNewS.size()); 
			onAfterUpdateSync(mapOldS, mapNewS);
		}else{
			//skip and process later by invoking method System.enqueueJob((new XC_TR_ConfigurationItem_Handler.OnAfterUpdateAsyncAggregate())) 
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'NF asyncAfterUpdate: ----> ASYNC BRANCH [skip & aggregate] - mapNewS.size()' + mapNewS.size()); 
			triggerContextList.add(new TriggerContext(mapOldS,mapNewS)); 
		}
	    /*20220316_NicoloFodera Ottimizzazione createOrder - end*/ 
	}
        

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOldS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on NE__OrderItem__c on ' + Trigger.operationType);
            Map<Id, NE__OrderItem__c> mapOld = (Map<Id, NE__OrderItem__c>) mapOldS;
            XC_TR_ConfItem_U_ChangeOffer.onAfterDelete(mapOld);
            XC_TR_ConfigItem_U_BundleAmount.calculateBundleTotalAmountAfterDelete(mapOld);
            XC_TR_ConfigurationItem_U_ManageFullLife.onAfterDelete(mapOld);
        }
        XC_TR_ConfigurationItem_U_ManageFullLife.fillCostTechItems(((Map<Id, NE__OrderItem__c>) mapOldS).values()); //DeAv 24.06.2022 CR758 Fix
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on NE__OrderItem__c on ' + Trigger.operationType);
        }
    }
}