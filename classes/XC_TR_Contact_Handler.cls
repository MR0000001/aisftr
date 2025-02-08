/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
* @date Creation 08/04/2019
* @description XC_TR_Contact_Handler – Handler for Contact Trigger
*/

public without sharing class XC_TR_Contact_Handler implements XC_I_TriggerHandler {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Contact_Handler');
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    
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
    public void onBeforeInsert(List<Contact> listNew){
        
            //XC_TR_Contact_U_CheckDuplicates.duplicationContactCheck(listNew, null, mapNew);
            //GS commented because the logic of this method is already checked by the standard duplication rule 17/09/18
            XC_TR_Contact_U_CheckIndividualChildren.checkChildren(listNew);
            XC_TR_Contact_U_CheckPrimaryContact.onContactInsert(listNew);
            XC_TR_Contact_U_ConcatenatePhone.ConcatenatePhoneOnInsert(listnew); 
            XC_TR_Contact_U_CheckPrimaryContact.manageContactFields(listNew);
            XC_TR_Contact_U_CheckFiscalCode.onContactInsert(listNew);
        
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
            List<Contact> listNew = mapNewS.values();
            Map<Id, Contact> mapOld = (Map<Id, Contact>) mapOldS; 
            Map<Id, Contact> mapNew = (Map<Id, Contact>) mapNews;
            XC_TR_Contact_U_ConcatenatePhone.ConcatenatePhoneOnUpdate(listnew, mapOld, mapNew);
            XC_TR_Contact_U_HandleIndividual.handleIndividual(listNew, mapOld, mapNew);
            XC_TR_Contact_U_CheckPrimaryContact.onContactUpdate(listNew,mapOld,mapNew);
            XC_TR_Contact_FillChildrenInfo.updateChildrenInfo(listNew,mapOld,mapNew);
            //XC_TR_Contact_U_FromContactToAccount.onContactInfoChanged(listNew);
            XC_TR_Contact_U_FromContactToAccount.checkFieldToCopy(listNew, mapOld, mapNew);
            XC_TR_Contact_U_CheckFiscalCode.onContactUpdate(listNew, mapOld, mapNew);
        
    } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOlds 
    */
    public void onBeforeDelete(Map<Id, SObject> mapOlds) { 
        
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            Map<Id, Contact> mapOld = (Map<Id, Contact>) mapOldS;  
            XC_TR_Contact_U_DeleteChildren.deletePersonalDocument(mapOld);
                
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNewS 
     */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
          
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            List<Contact> listNew = mapNewS.values();
            XC_TR_Contact_U_HandleIndividual.createIndividualGDPR(listNew);
            XC_TR_Contact_U_HandlePersonalDocument.createPersonalDocument(listNew);
            XC_TR_Contact_U_CheckIndividualChildren.checkAvailableLegalEntityOnSecContact(listNew);
          
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
            List<Contact> listNew = mapNewS.values();
            Map<Id, Contact> mapOld = (Map<Id, Contact>) mapOldS; 
            Map<Id, Contact> mapNew = (Map<Id, Contact>) mapNews; 
            XC_TR_Contact_U_CaringManagement.manageCaseCreation(listNew, mapOld, mapNew);
            XC_TR_Contact_U_HandleIndividual.updateIndividualsFromContact(listNew);
            XC_TR_Contact_U_HandleIndividual.updateAccountConsents(listNew);
            XC_TR_PersonalDocument_AllineateDoc.populateContactDocumentOnUpdate(listNew, mapOld, mapNew);
            XC_TR_PersonalDocument_AllineateDoc.createDocumentInContactEdit(listNew,mapOld,mapNew); 
            XC_TR_Contact_U_CaringManagement.manageDisalignmentWithZuora(listNew,mapOld,mapNew);
        
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