/**
* @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation 02/10/2019
* @date Modification 
* @description XC_TR_ZuoraSubscription – Trigger on Zuora__Subscription__c
*/

trigger XC_TR_ZuoraSubscription on Zuora__Subscription__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_ZuoraSubscription_Handler(), Trigger.operationType);
}