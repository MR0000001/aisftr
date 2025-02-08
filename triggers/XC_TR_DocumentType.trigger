/**
* @author massimiliano avallone massimiliano.avallone@nttdata.com - salvatore scarpato salvatore.scarpato@nttdata.com
* @date Creation 03/10/2019
* @date Modification 
* @description XC_TR_DocumentType – Trigger on XC_DocumentType__c
*/
trigger XC_TR_DocumentType on XC_DocumentType__c (before insert, before update, before delete, after insert, after update, after delete) {
	XC_TR_Dispatcher.init(new XC_TR_DocumentType_Handler(), Trigger.operationType); 	
}