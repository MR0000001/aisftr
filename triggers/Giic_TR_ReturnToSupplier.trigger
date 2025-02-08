trigger Giic_TR_ReturnToSupplier on gii__ReturntoSupplier__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new Giic_TR_ReturntoSupplier_Handler(),  Trigger.operationType);  
}