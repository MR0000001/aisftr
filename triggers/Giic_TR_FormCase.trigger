/**
* @author Milko Fatiga
* @date Creation 04/05/2022
* @date Modification 
* @description Giic_TR_FormCase – Trigger on XC_FormCase__c
*/
trigger Giic_TR_FormCase on XC_FormCase__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new Giic_TR_FormCase_Handler(), Trigger.operationType); 
    
}