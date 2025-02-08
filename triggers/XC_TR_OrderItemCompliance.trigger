/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 29/07/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_OrderItemCompliance – Trigger on XC_OrderItemCompliance__c
*/ 
trigger XC_TR_OrderItemCompliance on XC_OrderItemCompliance__c (before insert, before update, before delete, after insert, after update, after delete) {
        XC_TR_Dispatcher.init(new XC_TR_OrderItemCompliance_Handler(), Trigger.operationType);         
}