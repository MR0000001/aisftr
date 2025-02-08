/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 30/08/2019
* @date Modification 04/07/2019
* @description Giic_TR_POReceipt Trigger on PO Receipt
*/
trigger Giic_TR_POReceipt on gii__PurchaseOrderReceipt__c(after insert,after update,after delete,before insert,before update,before delete) {
 XC_TR_Dispatcher.init(new Giic_TR_POReceipt_Handler(), Trigger.operationType); 
}