/**
* @author FirstName : roberta porrega - roberta.porrega@nttdata.com
* @date Creation 09/12/2020
* @date Modification dd/mm/yyyy
* @description Giic_TR_ShipmentDetail.
*/ 
trigger Giic_TR_ShipmentDetail on gii__ShipmentDetail__c (after update, after insert,before update,before insert, before delete, after delete) {
    XC_TR_Dispatcher.init(new Giic_TR_ShipmentDetail_Handler(), Trigger.operationType);  
}