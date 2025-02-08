/**
* @author FirstName : roberta porrega - roberta.porrega@nttdata.com
* @date Creation 14/11/2019
* @date Modification dd/mm/yyyy
* @description Giic_TR_Shipment.
*/ 
trigger Giic_TR_Shipment on gii__Shipment__c (after update, after insert,before update,before insert, before delete, after delete) {
    XC_TR_Dispatcher.init(new Giic_TR_Shipment_Handler(), Trigger.operationType);  
}