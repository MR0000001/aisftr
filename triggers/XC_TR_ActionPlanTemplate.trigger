/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 10/12/2019
* @description XC_TR_ActionPlanTemplate – Trigger on Action Plan Template
*/
trigger XC_TR_ActionPlanTemplate on ActionPlanTemplate__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
     XC_TR_Dispatcher.init(new XC_TR_ActionPlanTemplate_Handler(), Trigger.operationType);
}