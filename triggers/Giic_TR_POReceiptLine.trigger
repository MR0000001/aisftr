/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 22/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_TR_POReceiptLine
*/
trigger Giic_TR_POReceiptLine on gii__PurchaseOrderReceiptLine__c(after insert,after update,after delete,before insert,before update,before delete) {  
    XC_TR_Dispatcher.init(new Giic_TR_POReceiptLine_Handler(), Trigger.operationType); 
}