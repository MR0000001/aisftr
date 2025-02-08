/**
 * The Class XC_TR_WorkOrderLineItem_Handler.
 *
 * @author Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 23/10/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_WorkOrderLineItem_Handler – Handler for XC_TR_WorkOrderLineItem Trigger
 */ 

public without sharing class XC_TR_WorkOrderLineItem_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrderLineItem_Handler');
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {
        if(mapTriggerStopped.containsKey(Trigger.operationType) && mapTriggerStopped.get(Trigger.operationType)){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'TR-> Trigger event ' + Trigger.operationType + ' recursion stopped');
            return true;
        }
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
    public void onBeforeInsert(List<WorkOrderLineItem> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);    
        }
        XC_TR_Woli_U_MaintenancePlan.getRT (listNew);
        XC_TR_Woli_U_MaintenancePlan.fillAddressWOLI(listNew);
        XC_AssignOwnerWorkOrder.assignOwner(listNew);
		XC_TR_CheckApprovalPartnerPayment.checkInsertPartnerPayment(listNew);
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
            List<WorkOrderLineItem> listNew = mapNewS.values();
            Map<Id, WorkOrderLineItem> mapOld = (Map<Id, WorkOrderLineItem>) mapOldS; 
            Map<Id, WorkOrderLineItem> mapNew = (Map<Id, WorkOrderLineItem>) mapNews;  
            XC_TR_WorkOrderLineItem_U_CheckOnClosure.checkStatus(listNew,mapOld,mapNew);
        }
            List<WorkOrderLineItem> listNew = mapNewS.values();
            Map<Id, WorkOrderLineItem> mapOld = (Map<Id, WorkOrderLineItem>) mapOldS; 
            Map<Id, WorkOrderLineItem> mapNew = (Map<Id, WorkOrderLineItem>) mapNews;
            //XC_TR_WOLI_CheckEditableRecord.checkBeforeUpdateRecords(mapNew, mapOld); //[DeAv 01-02-2022 NR2252]
            XC_TR_WOLI_U_CongaDocument.checkDocumentType(listNew);
        	XC_TR_WorkOrderLineItem_U_CloseTask.closeProjectTask(mapOld,mapNew);
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
        //Map<Id, WorkOrderLineItem> mpOld = (Map<Id, WorkOrderLineItem>) mapOld; //[DeAv 01-02-2022 NR2252]     
        //XC_TR_WOLI_CheckEditableRecord.checkBeforeDeleteRecords(mpOld); //[DeAv 01-02-2022 NR2252]     
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
          if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
          }


         if(!system.isFuture()){
           //XC_TR_WorkOrderLineItem_GetFromGlovia.setWarehouseCode(XC_UTIL_Sobject.getIds(mapNewS.values()));   
       }
     } 
    

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            List<WorkOrderLineItem> listNew = mapNewS.values();
            Map<Id, WorkOrderLineItem> mapOld = (Map<Id, WorkOrderLineItem>) mapOldS; 
            Map<Id, WorkOrderLineItem> mapNew = (Map<Id, WorkOrderLineItem>) mapNews;  
            XC_TR_WorkOrderLineItem_U_Expenses.expensesCreation(mapNew, mapOld);
        }
        List<WorkOrderLineItem> listNew = mapNewS.values();
        Map<Id, WorkOrderLineItem> mapOld = (Map<Id, WorkOrderLineItem>) mapOldS; 
        Map<Id, WorkOrderLineItem> mapNew = (Map<Id, WorkOrderLineItem>) mapNews;
        XC_TR_WOLI_U_ClosureManagementB2B.closeWoli(listNew, mapOld, mapNew);
		  XC_TR_CheckApprovalPartnerPayment.checkGoodIssueCompleted (listNew,mapOld);
        XC_TR_WorkOrderLineItem_U_CheckOnClosure.updateDateOnWO(listNew, mapOld, mapNew);
        XC_TR_WorkOrderLineItem_U_CheckStatus.checkWoliStatusAndSentNotif(listNew,mapOld,mapNew); //[R2 CR704 18.03.2022 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]
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