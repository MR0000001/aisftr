/**
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 04/11/2019
* @date Modification dd/mm/yyyy
* @description Giic_TR_TransferOrder 
*/
trigger Giic_TR_ReceiptQueue on gii__ReceiptQueue__c (after update, after insert,before update,after delete,before delete,before insert) {
    
    XC_TR_Dispatcher.init(new Giic_TR_ReceiptQueue_Handler(), Trigger.operationType);   
}