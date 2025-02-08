/**
* @author Andrea Di Cicco
* @date Creation 11/06/2020
* @description XC_TR_Event – Trigger on Event
*/ 

trigger XC_TR_Event on Event (before insert, before update, before delete, after insert, after update, after delete) {
	XC_TR_Dispatcher.init(new XC_TR_Event_Handler(), Trigger.operationType,Constants.MDT_SKIP_LEAD);  	
}