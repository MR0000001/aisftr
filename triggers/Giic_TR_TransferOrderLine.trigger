/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 22/07/2019
* @date Modification dd/mm/yyyy
* @description – Trigger on gii__TransferOrderLine__c
*/
trigger Giic_TR_TransferOrderLine on gii__TransferOrderLine__c (before insert,before update,after insert, after update,before delete,after delete) {
 XC_TR_Dispatcher.init(new Giic_TR_TransferOrderLine_Handler(), Trigger.operationType);   
}