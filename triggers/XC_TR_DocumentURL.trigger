/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 26/06/2020
* @description XC_TR_DocumentURL
* @param 
*/
trigger XC_TR_DocumentURL on XC_DocumentURL__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_DocumentURL_Handler(), Trigger.operationType); 
}