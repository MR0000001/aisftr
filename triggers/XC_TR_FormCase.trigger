/**
* @author Dimitris Karnavas / Eleni Tsiolaki 
* @date Creation 24/02/2022
* @date Modification 
* @description XC_TR_FormCase – Trigger on XC_FormCase__c
*/
trigger XC_TR_FormCase on XC_FormCase__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_FormCase_Handler(), Trigger.operationType,Constants.MDT_SKIP_FORM_CASE); 
    
}