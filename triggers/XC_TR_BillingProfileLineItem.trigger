/**
* @author Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 24/04/2019
* @date Modification 
* @description XC_TR_BillingProfileLineItem – Trigger on XC_BillingProfileLineItem__c
*/

trigger XC_TR_BillingProfileLineItem on XC_BillingProfileLineItem__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_BillingProfileLineItem_Handler(), Trigger.operationType);     
}