/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/03/2019
* @date Modification 08/04/2019 Marco Rosa - marco.rosa@nttdata.com
* @description XC_TR_Asset_Handler – Handler for XC_TR_Asset Trigger
*/ 

public without sharing class XC_TR_Asset_Handler implements XC_I_TriggerHandler {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Asset_Handler');
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    //20211126_DD_SO_14 - start
    public static Boolean bypassBeforeUpdate = false;
    public static Boolean bypassAfterUpdate = false;
    //20211126_DD_SO_14 - end
        
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {    
        //return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        return false;
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<Asset> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            XC_TR_Asset_U_PopulateDate.populatePurchasedDateOnInsert(listNew);
            XC_TR_Asset_U_FillFieldsByOrderItem.populateWBEFields(listNew);
            XC_TR_Asset_U_FillFields.populateFields(listNew);
            XC_TR_Asset_U_FillFields.populateAssetOwnership(listNew);
            XC_TR_Asset_U_PopulateDate.updateStartDate(listNew);
        } 
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        //20211126_DD_SO_14 - start
        if(!bypassBeforeUpdate){
            //20211126_DD_SO_14 - end
            if(XC_UTIL_OneOrg.isRightCountry('Spain')){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
                mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
                Map<Id, Asset> mapOld = (Map<Id, Asset>) mapOldS; 
                Map<Id, Asset> mapNew = (Map<Id, Asset>) mapNewS;
                List<Asset> listNew = mapNew.values();
                //XC_TR_Asset_U_PopulateDate.updateContractLineItem(listNew,mapOld,mapNew);
                //XC_TR_Asset_U_PopulateDate.updateInstalledDateOnUpdate(listNew,mapOld,mapNew);
                //XC_TR_Asset_U_PopulateDate.updateActivationDateOnUpdate(listNew, mapOld, mapNew);
                //XC_TR_Asset_U_PopulateDate.updateDisconnectionDateOnUpdate(listNew, mapOld, mapNew);
                XC_TR_Asset_U_PopulateDate.updateDatesOnUpdate(listNew, mapOld, mapNew);
                XC_TR_Asset_U_PopulateDate.populateActivationDateOnUpdate(listNew, mapOld, mapNew);
                XC_TR_Asset_U_FillAccountLookup.onBeforeUpdate(listNew, mapOld, mapNew);
                XC_TR_Asset_U_FillFields.populateSubscriptionLookup(mapOld, mapNew);
            }
        } //20211126_DD_SO_14 
    } 
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }         
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        List<Asset> listNew = mapNew.values(); //[DeAv 20210930 - CR NR1857]

        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            //List<Asset> listNew = mapNew.values(); [DeAv 20210930 - CR NR1857]
            //XC_TR_Asset_U_PopulateContractsLineItem.onAssetInsert(listNew);
            XC_TR_Asset_U_PopulateOriginalOrder.populateOriginalOrderAndOrderItem(listNew);
            XC_TR_Asset_U_PopulateContractsLineItem.manageAssetCreation(listNew); 
        }        
        XC_AffiliateBeneficiary_U.associateAssetToAffBen(listNew); //[DeAv 20210930 - CR NR1857]
    } 
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
		//20211126_DD_SO_14 - start
        if(!bypassAfterUpdate){
            //20211126_DD_SO_14 - end
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
            Map<Id, Asset> mapOld = (Map<Id, Asset>) mapOldS; 
            Map<Id, Asset> mapNew = (Map<Id, Asset>) mapNewS;
            List<Asset> listNew = mapNew.values();
            if(XC_UTIL_OneOrg.isRightCountry('Spain')){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);  
                /*mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
                Map<Id, Asset> mapOld = (Map<Id, Asset>) mapOldS; 
                Map<Id, Asset> mapNew = (Map<Id, Asset>) mapNewS;
                List<Asset> listNew = mapNew.values();*/           //[DeAv 20211007 - CR NR1857]
                //XC_TR_Asset_U_PopulateContractsLineItem.manageAssetStatusOnUpdate(listNew, mapOld,mapNew);
                XC_TR_Asset_U_CancelOpenSA.cancelOpenServiceAppointments(listNew, mapOld,mapNew);
                XC_TR_Asset_U_PopulateContractsLineItem.updateContractFromAsset(listNew, mapOld,mapNew);
                XC_TR_Asset_U_ContractSuspension.manageServiceAppointmentStatusForSuspendedAsset(mapOld, mapNew);
                XC_TR_Asset_U_ContractSuspension.manageServiceAppointmentStatusForActivatedAsset(mapOld, mapNew);
                XC_TR_Asset_U_PopulateContractsLineItem.updateContractEndDate(listNew, mapOld, mapNew);
                XC_TR_Asset_U_ManageProvisioning.checkIfToUpdateProvisioningStep(listNew, mapOld, mapNew);
                XC_TR_Asset_U_ManageProvisioning.activeServicesConfigurationItem(listNew, mapOld, mapNew);
                XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForAssetITA(listNew);
				XC_TR_Asset_U_ManageProvisioning.updateCheckRelatedProductActivationStep(listNew, mapOld, mapNew);
                XC_TR_Asset_U_CareManagement.creationsForCareManagement(mapOld, mapNew);
                XC_TR_Asset_U_CustomerInteraction.manageCustomerInteraction(mapNew,mapOld);
                XC_TR_Asset_U_PopulateContractsLineItem.updateContractField(listNew, mapOld,mapNew);
                XC_TR_Asset_U_ManageProvisioning.checkIfUpdateCheckAssetJuicebox(listNew, mapOld, mapNew);
            } 
            XC_AffiliateBeneficiary_U.associateAssetToAffBen(listNew); //[DeAv 20211007 - CR NR1857]
            XC_AffiliateBeneficiary_U.removeOldAffBen(listNew); //[DeAv 20211007 - CR NR1857]
            XC_AffiliateBeneficiary_U.beforeCloneAffBen(mapOld, mapNew); //[DeAv 13/12/2021 Jira THIRDPARTY-400: added method]
        } //20211126_DD_SO_14 
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            //XC_TR_Asset_U_PopulateContractsLineItem.onAssetDelete(listOld); DO NOT ACTIVATE 
        }           
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }                    
    }    
}