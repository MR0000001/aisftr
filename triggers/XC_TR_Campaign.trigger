/**
* @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 05/08/2019
* @date Modification ..
* @description XC_TR_Campaign – Trigger on Campaign
*/

trigger XC_TR_Campaign on Campaign (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_Campaign_Handler(), Trigger.operationType); 
}