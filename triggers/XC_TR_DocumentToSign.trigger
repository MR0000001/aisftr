/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 22/11/2019
* @description XC_TR_DocumentToSign – Trigger on XC_Document_to_sign__c
*/

trigger XC_TR_DocumentToSign on XC_Document_to_sign__c (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_DocumentToSign_Handler(), Trigger.operationType);     
}