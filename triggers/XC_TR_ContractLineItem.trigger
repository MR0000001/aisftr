/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ContractLineItem – Trigger on XC_ContractLineItem__c
*/

trigger XC_TR_ContractLineItem on XC_ContractLineItem__c (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_ContractLineItem_Handler(), Trigger.operationType);
}