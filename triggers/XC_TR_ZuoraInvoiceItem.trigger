/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 11/02/2020
* @date Modification dd/mm/yyyy
* @description XC_TR_ZuoraZInvoice – Trigger on Zuora__ZInvoice__c
*/ 
trigger XC_TR_ZuoraInvoiceItem on Zuora__InvoiceItem__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_ZuoraInvoiceItem_Handler(), Trigger.operationType);         
}