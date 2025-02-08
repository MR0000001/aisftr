/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 08-11-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   08-10-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_TR_VirtualIBANAssociation_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-10-2020 
    * @return Boolean 
    **/
    public Boolean stopRecursion() {   
        // return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
        return false;
    }


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-10-2020 
    **/
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, true);
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-10-2020 
    * @param listNew 
    **/
    public void onBeforeInsert(List<XC_VirtualIBANAssociation__c> listNew){
    }
    

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-10-2020 
    * @param mapOldS 
    * @param mapNewS 
    **/
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
    } 
    

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-10-2020 
    * @param mapOldS 
    **/
    public void onBeforeDelete(Map<Id, SObject> mapOldS){
    }
    

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-10-2020 
    * @param mapNew 
    **/
    public void onAfterInsert(Map<Id, SObject> mapNewS){ 
        Map<Id, XC_VirtualIBANAssociation__c> mapNew = (Map<Id, XC_VirtualIBANAssociation__c>) mapNewS;
        XC_TR_VirtualIBANAss_U_CreateIBAN.generateIBAN(mapNew.values());
    } 
    


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-10-2020 
    * @param mapOldS 
    * @param mapNewS 
    **/
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
    }
    

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-10-2020 
    * @param mapOld 
    **/
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
    } 


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-10-2020 
    * @param mapNew 
    **/
    public void onAfterUnDelete(Map<Id, SObject> mapNew){ 
    }    




}