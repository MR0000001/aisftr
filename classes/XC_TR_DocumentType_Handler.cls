/**
* @author massimiliano avallone massimiliano.avallone@nttdata.com - salvatore scarpato salvatore.scarpato@nttdata.com
* @date Creation 03/10/2019
* @date Modification 
* @description XC_TR_DocumentType_Handler – Handler for XC_TR_DocumentType Trigger
*/  
 
public without sharing class XC_TR_DocumentType_Handler implements XC_I_TriggerHandler {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_DocumentType');
    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    
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
    public void onBeforeInsert(List<XC_DocumentType__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> XC_TR_DocumentType_Handler.onBeforeInsert'); 
        System.debug('Doc type handler');
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
         XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    } 
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on before delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        system.debug('@@@after insert doxee document');
        List<XC_DocumentType__c> listNew = mapNew.values();
        XC_TR_DocumentType_U_CheckCieDocument.onInsert(listNew);
                XC_TR_DocumentType_U_SendEmail.onupdate(listNew);
                XC_TR_DocumentType_LoiStatus.loiStatus(listNew);
                XC_TR_DocumentType_Account_NDA_Signed.ndaManagedStatus(listNew);
                XC_TR_DocumentType_U_Contract.updateSignatureDateOnOrder(listNew);
        XC_TR_DocumentType_U_CreateSRSkills.onInsert(listNew);
        //XC_TR_DocumentType_U_WorkOrder.onInsert(listNew);
    } 
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        system.debug('@@@after update doxee document');
        mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);
        Map<Id, XC_DocumentType__c> mapOld = (Map<Id, XC_DocumentType__c>) mapOldS; 
        Map<Id, XC_DocumentType__c> mapNew = (Map<Id, XC_DocumentType__c>) mapNewS;      
        List<XC_DocumentType__c> listNew = mapNew.values();
        XC_TR_DocumentType_U_CheckCieDocument.onUpdate(mapOld,mapNew); 
        XC_TR_DocumentType_U_Contract.updateSignatureDateOnOrder(listNew);
		XC_TR_DocumentType_U_SendEmail.onupdate(listNew);
        XC_TR_DocumentType_U_CreateSRSkills.onUpdate(mapOld,mapNew);

        system.debug('@@@update trigger cie over');
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOldS){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew ){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    }     

}