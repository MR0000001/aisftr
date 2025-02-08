/**
* @author Sara Miozza - sara.miozza@nttdata.com
* @date Creation 28/05/2019
* @date Modification 
* @description XC_TR_PersonalDocument_Handler - Handler for XC_PersonalDocument__c Trigger
*/ 
public  without sharing class  XC_TR_PersonalDocument_Handler implements XC_I_TriggerHandler {
    
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_PersonalDocument_Handler');
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com 
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<XC_PersonalDocument__c> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            //XC_TR_PersonalDocument_U_FillFields.populateLeadId(listNew);
            //XC_TR_PersonalDocument_U_FillFields.populateAccountId(listNew);
            XC_TR_PersonalDocument_AllineateDoc.populateContactLookupOnMainDocument(listNew);
            XC_TR_PersonalDocument_AllineateDoc.populateAccountLookupOnMainDocument(listNew);
            XC_TR_PersonalDocument_U_FillFields.populateContactId(listNew);
            XC_TR_PersonalDoc_U_CheckFiscalCode.onPersonalDocumentInsert(listnew);
        }
    }
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);        
        }
    } 
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOldS) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            Map<Id,XC_PersonalDocument__c> mapOld = (Map<Id, XC_PersonalDocument__c>)mapOldS;
            List<XC_PersonalDocument__c> listNew = mapOld.values();
            XC_TR_PersonalDocument_AllineateDoc.checkPossibilityToDelete(listNew, mapOld);
        }        
    }
    
    /**
     * @author Sara Miozza - lorenzo.orlanducci@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
          if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            Map<Id, XC_PersonalDocument__c> mapNew = (Map<Id,XC_PersonalDocument__c>) mapNewS;
            List<XC_PersonalDocument__c> listNew = mapNew.values();
            //XC_TR_PersonalDocument_AllineateDoc.checkIfAccountFieldNeedPop(listNew);
            XC_TR_PersonalDocument_AllineateDoc.populatePersonalDocumentOnInsert(listNew); 
          }
      } 
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            Map<Id, XC_PersonalDocument__c> mapNew = (Map<Id,XC_PersonalDocument__c>) mapNewS;
            Map<Id, XC_PersonalDocument__c> mapOld = (Map<Id,XC_PersonalDocument__c>) mapOldS;
            List<XC_PersonalDocument__c> listNew = mapNew.values();
            XC_TR_PersonalDocument_AllineateDoc.populatePersonalDocumentOnUpdate(listNew, mapOld, mapNew);
            XC_TR_PersonalDoc_U_CaringManagement.manageCaseCreation(listNew, mapOld, mapNew);
        }
    }
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
        }           
    } 

    /**
     * @author Sara Miozza - sara.miozza@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }           
    }    

}