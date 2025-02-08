/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 18/12/2020
* @date Modification 
* @description XC_TR_CTIInteraction
*/

trigger XC_TR_CTIInteraction on XC_CTI_Interaction__c (before insert, before update, before delete, after insert, after update, after delete) {
        XC_TR_Dispatcher.init(new XC_TR_CTIInteraction_Handler(), Trigger.operationType);         
}