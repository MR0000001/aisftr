/**
* @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation 08/11/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_NbaNbo – Trigger on NbaNbo
*/ 

trigger XC_TR_NbaNbo on XC_NbaNbo__c (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_NbaNbo_Handler(), Trigger.operationType);  
}