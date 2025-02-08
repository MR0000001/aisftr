/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 22/07/2019
* @date Modification dd/mm/yyyy
* @description – To check limits for incoming purchase orders.
*/
trigger Giic_TR_PurchaseOrderLine on gii__PurchaseOrderLine__c (before insert,after insert,before update, after update,before delete,after delete) {
    XC_TR_Dispatcher.init(new Giic_TR_PurchaseOrderLine_Handler(), Trigger.operationType);   
}