/**
* @author Antonio D'Onofrio - andonofrio@deloitte.it
* @date Creation 20/04/2020
* @description Product2 – Trigger on Product2
*/ 

trigger XC_TR_Product2 on Product2 (before insert, before update, before delete, after insert, after update, after delete) {
	XC_TR_Dispatcher.init(new XC_TR_Product2_Handler(), Trigger.operationType,Constants.MDT_SKIP_LEAD); 	
}