/**
* @author Nicolò Leonardi - nleonardi@deloitte.it & Marco Rosa - marco.rosa@nttdata.com
* @date Creation 21/08/2018
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_Lead_Handler – Handler for XC_TR_Lead Trigger
*/  

public without sharing class XC_TR_Lead_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Lead_Handler');
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
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
    public void onBeforeInsert(List<Lead> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        XC_TR_Lead_U_HandleIndividual.handleIndividualGDPR(listNew);
        XC_TR_Lead_U_HandleMapping.mapLeadFields(listNew);
        XC_TR_Lead_U_HandleMapping.getProductCategoryCommercialVisit(listNew);
        XC_TR_Lead_U_ConcatenatePhone.concatenatePhoneOnInsert(listnew);
        XC_TR_Lead_U_CheckZipBlacklist.checkBlackListOnInsert(listNew);
        XC_TR_Lead_U_HandleMapping.mapLeadOwner(listNew);
        XC_TR_Lead_U_CheckDuplicates.checkDuplicates(listNew);
        XC_TR_Lead_U_AssignLead.onBeforeInsert(listNew);
        //XC_TR_Lead_U_HandleMapping.mapLeadOwner(listNew); //TO DO -- The Map Lead Owner must be called after the Lead Assignment Master, not before.
        //XC_TR_Lead_U_UpdateChildren.createAddressForDataImport(listNew);
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */

    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        Map<Id, Lead> mapOld = (Map<Id, Lead>) mapOldS; 
        Map<Id, Lead> mapNew = (Map<Id, Lead>) mapNewS;
        List<Lead> listNew = mapNew.values();
        XC_TR_Lead_U_CheckFields.checkOnUpdate(mapOld, mapNew);
        XC_TR_Lead_U_CheckDuplicates.checkDuplicatesOnUpdate(mapOldS, mapNewS);
        XC_TR_Lead_U_CreateTaskLead.createTask(listNew, mapOld, mapNew);
        XC_TR_Lead_U_AssignLead.assignLeadChanged(listNew, mapOld, mapNew);
        XC_TR_Lead_U_HandleMapping.handleCustomMapping(listNew, mapOld, mapNew);
        XC_TR_Lead_U_HandleMapping.getCommercialVisitRequired(listNew, mapOld, mapNew);
        //XC_TR_Lead_U_CheckStatus.checkWhyNotConverted(listNew, mapOld, mapNew);
        XC_TR_Lead_U_ConcatenatePhone.concatenatePhoneOnUpdate(listnew, mapOld, mapNew);
        //XC_TR_Lead_U_CheckStatus.checkStatusUpdated(listNew, mapOld, mapNew);
        //XC_TR_Lead_U_CheckStatus.checkIsConvertedStatus(listNew, mapOld, mapNew);
        XC_TR_Lead_U_CheckZipBlacklist.checkBlackListOnUpdate(listNew, mapOld, mapNew);
        XC_TR_Lead_U_UpdateChildren.updateOrCreateAddress(mapOld, mapNew);
        XC_TR_Lead_U_HandleMapping.handleOwnerMapping(listNew, mapOld, mapNew);
        //XC_TR_Lead_U_AssignLead.onBeforeUpdate(listNew, mapOld, mapNew);
        XC_TR_Lead_U_SetDateTimeFields.onBeforeUpdate(listNew, mapOld, mapNew);
    } 
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on before delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        Map<Id, Lead> mapOld = (Map<Id, Lead>) mapOldS; 
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        List<Lead> listNew = mapNew.values();
        XC_TR_Lead_U_CheckFields.checkOnInsert((Map<Id, Lead>) mapNew);
        XC_TR_Lead_U_AssignLead.encryptLeadIds(listNew);
        //XC_TR_Lead_U_HandleIndividual.insertLegalEntity(listNew);
        XC_TR_Lead_U_CustomInteractionGeneration.handleLeadCreation(listNew); //Add Riccardo Cossu 11_01_2018
        XC_TR_CustomerInteractionRelationship.setInteractionIdOnLead(listNew); 
        XC_TR_Lead_U_UpdateChildren.createAddressForDataImportAfterInsert(listNew);
        XC_TR_Lead_U_HandleIndividual.setLeadOnIndividual(listNew);
    } 
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */

    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);  
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        Map<Id, Lead> mapOld = (Map<Id, Lead>) mapOldS; 
        Map<Id, Lead> mapNew = (Map<Id, Lead>) mapNewS;      
        List<Lead> listNew = mapNew.values();
        XC_TR_Lead_U_CustomInteractionGeneration.createCustomerInteractionSalesCallSurvey(listNew, mapOld, mapNew);
        XC_TR_Lead_U_HandleIndividual.updateIndividual(listNew, mapOld, mapNew);
        //XC_TR_Lead_U_CustomInteractionGeneration.handleLeadCreation(listNew);  
        //XC_TR_Lead_U_PopulateFromConversion.populateStandardConversionFields(listNew, mapOld, mapNew);
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    }    

}