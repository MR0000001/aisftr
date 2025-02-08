/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @description XC_TR_Contract_Handler – Handler for NE__Order__c Trigger
*/

public without sharing class XC_TR_Contract_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Contract_Handler');
     
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */ 
    public Boolean stopRecursion() {   
        //return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        return false;
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
    public void onBeforeInsert(List<Contract> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);    
            XC_TR_Contract_U_PopulateField.manageInsertContract(listNew);
        }

        giic_TR_PriceBookEntry_FillFields.getCompanyNameByCompanyCode(listNew);
		 XC_TR_Contract_U_PopulateFromOpp.populatefields(listNew);
        XC_TR_Contract_ManageLOAContracts.updateContractLOAStatus(listNew);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        }
         Map<Id, Contract> mapOld = (Map<Id, Contract>) mapOldS; 
         Map<Id, Contract> mapNew = (Map<Id, Contract>) mapNews;  
        List<Contract> listNew = mapNew.values();
         giic_TR_PriceBookEntry_FillFields.getCompanyNameByCompanyCodeInUpdate(listNew,mapOld,mapNew);
         XC_TR_Contract_U_CongaFromContract.populateContractField(listNew,mapOld,mapNew);  
        XC_TR_Contract_U_Fill_TermDate.checkDate(listNew,mapOld,mapNew);
        XC_TR_Contract_ManageLOAContracts.updateContractLOAStatus(listNew);
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
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            List<Contract> listNew = mapNewS.values();
            Map<Id, Contract> mapNew = (Map<Id, Contract>) mapNews;
            XC_TR_Contract_ManageConsents.updateDatesLec(listNew);
            XC_TR_Contract_ManageLOAContracts.updateServiceAccounts(null, mapNew);
        }
        //XC_TR_Contract_AccountPartner.afterInsertManageContract((Map<Id,Contract>) mapNewS);
        XC_TR_Contract_ContractAutoRenewal.generateCI(null,(Map<Id,Contract>)mapNewS);
      } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        Map<Id, Contract> mapOld = (Map<Id, Contract>) mapOldS; 
        Map<Id, Contract> mapNew = (Map<Id, Contract>) mapNews; 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);              
            XC_TR_Contract_U_PipelineAutomation.manageStage(mapOld, mapNew );
        }
        //XC_TR_Contract_AccountPartner.afterUpdateManageContract((Map<Id,Contract>) mapNewS, (Map<Id,Contract>) mapOlds);
        XC_TR_Contract_UpdateSubscriptions.updateSubscriptions(mapOld, mapNew);
        XC_TR_Contract_ManageLOAContracts.updateServiceAccounts(mapOld, mapNew);
        
        XC_TR_Contract_ContractAutoRenewal.generateCI(mapOld,mapNew);
        XC_TR_Contract_U_UpdateStatus.checkStatus(mapOld,mapNew);//CR763
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
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