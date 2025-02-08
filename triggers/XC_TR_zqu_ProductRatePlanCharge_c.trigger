/**
* @author Antonio D'Onofrio - andonofrio@deloitte.it
* @date Creation 21/04/2020
* @description zqu__ProductRatePlan__c – Trigger on zqu__ProductRatePlan__c
*/ 

trigger XC_TR_zqu_ProductRatePlanCharge_c on zqu__ProductRatePlanCharge__c (before insert, before update, before delete, after insert, after update, after delete) {
	XC_TR_Dispatcher.init(new XC_TR_zqu_ProductRatePlanCharge_Handler(), Trigger.operationType,Constants.MDT_SKIP_LEAD); 	
}