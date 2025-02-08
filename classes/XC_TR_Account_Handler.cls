/**
* @author Nicolò Leonardi - nleonardi@deloitte.it & Marco Rosa - marco.rosa@nttdata.com
* @date Creation 21/08/2018
* @date Modification 08/04/2019 Marco Rosa - marco.rosa@nttdata.com
* @description XC_TR_Account_Handler – Handler for XC_TR_Account Trigger
*/  
  
public without sharing class XC_TR_Account_Handler implements XC_I_TriggerHandler { 

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Account_Handler');
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
    public void onBeforeInsert(List<Account> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> XC_TR_Account_Handler.onBeforeInsert'); 
        XC_TR_Account_RiskScoring.checkRiskScoring(listNew);
        XC_TR_Account_U_CheckDuplicates.onInsertDuplicationCheck(listNew); 
        XC_TR_Account_U_ConcatenatePhone.concatenatePhoneOnInsert(listNew);
        XC_TR_Account_U_ConcatenatePhone.concatenateNameOnInsert(listNew);
        XC_TR_Account_U_ConcatenatePhone.setSplitPayment(listNew);
        XC_TR_Account_SetFields.setFieldsBefore(listNew);
        XC_TR_Account_U_CheckFiscalCode.onAccountInsert(listnew);
        XC_TR_Account_U_VATGroupManage.grouppoIvaEnelCheckFields(listNew);
        XC_TR_Account_U_CheckSPW.setSafetyPointWalletFlag(listNew);
        XC_TR_Account_SetFieldsGuestUser.setFieldsBefore(listNew);
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
        Map<Id, Account> mapOld = (Map<Id, Account>) mapOldS; 
        Map<Id, Account> mapNew = (Map<Id, Account>) mapNewS;
        List<Account> listNew = mapNew.values();
        XC_TR_Account_U_ConcatenatePhone.concatenatePhoneOnUpdate(listnew, mapOld, mapNew); 
        XC_TR_Account_U_ConcatenatePhone.concatenateNameOnUpdate(listnew, mapOld, mapNew); 
        XC_TR_Account_U_CheckDuplicates.onUpdateduplicationCheck(listNew, mapOld, mapNew);
        XC_TR_Account_U_CheckFields.checkOnUpdate(mapOld, mapNew);
        XC_TR_Account_U_CongaFromAccount.populateAccountField(listnew, mapOld, mapNew);
        XC_TR_Account_U_CheckFiscalCode.onAccountUpdate(listnew, mapOld, mapNew);
        
        XC_TR_Account_SetFields.setUpdateDocuments(listNew,mapOld);
        XC_TR_Account_U_VATGroupManage.grouppoIvaEnelCheckFields(listNew);
        XC_TR_Account_SetFieldsGuestUser.setFieldsBefore(listNew);
    } 
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on before delete
     * @param mapOldS - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        Map<Id, Account> mapOld = (Map<Id, Account>) mapOldS; 
        XC_TR_Account_U_DeleteChildren.deletePersonalDocument(mapOld);       
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to be executed on after insert
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        List<Account> listNew = mapNew.values();
        XC_TR_Account_U_CheckFields.checkOnInsert((Map<Id, Account>) mapNew);
        XC_TR_Account_U_CheckSPW.createSafetyPointsWallets(listNew);
        XC_TR_Sla_Managment.defaultSlaManagment((Map<Id, Account>) mapNew); // VDB CR760 22-02-22
        //XC_TR_Account_U_FillFields.createGroup(listNew);
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
        Map<Id, Account> mapOld = (Map<Id, Account>) mapOldS; 
        Map<Id, Account> mapNew = (Map<Id, Account>) mapNewS;      
        List<Account> listNew = mapNew.values();
        //XC_TR_Account_U_FromAccountToContact.copyInfoFromAccountToContact(listNew);
        XC_TR_Account_U_FromAccountToContact.checkFieldToCopy(listNew, mapOld, mapNew);
        XC_TR_Account_U_CopyChannelOnUsers.populateChannelOnUsers(listNew, mapOld, mapNew);
        XC_TR_Account_U_PartnerDeactivation.checkPartnerStatus(mapOld, mapNew);
        XC_TR_PersonalDocument_AllineateDoc.populateAccountDocumentOnUpdate(listNew, mapOld, mapNew);

        XC_TR_Account_U_CheckFields.checkGroupNameHasChanged(mapOld, listNew); //Lorenzo Evangelisti lorenzo.evangelisti@webresults.it - EXSFDCSL-352 20/06/2022
        
        XC_TR_Account_UpdateZuoraAccount.updateBillingAccount(mapOld, mapNew);
        XC_TR_Account_SetZoneOnAsset.setZoneOnAsset(listNew, mapOld, mapNew); //[Denise Avolio denise.avolio@accenture.com 18-03-2022 R2 CR756]
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