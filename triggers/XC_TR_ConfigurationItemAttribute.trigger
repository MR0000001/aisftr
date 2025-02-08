/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 21/03/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ConfigurationItemAttribute – Trigger on NE__Order_Item_Attribute__c
*/ 

trigger XC_TR_ConfigurationItemAttribute on NE__Order_Item_Attribute__c (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_ConfigurationItemAttribute_Handler(), Trigger.operationType);   
}