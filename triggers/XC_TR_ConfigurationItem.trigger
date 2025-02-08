/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 19/10/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_ConfigurationItem – Trigger on NE__OrderItem__c
*/ 

trigger XC_TR_ConfigurationItem on NE__OrderItem__c (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_ConfigurationItem_Handler(), Trigger.operationType,constants.MDT_SKIP_ORDITEM);     
}