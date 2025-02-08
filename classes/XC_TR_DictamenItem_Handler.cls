/**
 * @File Name          : XC_TR_DictamenItem_Handler.cls
 * @description        : Handler for dictamen item trigger
 * @Author             : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Group              :
 * @Last Modified By   : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Last Modified On   : 9/10/2019, 10:53:50
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    9/10/2019     Andrea Bravaccino          Initial Version
 **/
public without sharing class XC_TR_DictamenItem_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object> > mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object> >();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_DictamenItem_Handler');

    /**
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @description Method to stop recursion of the same event method in the same transaction
    * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }

    /**
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @description Method to set to true the stop recursion variable on the current trigger event
    */
    public void executedTrigger(){
        mapTriggerStopped.put(Trigger.operationType, true);
    }

    /**
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @description Method to be executed on after undelete
    * @param listNew
    */
    public void onBeforeInsert(List<XC_DictamenItem__c> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            XC_TR_DictamenItem_U_FillFields.populateDictamenFields(listNew);
        }
    }

    /**
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @description Method to be executed on before update
    * @param mapOld - map Id -> old value of record
    * @param mapNew - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }
    }

    /**
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @description Method to be executed on before delete
    * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }
    }

    /**
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @description Method to be executed on after insert
    * @param mapNew - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNew) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            XC_TR_DictamenItem_U_Repair.createRepairWo(mapNew.values());
        }
    }

    /**
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @description Method to be executed on after update
    * @param mapOld - map Id -> old value of record
    * @param mapNew - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            List<XC_DictamenItem__c> listNew = mapNew.values();
            XC_TR_DictamenItem_U_TechnicalQuote.checkRepairStatusChanged(listNew, mapOld, mapNew);
        }
    }

    /**
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @description Method to be executed on after delete
    * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }
    }

    /**
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @description Method to be executed on after undelete
    * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }
    }

}