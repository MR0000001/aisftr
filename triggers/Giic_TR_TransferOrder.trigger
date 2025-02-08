/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 04/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_TR_TransferOrder – To create case on update of 'New Inventory Date' field on Transfer Order.
*/
trigger Giic_TR_TransferOrder on gii__TransferOrder__c (after update, after insert,before update,after delete,before delete,before insert) {
    
    XC_TR_Dispatcher.init(new Giic_TR_TransferOrder_Handler(), Trigger.operationType);   
}