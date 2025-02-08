/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 11/10/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ZuoraZInvoice – Trigger on Zuora__ZInvoice__c
*/ 
trigger XC_TR_ZuoraZInvoice on Zuora__ZInvoice__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_ZuoraZInvoice_Handler(), Trigger.operationType);         
}