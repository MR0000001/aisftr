/**
* @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 11/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ZQuote – Trigger on zqu__Quote__c
*/ 

trigger XC_TR_ZQuote on zqu__Quote__c (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_ZQuote_Handler(), Trigger.operationType); 	
}