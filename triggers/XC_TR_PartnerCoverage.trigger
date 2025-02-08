/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 10/09/2019
* @description XC_TR_PartnerCoverage – Trigger on XC_PartnerCoverage__c
*/ 

trigger XC_TR_PartnerCoverage on XC_PartnerCoverage__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_PartnerCoverage_Handler(), Trigger.operationType, Constants.MDT_SKIP_PARTNERCOVERAGE); 
}