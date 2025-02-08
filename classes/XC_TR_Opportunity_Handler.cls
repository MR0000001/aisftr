/**
* @author Giulio Serra - giserra@deloitte.it 
* @date Creation 26/09/2018
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_Opportunity_Handler – Trigger Handler on Opportunity
*/ 

public without sharing class XC_TR_Opportunity_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Opportunity_Handler');
    
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
    public void onBeforeInsert(List<Opportunity> listNew){
        
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            List<Opportunity> listNewS = XC_TR_Dispatcher.skipSFMObject(listNew);
            //XC_TR_Opportunity_U_PopulateFields.populateFields(listNewS); // Fix 30/06/2020
            //if((listNew[0].XC_Segment__c != null && listNew[0].XC_Segment__c.equalsIgnoreCase('B2C')) || !XC_TR_Dispatcher.skipSFMObject(listNew, 'Opportunity')){  // Fix 30/06/2020
            if(!listNewS.isEmpty()){
                XC_TR_Opportunity_U_PopulateFields.populateFields(listNewS);
                XC_TR_Opportunity_U_CheckCommercialVisit.getProductCategoryCommercialVisit(listNewS);
                XC_TR_Opportunity_U_ProdCatAddress.checkProductCategory(listNewS);
                XC_TR_Opp_U_CheckZipBlackList.checkBlackListOnInsert(listNewS);
                XC_TR_Opportunity_U_ManageSubStatus.updateSubstatusPicklist(listNewS);
                //XC_TR_Opportunity_U_ManageScoring.rebaltScoring(listNew); // Add 3 sept 19
                XC_TR_Opportunity_U_CheckDuplicates.checkDuplicateOpportunity(listNewS); //Add 6 Nov
                XC_TR_Opportunity_WeightFields.industrialKPIfield(listNewS);
                XC_TR_Opportunity_U_Community.populatePartnerFields(listNewS);
                XC_TR_Opportunity_DealRegistration.insertDealStatus(listNewS);
                XC_TR_Opportunity_RiskScoring.checkRiskScoring(listNewS);
                XC_TR_Opportunity_U_PopulateFields.populateShippingCostArea(listNewS);
                XC_TR_Opportunity_U_PopulateFields.populateZone(listNewS);
                XC_TR_Opportunity_U_PopulateFields.populateContractType(listNewS); //DeAv 19.03.2022 CR758
            }
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
            //List<Opportunity> listNew = mapNewS.values();
            //Map<Id, Opportunity> mapOld = (Map<Id, Opportunity>) mapOldS; 
            //Map<Id, Opportunity> mapNew = (Map<Id, Opportunity>) mapNews; 
            List<Opportunity> listNew = XC_TR_Dispatcher.skipSFMObject(mapNewS.values());
            Map<Id, Opportunity> mapOld =  (Map<Id, Opportunity>) XC_TR_Dispatcher.skipSFMObject(mapOldS);
            Map<Id, Opportunity> mapNew = (Map<Id, Opportunity>) XC_TR_Dispatcher.skipSFMObject(mapNews);
            //if((listNew[0].XC_Segment__c != null && listNew[0].XC_Segment__c.equalsIgnoreCase('B2C')) || !XC_TR_Dispatcher.skipSFMObject(listNew, 'Opportunity')){
            if(!listNew.isEmpty()){
                XC_TR_Opportunity_U_CheckCommercialVisit.getCommercialVisitRequired(listNew, mapOld, mapNew);
                XC_TR_Opp_U_CheckZipBlackList.checkBlackListOnUpdate(listNew,mapOld,mapNew);
                XC_TR_Opportunity_U_SetStatus.setStatusFromConfiguration(listNew, mapOld, mapNew);
                XC_TR_Opportunity_U_SetStatus.setClosingUser(listNew, mapOld, mapNew);
                XC_TR_Opportunity_U_CheckDuplicates.checkDuplicateOpportunityUpdate(listNew, mapOld, mapNew); //Add 6 Nov 
                XC_TR_Opportunity_U_ManageSubStatus.updateSubstatusPicklist(listNew, mapOld, mapNew);
                XC_TR_Opportunity_WeightFields.changePipelineFields(listNew,mapOld);
                XC_TR_Opportunity_WeightFields.industrialKPIfieldUpdate(listNew);
                XC_TR_Opportunity_U_SetStatus.setStageInProgress(listNew, mapOld, mapNew);
                //XC_TR_Opportunity_U_Credit_UpdateAmount.updateAmount(mapNew, mapOld); sbernard: Rimuovo questa logica perchè richiesto dalla CR1893 
                XC_TR_Opportunity_U_PopulateFields.changeCampaignField(listNew, mapOld, mapNew);
                
                //XC_TR_Opportunity_UpdateConsipLot.checkRPFVerification(mapOld, mapNew);
                //XC_TR_Opportunity_U_CongaWFCustomObj.checkRPF(mapOld, mapNew);
                XC_TR_Opportunity_U_PopulateFields.populateContractTypeOnUpdate(listNew, mapOld, mapNew); //DeAv 19.03.2022 CR758
            }
            
            
        
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
            //List<Opportunity> listNew = mapNewS.values(); 
            List<Opportunity> listNew = XC_TR_Dispatcher.skipSFMObject(mapNewS.values());
            Map<Id, Opportunity> mapNew = (Map<Id, Opportunity>) XC_TR_Dispatcher.skipSFMObject(mapNews);
            //if((listNew[0].XC_Segment__c != null && listNew[0].XC_Segment__c.equalsIgnoreCase('B2C')) || !XC_TR_Dispatcher.skipSFMObject(listNew, 'Opportunity')){
            if(!listNew.isEmpty()){
            XC_TR_Opportunity_U_PopulateFields.encryptOpportunityIds(listNew);       
            XC_TR_Opportunity_U_AssignOpportunity.rebaltCUPS(listNew);
            XC_TR_Opportunity_U_SetParentCaseStatus.setParentCaseStatusInPending(listNew);
            //XC_TR_Opp_U_CustomInteractionGeneration.generateCustomInteractionFromOpportunity(listNew);
            XC_TR_CustomerInteractionRelationship.setInteractionIdOnOpportunity(listNew);
            //XC_TR_Opportunity_U_ManageScoring.rebaltScoring(listNew);
            XC_TR_Opportunity_U_CheckLEConsens.checkLE(listNew);
            }
            XC_TR_Opportunity_U_Create_Annual_Rev.createARonAfterInsert((Map<Id, Opportunity>)mapNewS);
            XC_TR_Opportunity_U_AssignOpportunity.assignAutoNumberName((List<Opportunity>)mapNewS.values());
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
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapNews = ' + mapNews);
            //List<Opportunity> listNew = mapNewS.values();
            //Map<Id, Opportunity> mapOld = (Map<Id, Opportunity>) mapOldS; 
            //Map<Id, Opportunity> mapNew = (Map<Id, Opportunity>) mapNews;
            List<Opportunity> listNew = XC_TR_Dispatcher.skipSFMObject(mapNewS.values());
            Map<Id, Opportunity> mapOld = (Map<Id, Opportunity>) XC_TR_Dispatcher.skipSFMObject(mapOldS);
            Map<Id, Opportunity> mapNew = (Map<Id, Opportunity>) XC_TR_Dispatcher.skipSFMObject(mapNews);
            //if((listNew[0].XC_Segment__c != null && listNew[0].XC_Segment__c.equalsIgnoreCase('B2C')) || !XC_TR_Dispatcher.skipSFMObject(listNew, 'Opportunity')){
            if(!listNew.isEmpty()){
            //XC_UTIL_Case.manageCasePendingOpp(listNew,mapOld,mapNew); //DT 2/10/2019
            XC_TR_Opportunity_U_SetParentCaseStatus.manageCasePendingOpp(listNew,mapOld,mapNew);
            XC_TR_Opportunity_U_ManageVoucher.afterOpportunityUpdate(listNew,mapOld,mapNew);
            XC_TR_Opportunity_U_updateContract.updateContract(mapNew, mapOld);
            XC_TR_Opportunity_U_SetStatus.createNotification(listNew,  mapOld, mapNew);
            }
            XC_TR_Opportunity_U_Create_Annual_Rev.createARonAfterUpdate((Map<Id, Opportunity>)mapNewS,(Map<Id, Opportunity>)mapOldS);
            XC_TR_Opportunity_UpdateConsipLot.checkOpportunities((Map<Id, Opportunity>)mapOldS,(Map<Id, Opportunity>)mapNewS);
            XC_TR_Opportunity_UpdateConsipLot.checkRPFVerification(mapOld, mapNew);
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
     * @param mapNew- map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
                   
    }    
}