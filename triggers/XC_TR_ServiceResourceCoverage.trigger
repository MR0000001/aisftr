/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/01/2020
* @description XC_TR_ServiceResourceCoverage – Trigger on XC_ServiceResourceCoverage__c
*/ 

trigger XC_TR_ServiceResourceCoverage on XC_ServiceResourceCoverage__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_ServiceResourceCoverage_Handler(), Trigger.operationType, Constants.MDT_SKIP_SERVRESCOVERAGE);  
}