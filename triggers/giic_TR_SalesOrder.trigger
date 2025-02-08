/**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 17/10/2019
* @description Giic_TR_SalesOrderChangeEvent – Change Event Trigger to close Delivery WO
*/

trigger giic_TR_SalesOrder on gii__SalesOrder__c (before insert, before update, before delete, after insert, after update, after delete) {
	XC_TR_Dispatcher.init(new Giic_TR_SalesOrder_Handler(), Trigger.operationType);    
}