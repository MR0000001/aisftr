/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 03/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_PurchaseOrderTrigger – To create case on update of 'New Inventory Date' field on Purchase Order.
*/ 
trigger Giic_TR_PurchaseOrder on gii__PurchaseOrder__c (after update, after insert,before update,before insert) {
    XC_TR_Dispatcher.init(new Giic_TR_PurchaseOrder_Handler(), Trigger.operationType);  
}