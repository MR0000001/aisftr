/**
* @author Sara Miozza - sara.miozza@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 12/04/2019
* @date Modification 
* @description XC_TR_ZuoraCustomerAccount – Trigger on Zuora__CustomerAccount__c
*/

trigger XC_TR_ZuoraCustomerAccount on Zuora__CustomerAccount__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_ZuoraCustomerAccount_Handler(), Trigger.operationType);     
}