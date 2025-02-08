/**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 07/11/2019 
* @description Giic_TR_POReceipt Trigger on PO Receipt
*/
trigger giic_TR_POReceiptStaging on gii__PurchaseOrderReceiptStaging__c (after update, after insert,before update, after delete, before delete, before insert, after undelete) {
 XC_TR_Dispatcher.init(new giic_TR_POReceiptStaging_Handler(), Trigger.operationType); 
}