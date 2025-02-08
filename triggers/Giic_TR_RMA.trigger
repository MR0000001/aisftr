trigger Giic_TR_RMA on gii__RMA__c (after update, after insert,before update,after delete,before delete,before insert) {
    
    XC_TR_Dispatcher.init(new Giic_TR_RMA_Handler(), Trigger.operationType);   
    
}