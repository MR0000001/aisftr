/**
 * @File Name          : XC_TR_QueuedRequest_Handler.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 07-13-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_TR_QueuedRequest_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_QueuedRequest_Handler');
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        // return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        return false;
    }
    

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @return void 
    **/
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }
    

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param listNew 
    * @return void 
    **/
    public void onBeforeInsert(List<XC_QueuedRequest__c> listNew){
        // XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        //XC_TR_QueuedRequest_U_CompleteReq.PopulateTemplateName(listNew);
    }
    

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param mapOldS 
    * @param mapNewS 
    * @return void 
    **/
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        Map<Id,XC_QueuedRequest__c> mapNew = (Map<Id,XC_QueuedRequest__c>) mapNewS;
        Map<Id,XC_QueuedRequest__c> mapOld = (Map<Id,XC_QueuedRequest__c>) mapOldS;
        //set completed status
        XC_TR_QueuedRequest_U_CompleteReq.setCompleteRequest(mapNew,mapOld);
        XC_TR_QueuedRequest_U_CompleteReq.setRequestError(mapNew, mapOld);
        XC_TR_QueuedRequest_U_CompleteReq.setRequestInProgress(mapNew, mapOld);

    } 
    

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param mapOldS 
    * @return void 
    **/
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
        // XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        // Map<Id, Lead> mapOld = (Map<Id, Lead>) mapOldS; 
    }
    

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param mapNew 
    * @return void 
    **/
    public void onAfterInsert(Map<Id, SObject> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        //insert steps on after insert and launch the flow at rest
        Map<Id,XC_QueuedRequest__c> mapNewReq = (Map<Id,XC_QueuedRequest__c>) mapNew;
        XC_TR_QueuedRequest_U_CreateSteps.createQueuedRequestStepsFiltered(mapNewReq.values());

    } 
    
    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param mapOldS 
    * @param mapNewS 
    * @return void 
    **/
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        Map<Id,XC_QueuedRequest__c> mapNew = (Map<Id,XC_QueuedRequest__c>) mapNewS;
        Map<Id,XC_QueuedRequest__c> mapOld = (Map<Id,XC_QueuedRequest__c>) mapOldS;
        //set completed status
        XC_TR_QueuedRequest_U_CreateSteps.startStepOnUpdate(mapNew,mapOld);
        XC_TR_QueuedRequest_U_ManageSteps.closeWatingStepOnQRUpdate(mapNew,mapOld);

    }
    

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param mapOld 
    * @return void 
    **/
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        // XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    } 


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param mapNew 
    * @return void 
    **/
    public void onAfterUnDelete(Map<Id, SObject> mapNew){ 
        // XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    }    

}