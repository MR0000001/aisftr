/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 11/12/2020
* @description XC_TR_QualityCheck – Trigger on XC_B2BG_QualityCheck__c
*/ 

trigger XC_TR_QualityCheck on XC_B2BG_QualityCheck__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_QualityCheck_Handler(), Trigger.operationType, Constants.MDT_SKIP_PARTNERCOVERAGE); 
}